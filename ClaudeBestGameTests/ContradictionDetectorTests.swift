import XCTest
@testable import ClaudeBestGame

final class ContradictionDetectorTests: XCTestCase {

    func testNoMatchYieldsNone() {
        let r = ContradictionDetector.detect(
            playerQuestion: "好きな食べ物は？",
            suspectReply: "和食です",
            contradictionKeywords: ["妻", "出張"],
            priorTurns: []
        )
        XCTAssertEqual(r.severity, .none)
    }

    func testSingleKeywordMatchYieldsSmall() {
        let r = ContradictionDetector.detect(
            playerQuestion: "妻はどこにいた？",
            suspectReply: "自宅にいました",
            contradictionKeywords: ["妻", "出張", "海外"],
            priorTurns: []
        )
        XCTAssertEqual(r.severity, .small)
    }

    func testTwoKeywordsYieldMedium() {
        let r = ContradictionDetector.detect(
            playerQuestion: "妻が海外にいたなら、誰と夕食を？",
            suspectReply: "妻と一緒です",
            contradictionKeywords: ["妻", "出張", "海外"],
            priorTurns: []
        )
        // Q+R contains "妻" "海外" "妻" → 2 unique keywords → medium
        XCTAssertEqual(r.severity, .medium)
    }

    func testManyKeywordsYieldLarge() {
        let r = ContradictionDetector.detect(
            playerQuestion: "妻は出張で海外にいた、誰か他の人がいたのでは？",
            suspectReply: "...覚えていません...知りません",
            contradictionKeywords: ["妻", "出張", "海外", "誰か他", "別の人", "不在"],
            priorTurns: []
        )
        XCTAssertEqual(r.severity, .large)
    }

    func testEvasionMarkersAddOneStep() {
        // 1 keyword + 2 evasion markers → +1 → severity medium
        let r = ContradictionDetector.detect(
            playerQuestion: "妻は？",
            suspectReply: "...覚えていません...答えかねます",
            contradictionKeywords: ["妻"],
            priorTurns: []
        )
        XCTAssertEqual(r.severity, .medium)
    }
}
