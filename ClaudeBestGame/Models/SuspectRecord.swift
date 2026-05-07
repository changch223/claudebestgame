import Foundation
import SwiftData

@Model
final class SuspectRecord {
    @Attribute(.unique) var id: UUID
    var caseId: UUID
    var name: String
    var age: Int
    var job: String
    var personaType: String
    var alibiStory: String
    var weakPoint: String

    init(
        id: UUID = UUID(),
        caseId: UUID,
        name: String,
        age: Int,
        job: String,
        personaType: String,
        alibiStory: String,
        weakPoint: String
    ) {
        self.id = id
        self.caseId = caseId
        self.name = name
        self.age = age
        self.job = job
        self.personaType = personaType
        self.alibiStory = alibiStory
        self.weakPoint = weakPoint
    }
}
