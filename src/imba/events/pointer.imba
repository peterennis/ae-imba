# imba$imbaPath=global

import {Event,PointerEvent,Element} from '../dom/core'

import {listen,once,emit,unlisten} from '../utils'

export def use_events_pointer
	yes

def round val,step = 1
	let inv = 1.0 / step
	Math.round(val * inv) / inv
	
def clamp val,min,max
	if min > max
		Math.max(max,Math.min(min,val))
	else
		Math.min(max,Math.max(min,val))

def parseDimension val
	if typeof val == 'string'
		let [m,num,unit] = val.match(/^([-+]?[\d\.]+)(%|\w+)$/)
		return [parseFloat(num),unit]
	elif typeof val == 'number'
		return [val]

def scale a0,a1,b0r,b1r,s = 0.1
	let [b0,b0u] = parseDimension(b0r)
	let [b1,b1u] = parseDimension(b1r)
	let [sv,su] = parseDimension(s)
	
	b0 = (a1 - a0) * (b0 / 100) if b0u == '%'
	b1 = (a1 - a0) * (b1 / 100) if b1u == '%'
	
	sv = (b1 - b0) * (sv / 100) if su == '%'
	
	return do(value,fit)
		let pct = (value - a0) / (a1 - a0)
		let val = b0 + (b1 - b0) * pct
		# console.log 'scaling',value,[a0,a1],[b0,b1],s,val
		val = round(val,sv) if s
		val = clamp(val,b0,b1) if fit
		return val

# Adding the pointerevent modifiers
extend class PointerEvent
	
	def primary$mod
		return !!event.isPrimary
	
	def mouse$mod
		return event.pointerType == 'mouse'
	
	def pen$mod
		return event.pointerType == 'pen'
	
	def touch$mod
		return event.pointerType == 'touch'
	
	def pressure$mod threshold = 0
		return event.pressure > threshold

	def lock$mod dr
		return yes

class Touch
	def constructor e,handler,el
		phase = 'init'
		events = []
		originalEvent = e
		handler = handler
		target = currentTarget = el
	
	set event value
		events.push(value)

	get ctrlKey do originalEvent.ctrlKey
	get altKey do originalEvent.altKey
	get shiftKey do originalEvent.shiftKey
	get metaKey do originalEvent.metaKey
	get isPrimary do originalEvent.isPrimary
	get pointerType do originalEvent.pointerType
	
	get start
		originalEvent

	get originalTarget
		originalEvent.target
		
	get event
		events[events.length - 1]
	
	get elapsed
		event.timeStamp - events[0].timeStamp
	
	get pointerId do event.pointerId
	get clientX do event.clientX
	get clientY do event.clientY
	get offsetX do event.offsetX
	get offsetY do event.offsetY
	get type do event.type
	get active? do phase != 'ended'

	def stopImmediatePropagation
		cancelBubble = yes
		event.stopImmediatePropagation!
		self

	def stopPropagation
		cancelBubble = yes
		event.stopPropagation!
		self

	def preventDefault
		defaultPrevented = yes
		event.preventDefault!
		
	def emit name, ...params do emit(self,name,params)
	def on name, ...params do listen(self,name,...params)
	def once name, ...params do once(self,name,...params)
	def un name, ...params do unlisten(self,name,...params)

def Event.touch$in$mod
	return Event.touch$reframe$mod.apply(this,arguments)
	
def Event.touch$fit$mod
	let o = (state[step] ||= {clamp:yes})
	return Event.touch$reframe$mod.apply(this,arguments)

def Event.touch$round$mod sx=1,sy=sx
	event.x = round(event.x,sx)
	event.y = round(event.y,sy)
	return yes

def Event.touch$snap$mod sx=1,sy=sx
	event.x = round(event.x,sx)
	event.y = round(event.y,sy)
	return yes
	
def Event.touch$moved$mod a,b
	let o = state[step] ||= {}
	unless o.setup
		let th = a or 4
		if typeof a == 'string' and a.match(/^(up|down|left|right|x|y)$/)
			o.dir = a
			th = b or 4

		o.setup = yes
		let [tv,tu] = parseDimension(th)
		o.threshold = tv
		o.sy = tv
		o.x0 = event.x
		o.y0 = event.y
		if (tu and tu != 'px')
			console.warn 'only px threshold allowed in @touch.moved'

	if o.active
		return yes
	
	let th = o.threshold
	let dx = event.x - o.x0
	let dy = event.y - o.y0
	let hit = no
	
	if dx > th and (o.dir == 'right' or o.dir == 'x')
		hit = yes
		
	if !hit and dx < -th and (o.dir == 'left' or o.dir == 'x')
		hit = yes
		
	if !hit and dy > th and (o.dir == 'down' or o.dir == 'y')
		hit = yes
	
	if !hit and dy < -th and (o.dir == 'up' or o.dir == 'y')
		hit = yes
		
	if !hit
		let dr = Math.sqrt(dx*dx + dy*dy)
		if dr > th and !o.dir
			hit = yes
	
	if hit
		o.active = yes
		let pinned = state.pinTarget
		element.flags.incr('_move_')
		pinned.flags.incr('_move_') if pinned
		once(current,'end') do
			pinned.flags.decr('_move_') if pinned
			element.flags.decr('_move_')

	return !!o.active
	
def Event.touch$reframe$mod ...params
	let o = (state[step] ||= {})
		
	unless o.rect
		let el = element
		let len = params.length
		let box = params[0]
		let min = 0
		let max = 100%
		let snap = 1
		let typ = typeof box
		
		if typ == 'number' or (typ == 'string' and (/^([-+]?\d[\d\.]*)(%|\w+)$/).test(box)) or box isa Array
			box = null

		elif typ == 'string'
			if box == 'this' or box == ''
				box = element
			elif box == 'up'
				box = element.parentNode
			elif box == 'op'
				box = element.offsetParent
			else
				box = el.closest(box) or el.querySelector(box)

		if box == null
			len++
			params.unshift(box = el)
		
		if len == 2
			snap = params[1]
		elif len > 2
			[min,max,snap=1] = params.slice(1)

		let rect = box.getBoundingClientRect!
		min = [min,min] unless min isa Array
		max = [max,max] unless max isa Array
		snap = [snap,snap] unless snap isa Array

		o.rect = rect
		o.x = scale(rect.left,rect.right,min[0],max[0],snap[0])
		o.y = scale(rect.top,rect.bottom,min[1],max[1],snap[1])

		state.scaleX = o.x
		state.scaleY = o.y
		event.x0 = event.x = o.x(event.x,o.clamp)
		event.y0 = event.y = o.y(event.y,o.clamp)
	else
		let x = event.x = o.x(event.x,o.clamp)
		let y = event.y = o.y(event.y,o.clamp)
		event.dx = x - event.x0
		event.dy = y - event.y0

	return yes
	
def Event.touch$pin$mod ...params
	let o = state[step] 
		
	unless o
		let box = params[0]
		if typeof box == 'string'
			box = element.closest(box) or element.querySelector(box)
		unless box isa Element
			params.unshift(box = state.target)
		
		let ax = params[1] or 0
		let ay = params[2] ?= ax
		let rect = box.getBoundingClientRect!
		
		o = state[step] = {
			x: state.clientX - (rect.left + rect.width * ax)
			y: state.clientY - (rect.top + rect.height * ay)
		}
		
		if box
			state.pinTarget = box
			box.flags.incr('_touch_')
			state.once('end') do box.flags.decr('_touch_')

	event.x -= o.x
	event.y -= o.y
	return yes

def Event.touch$lock$mod ...params
	let o = state[step]
	
	unless o
		o = state[step] = state.target.style
		let prev = o.touchAction
		o.touchAction = 'none'
		state.once('end') do o.removeProperty('touch-action')
	return yes
	
def Event.touch$sync$mod item,xalias='x',yalias='y'
	let o = state[step]
	# how does clamping come into the picture?
	unless o
		o = state[step] = {
			x: item[xalias] or 0
			y: item[yalias] or 0
			tx: state.x
			ty: state.y
		}
	
	if commit === null
		commit = yes

	item[xalias] = o.x + (state.x - o.tx) if xalias
	item[yalias] = o.y + (state.y - o.ty) if yalias
	return yes

def isIOS
	let nav = global.navigator.platform or ''
	return true if nav.match(/iPhone|iPod|iPad/)
	return true if nav == 'MacIntel' and global.navigator.maxTouchPoints > 2
	return false

extend class Element
	def on$touch(mods,context,handler,o)
		handler.type = 'touch'
		handler.isIOS = isIOS!
		# global.document.documentElement.ontouchstart !== undefined
		self.addEventListener('pointerdown',handler,o)
		if handler.isIOS and !mods.passive
			self.addEventListener('touchstart',handler)
		return handler
		
def Event.touch$handle
	let e = event
	let el = element
	let id = state.pointerId
	let m = modifiers
	current = state

	if e.type == 'touchstart'
		# to make PointerEvents work well on ios we need to capture
		# the touchstart for the linked touch and cancel that
		try 
			if id and id == e.targetTouches[0].identifier
				e.preventDefault!
		return false

	return id == e.pointerId if id != undefined

	# reject the touch before creation for certain modifiers
	# TODO should allow specifying pen OR mouse etc
	return if m.ctrl and !e.ctrlKey
	return if m.alt and !e.altKey
	return if m.meta and !e.metaKey
	return if m.shift and !e.shiftKey
	return if m.if and !!m.if[0] == false
	return if m.self and e.target != el
	return if m.primary and !e.isPrimary
	return if m.pen and e.pointerType != 'pen'
	return if m.mouse and e.pointerType != 'mouse'
	return if m.touch and e.pointerType != 'touch'
	return if m.sel and !e.target.matches(String(m.sel[0]))
	
	let t = state = handler.state = current = new Touch(e,handler,el)

	let canceller = do(e)
		e.preventDefault!
		return false
		
	let listener = do(e)
		let typ = e.type
		let ph = t.phase
		t.event = e
		let end = typ == 'pointerup' or typ == 'pointercancel'

		unless typ == 'pointercancel'
			t.x = e.clientX
			t.y = e.clientY
		# console.log 'pointer',typ,ph,t.target..nodeName,e.x,e.y
		if end
			t.phase = 'ended'
		
		try handler.handleEvent(t)
		
		if ph == 'init'
			t.phase = 'active'

		if end and !handler.isIOS
			el.releasePointerCapture(e.pointerId)

	let disposed = no
	
	let teardown = do(e)
		return if disposed
		el.flags.decr('_touch_')
		t.emit('end')
		unless m.passive
			if (--handler.prevents) == 0
				el.style.removeProperty('touch-action')
		handler.state = {}
		el.removeEventListener('pointermove',listener)
		el.removeEventListener('pointerup',listener)
		el.removeEventListener('pointercancel',listener)
		global.document.removeEventListener('selectstart',canceller,capture:true)
		disposed = yes
	
	unless m.passive
		handler.prevents ||= 0
		handler.prevents++
		el.style.setProperty('touch-action','none')
		el.offsetWidth # force reflow for touch-action none to take effect

	el.flags.incr('_touch_')
	el.addEventListener('pointermove',listener)
	el.addEventListener('pointerup',listener)
	el.addEventListener('pointercancel',listener)
	el.addEventListener('lostpointercapture',teardown,once:true)

	if !handler.isIOS
		el.setPointerCapture(e.pointerId)

	global.document.addEventListener('selectstart',canceller,capture:true)

	listener(e)
	return false