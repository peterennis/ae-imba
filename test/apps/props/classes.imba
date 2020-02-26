let flip = false
let name = null
let mult = 'm1 m2'

tag nested-element

	def render
		<self.inner .innerflip=flip>
			<div.d1> "Div"
			<slot>

tag static-inside

	def render
		<self.inner>
			"Static inside"

tag custom-element
	def render
		<self.custom-class>
			<input[flip] type='checkbox'>
			<input[name] type='checkbox' value='hello'>
			<input[name]>
			<div.child-class>
				<span> 'child'
			<div.one.two .{name} .{mult} .flipped=flip>
			<nested-element.outer .outerflip=flip>
			<nested-element.static-outer>
			<static-inside.outer>

let el = <custom-element>
imba.mount(el)

test 'class added in self' do
	ok el.classList.contains('custom-class')

test 'static class in child' do
	ok $(div.child-class)

test 'multiple dynamic' do
	ok $(div.one.m1.m2)
	mult = ''
	await spec.tick()
	ok $(div.one:not(.m2))

test 'combined outer and inner flags' do
	ok $(nested-element.outer.inner)
	ok $(static-inside.outer.inner)

test 'combined outer and inner flags' do
	flip = true
	await spec.tick()
	ok $(nested-element.outerflip.innerflip)

test 'static outer and inner flags' do
	ok $(nested-element.static-outer.inner)