import Foundation
import SwiftData

/// A piece of evidence the player has uncovered during the interrogation
/// of a specific case. Persists across loops within the same case so the
/// player can reuse it.
@Model
final class EvidenceItem {
    @Attribute(.unique) var id: UUID
    /// Logical case identifier (FallbackCase.id or CaseRecord.id.uuidString).
    var caseKey: String
    var title: String
    var detail: String
    /// In which loop the evidence was first discovered (0-indexed).
    var discoveredAtLoop: Int
    var discoveredAt: Date

    init(
        id: UUID = UUID(),
        caseKey: String,
        title: String,
        detail: String,
        discoveredAtLoop: Int,
        discoveredAt: Date = Date()
    ) {
        self.id = id
        self.caseKey = caseKey
        self.title = title
        self.detail = detail
        self.discoveredAtLoop = discoveredAtLoop
        self.discoveredAt = discoveredAt
    }
}
