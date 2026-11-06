import Foundation

let grok = "“Grok Bot.app” wants access to control “Terminal.app”. Allowing control will provide access to documents and data in “Terminal.app”, and to perform actions within that app."
let grokJa = "“Grok Bot.app”が“Terminal.app”を制御するアクセスを要求しています。制御を許可すると、“Terminal.app”の書類やデータにアクセスしたり、そのアプリ内で操作を実行したりできるようになります。"
let mise = "“mise” would like to access files in your Documents folder."
let miseJa = "“mise”が書類フォルダ内のファイルへのアクセスを求めています。"
let allowButtons = ["Don’t Allow", "Allow"]
let allowButtonsAscii = ["Don't Allow", "Allow"]
let allowButtonsJa = ["許可しない", "許可"]

let cases: [(String, AllowDialog, Bool)] = [
    ("apple events", AllowDialog(verifiedSystemOwner: true, isModal: true, message: grok, buttons: allowButtons), true),
    ("other requester", AllowDialog(verifiedSystemOwner: true, isModal: true, message: grok.replacingOccurrences(of: "Grok Bot.app", with: "Other.app"), buttons: allowButtons), true),
    ("documents access", AllowDialog(verifiedSystemOwner: true, isModal: true, message: mise, buttons: allowButtons), true),
    ("ascii apostrophe", AllowDialog(verifiedSystemOwner: true, isModal: true, message: mise, buttons: allowButtonsAscii), true),
    ("japanese documents", AllowDialog(verifiedSystemOwner: true, isModal: true, message: miseJa, buttons: allowButtonsJa), true),
    ("japanese apple events", AllowDialog(verifiedSystemOwner: true, isModal: true, message: grokJa, buttons: allowButtonsJa), true),
    ("unverified owner", AllowDialog(verifiedSystemOwner: false, isModal: true, message: mise, buttons: allowButtons), false),
    ("nonmodal", AllowDialog(verifiedSystemOwner: true, isModal: false, message: mise, buttons: allowButtons), false),
    ("empty message", AllowDialog(verifiedSystemOwner: true, isModal: true, message: "   ", buttons: allowButtons), false),
    ("duplicate button", AllowDialog(verifiedSystemOwner: true, isModal: true, message: mise, buttons: ["Don’t Allow", "Allow", "Allow"]), false),
    ("denial only", AllowDialog(verifiedSystemOwner: true, isModal: true, message: mise, buttons: ["Don’t Allow"]), false),
    ("ok cancel", AllowDialog(verifiedSystemOwner: true, isModal: true, message: mise, buttons: ["Cancel", "OK"]), false)
]

let failures = cases.filter { AllowRule.matches($0.1) != $0.2 }
if failures.isEmpty {
    print("Passed \(cases.count) matcher checks")
} else {
    for failure in failures { print("Failed: \(failure.0)") }
    exit(1)
}
