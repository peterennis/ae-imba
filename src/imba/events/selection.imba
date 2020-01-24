
var selHandler

def activateSelectionHandler
	unless selHandler
		selHandler = do |e|
			return if e.handled$
			e.handled$ = yes
			
			let target = document.activeElement
			if target and target.matches('input,textarea')
				let custom = CustomEvent.new('selection',{
					detail: {
						start: target.selectionStart
						end: target.selectionEnd
					}
				})
				target.dispatchEvent(custom)
		document.addEventListener('selectionchange',selHandler)

Element.prototype.on$selection = do |mods, context|
	activateSelectionHandler()