import AppKit
import ApplicationServices
import Foundation
import Security

private struct ElementIdentity: Hashable {
    let element: AXUIElement

    static func == (lhs: ElementIdentity, rhs: ElementIdentity) -> Bool {
        CFEqual(lhs.element, rhs.element)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(element))
    }
}

final class AutomationWatcher {
    private var timer: Timer?
    private var lastAttempt: Date = .distantPast
    private var checkedApplications: [String: Bool] = [:]
    private let appleRequirement: SecRequirement? = {
        var requirement: SecRequirement?
        guard SecRequirementCreateWithString("anchor apple" as CFString, SecCSFlags(), &requirement) == errSecSuccess else { return nil }
        return requirement
    }()
    var onStatusChange: ((String) -> Void)?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.scan()
        }
    }

    private func scan() {
        guard AXIsProcessTrusted() else {
            onStatusChange?("Accessibility permission required")
            return
        }
        onStatusChange?("Monitoring")
        guard Date().timeIntervalSince(lastAttempt) >= 2 else { return }
        let running = NSWorkspace.shared.runningApplications
        let currentKeys = Set(running.map(applicationKey))
        checkedApplications = checkedApplications.filter { currentKeys.contains($0.key) }
        for app in running where isAppleSystemApp(app) {
            let root = AXUIElementCreateApplication(app.processIdentifier)
            AXUIElementSetMessagingTimeout(root, 0.1)
            for window in elements(root, kAXWindowsAttribute as String) {
                if let button = matchingButton(window) {
                    lastAttempt = Date()
                    let result = AXUIElementPerformAction(button, kAXPressAction as CFString)
                    NSLog("AllowClick: AXPress result %d", result.rawValue)
                    return
                }
            }
        }
    }

    private func isAppleSystemApp(_ app: NSRunningApplication) -> Bool {
        guard let path = app.bundleURL?.standardizedFileURL.path,
              path.hasPrefix("/System/Library/"), let appleRequirement else { return false }
        let key = applicationKey(app)
        if let result = checkedApplications[key] { return result }
        var code: SecCode?
        let attributes = [kSecGuestAttributePid as String: app.processIdentifier] as CFDictionary
        guard SecCodeCopyGuestWithAttributes(nil, attributes, SecCSFlags(), &code) == errSecSuccess,
              let code else { return false }
        let valid = SecCodeCheckValidity(code, SecCSFlags(), appleRequirement) == errSecSuccess
        checkedApplications[key] = valid
        return valid
    }

    private func applicationKey(_ app: NSRunningApplication) -> String {
        "\(app.processIdentifier):\(app.launchDate?.timeIntervalSince1970 ?? 0)"
    }

    private func matchingButton(_ window: AXUIElement) -> AXUIElement? {
        guard bool(window, kAXModalAttribute as String) == true else { return nil }
        var pending: [(AXUIElement, Int)] = [(window, 0)]
        var seen = Set<ElementIdentity>()
        var messages: [String] = []
        var buttons: [(String, AXUIElement)] = []
        while let (element, depth) = pending.popLast(), seen.count < 3000 {
            guard depth <= 24, seen.insert(ElementIdentity(element: element)).inserted else { continue }
            let role = string(element, kAXRoleAttribute as String)
            if role == "AXWebArea" || role == kAXMenuBarRole as String || role == kAXMenuRole as String { continue }
            if role == kAXStaticTextRole as String {
                messages.append(string(element, kAXValueAttribute as String))
                messages.append(string(element, kAXTitleAttribute as String))
            } else if role == kAXButtonRole as String, bool(element, kAXEnabledAttribute as String) == true {
                buttons.append((string(element, kAXTitleAttribute as String), element))
            }
            pending.append(contentsOf: elements(element, kAXChildrenAttribute as String).map { ($0, depth + 1) })
        }
        let labels = buttons.map(\.0)
        for message in messages {
            let dialog = AllowDialog(verifiedSystemOwner: true, isModal: true, message: message, buttons: labels)
            guard AllowRule.matches(dialog) else { continue }
            let expected = message.split(whereSeparator: \.isWhitespace).joined(separator: " ") == AllowRule.messages[0] ? "Allow" : "許可"
            return buttons.first { $0.0 == expected }?.1
        }
        return nil
    }

    private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
        return value
    }

    private func string(_ element: AXUIElement, _ name: String) -> String {
        attribute(element, name) as? String ?? ""
    }

    private func bool(_ element: AXUIElement, _ name: String) -> Bool? {
        attribute(element, name) as? Bool
    }

    private func elements(_ element: AXUIElement, _ name: String) -> [AXUIElement] {
        attribute(element, name) as? [AXUIElement] ?? []
    }
}
