import XCTest

final class HtmlParserTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNormalizeHTML() throws {
        let expected = "line1 \n \nline2 \nline3"

        let html = "line1<br/><br/>\r\nline2<br/>\r\nline3\r\n"
        let normalizedString = HtmlParser.normalizeTexts(content: html)

        XCTAssertEqual(expected, normalizedString)
    }

}
