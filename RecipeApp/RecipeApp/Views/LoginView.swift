import SwiftUI
import Supabase

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            Section {
                Button("Sign in") {
                    signInButtonTapped()
                }
                if isLoading {
                    ProgressView()
                }
            }

            if let result {
                Section {
                    switch result {
                    case .success:
                        Text("Successfully signed in.")
                    case .failure(let error):
                        Text(error.localizedDescription).foregroundStyle(.red)
                    }
                }
            }
        }
    }

    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signIn(email: email, password: password)
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    LoginView()
}
