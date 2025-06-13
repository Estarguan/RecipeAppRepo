import SwiftUI

struct Profile2: Decodable {
    let full_name: String?
}

struct MenuView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var isAuthenticated = false
    @State private var userFullName: String? = nil   // <--- Store user name here

    // Translated text states
    @State private var greetingStart: String = "Hello, "
    @State private var signInText: String = "Sign in?"
    @State private var addFormText: String = "+ Add Form"
    @State private var extraHelpText: String = "Extra Help"
    @State private var changeLanguageText: String = "Change Language"
    @State private var guestText: String = "Guest" // Store the translated "Guest"

    var displayedName: String {
        if isAuthenticated, let userFullName, !userFullName.isEmpty {
            return userFullName
        } else {
            return guestText
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                // Top bar with Change Language
                VStack {
                    HStack {
                        NavigationLink(destination: AuthenticationView()) {
                            Text(changeLanguageText)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                                .padding(.top, 60)
                        }

                        Spacer()

                        let locale = Locale(identifier: appSettings.selectedLanguage)
                        Text(locale.localizedString(forLanguageCode: appSettings.selectedLanguage)?
                            .capitalized ?? appSettings.selectedLanguage)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                            .padding(.top, 60)
                    }
                    Spacer()
                }

                // Top circular design
                ZStack {
                    Circle()
                        .fill(Color("ColorBlack"))
                        .frame(width: 500, height: 500)
                        .offset(y: -245)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 170, height: 170)
                        .offset(y: -190)

                    VStack {
                        Image("PolarisSymbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .offset(y: -152)

                        Text("Polaris")
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(Color("ColorLightGray"))
                            .offset(y: -130)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                    }
                }
                .padding(.top, 40)

                // Greeting Bar
                HStack {
                    Text(greetingStart)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("ColorWhite"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .truncationMode(.tail)
                        .padding(.leading, 20)

                    Text(displayedName) // <-- Use computed var
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ColorWhite"))

                    Text(":)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("ColorWhite"))
                        .padding(.leading, 5)

                    Spacer()

                    if !isAuthenticated {
                        NavigationLink(destination: CreateAccountView()) {
                            Text(signInText)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .truncationMode(.tail)
                                .padding(8)
                                .background(Color("ColorBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.trailing, 20)
                        }
                    }
                }
                .frame(maxWidth: 380, minHeight: 50)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color("ColorBlack")))
                .offset(y: 320)

                // Action Buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: FormView()) {
                        Text(addFormText)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("ColorBlack"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .truncationMode(.tail)
                            .padding()
                            .frame(maxWidth: 360, minHeight: 80)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorDarkGray")))
                    }

                    NavigationLink(destination: HelpBot()) {
                        Text(extraHelpText)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("ColorBlack"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .truncationMode(.tail)
                            .padding()
                            .frame(maxWidth: 360, minHeight: 80)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorDarkGray")))
                    }
                }
                .padding(.horizontal, 30)
                .offset(y: 400)

                // Bottom Navigation Bar
                NavigationBar(selectedTab: .home)
                    .offset(y: 630)
            }
        }
        .task {
            // Auth state handling
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                    if isAuthenticated, let user = state.session?.user {
                        await fetchUserName(for: user.id)
                    } else {
                        await MainActor.run { userFullName = nil }
                    }
                }
            }
        }
        .task {
            // Translate only UI text, not the user's name!
            greetingStart = await TranslationTool(text: "Hello, ", targetLanguage: appSettings.selectedLanguage)
            signInText = await TranslationTool(text: "Sign in?", targetLanguage: appSettings.selectedLanguage)
            addFormText = await TranslationTool(text: "+ Add Form", targetLanguage: appSettings.selectedLanguage)
            extraHelpText = await TranslationTool(text: "Extra Help", targetLanguage: appSettings.selectedLanguage)
            changeLanguageText = await TranslationTool(text: "Change Language", targetLanguage: appSettings.selectedLanguage)
            guestText = await TranslationTool(text: "Guest", targetLanguage: appSettings.selectedLanguage)
        }
        .onChange(of: appSettings.selectedLanguage) { _ in
            // When language changes, update translations, but do not overwrite user's name!
            Task {
                greetingStart = await TranslationTool(text: "Hello, ", targetLanguage: appSettings.selectedLanguage)
                signInText = await TranslationTool(text: "Sign in?", targetLanguage: appSettings.selectedLanguage)
                addFormText = await TranslationTool(text: "+ Add Form", targetLanguage: appSettings.selectedLanguage)
                extraHelpText = await TranslationTool(text: "Extra Help", targetLanguage: appSettings.selectedLanguage)
                changeLanguageText = await TranslationTool(text: "Change Language", targetLanguage: appSettings.selectedLanguage)
                guestText = await TranslationTool(text: "Guest", targetLanguage: appSettings.selectedLanguage)
            }
        }
    }

    // Fetch user full name from Supabase
    func fetchUserName(for userId: UUID) async {
        do {
            let response = try await supabase
                .from("profiles")
                .select("full_name")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()

            let data = response.data

            let profile = try JSONDecoder().decode(Profile2.self, from: data)
            let fullName = profile.full_name ?? ""

            await MainActor.run {
                self.userFullName = fullName
            }
        } catch {
            await MainActor.run {
                self.userFullName = nil
            }
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppSettings())
}
