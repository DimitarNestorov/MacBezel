import AppKit
import AssetCatalog
import MacBezel

class Playground {
	@IBOutlet var window: NSWindow! {
		didSet {
			NSApplication.shared.activate(ignoringOtherApps: true)
			window.makeKeyAndOrderFront(self)
		}
	}
	
	@IBOutlet weak var leftColorWell: NSColorWell!
	@IBOutlet weak var rightColorWell: NSColorWell!
	
	@IBOutlet weak var leftColoredView: ColoredView!
	@IBOutlet weak var rightColoredView: ColoredView!
	
	lazy var coloredViewDictionary = [
		leftColorWell: leftColoredView,
		rightColorWell: rightColoredView,
	]
	
	@IBAction func showIconA(_ sender: NSButton) {
		show(.iconA, options: [.text: "Build Succeeded"])
	}
	
	@IBAction func showIconBOnMainThread(_ sender: NSButton) {
		show(.iconB, qos: nil)
	}
	
	@IBAction func showBrightness(_ sender: NSButton) {
		show(.brightness)
	}
	
	@IBAction func showVolume(_ sender: NSButton) {
		show(.volume)
	}
	
	@IBAction func showMuteAndNotAllowed(_ sender: NSButton) {
		show([.mute, .notAllowed])
	}
	
	@IBAction func showOnDifferentDisplay(_ sender: NSButton) {
		var screensSet = Set(NSScreen.screens)
		screensSet.remove(NSScreen.main!)
		if screensSet.count == 0 {
			print("No other screen available")
		} else {
			show(.iconA, options: [.screen: Array(screensSet).randomElement()!])
		}
	}
	
	@IBAction func showBeneath(_ sender: NSButton) {
		show(.iconA, qos: nil, options: [.level: kCGNormalWindowLevel])
		
		DispatchQueue.main.async {
			self.window.orderFront(self)
		}
	}
	
	// #region Lock SF Symol
	var lockSymbol: NSImage?
	
	@IBOutlet weak var showSFSymbolButton: NSButton! {
		didSet {
			if #available(macOS 11.0, *) {
				self.lockSymbol = NSImage(systemSymbolName: "lock", accessibilityDescription: nil)!
					.withSymbolConfiguration(.init(pointSize: 500, weight: .medium, scale: .large))!
					.resizeForBezel()
			} else {
				showSFSymbolButton.isEnabled = false
			}
		}
	}
	
	@IBAction func showLockSFSymbolWithCustomFadeOutDuration(_ sender: NSButton) {
		Bezel.show([lockSymbol!], options: [.fadeOutDuration: 5, .visibleDuration: 30, .text: "Locked"])
	}
	// #endregion
	
	@IBAction func showWithCustomFadeOutDurationAndEaseInEaseOutTimingFunction(_ sender: NSButton) {
		show(.iconB, options: [.fadeOutDuration: 5, .fadeOutTimingFunctionName: CAMediaTimingFunctionName.easeInEaseOut])
	}
	
	@IBAction func showWithVisibleDuration10AndFadeOutDuration0(_ sender: NSButton) {
		show(.iconA, options: [.fadeOutDuration: 0, .visibleDuration: 10])
	}
	
	// #region Xcode wrench
	var wrench: NSImage?
	
	@IBOutlet weak var showXcodeWrenchButton: NSButton! {
		didSet {
			let path = "/Applications/Xcode.app/Contents/Frameworks/IDEKit.framework/Versions/A/Resources/Assets.car"
			
			guard FileManager.default.fileExists(atPath: path) else {
				showXcodeWrenchButton.isEnabled = false
				return
			}
			
			let catalog = AssetCatalog(fileURL: URL(fileURLWithPath: path))
			
			let result = catalog.readImages("IDEAlertBezel_Build", distinguishCatalogsFromThemeStores: true)
			
			let image = (result[1] as! NSDictionary)["image"] as! NSImage
			image.isTemplate = true
			wrench = image.resize(insideRect: .init(x: 0, y: 0, width: 174, height: 174), leftPadding: 31.5, rightPadding: 31.5, topPadding: 22, bottomPadding: 42)
		}
	}
	
	@IBAction func showXcodeWrench(_ sender: NSButton) {
		Bezel.show([wrench!], options: [.text: "Build Succeeded"])
	}
	// #endregion
	
	@IBAction func changeColoredViewColor(_ sender: NSColorWell) {
		let coloredView = coloredViewDictionary[sender]!!
		coloredView.color = sender.color
		coloredView.needsDisplay = true
	}
	
	private func show(_ image: Image, qos: DispatchQoS.QoSClass? = .userInitiated, options: [BezelShowOptionKey : Any]? = nil) {
		show([image], qos: qos, options: options)
	}
	
	private func show(_ images: [Image], qos: DispatchQoS.QoSClass? = .userInitiated, options: [BezelShowOptionKey : Any]? = nil) {
		let images = images.map { $0.rawValue }
		
		guard let qos = qos else {
			Bezel.show(images, options: options)
			return
		}
		
		DispatchQueue.global(qos: qos).async {
			Bezel.show(images, options: options)
		}
	}
	
	private enum Image {
		case iconA, iconB, testBackground, brightness, volume, mute, notAllowed
		
		var rawValue: NSImage {
			switch self {
			case .iconA: return Image.memoizedGetImage("Icon A", true)
			case .iconB: return Image.memoizedGetImage("Icon B", true)
			case .testBackground: return Image.memoizedGetImage("Test Background", false)
			case .brightness: return Image.memoizedGetSystemImage("Brightness")
			case .volume: return Image.memoizedGetSystemImage("Volume")
			case .mute: return Image.memoizedGetSystemImage("Mute")
			case .notAllowed: return Image.memoizedGetSystemImage("NotAllowed")
			}
		}
		
		static let memoizedGetImage = memoize(getImage)
		static let memoizedGetSystemImage = memoize(getSystemImage)
	}
}

let bundle = Bundle(url: Bundle.main.bundleURL.appendingPathComponent("MacBezel_MacBezel Playground.bundle"))!

fileprivate func getImage(_ image: String, isTemplate: Bool) -> NSImage {
	let image = NSImage(byReferencing: bundle.url(forResource: "Icons/\(image)", withExtension: "pdf")!)
	image.isTemplate = isTemplate
	return image
}

fileprivate func getSystemImage(_ image: String) -> NSImage {
	let image = NSImage(byReferencingFile: "/System/Library/CoreServices/OSDUIHelper.app/Contents/Resources/\(image).pdf")!
	image.isTemplate = true
	return image
}

// #region memoize
/// https://www.hackingwithswift.com/plus/high-performance-apps/using-memoization-to-speed-up-slow-functions
fileprivate func memoize<Input: Hashable, Output>(_ function: @escaping (Input) -> Output) -> (Input) -> Output {
	var storage = [Input: Output]()
	
	return { input in
		if let cached = storage[input] {
			return cached
		}
		
		let result = function(input)
		storage[input] = result
		return result
	}
}

struct DualHashable<Input1: Hashable, Input2: Hashable> {
	var a: Input1
	var b: Input2
}

extension DualHashable: Hashable {
	static func ==(lhs: DualHashable, rhs: DualHashable) -> Bool {
		return lhs.a == rhs.a && lhs.b == rhs.b
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(a)
		hasher.combine(b)
	}
}

fileprivate func memoize<Input1: Hashable, Input2: Hashable, Output>(_ function: @escaping (Input1, Input2) -> Output) -> (Input1, Input2) -> Output {
	var storage = [DualHashable<Input1, Input2>: Output]()
	
	return { input1, input2 in
		let key = DualHashable(a: input1, b: input2)
		if let cached = storage[key] {
			return cached
		}
		
		let result = function(input1, input2)
		storage[key] = result
		return result
	}
}
// #endregion memoize
