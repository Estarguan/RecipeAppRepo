import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State var username = ""
    @State var fullName = ""
    @State var website = ""

    @State var isLoading = false

    // Translated text
    @State private var usernameLabel: String = "Username"
    @State private var fullNameLabel: String = "Full name"
    @State private var websiteLabel: String = "Website"
    @State private var updateButtonText: String = "Update profile"
    @State private var profileTitleText: String = "Profile"
    @State private var signOutText: String = "Sign out"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(usernameLabel, text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)

                    TextField(fullNameLabel, text: $fullName)
                        .textContentType(.name)

                    TextField(websiteLabel, text: $website)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Button(updateButtonText) {
                        updateProfileButtonTapped()
                    }
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)

                    if isLoading {
                        ProgressView()
                    }
                }
            }
            .navigationTitle(profileTitleText)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(signOutText, role: .destructive) {
                        Task {
                            try? await supabase.auth.signOut()
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .truncationMode(.tail)
                }
            }
        }
        .task {
            await loadTranslations()
        }
        .task {
            await getInitialProfile()
        }
    }

    func loadTranslations() async {
        usernameLabel = await TranslationTool(text: "Username", targetLanguage: appSettings.selectedLanguage)
        fullNameLabel = await TranslationTool(text: "Full name", targetLanguage: appSettings.selectedLanguage)
        websiteLabel = await TranslationTool(text: "Website", targetLanguage: appSettings.selectedLanguage)
        updateButtonText = await TranslationTool(text: "Update profile", targetLanguage: appSettings.selectedLanguage)
        profileTitleText = await TranslationTool(text: "Profile", targetLanguage: appSettings.selectedLanguage)
        signOutText = await TranslationTool(text: "Sign out", targetLanguage: appSettings.selectedLanguage)
    }

    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value

            self.username = profile.username ?? ""
            self.fullName = profile.fullName ?? ""
            self.website = profile.website ?? ""
        } catch {
            debugPrint(error)
        }
    }

    func updateProfileButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let currentUser = try await supabase.auth.session.user

                try await supabase
                    .from("profiles")
                    .update(
                        UpdateProfileParams(
                            username: username,
                            fullName: fullName,
                            website: website
                        )
                    )
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                debugPrint(error)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppSettings())
}
