import Foundation

struct AllowDialog {
    let verifiedSystemOwner: Bool
    let isModal: Bool
    let message: String
    let buttons: [String]
}

enum AllowRule {
    static let messages = [
        "“Grok Bot.app” wants access to control “Terminal.app”. Allowing control will provide access to documents and data in “Terminal.app”, and to perform actions within that app.",
        "“Grok Bot.app”が“Terminal.app”を制御するアクセスを要求しています。制御を許可すると、“Terminal.app”の書類やデータにアクセスしたり、そのアプリ内で操作を実行したりできるようになります。"
    ]

    static func matches(_ dialog: AllowDialog) -> Bool {
        guard dialog.verifiedSystemOwner, dialog.isModal else { return false }
        guard messages.contains(normalize(dialog.message)) else { return false }
        let buttons = dialog.buttons.map(normalize)
        if normalize(dialog.message) == messages[0] {
            return buttons.filter { $0 == "Allow" }.count == 1
                && buttons.filter { $0 == "Don’t Allow" }.count == 1
        }
        return buttons.filter { $0 == "許可" }.count == 1
            && buttons.filter { $0 == "許可しない" }.count == 1
    }

    private static func normalize(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}
