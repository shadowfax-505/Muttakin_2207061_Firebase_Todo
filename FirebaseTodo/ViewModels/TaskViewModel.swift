import Foundation
import FirebaseFirestore

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var uid: String?

    // users/{uid}/tasks
    private var tasksRef: CollectionReference? {
        guard let uid else { return nil }
        return db.collection("users").document(uid).collection("tasks")
    }

    func startListening(uid: String) {
        stopListening()
        self.uid = uid

        listener = tasksRef?
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.tasks = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: TodoTask.self)
                } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        uid = nil
        tasks = []
    }

    func addTask(title: String, description: String) {
        guard let tasksRef else { return }
        let task = TodoTask(title: title, description: description)
        do {
            _ = try tasksRef.addDocument(from: task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTask(_ task: TodoTask) {
        guard let tasksRef, let id = task.id else { return }
        do {
            try tasksRef.document(id).setData(from: task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleDone(_ task: TodoTask) {
        var updated = task
        updated.isDone.toggle()
        updateTask(updated)
    }

    func deleteTask(_ task: TodoTask) {
        guard let tasksRef, let id = task.id else { return }
        tasksRef.document(id).delete { [weak self] error in
            if let error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func deleteTasks(at offsets: IndexSet) {
        offsets.map { tasks[$0] }.forEach(deleteTask)
    }
}
