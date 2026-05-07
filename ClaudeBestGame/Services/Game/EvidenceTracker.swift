import Foundation

/// Result of scanning a player turn for new evidence discoveries.
struct EvidenceDiscovery: Equatable, Sendable {
    let title: String
    let detail: String
}

/// Pure logic that scans a player's question + suspect's reply
/// against a case's evidenceTriggers map and produces 0..N new evidence
/// findings. Existing evidence (by title) should be filtered by the caller.
enum EvidenceTracker {

    /// - Parameters:
    ///   - playerQuestion: text of the player's question
    ///   - suspectReply:  suspect's response text
    ///   - triggers:      mapping of trigger keyword → (title, detail) for the case
    /// - Returns: list of new EvidenceDiscovery values, in trigger order.
    static func scan(
        playerQuestion: String,
        suspectReply: String,
        triggers: [EvidenceTrigger]
    ) -> [EvidenceDiscovery] {
        let combined = playerQuestion + " " + suspectReply
        var found: [EvidenceDiscovery] = []
        var seen: Set<String> = []
        for trigger in triggers {
            // Trigger fires only if any of its keywords appears in combined text
            let hit = trigger.keywords.contains { combined.contains($0) }
            guard hit, !seen.contains(trigger.title) else { continue }
            seen.insert(trigger.title)
            found.append(EvidenceDiscovery(title: trigger.title, detail: trigger.detail))
        }
        return found
    }
}

/// JSON-decoded shape of an evidence trigger from cases.json.
struct EvidenceTrigger: Codable, Sendable {
    let keywords: [String]
    let title: String
    let detail: String
}
