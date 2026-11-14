import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published var isLoading = false

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async {
        infoMessage = nil
        guard validate(email: email, password: password) else { return }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String, confirmPassword: String) async {
        guard validate(email: email, password: password) else { return }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func resetPassword(email: String) async {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        infoMessage = nil
        guard !trimmed.isEmpty else {
            errorMessage = "Enter your email first."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: trimmed)
            infoMessage = "Password reset email sent to \(trimmed)."
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validate(email: String, password: String) -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty {
            errorMessage = "Email and password are required."
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }
}
