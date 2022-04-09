import AppKit
import AVFoundation

extension NSImage {
	func resize(insideRect: NSRect, leftPadding: CGFloat, rightPadding: CGFloat, topPadding: CGFloat, bottomPadding: CGFloat) -> NSImage {
		let img = NSImage(size: insideRect.size)
		img.isTemplate = self.isTemplate
		
		img.lockFocus()
		let ctx = NSGraphicsContext.current
		ctx?.imageInterpolation = .high
		self.draw(
			in: insideRect,
			from: NSMakeRect(-leftPadding, -bottomPadding, size.width + leftPadding + rightPadding, size.height + topPadding + bottomPadding),
			operation: .copy,
			fraction: 1
		)
		img.unlockFocus()
		
		return img
	}
}

