import SwiftUI
import OpenAISwift

struct AuthenticationView: View {
    @State var country = "CA"
    @State var language = "en"
    @State var isLanguageSelected = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color("ColorWhite")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    
                    // 3. Canadian Flag in top-right corner
                    HStack {
                        Spacer()
                        Image("CanadianFlag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 50) // Larger flag size
                            .padding(.top, 40)
                    }
                    
                    // 1. Logo (Polaris) - Larger size
                    Image("PolarisLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 250) // Increased size of the logo
                        .padding(.top, 50)
                        .padding(.bottom, 50)

                    Spacer()
                    
                    // 2. Subtitle under the logo

                    Text("The #1 Form Filling Buddy!")
                        .font(.custom("SFProText", size: 20)) // Using SF Pro Text for subtitle
                        .fontWeight(.regular)
                        .foregroundColor(Color("ColorBlue"))
                        .padding(.bottom, 30)
                    // 3. Language Selection (Centered and clean)
                    VStack {
                        Text("Select your language")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.bottom, 10)

                        Picker("Select a language", selection: $language) {
                            ForEach(NSLocale.isoLanguageCodes, id: \.self) { languageCode in
                                Text(Locale.current.localizedString(forLanguageCode: languageCode) ?? "")
                                    .font(.system(size: 18))
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Clean dropdown style
                        .tint(Color("ColorBlack"))
                        .frame(width: 250) // Adjust width to make it more centered
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("ColorBlack"), lineWidth: 2)
                            .background(Color("ColorLightGray")))
                    }
                    .padding(.horizontal, 20)
                    
                    // 4. Enter Button (Navigate to MainView)

                       Button(action: {

                           // Proceed to MainView when button is pressed

                           isLanguageSelected = true

                       }) {

                           Text("Enter")
                               .font(.title2)
                               .fontWeight(.bold)
                               .foregroundColor(Color("ColorWhite"))
                               .frame(width: 250, height: 50)
                               .background(isLanguageSelected ? Color("ColorLightGray") : Color("ColorBlue"))
                               .cornerRadius(10)
                               .padding(.bottom, 30)
                               .animation(.easeInOut, value: isLanguageSelected)

                       }
                       .disabled(language.isEmpty) // Disable the button if no language is selected
                       Spacer()
                           .padding(.bottom, 30)
                   }
                   .padding(.horizontal, 20)
                   // Use navigationDestination to navigate when the button is clicked
                   NavigationLink("", destination: MainView())
                       .isDetailLink(false)
                       .navigationDestination(isPresented: $isLanguageSelected) {
                           MenuView()
                       }

               }
        }
    }
}

class AppSettings: ObservableObject {
    @Published var selectedLanguage: String = "en"
}

#Preview {
    AuthenticationView()
        .environmentObject(AppSettings())
}
