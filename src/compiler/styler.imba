
# var conv = require('../../vendor/colors')
import * as selparser from './selparse'
import {conv} from '../../vendor/colors'
import {fonts,colors,variants} from './theme.imba'
import * as theme from  './theme.imba'

const extensions = {}
let ThemeInstance = null
const ThemeCache = new WeakMap

# {string: "hsla(0,0,0,var(--alpha,1))",h:0,s:0,l:0}
# {string: "hsla(0,100%,100%,var(--alpha,1))",h:0,s:0,l:100}

# export const properties =

export const layouts =
	group: do(o)
		o.display = 'flex'
		o.jc = 'flex-start'
		o.flw = 'wrap'
		# unique variable for this?
		o['--u_sx'] = "calc(var(--u_cg,0) * 0.5)"
		o['--u_sy'] = "calc(var(--u_rg,0) * 0.5)"
		# this should be added as ultra low specificity
		o.margin = "calc(var(--u_sy) * -1) calc(var(--u_sx) * -1)"
		o["&>*"] = {margin: "var(--u_sy) var(--u_sx)"}
	
	vflex: do(o)
		o.display = 'flex'
		o.fld = 'column'
	
	hflex: do(o)
		o.display = 'flex'
		o.fld = 'row'

	hgrid: do(o)
		o.display = 'grid'
		o.gaf = 'column'
		o.gac = '1fr'
	
	vgrid: do(o)
		o.display = 'grid'
		o.gaf = 'row'

export const validTypes = {
	ease: 'linear|ease|ease-in|ease-out|ease-in-out|step-start|step-end|stepsƒ|cubic-bezierƒ'
}

for own k,v of validTypes
	let o = {}
	for item in v.split('|')
		o[item] = 1
	validTypes[k] = o

export const aliases =
	
	c: 'color'
	d: 'display'
	pos: 'position'

	# padding
	p: 'padding'
	pl: 'padding-left'
	pr: 'padding-right'
	pt: 'padding-top'
	pb: 'padding-bottom'
	px: ['pl','pr']
	py: ['pt','pb']
	
	# margins
	m: 'margin'
	ml: 'margin-left'
	mr: 'margin-right'
	mt: 'margin-top'
	mb: 'margin-bottom'
	mx: ['ml','mr']
	my: ['mt','mb']
	
	# add scroll snap shorthands?
	
	w: 'width'
	h: 'height'
	t: 'top'
	b: 'bottom'
	l: 'left'
	r: 'right'
	size: ['width','height']
	
	# justify
	ji: 'justify-items'
	jc: 'justify-content'
	js: 'justify-self'
	j: ['justify-content','justify-items']
	
	# align
	ai: 'align-items'
	ac: 'align-content'
	as: 'align-self'
	a: ['align-content','align-items']

	# justify & align
	jai: ['justify-items','align-items']
	jac: ['justify-content','align-content']
	jas: ['justify-self','align-self']
	ja: ['justify-content','align-content','justify-items','align-items']
	
	# place
	# pi: 'place-items'
	# pc: 'place-content'
	# ps: 'place-self'

	# flex
	fl: 'flex'
	flf: 'flex-flow'
	fld: 'flex-direction'
	flb: 'flex-basis'
	flg: 'flex-grow'
	fls: 'flex-shrink'
	flw: 'flex-wrap'
	
	# fonts
	ff: 'font-family'
	fs: 'font-size'
	fw: 'font-weight'
	ts: 'text-shadow'
	
	# text-decoration
	td: 'text-decoration'
	tdl: 'text-decoration-line'
	tdc: 'text-decoration-color'
	tds: 'text-decoration-style'
	tdt: 'text-decoration-thickness'
	tdsi: 'text-decoration-skip-ink'
	
	# text-emphasis
	te: 'text-emphasis'
	tec: 'text-emphasis-color'
	tes: 'text-emphasis-style'
	tep: 'text-emphasis-position'
	tet: 'text-emphasis-thickness'
		
	# text
	tt: 'text-transform'
	ta: 'text-align'
	va: 'vertical-align'
	ls: 'letter-spacing'
	lh: 'line-height'

	# border
	bd: 'border'
	bdr: 'border-right'
	bdl: 'border-left'
	bdt: 'border-top'
	bdb: 'border-bottom'

	# border-style
	bs: 'border-style'
	bsr: 'border-right-style'
	bsl: 'border-left-style'
	bst: 'border-top-style'
	bsb: 'border-bottom-style'

	# border-width
	bw: 'border-width'
	bwr: 'border-right-width'
	bwl: 'border-left-width'
	bwt: 'border-top-width'
	bwb: 'border-bottom-width'

	# border-color
	bc: 'border-color'
	bcr: 'border-right-color'
	bcl: 'border-left-color'
	bct: 'border-top-color'
	bcb: 'border-bottom-color'

	# border-radius
	rd: 'border-radius'
	rdtl: 'border-top-left-radius'
	rdtr: 'border-top-right-radius'
	rdbl: 'border-bottom-left-radius'
	rdbr: 'border-bottom-right-radius'
	rdt: ['border-top-left-radius','border-top-right-radius']
	rdb: ['border-bottom-left-radius','border-bottom-right-radius']
	rdl: ['border-top-left-radius','border-bottom-left-radius']
	rdr: ['border-top-right-radius','border-bottom-right-radius']
	
	# background
	bg: 'background'
	bgp: 'background-position'
	bgc: 'background-color'
	bgr: 'background-repeat'
	bgi: 'background-image'
	bga: 'background-attachment'
	bgs: 'background-size'
	bgo: 'background-origin'
	bgclip: 'background-clip'
	
	# grid
	g: 'gap'
	rg: 'row-gap'
	cg: 'column-gap'
	gtr: 'grid-template-rows'
	gtc: 'grid-template-columns'
	gta: 'grid-template-areas'
	gar: 'grid-auto-rows'
	gac: 'grid-auto-columns'
	gaf: 'grid-auto-flow'
	gcg: 'grid-column-gap'
	grg: 'grid-row-gap'
	ga: 'grid-area'
	gr: 'grid-row'
	gc: 'grid-column'
	gt: 'grid-template'
	grs: 'grid-row-start'
	gcs: 'grid-column-start'
	gre: 'grid-row-end'
	gce: 'grid-column-end'
	
	# shadow
	bxs: 'box-shadow'
	shadow: 'box-shadow' # DEPRECATED
	
	# overflow
	'of':'overflow'
	'ofx':'overflow-x'
	'ofy':'overflow-y'
	'ofa':'overflow-anchor'
	
	# content
	prefix: 'content@before'
	suffix: 'content@after'
	
	# transforms
	x: 'x'
	y: 'y'
	z: 'z'
	rotate: 'rotate'
	scale: 'scale'
	'scale-x': 'scale-x'
	'scale-y': 'scale-y'
	'skew-x': 'skew-x'
	'skew-y': 'skew-y'
	origin: 'transform-origin'
	
	# others
	ws: 'white-space'
	zi: 'z-index'
	pe: 'pointer-events'
	us: 'user-select'
	o: 'opacity'
	tween: 'transition'

export const abbreviations = {}
for own k,v of aliases
	if typeof v == 'string'
		abbreviations[v] = k

def isNumber val
	if val._value and val._value._type == "NUMBER" and !val._unit
		return true
	return false

export class Color
	
	def constructor name,h,s,l,a = '100%'
		name = name
		h = h
		s = s
		l = l
		a = a
		
	def alpha a = '100%'
		new Color(name,h,s,l,a)

	def clone
		new Color(name,h,s,l,a)

	def mix other, hw = 0.5, sw = 0.5, lw = 0.5
		let	h1 = h + (other.h - h) * hw
		let	s1 = s + (other.s - s) * sw
		let	l1 = l + (other.l - l) * lw
		return new Color(name + other.name,h1,s1,l1)
	
	def toString
		"hsla({h.toFixed(2)},{s.toFixed(2)}%,{l.toFixed(2)}%,{a})"
		
	def c
		toString!

export class Length
	
	static def parse value
		let m = String(value).match(/^(\-?[\d\.]+)(\w+|%)?$/)
		return null unless m
		return new self(parseFloat(m[1]),m[2])
	
	def constructor number, unit
		number = number
		unit = unit
	
	def valueOf
		number
		
	def toString
		number + (unit or '')
		
	def clone num = number, u = unit
		new Length(num,u)
		
	def rounded
		clone(Math.round(number))
		
	def c
		toString!
	
	get _unit
		unit
	
	get _number
		number

export class Var
	
	def constructor name, fallback
		name = name
		fallback = fallback
		
	def c
		fallback ? "var(--{name},{fallback.c ? fallback.c! : String(fallback)})" : "var(--{name})"

export class Calc
	
	def constructor expr
		expr = expr
		
	def cpart parts
		let out = '('
		for part in parts
			if typeof part == 'string'
				out += ' ' + part + ' '
			elif typeof part == 'number'
				out += part
			elif part.c isa Function
				out += part.c!
			elif part isa Array
				out += cpart(part)
			
		out += ')'
		return out
	
	def c
		'calc' + cpart(expr)
		

# This has to move into StyleTheme class
let defaultPalette = {
	current: {string: "currentColor"}
	transparent: new Color('transparent',0,0,100,'0%')
	clear: new Color('transparent',100,100,100,'0%')
	black: new Color('black',0,0,0,'100%')
	white: new Color('white',0,0,100,'100%')
}

def parseColorString str
	if let m = str.match(/hsl\((\d+), *(\d+\%), *(\d+\%?)/)
		let h = parseInt(m[1])
		let s = parseInt(m[2])
		let l = parseInt(m[3])
		return [h,s,l]
	elif str[0] == '#'
		return conv.rgb.hsl(conv.hex.rgb(str))


def parseColors palette, colors
	for own name,variations of colors
		for own subname,raw of variations
			let path = name + subname

			if palette[raw]
				palette[path] = palette[raw]
			else
				let [h,s,l] = parseColorString(raw)
				let color = palette[path] = new Color(path,h,s,l,'100%')
	return palette

parseColors(defaultPalette,colors)

const VALID_CSS_UNITS = 'cm mm Q in pc pt px em ex ch rem vw vh vmin vmax % s ms fr deg rad grad turn Hz kHz'.split(' ')

export class StyleTheme
	
	static def instance
		ThemeInstance ||= new self
		
	static def propAbbr name
		abbreviations[name] or name

	static def wrap config
		return self.instance() unless config

		let theme = ThemeCache.get(config)
		ThemeCache.set(config,theme = new self(config)) unless theme
		return theme
		
	def constructor ext = {}
		options = theme
		palette = Object.assign({},defaultPalette)

		if ext.theme and ext.theme.colors
			parseColors(palette,ext.theme.colors)

	def expandProperty name
		return aliases[name] or undefined
		
	def expandValue value, config
	
		if value == undefined
			value = config.default

		if config.hasOwnProperty(value)
			value = config[value]

		if typeof value == 'number' and config.NUMBER
			let [step,num,unit] = config.NUMBER.match(/^(\-?[\d\.]+)(\w+|%)?$/)
			return value * parseFloat(num) + unit

		return value
	
	def padding-x [l,r=l]
		{'padding-left': l, 'padding-right': r}
	
	def padding-y [t,b=t]
		{'padding-top': t, 'padding-bottom': b}
		
	def margin-x [l,r=l]
		{'margin-left': l, 'margin-right': r}
	
	def margin-y [t,b=t]
		{'margin-top': t, 'margin-bottom': b}

		
	def inset [t,r=t,b=t,l=r]
		{top: t, right: r, bottom: b, left: l}
		
	def size [w,h=w]
		{width: w, height: h}
		
	def grid params
		if let m = $varFallback('grid',params)
			return m
		return

	def animation ...params
		
		let valids = {
			normal:1,reverse:1,alternate:1,'alternate-reverse':1
			infinite:2
			none:3,forwards:3,backwards:3,both:3
			running:4,paused:4
		}
		let used = {}
		for anim,k in params
			let name = null
			let ease = null
			for part,i in anim
				let str = String(part)
				let typ = valids[str]

				if validTypes.ease[str] and !ease
					ease = yes
				elif typ
					if used[typ]
						name = [i,str]
					used[typ] = yes
				elif str.match(/^[^\d\.]/) and str.indexOf('(') == -1
					if name
						ease = [i,str]
					else
						name = [i,str]
			if name
				anim[name[0]] = new Var("animation-{name[1]}",name[1])
			if ease isa Array
				let fallback = options.variants.easings[ease[1]]
				anim[ease[0]] = new Var("ease-{ease[1]}",fallback)

		return {animation: params}

	def animation-timing-function ...params
		for param,i in params
			let fb = $varFallback('ease',param)
			params[i] = fb if fb
		return params

	def animation-name ...params
		for param,i in params
			let fb = $varFallback('animation',param)
			if fb
				# param[0] = fb[0]
				params[i] = fb
			# params[i] = $varFallback('animation',param)
		return params

		if let m = $varFallback('animation',params)
			return m
		return
		
	def display params
		let out = {display: params}
		for par in params
			if let layout = layouts[String(par)]
				layout.call(this,out,par,params)
		return out

	def position params
		let out = {position: params}
		let str = String(params[0])
		if str == 'abs'
			out.position = 'absolute'
		elif str == 'rel'
			out.position = 'relative'
		return out
		
		
	def width [...params]
		let o = {}
		for param in params
			let opts = param._options or {}
			let u = param._unit
			if u == 'c' or u == 'col' or u == 'cols'
				o['grid-column-end'] = "span {param._number}"
			elif opts.op and String(opts.op) == '>'
				o['min-width'] = param
			elif opts.op and String(opts.op) == '<'
				o['max-width'] = param
			else
				o.width = param
		return o
		
	def height [...params]
		let o = {}
		for param in params
			let opts = param._options or {}
			let u = param._unit
			if u == 'r' or u == 'row' or u == 'rows'
				o['grid-row-end'] = "span {param._number}"
			elif opts.op and String(opts.op) == '>'
				o['min-height'] = param
			elif opts.op and String(opts.op) == '<'
				o['max-height'] = param
			else
				o.height = param
		return o

	def transition ...parts
		let out = {}
		let add = {}

		let signatures = [
			'name | duration'
			'name | duration | delay'
			'name | duration | ease'
			'name | duration | ease | delay'
		]
		
		let groups = {
			styles: ['background-color','border-color','color','fill','stroke','opacity','box-shadow','transform']
			sizes: ['width','height','left','top','right','bottom','margin','padding']
			colors: ['background-color','border-color','color','fill','stroke']
		}
		
		let i = 0
		while i < parts.length
			let part = parts[i]
			let name = String(part[0])
			if name.match(/^[\-\+]?\d?(\.?\d+)(s|ms)?$/)
				part.unshift(name = 'styles')
				
			let ease = part[2]
			let group = groups[name]
			
			if group and parts.length == 1
				part[0] = 'none'
				Object.assign(add,{'transition-property': group.join(',')})
			elif group and parts.length > 1
				# TODO we could do a more advanced version where we 
				# create repeating transition-property and duration etc and seam
				# the pairs together
				let subparts = group.map do [$1].concat(part.slice(1))
				parts.splice(i,1,...subparts)
				continue
			i++

		Object.assign(out,{'transition': parts},add)
		return out
		
	def font params,...rest
		for param,i in params
			yes
		return
		
	def font-family params
		if let m = $varFallback('font',params)
			return m
		return
		
	def text-shadow params
		if let m = $varFallback('text-shadow',params)
			return m
		return

	def grid-template params
		for param,i in params
			if isNumber(param)
				param._resolvedValue = "repeat({param._value},1fr)"
		return

	def grid-template-columns params
		grid-template(params)

	def grid-template-rows params
		grid-template(params)

	def font-size [v]
		let sizes = options.variants.fontSize
		let raw = String(v)
		let size = v
		let lh
		let out = {}
		
		if sizes[raw]
			[size,lh] = sizes[raw]
			size = Length.parse(size)
			lh = Length.parse(lh or '')
		
		if v.param and v.param
			lh = v.param
			
		out['font-size'] = size
		
		if lh
			let lhu = lh._unit
			let lhn = lh._number
			out.lh = lh
			# supprt base unit as well?
			if lhu == 'fs'
				out.lh = new Length(lhn)
			elif lhu
				out.lh = lh
			elif lhn == 0
				out.lh = 'inherit'
			elif lhn and size._unit == 'px'
				let rounded = Math.round(size._number * lhn)
				if rounded % 2 == 1
					rounded++
				out.lh = new Length(rounded,'px')
		
		return out
		
	def line-height [v]
		let uvar = v
		# TODO what if it has u unit?
		if v._number and !v._unit
			uvar = v.clone(v._number,'em')
			
		return {
			'line-height': v
			'--u_lh': uvar
		}
		
	def text-decoration params
		for param,i in params
			let str = String(param)
			if str == 'u'
				param._resolvedValue = 'underline'
			elif str == 's'
				param._resolvedValue = 'line-through'
			
		return [params]

	# TODO allow setting border style and color w/o width?
	# TODO allow size hidden etc?
	def border [...params]
		if params.length == 1 and $parseColor(params[0])
			return [['1px','solid',params[0]]]
		return

	def border-left params
		return border(params)
		
	def border-right params
		return border(params)
	
	def border-top params
		return border(params)
		
	def border-bottom params
		return border(params)
		
	def border-x params
		{'border-left': border(params) or params, 'border-right': border(params) or params}
		
	def border-y params
		{'border-top': border(params) or params, 'border-bottom': border(params) or params}
		
	def border-x-width [l,r=l]
		{blw: l, brw: r}
		
	def border-y-width [t,b=t]
		{btw: t, bbw: b}
		
	def border-x-style [l,r=l]
		{bls: l, brs: r}
		
	def border-y-style [t,b=t]
		{bts: t, bbs: b}
	
	def border-x-color [l,r=l]
		{blc: l, brc: r}
		
	def border-y-color [t,b=t]
		{btc: t, bbc: b}
	
	def gap [v]
		{'gap': v, '--u_rg': v,'--u_cg': v}
			
	def row-gap [v]
		{'row-gap': v, '--u_rg': v}

	def column-gap [v]
		{'column-gap': v, '--u_cg': v}

	# def shadow ...params
	#	{}

	def $color name

		if palette[name]
			return palette[name]

		if let m = name.match(/^(\w+)(\d)(?:\-(\d+))?$/)			
			let ns = m[1]
			let nr = parseInt(m[2])
			let fraction = parseInt(m[3]) or 0
			let from = null
			let to = null
			let n0 = nr + 1
			let n1 = nr

			while n0 > 1 and !from
				from = palette[ns + (--n0)]

			while n1 < 9 and !to
				to = palette[ns + (++n1)]

			let weight = ((nr - n0) + (fraction / 10)) / (n1 - n0)
			let hw = weight
			let sw = weight
			let lw = weight

			if !to
				to = palette.blue9
				hw = 0
			
			if !from
				from = palette.blue1
				hw = 1

			if from and to
				return palette[name] = from.mix(to,hw,sw,lw)
		null

	def $parseColor identifier
		let key = String(identifier)
		if let color = $color(key)
			return color

		if key.match(/^#[a-fA-F0-9]{3,8}/)
			return identifier
			
		elif key.match(/^(rgb|hsl)/)
			return identifier
		
		elif key == 'currentColor'
			return identifier

		return null
		
	def $varFallback name, params, exclude = []
		if params.length == 1
			let str = String(params[0])
			let fallback = params[0]
			exclude.push('none','initial','unset','inherit')
			if exclude.indexOf(str) == -1 and str.match(/^[\w\-]+$/)
				if name == 'font' and fonts[str]
					fallback = fonts[str]
				if name == 'ease' and options.variants.easings[str]
					fallback = options.variants.easings[str]
				# elif name == 'box-shadow' and 
				return [new Var("{name}-{str}",fallback)]
		return
	

	def $value value, index, config
		let key = config
		let orig = value
		let raw = value && value.toRaw ? value.toRaw! : String(value)
		let str = String(value)
		let fallback = no
		let result = null
		let unit = orig._unit
		# console.log 'resolve value',raw
		if typeof config == 'string'
			if aliases[config]
				config = aliases[config]
				
				if config isa Array
					config = config[0]

			if config.match(/^((min-|max-)?(width|height)|top|left|bottom|right|padding|margin|sizing|inset|spacing|sy$|s$|\-\-s[xy])/)
				config = 'sizing'
			elif config.match(/^\-\-[gs][xy]_/)
				config = 'sizing'
			elif config.match(/^(row-|column-)?gap/)
				config = 'sizing'
			elif config.match(/^[mps][trblxy]?$/)
				config = 'sizing'
			elif config.match(/^[trblwh]$/)
				config = 'sizing'
			elif config.match(/^border-.*radius/) or config.match(/^rd[tlbr]{0,2}$/)
				config = 'radius'
				fallback = 'border-radius'
			elif config.match(/^box-shadow/)
				fallback = config = 'box-shadow'
			elif config.match(/^tween|transition/) and options.variants.easings[raw]
				return options.variants.easings[raw]

			config = options.variants[config] or {}
		
		if value == undefined
			value = config.default
		
		if config.hasOwnProperty(raw)
			# should we convert it or rather just link it up?
			value = config[value]
			
		if typeof raw == 'number' and config.NUMBER
			let [step,num,unit] = config.NUMBER.match(/^(\-?[\d\.]+)(\w+|%)?$/)
			return value * parseFloat(num) + unit
		
		elif typeof raw == 'string'
			if let color = $parseColor(raw)
				return color
		
		if fallback
			let okstr = str.match(/^[a-zA-Z\-][\w\-]*$/) and !str.match(/^(none|inherit|unset|initial)$/)
			let oknum = unit and VALID_CSS_UNITS.indexOf(unit) == -1
			if (okstr or oknum) and value.alone
				return new Var("{fallback}-{str}",orig != value ? value : raw)
			
		return value
		
# should not happen at root - but create a theme instance
	
export const TransformMixin = '''
	--t_x:0;--t_y:0;--t_z:0;--t_rotate:0;--t_scale:1;--t_scale-x:1;--t_scale-y:1;--t_skew-x:0;--t_skew-y:0;
	transform: translate3d(var(--t_x),var(--t_y),var(--t_z)) rotate(var(--t_rotate)) skewX(var(--t_skew-x)) skewY(var(--t_skew-y)) scaleX(var(--t_scale-x)) scaleY(var(--t_scale-y)) scale(var(--t_scale));
'''

export class StyleRule
	
	def constructor parent,selector,content,options = {}
		parent = parent
		selector = selector
		content = content
		options = options
		isKeyFrames = !!selector.match(/\@keyframes \w/)
		isKeyFrame = parent and parent.isKeyFrames
		meta = {}
		
	def root
		parent ? parent.root : self
		
	def toString o = {}
		let parts = []
		let subrules = []

		if isKeyFrames
			let [context,name] = selector.split(/\s*\@keyframes\s*/)

			context = context.trim!
			name = name.trim!

			let path = [name,context,options.ns].filter(do $1).join('-')
			# what if it is global?
			meta.name = name
			meta.uniqueName = path.replace(/[\s\.\,]+/g,'').replace(/[^\w\-]/g,'_')

			if options.global and !context
				meta.uniqueName = meta.name

			let subprops = {}
			subprops["--animation-{name}"] = "{meta.uniqueName}"

			if context
				subrules.push new StyleRule(null,context,subprops,options)
			elif options.ns and !options.global
				subrules.push new StyleRule(null,".{options.ns}",subprops,{})

		for own key,value of self.content
			continue if value == undefined
			
			let subsel = null
			
			if key.indexOf('&') >= 0
				if isKeyFrames
					let keyframe = key.replace(/&/g,'')
					let rule = new StyleRule(self,keyframe,value,options)
					parts.push(rule.toString(indent: yes))
					continue

				let subsel = selparser.unwrap(selector,key)
				subrules.push new StyleRule(self,subsel,value,options)
				continue
			
			elif key.indexOf('§') >= 0
				# let keys = key.replace(/[\.\~\@\+]/g,'\\$&').split('§')
				let keys = key.split('§')
				let subsel = selparser.unwrap(selector,keys.slice(1).join(' '))
				let obj = {}
				obj[keys[0]] = value
				subrules.push new StyleRule(self,subsel,obj,options)
				continue
			
			elif key[0] == '['
				# better to just check if key contains '.'
				# this is only for a single property
				console.warn "DEPRECATED",key,self
				let o = JSON.parse(key)
				subrules.push new StyleRule(self,selector,value,options)
				continue

			elif key.match(/^(x|y|z|scale|scale-x|scale-y|skew-x|skew-y|rotate)$/)
				unless meta.transform
					meta.transform = yes
					parts.unshift(TransformMixin)
				parts.push "--t_{key}: {value} !important;"
			else
				parts.push "{key}: {value};"
		
		let content = parts.join('\n')
		let out = ""
		if o.indent or isKeyFrames
			content = '\n' + content + '\n'

		if isKeyFrame
			out = "{selector} \{{content}\}"

		elif isKeyFrames
			out = "@keyframes {meta.uniqueName} \{{content}\}"
		else
			let sel = isKeyFrame ? selector : selparser.parse(selector,options)
			out = content.match(/[^\n\s]/) ? selparser.render(sel,content,options) : ""

		for own subrule in subrules
			out += '\n' + subrule.toString()

		return out
