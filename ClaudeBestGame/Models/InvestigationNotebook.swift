import Foundation
import SwiftData

/// Per-case notebook that accumulates across loops.
/// Singleton-per-caseKey: looking up the notebook for a case key
/// either fetches the existing one or creates a fresh empty one.
@Model
final class InvestigationNotebook {
    @Attribute(.unique) var caseKey: String
    var totalLoops: Int
    var lastUpdatedAt: Date
    /// Free-text summary lines accumulated across loops, joined with newline.
    var summaryLines: String
    /// JSON-encoded array of suspect quotes flagged as suspicious.
    var flaggedQuotesData: Data

    init(
        caseKey: String,
        totalLoops: Int = 0,
        lastUpdatedAt: Date = Date(),
        summaryLines: String = "",
        flaggedQuotes: [String] = []
    ) {
        self.caseKey = caseKey
        self.totalLoops = totalLoops
        self.lastUpdatedAt = lastUpdatedAt
        self.summaryLines = summaryLines
        self.flaggedQuotesData = (try? JSONEncoder().encode(flaggedQuotes)) ?? Data()
    }

    var flaggedQuotes: [String] {
        get { (try? JSONDecoder().decode([String].self, from: flaggedQuotesData)) ?? [] }
        set { flaggedQuotesData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    func appendLine(_ line: String) {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if summaryLines.isEmpty {
            summaryLines = trimmed
        } else {
            summaryLines += "\n" + trimmed
        }
    }

    func flag(quote: String) {
        let trimmed = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var arr = flaggedQuotes
        if !arr.contains(trimmed) {
            arr.append(trimmed)
            flaggedQuotes = arr
        }
    }
}
