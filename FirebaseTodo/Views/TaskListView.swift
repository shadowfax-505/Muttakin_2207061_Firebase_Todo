import SwiftUI

struct TaskListView: View {
    let uid: String
    let email: String

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var taskVM = TaskViewModel()

    @State private var showAddSheet = false
    @State private var editingTask: TodoTask?
    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if taskVM.tasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("No tasks yet")
                            .font(.headline)
                        Text("Tap + to add your first task.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(taskVM.tasks) { task in
                            TaskRow(task: task) {
                                taskVM.toggleDone(task)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingTask = task }
                        }
                        .onDelete(perform: taskVM.deleteTasks)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Log Out") {
                        showLogoutConfirm = true
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                TaskFormView { title, description in
                    taskVM.addTask(title: title, description: description)
                }
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(task: task) { title, description in
                    var updated = task
                    updated.title = title
                    updated.description = description
                    taskVM.updateTask(updated)
                }
            }
            .confirmationDialog("Log out of \(email)?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    taskVM.stopListening()
                    authVM.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Error", isPresented: Binding(
                get: { taskVM.errorMessage != nil },
                set: { if !$0 { taskVM.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(taskVM.errorMessage ?? "")
            }
        }
        .onAppear { taskVM.startListening(uid: uid) }
        .onDisappear { taskVM.stopListening() }
    }
}

struct TaskRow: View {
    let task: TodoTask
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isDone ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isDone)
                    .foregroundColor(task.isDone ? .secondary : .primary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text(task.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
