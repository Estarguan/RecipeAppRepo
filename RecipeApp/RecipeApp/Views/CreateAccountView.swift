import SwiftUI
import OpenAISwift

struct CreateAccountView: View {
    @EnvironmentObject var appSettings: AppSettings

    // Translated text states
    @State private var titleText: String = "Create an Account"
    @State private var registerText: String = "Register"
    @State private var loginText: String = "Login"

    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Logo + Flag
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
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(Color("ColorBlue"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .truncationMode(.tail)
                        .padding(.top, 20)

                    Spacer()

                    // Images
                    HStack(spacing: 20) {
                        Image("Phone")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 340)

                        Image("Person")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .padding(.trailing, 10)
                    }
                    .padding(.top, 30)

                    Spacer()

                    // Buttons over Paper background
                    ZStack(alignment: .center) {
                        Image("PaperThing")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 260)
                            .clipped()

                        VStack {
                            NavigationLink(destination: RegisterView()) {
                                Text(registerText)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("ColorWhite"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .truncationMode(.tail)
                                    .frame(width: 250, height: 50)
                                    .background(Color("ColorBlue"))
                                    .cornerRadius(10)
                                    .padding(.bottom, 20)
                            }

                            NavigationLink(destination: LoginView()) {
                                Text(loginText)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("ColorBlue"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .truncationMode(.tail)
                                    .frame(width: 250, height: 50)
                                    .background(Color("ColorWhite"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            // Load translated text
            titleText = await TranslationTool(text: "Create an Account", targetLanguage: appSettings.selectedLanguage)
            registerText = await TranslationTool(text: "Register", targetLanguage: appSettings.selectedLanguage)
            loginText = await TranslationTool(text: "Login", targetLanguage: appSettings.selectedLanguage)
        }
    }
}

#Preview {
    CreateAccountView()
        .environmentObject(AppSettings())
}
