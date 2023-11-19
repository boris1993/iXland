import Foundation
import SwiftSoup

class HtmlParser {
    private init() {}

    private static let NewLine = "\n"

    public static func normalizeTexts(content: String) -> String {
        do {
            let document = try SwiftSoup.parse(content.replacingOccurrences(of: "\r\n", with: ""))
            document.outputSettings(OutputSettings().prettyPrint(pretty: false))

            try replaceBrToLineBreak(document: document)
            try normalizeLinks(document: document)

            return try document.text(trimAndNormaliseWhitespace: false)
        } catch {
            print(error)
            return content
        }
    }

    private static func replaceBrToLineBreak(document: Document) throws {
        let brNodes = try document.select("br")
        try brNodes.forEach { node in
            try node.text(NewLine)
        }
    }

    private static func normalizeLinks(document: Document) throws {
        let links = try document.select("a")
        try links.forEach { link in
            let linkHref = try link.attr("href")
            let linkText = try link.text()

            try link.text("[\(linkText)](\(linkHref))")
        }
    }
}
