import SwiftUI

enum TabSelection {
    case home, saved, help, profile
}

struct NavigationBar: View {
    @EnvironmentObject var appSettings: AppSettings

    var selectedTab: TabSelection

    // Translated tab labels
    @State private var homeText: String = "Home"
    @State private var savedText: String = "Saved"
    @State private var helpText: String = "Help"
    @State private var profileText: String = "Profile"

    var body: some View {
        HStack {
            // Home
            VStack {
                NavigationLink(destination: MenuView()) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 25))
                        .foregroundColor(selectedTab == .home ? Color("ColorBlack") : .white)
                        .padding(12)
                }
                Text(homeText)
                    .font(.footnote)
                    .foregroundColor(selectedTab == .home ? Color("ColorBlack") : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
            }

            Spacer()

            // Saved
            VStack {
                NavigationLink(destination: SavedView()) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 25))
                        .foregroundColor(selectedTab == .saved ? Color("ColorBlack") : .white)
                        .padding(12)
                }
                Text(savedText)
                    .font(.footnote)
                    .foregroundColor(selectedTab == .saved ? Color("ColorBlack") : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
            }

            Spacer()

            // Help
            VStack {
                NavigationLink(destination: HelpBot()) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 25))
                        .foregroundColor(selectedTab == .help ? Color("ColorBlack") : .white)
                        .padding(12)
                }
                Text(helpText)
                    .font(.footnote)
                    .foregroundColor(selectedTab == .help ? Color("ColorBlack") : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
            }

            Spacer()

            // Profile
            VStack {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 25))
                        .foregroundColor(selectedTab == .profile ? Color("ColorBlack") : .white)
                        .padding(12)
                }
                Text(profileText)
                    .font(.footnote)
                    .foregroundColor(selectedTab == .profile ? Color("ColorBlack") : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: 350)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorBlue")))
        .shadow(radius: 5)
        .task {
            homeText = await TranslationTool(text: "Home", targetLanguage: appSettings.selectedLanguage)
            savedText = await TranslationTool(text: "Saved", targetLanguage: appSettings.selectedLanguage)
            helpText = await TranslationTool(text: "Help", targetLanguage: appSettings.selectedLanguage)
            profileText = await TranslationTool(text: "Profile", targetLanguage: appSettings.selectedLanguage)
        }
    }
}
