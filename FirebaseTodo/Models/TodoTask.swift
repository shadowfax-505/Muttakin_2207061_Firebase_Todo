import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isDone: Bool = false
    var createdAt: Date = Date()
}
