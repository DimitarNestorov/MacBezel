import Cocoa

class ColoredView: NSView {
	@IBInspectable var color: NSColor = NSColor.clear
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		color.setFill()
		dirtyRect.fill()
	}
}
