import Foundation
import Observation

@MainActor
@Observable
final class NotebookViewModel {
    let notebook: InvestigationNotebook?
    let evidence: [EvidenceItem]
    let caseTitle: String

    init(
        notebook: InvestigationNotebook?,
        evidence: [EvidenceItem],
        caseTitle: String
    ) {
        self.notebook = notebook
        self.evidence = evidence
        self.caseTitle = caseTitle
    }

    var summaryLines: [String] {
        guard let notebook else { return [] }
        return notebook.summaryLines
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { String($0) }
    }

    var flaggedQuotes: [String] {
        notebook?.flaggedQuotes ?? []
    }
}
