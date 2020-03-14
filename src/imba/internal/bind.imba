var isGroup = do |obj|
	return obj isa Array or (obj && obj.has isa Function)

var bindHas = do |object,value|
	if object isa Array
		object.indexOf(value) >= 0
	elif object and object.has isa Function
		object.has(value)
	elif object and object.contains isa Function
		object.contains(value)
	elif object == value
		return true
	else
		return false

var bindAdd = do |object,value|
	if object isa Array
		object.push(value)
	elif object and object.add isa Function
		object.add(value)

var bindRemove = do |object,value|
	if object isa Array
		let idx = object.indexOf(value)
		object.splice(idx,1) if idx >= 0
	elif object and object.delete isa Function
		object.delete(value)

def createProxyProperty target
	def getter
		target[0] ? target[0][target[1]] : undefined

	def setter v
		target[0] ? (target[0][target[1]] = v) : null

	return {
		get: getter
		set: setter
	}

###
Data binding
###
extend class Element
	def getRichValue
		self.value

	def setRichValue value
		self.value = value
	
	def bind$ key, value
		let o = value or []

		if key == 'data'
			unless #f & $TAG_BIND_MODEL$
				#f |= $TAG_BIND_MODEL$
				this.on$('change',{_change$: true},this) if this.change$
				this.on$('input',{capture: true,_input$: true},this) if this.input$

		Object.defineProperty(self,key,o isa Array ? createProxyProperty(o) : o)
		return o

Object.defineProperty(Element.prototype,'richValue',{
	def get
		self.getRichValue()
	def set v
		self.setRichValue(v)
})

extend class HTMLSelectElement

	def change$ e
		return unless #f & $TAG_BIND_MODEL$

		let model = self.data
		let prev = #richValue
		#richValue = undefined
		let values = self.getRichValue()

		if self.multiple
			if prev
				for value in prev when values.indexOf(value) == -1
					bindRemove(model,value)

			for value in values
				if !prev or prev.indexOf(value) == -1
					bindAdd(model,value)
		else
			self.data = values[0]
		self

	def getRichValue
		if #richValue
			return #richValue

		#richValue = for o in self.selectedOptions
			o.richValue

	def syncValue
		let model = self.data

		if self.multiple
			let vals = []
			for option,i in self.options
				let val = option.richValue
				let sel = bindHas(model,val)
				option.selected = sel
				vals.push(val) if sel
			#richValue = vals

		else
			for option,i in self.options
				let val = option.richValue
				if val == model
					#richValue = [val]
					break self.selectedIndex = i
		return

	def end$
		self.syncValue()

extend class HTMLOptionElement
	def setRichValue value
		#richValue = value
		self.value = value

	def getRichValue
		if #richValue !== undefined
			return #richValue
		return self.value

extend class HTMLTextAreaElement
	def setRichValue value
		#richValue = value
		self.value = value

	def getRichValue
		if #richValue !== undefined
			return #richValue
		return self.value

	def input$ e
		self.data = self.value

	def end$
		self.value = self.data

extend class HTMLInputElement
	
	def input$ e
		return unless #f & $TAG_BIND_MODEL$
		let typ = self.type

		if typ == 'checkbox' or typ == 'radio'
			return

		#richValue = undefined
		self.data = self.richValue

	def change$ e
		return unless #f & $TAG_BIND_MODEL$

		let model = self.data
		let val = self.richValue

		if self.type == 'checkbox' or self.type == 'radio'
			let checked = self.checked
			if isGroup(model)
				checked ? bindAdd(model,val) : bindRemove(model,val)
			else
				self.data = checked ? val : false

	def setRichValue value
		#richValue = value
		self.value = value

	def getRichValue
		if #richValue !== undefined
			return #richValue

		let value = self.value
		let typ = self.type

		if typ == 'range' or typ == 'number'
			value = self.valueAsNumber
			value = null if Number.isNaN(value)
		elif typ == 'checkbox'
			value = true if value == undefined or value === 'on'

		return value

	def end$
		if #f & $TAG_BIND_MODEL$
			let typ = self.type
			if typ == 'checkbox' or typ == 'radio'
				let val = self.data
				if val === true or val === false or val == null
					self.checked = !!val
				else
					self.checked = bindHas(val,self.richValue)
			else
				self.richValue = self.data
		return