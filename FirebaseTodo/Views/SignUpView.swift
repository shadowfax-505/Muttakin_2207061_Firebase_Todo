import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle.bold())
                .padding(.bottom, 8)

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

            SecureField("Password (min 6 characters)", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

            if let error = authVM.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await authVM.signUp(email: email, password: password, confirmPassword: confirmPassword)
                }
            } label: {
                if authVM.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(authVM.isLoading)

            Spacer()
        }
        .padding()
        .padding(.top, 20)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { authVM.errorMessage = nil }
    }
}
