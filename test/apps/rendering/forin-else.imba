var todos = [
	{id: 1, title: "One"}
	{id: 2, title: "Two"}
	{id: 3, title: "Three"}
]

var truthy = true

tag app-original

	def flip
		truthy = !truthy

	def render
		<self :click.flip>
			if truthy
				# <div> @hello
				for item in todos
					<div> <span> item.title
			else
				<div> "--"

tag app-root
	def render
		<self>
			for item in todos
				<li> <span> item.title
			else
				<li> "No todo items here"

imba.mount(var app = <app-original>)

var ordered = do
	var titles = todos.map(|t| t.title).join("")
	console.log titles,app.textContent
	eq app.textContent, titles

var titles = todos.map(|t| t.title).join("")

test do
	eq app.textContent, titles
	
	app.flip()
	app.render()
	eq app.textContent, "--"
	app.flip()
	app.render()

	eq app.textContent, titles
	app.flip()
	app.render()
	eq app.textContent, "--"