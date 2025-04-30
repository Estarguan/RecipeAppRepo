import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    @State var signedIn = false

    // Translated text
    @State private var titleText: String = "Login"
    @State private var emailPlaceholder: String = "Enter your email"
    @State private var passwordPlaceholder: String = "Enter your password"
    @State private var signInButtonText: String = "Sign in"
    @State private var successMessage: String = "Successfully signed in."

    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Top header
                    HStack {
                        Image("PolarisSymbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.top, 10)
                        Spacer()
                        Image("CanadianFlag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 30)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 40)

                    // Title
                    Text(titleText)
                        .font(.system(size: 70, weight: .heavy))
                        .foregroundColor(Color("ColorBlue"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .truncationMode(.tail)
                        .padding(.top, 40)

                    Spacer()

                    // Email field
                    TextField(emailPlaceholder, text: $email)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                            startPoint: .leading,
                            endPoint: .trailing))
                        .cornerRadius(25)
                        .foregroundColor(Color("ColorBlack"))
                        .padding(.horizontal, 30)
                        .autocapitalization(.none)

                    // Password field
                    SecureField(passwordPlaceholder, text: $password)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                            startPoint: .leading,
                            endPoint: .trailing))
                        .cornerRadius(25)
                        .foregroundColor(Color("ColorWhite"))
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .autocapitalization(.none)

                    Spacer()

                    // Sign In Button
                    Button(action: {
                        signInButtonTapped()
                    }) {
                        Text(signInButtonText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorBlack"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .frame(width: 250, height: 50)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                                startPoint: .leading,
                                endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    if isLoading {
                        ProgressView()
                    }

                    // Navigation to main view after successful sign-in
                    NavigationLink(destination: MainView(), isActive: $signedIn) {
                        EmptyView()
                    }

                    // Result messages
                    if let result {
                        switch result {
                        case .success:
                            Text(successMessage)
                        case .failure(let error):
                            Text(error.localizedDescription).foregroundStyle(.red)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            titleText = await TranslationTool(text: "Login", targetLanguage: appSettings.selectedLanguage)
            emailPlaceholder = await TranslationTool(text: "Enter your email", targetLanguage: appSettings.selectedLanguage)
            passwordPlaceholder = await TranslationTool(text: "Enter your password", targetLanguage: appSettings.selectedLanguage)
            signInButtonText = await TranslationTool(text: "Sign in", targetLanguage: appSettings.selectedLanguage)
            successMessage = await TranslationTool(text: "Successfully signed in.", targetLanguage: appSettings.selectedLanguage)
        }
    }

    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signIn(email: email, password: password)
                result = .success(())
                signedIn = true
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppSettings())
}
