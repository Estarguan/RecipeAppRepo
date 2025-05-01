import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var name: String = "Guest"
    @State private var isAuthenticated = false

    // Translated text states
    @State private var greetingStart: String = "Hello, "
    @State private var signInText: String = "Sign in?"
    @State private var addFormText: String = "+ Add Form"
    @State private var extraHelpText: String = "Extra Help"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                // Top-right language display
                VStack {
                    HStack {
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

                    Text(name)
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
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                }
            }
        }
        .task {
            greetingStart = await TranslationTool(text: "Hello, ", targetLanguage: appSettings.selectedLanguage)
            signInText = await TranslationTool(text: "Sign in?", targetLanguage: appSettings.selectedLanguage)
            addFormText = await TranslationTool(text: "+ Add Form", targetLanguage: appSettings.selectedLanguage)
            extraHelpText = await TranslationTool(text: "Extra Help", targetLanguage: appSettings.selectedLanguage)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppSettings())
}
