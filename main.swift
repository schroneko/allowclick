import Foundation

let message = AllowRule.messages[0]
let valid = AllowDialog(verifiedSystemOwner: true, isModal: true, message: message, buttons: ["Don’t Allow", "Allow"])
let cases: [(String, AllowDialog, Bool)] = [
    ("target", valid, true),
    ("other requester", AllowDialog(verifiedSystemOwner: true, isModal: true, message: message.replacingOccurrences(of: "Grok Bot.app", with: "Other.app"), buttons: valid.buttons), false),
    ("other destination", AllowDialog(verifiedSystemOwner: true, isModal: true, message: message.replacingOccurrences(of: "Terminal.app", with: "Other.app"), buttons: valid.buttons), false),
    ("unverified owner", AllowDialog(verifiedSystemOwner: false, isModal: true, message: message, buttons: valid.buttons), false),
    ("nonmodal", AllowDialog(verifiedSystemOwner: true, isModal: false, message: message, buttons: valid.buttons), false),
    ("duplicate button", AllowDialog(verifiedSystemOwner: true, isModal: true, message: message, buttons: ["Don’t Allow", "Allow", "Allow"]), false),
    ("denial only", AllowDialog(verifiedSystemOwner: true, isModal: true, message: message, buttons: ["Don’t Allow"]), false),
    ("Japanese", AllowDialog(verifiedSystemOwner: true, isModal: true, message: AllowRule.messages[1], buttons: ["許可しない", "許可"]), true)
]

let failures = cases.filter { AllowRule.matches($0.1) != $0.2 }
if failures.isEmpty {
    print("Passed \(cases.count) matcher checks")
} else {
    for failure in failures { print("Failed: \(failure.0)") }
    exit(1)
}
