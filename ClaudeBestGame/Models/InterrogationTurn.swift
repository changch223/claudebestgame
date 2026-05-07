import Foundation
import SwiftData

@Model
final class InterrogationTurn {
    @Attribute(.unique) var id: UUID
    var sessionId: UUID
    var index: Int
    var speaker: String      // "player" / "suspect"
    var text: String
    var chosenChoiceCategory: String?     // ChoiceCategory.rawValue (player only)
    var contradictionSeverity: String?    // suspect only
    var gaugeDelta: Double
    var gaugeAfter: Double
    var vigilanceAfter: Double
    var timestamp: Date

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        index: Int,
        speaker: String,
        text: String,
        chosenChoiceCategory: String? = nil,
        contradictionSeverity: String? = nil,
        gaugeDelta: Double = 0,
        gaugeAfter: Double = 0,
        vigilanceAfter: Double = 0,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.index = index
        self.speaker = speaker
        self.text = text
        self.chosenChoiceCategory = chosenChoiceCategory
        self.contradictionSeverity = contradictionSeverity
        self.gaugeDelta = gaugeDelta
        self.gaugeAfter = max(0, min(1, gaugeAfter))
        self.vigilanceAfter = max(0, min(1, vigilanceAfter))
        self.timestamp = timestamp
    }
}
