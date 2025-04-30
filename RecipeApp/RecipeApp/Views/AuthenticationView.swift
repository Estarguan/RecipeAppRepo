import SwiftUI
import OpenAISwift
import Translation

struct AuthenticationView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var language = "en"
    @State private var isLanguageSelected = false

    // Translated UI strings
    @State private var subtitleText: String = "The #1 Form Filling Buddy!"
    @State private var selectLanguageText: String = "Select your language"
    @State private var enterButtonText: String = "Enter"

    // Supported languages by Apple Translation Framework (as of iOS 17.4)
    let supportedLanguages: [String] = [
        "en", "es", "fr", "de", "it", "pt", "zh", "ja", "ko", "ru", "ar", "hi"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorWhite")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Top flag
                    HStack {
                        Spacer()
                        Image("CanadianFlag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 50)
                            .padding(.top, 40)
                    }

                    // Logo
                    Image("PolarisLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 250)
                        .padding(.top, 50)
                        .padding(.bottom, 50)

                    Spacer()

                    // Subtitle
                    Text(subtitleText)
                        .font(.custom("SFProText", size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(Color("ColorBlue"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .truncationMode(.tail)
                        .padding(.bottom, 30)

                    // Language Picker
                    VStack {
                        Text(selectLanguageText)
                            .font(.title2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .padding(.bottom, 10)

                        Picker("Select a language", selection: $language) {
                            ForEach(supportedLanguages, id: \.self) { languageCode in
                                let locale = Locale(identifier: languageCode)
                                Text(locale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode)
                                    .font(.system(size: 18))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(Color("ColorBlack"))
                        .frame(width: 250)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("ColorBlack"), lineWidth: 2)
                                .background(Color("ColorLightGray"))
                        )
                    }
                    .padding(.horizontal, 20)

                    // Enter Button
                    Button(action: {
                        appSettings.selectedLanguage = language
                        UserDefaults.standard.set(language, forKey: "selectedLanguage")
                        isLanguageSelected = true
                    }) {
                        Text(enterButtonText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorWhite"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .frame(width: 250, height: 50)
                            .background(isLanguageSelected ? Color("ColorLightGray") : Color("ColorBlue"))
                            .cornerRadius(10)
                            .padding(.bottom, 30)
                            .animation(.easeInOut, value: isLanguageSelected)
                    }
                    .disabled(language.isEmpty)

                    Spacer()
                        .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)

                // Navigation
                NavigationLink("", destination: MainView())
                    .isDetailLink(false)
                    .navigationDestination(isPresented: $isLanguageSelected) {
                        MenuView()
                    }
            }
        }
        .task {
            subtitleText = await TranslationTool(text: "The #1 Form Filling Buddy!", targetLanguage: appSettings.selectedLanguage)
            selectLanguageText = await TranslationTool(text: "Select your language", targetLanguage: appSettings.selectedLanguage)
            enterButtonText = await TranslationTool(text: "Enter", targetLanguage: appSettings.selectedLanguage)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AppSettings())
}
