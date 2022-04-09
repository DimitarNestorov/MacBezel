import AppKit

let app = NSApplication.shared
let appDelegate = AppDelegate()
app.setActivationPolicy(.regular)
app.delegate = appDelegate
app.run()
