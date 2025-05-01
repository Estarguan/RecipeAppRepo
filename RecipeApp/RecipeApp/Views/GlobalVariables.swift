import Foundation
import SwiftUI

// Access your Google Translate API key from Info.plist
let googleTranslateAPIKey: String = {
    Bundle.main.object(forInfoDictionaryKey: "GoogleTranslateAPIKey") as? String ?? ""
}()

// Shared app-wide settings for language, etc.
class AppSettings: ObservableObject {
    @Published var selectedLanguage: String = "en"
    
}

// Create a shared instance of AppSettings
let sharedAppSettings = AppSettings()
