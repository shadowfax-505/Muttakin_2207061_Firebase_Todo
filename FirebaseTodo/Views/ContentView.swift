import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        if let user = authVM.user {
            TaskListView(uid: user.uid, email: user.email ?? "")
        } else {
            LoginView()
        }
    }
}
