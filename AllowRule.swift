import Foundation

struct AllowDialog {
    let verifiedSystemOwner: Bool
    let isModal: Bool
    let message: String
    let buttons: [String]
}

enum AllowRule {
    static let allowEnglish = "Allow"
    static let allowJapanese = "許可"
    static let denyJapanese = "許可しない"

    static func matches(_ dialog: AllowDialog) -> Bool {
        guard dialog.verifiedSystemOwner, dialog.isModal else { return false }
        guard !normalize(dialog.message).isEmpty else { return false }
        return allowButtonTitle(in: dialog.buttons) != nil
    }

    static func allowButtonTitle(in buttons: [String]) -> String? {
        let labels = buttons.map(normalize)
        let allowEn = labels.filter { $0 == allowEnglish }.count
        let denyEn = labels.filter(isEnglishDeny).count
        let allowJa = labels.filter { $0 == allowJapanese }.count
        let denyJa = labels.filter { $0 == denyJapanese }.count
        if allowEn == 1 && denyEn == 1 && allowJa == 0 && denyJa == 0 {
            return allowEnglish
        }
        if allowJa == 1 && denyJa == 1 && allowEn == 0 && denyEn == 0 {
            return allowJapanese
        }
        return nil
    }

    static func normalize(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static func isEnglishDeny(_ text: String) -> Bool {
        let folded = text
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{2018}", with: "'")
        return folded == "Don't Allow"
    }
}
