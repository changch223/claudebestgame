import XCTest
@testable import ClaudeBestGame

final class EvidenceTrackerTests: XCTestCase {

    private let triggers: [EvidenceTrigger] = [
        EvidenceTrigger(
            keywords: ["妻", "出張"],
            title: "妻の出張記録",
            detail: "妻は海外出張中"
        ),
        EvidenceTrigger(
            keywords: ["夕食", "食事"],
            title: "夕食の不審点",
            detail: "1人前のみ用意されていた"
        )
    ]

    func testNoTriggerYieldsEmpty() {
        let r = EvidenceTracker.scan(
            playerQuestion: "好きな食べ物は？",
            suspectReply: "和食です",
            triggers: triggers
        )
        XCTAssertEqual(r.count, 0)
    }

    func testKeywordMatchYieldsEvidence() {
        let r = EvidenceTracker.scan(
            playerQuestion: "妻はどこにいた？",
            suspectReply: "自宅にいました",
            triggers: triggers
        )
        XCTAssertEqual(r.count, 1)
        XCTAssertEqual(r.first?.title, "妻の出張記録")
    }

    func testReplyKeywordMatchAlsoTriggers() {
        let r = EvidenceTracker.scan(
            playerQuestion: "何を食べました？",
            suspectReply: "夕食を取りました",
            triggers: triggers
        )
        XCTAssertEqual(r.count, 1)
        XCTAssertEqual(r.first?.title, "夕食の不審点")
    }

    func testMultipleTriggersAreReturnedInOrder() {
        let r = EvidenceTracker.scan(
            playerQuestion: "妻は出張先で何の夕食を？",
            suspectReply: "...",
            triggers: triggers
        )
        XCTAssertEqual(r.count, 2)
        XCTAssertEqual(r[0].title, "妻の出張記録")
        XCTAssertEqual(r[1].title, "夕食の不審点")
    }

    func testDuplicateTitleSkipped() {
        let dupTriggers = [
            EvidenceTrigger(keywords: ["A"], title: "Same", detail: "x"),
            EvidenceTrigger(keywords: ["B"], title: "Same", detail: "y")
        ]
        let r = EvidenceTracker.scan(
            playerQuestion: "A B 両方", suspectReply: "",
            triggers: dupTriggers
        )
        XCTAssertEqual(r.count, 1)
    }
}
