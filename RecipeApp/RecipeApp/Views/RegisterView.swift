import SwiftUI
import Supabase

struct RegisterView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    @State var signedUp = false

    // Translated text
    @State private var titleText: String = "Sign Up"
    @State private var emailPlaceholder: String = "Enter your email"
    @State private var passwordPlaceholder: String = "Enter your password"
    @State private var signUpButtonText: String = "Sign Up"

    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Top: Logo and flag
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
                        .fontWeight(.bold)
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
                            startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                        .foregroundColor(Color("ColorBlack"))
                        .frame(height: 60)
                        .padding(.horizontal, 30)
                        .autocapitalization(.none)

                    // Password field
                    SecureField(passwordPlaceholder, text: $password)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                            startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                        .foregroundColor(Color("ColorBlack"))
                        .frame(height: 60)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .autocapitalization(.none)

                    Spacer()

                    // Sign Up button
                    Button(action: {
                        signUpButtonTapped()
                    }) {
                        Text(signUpButtonText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorBlack"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .frame(width: 250, height: 50)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                                startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    if isLoading {
                        ProgressView()
                    }

                    // Navigation to main screen
                    NavigationLink(destination: MainView(), isActive: $signedUp) {
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            titleText = await TranslationTool(text: "Sign Up", targetLanguage: appSettings.selectedLanguage)
            emailPlaceholder = await TranslationTool(text: "Enter your email", targetLanguage: appSettings.selectedLanguage)
            passwordPlaceholder = await TranslationTool(text: "Enter your password", targetLanguage: appSettings.selectedLanguage)
            signUpButtonText = await TranslationTool(text: "Sign Up", targetLanguage: appSettings.selectedLanguage)
        }
    }

    func signUpButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signUp(email: email, password: password)
                result = .success(())
                signedUp = true
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AppSettings())
}
