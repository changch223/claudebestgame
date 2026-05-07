import XCTest
@testable import ClaudeBestGame

final class SmokeTests: XCTestCase {
    func testFallbackCasesLoad() {
        let cases = FallbackCaseProvider.loadAll()
        XCTAssertEqual(cases.count, 10, "10件のフォールバック事件がロードされるはず")
        for c in cases {
            XCTAssertFalse(c.suspectName.isEmpty)
            XCTAssertFalse(c.alibiStory.isEmpty)
            XCTAssertFalse(c.contradictionKeywords.isEmpty)
        }
    }
}
