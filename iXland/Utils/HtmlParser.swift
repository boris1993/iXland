import Foundation
import SwiftSoup

class HtmlParser {
    private init() {}

    private static let XPATH_TEXT_NODE_ANYWHERE = "//text()"
    private static let XPATH_BR_NODE = "br"
    private static let XPATH_BR_NODE_EVERYWHERE = "//br"

    public static func normalizeTexts(content: String) -> String {
        do {
            let document = try SwiftSoup.parse(content.replacingOccurrences(of: "\r\n", with: ""))
            document.outputSettings(OutputSettings().prettyPrint(pretty: false))

            replaceBrToLineBreak(document: document)
            normalizeLinks(document: document)

            return try document.text(trimAndNormaliseWhitespace: false)
        } catch {
            print(error)
            return content
        }
    }

    private static func replaceBrToLineBreak(document: Document) {
        do {
            let brNodes = try document.select("br")
            try brNodes.forEach { node in
                try node.text("\n")
            }
        } catch {
            print(error)
        }
    }

    private static func normalizeLinks(document: Document) {
        do {
            let links = try document.select("a")
            try links.forEach { link in
                let linkHref = try link.attr("href")
                let linkText = try link.text()

                try link.text("[\(linkText)](\(linkHref))")
//                try link.prepend("[\(linkText)](\(linkHref))")
                // TODO remove this node correctly
//                try link.remove()
            }

//            return document
        } catch {
            print(error)
//            return document
        }
    }
}
