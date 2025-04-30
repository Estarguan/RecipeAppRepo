import SwiftUI

struct MainView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var isAuthenticated = false

    // Translated text states
    @State private var changeLanguageText: String = "Change Language"
    @State private var loginText: String = "Login"
    @State private var registerText: String = "Register"
    @State private var signOutText: String = "Sign out"

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: AuthenticationView()) {
                        Text(changeLanguageText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .padding(.leading)
                    }

                    Spacer()

                    if isAuthenticated {
                        Button(role: .destructive) {
                            Task {
                                try? await supabase.auth.signOut()
                                isAuthenticated = false
                            }
                        } label: {
                            Text(signOutText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .truncationMode(.tail)
                        }
                    } else {
                        HStack {
                            NavigationLink(destination: LoginView()) {
                                Text(loginText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .truncationMode(.tail)
                            }

                            NavigationLink(destination: RegisterView()) {
                                Text(registerText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .padding(.trailing)
                .frame(width: 400, height: 60)

                // Embedded menu view
                MenuView()
            }
            .task {
                for await state in supabase.auth.authStateChanges {
                    if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                        isAuthenticated = state.session != nil
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            // Load translations on view appear
            changeLanguageText = await TranslationTool(text: "Change Language", targetLanguage: appSettings.selectedLanguage)
            loginText = await TranslationTool(text: "Login", targetLanguage: appSettings.selectedLanguage)
            registerText = await TranslationTool(text: "Register", targetLanguage: appSettings.selectedLanguage)
            signOutText = await TranslationTool(text: "Sign out", targetLanguage: appSettings.selectedLanguage)
        }
    }
}

class AppStore: ObservableObject {
    @Published var isAuthenitcated: Bool = false
}

#Preview {
    MainView()
        .environmentObject(AppSettings())
        .environmentObject(AppStore())
}
