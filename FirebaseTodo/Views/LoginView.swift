import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checklist")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 8)

                Text("Todo List")
                    .font(.largeTitle.bold())

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .textContentType(.password)
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
                    Task { await authVM.signIn(email: email, password: password) }
                } label: {
                    if authVM.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Log In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(authVM.isLoading)

                NavigationLink("Don't have an account? Sign up") {
                    SignUpView()
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
            .padding(.top, 40)
            .onAppear { authVM.errorMessage = nil }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
