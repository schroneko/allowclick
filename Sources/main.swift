import AppKit
import ApplicationServices

if CommandLine.arguments.dropFirst().contains("--version") {
    print("AllowClick 0.2.0")
    exit(0)
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private let watcher = AutomationWatcher()
    private let setupOnly = CommandLine.arguments.contains("--setup-only")
    private let status = NSMenuItem(title: "Starting", action: nil, keyEquivalent: "")
    private let accessibilityStatus = NSMenuItem(title: "Accessibility: Checking", action: nil, keyEquivalent: "")
    private let accessibilitySettings = NSMenuItem(title: "Open Accessibility Settings…", action: #selector(openAccessibilitySettings), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "AllowClick"
        let menu = NSMenu()
        menu.delegate = self
        status.isEnabled = false
        accessibilityStatus.isEnabled = false
        accessibilitySettings.target = self
        menu.autoenablesItems = false
        menu.addItem(status)
        menu.addItem(accessibilityStatus)
        menu.addItem(accessibilitySettings)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
        watcher.onStatusChange = { [weak self] text in
            self?.status.title = text
            self?.refreshAccessibilityStatus()
        }
        refreshAccessibilityStatus()
        if setupOnly {
            status.title = "Monitoring paused during setup"
        } else {
            watcher.start()
        }
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshAccessibilityStatus()
    }

    private func refreshAccessibilityStatus() {
        let trusted = AXIsProcessTrusted()
        accessibilityStatus.title = trusted ? "Accessibility: Allowed" : "Accessibility: Not Allowed"
        accessibilitySettings.isEnabled = !trusted
    }

    @objc private func openAccessibilitySettings() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
