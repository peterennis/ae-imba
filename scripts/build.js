const imba1 = require('./bootstrap.compiler.js');
const imba2 = require('./bootstrap.compiler2.js');
const chokidar = require('chokidar');
const fs = require('fs');
const np = require('path');
const esbuild = require('esbuild');

let helpers = imba2.helpers;
let time = 0;
let argv = helpers.parseArgs(process.argv.slice(2),{
	alias: {w: 'watch'}
})

let meta = Symbol();
let compileCache = {};

let globalNames = {
	index: "imba",
	compiler: "imbacompiler",
	program: "imbaprogram",
	devtools: "imbadevtools"
}

function plugin(build){
	// console.log('setting up plugin',build,this);
	let options = this.options;
	let self = this;
	let watcher = this.watcher;
	let fs = require('fs');
	let basedir = np.resolve(__dirname,'..');
	let outdir = options.outdir || np.dirname(options.outfile);
	let distdir = np.resolve(__dirname,'..','dist')
	let distrel = './' + np.relative(distdir,outdir);
	let absoutdir = np.resolve(__dirname,'..',outdir);

	function relative(path){
		let res = np.relative(absoutdir,np.resolve(basedir,path));
		if(res[0] != '.') res = './' + res;
		return res;
	}

	build.onResolve({filter: /^dist\//}, (p) => {
		return {path: relative(p.path), external: true}
	});

	build.onResolve({filter: /^compiler1?$/}, (p) => {
		// find the output dir
		// console.log('resolve compiler?',p,options);
		let src = p.path == 'compiler1' ? "../scripts/bootstrap.compiler.js" : "./compiler.imba.js";
		return {path: src, external: true}
	});

	build.onLoad({ filter: /\.imba1/ }, async (args) => {
		// console.log('loading imba',args);
		if(watcher) watcher.add(args.path);

		let key = `${args.path}:${options.platform}`
		let raw = await fs.promises.readFile(args.path, 'utf8');
		let cached = compileCache[key];

		if(cached && cached.input == raw){
			return {contents: cached.output};
		}
		
		let target = {
			browser: 'web',
			worker: 'webworker'
		}[options.platform] || options.platform || 'web';
		let t0 = Date.now();

		let body = imba1.compile(raw,{
			target: target,
			filename: args.path,
			sourcePath: args.path
		});
		time += (Date.now() - t0);
		compileCache[key] = {input: raw, output: body.js};
		return {contents: body.js}
	})

	build.onLoad({ filter: /\.imba/ }, async (args) => {
		// console.log('loading imba',args);
		if(watcher) watcher.add(args.path);
		let raw = await fs.promises.readFile(args.path, 'utf8');
		let key = `${args.path}:${options.platform}`
		let cached = compileCache[key];

		if(cached && cached.input == raw){
			// console.log('found cached version',key);
			return {contents: cached.output};
		}

		let t0 = Date.now();
		let body = imba2.compile(raw,Object.assign({
			platform: options.platform || 'browser',
			format: 'esm',
			sourcePath: args.path,
		},self.imbaOptions));

		time += (Date.now() - t0);
		compileCache[key] = {input: raw, output: body.js};

		return {
			contents: body.js
		}
	})
}
async function universalise(result,o){
	// console.log('result',result);
	for(let file of result.outputFiles){
		
		let bname = np.basename(file.path).split(".")[0];
		console.log("output",file.path,bname);
		
		if(o.format == 'esm' && o.platform == 'node'){
			console.log("create cjs version as well",file.path);
			let cjs = esbuild.transformSync(file.text,{
				format: 'cjs'
			})
			let name = file.path.replace('.mjs','.js');
			console.log("transformed to cjs",cjs.code.length,file.text.length);
			fs.writeFileSync(name,cjs.code);
			if(bname == 'compiler'){
				fs.writeFileSync(file.path,file.contents);
			}
		} else {
			fs.writeFileSync(file.path,file.contents);
		}

		

		if(o.format == 'esm' && o.platform == 'browser' && globalNames[bname]){
			console.log("create cjs version as well");
			let iife = esbuild.transformSync(file.text,{
				format: 'iife',
				globalName: globalNames[bname]
			})
			let name = file.path.replace('.mjs','.js');
			console.log("transformed to iife",name,iife.code.length,file.text.length);
			fs.writeFileSync(name,iife.code);
		}
	}
}

async function bundle(o){
	if(o instanceof Array){
		for(let config of o){
			bundle(config);
		}
		return;
	}
	let input = o.entryPoints[0];
	let entry = {options: o}
	let watcher = entry.watcher = argv.watch && chokidar.watch([]);

	entry.imbaOptions = o.options || {};

	o.plugins = [{name: 'imba', setup: plugin.bind(entry)}];

	if(o.platform == 'node'){
		o.resolveExtensions = ['.node.imba','.imba','.imba1','.ts','.mjs','.cjs','.js','.css','.json'];
	} else {
		o.resolveExtensions = ['.web.imba','.imba','.imba1','.ts','.mjs','.cjs','.js','.css','.json'];
	}

	if(!o.outdir && !o.outfile){
		o.outdir = `dist/${o.platform}`;
	}
	

	o.target = o.target || ['es2019'];
	if(o.bundle == undefined) o.bundle = true;
	o.loader = {'.txt':'text'}
	o.incremental = !!watcher;
	o.logLevel = 'info';
	// o.minify = true;
	if(o.write == undefined) o.write = false;

	delete o.options;
	
	let result = await esbuild.build(o);
	await universalise(result, o);
	if(watcher){
		watcher.on('change',async ()=>{
			console.log('rebuilding',input);
			let rebuilt = await result.rebuild();
			await universalise(rebuilt, o);
			console.log('rebuilt',input);
		})
	}
	console.log(`built`);
}

let bundles = [{
	entryPoints: ['devtools.imba'],
	outExtension: {".js": ".imba.web.js"},
	bundle: true,
	format: 'esm',
	outdir: '.',
	platform: 'browser'
},{
	entryPoints: ['bin/imba.imba','bin/imba-create.imba','index.imba','program.imba','compiler.imba','workers.imba','loader.imba'],
	outExtension: {".js": ".imba.js"},
	bundle: true,
	minify: false,
	external: ['chokidar','esbuild'],
	outdir: '.',
	format: 'cjs',
	platform: 'node'
}]

bundle(bundles)