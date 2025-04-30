import Foundation

/// Translates text using the Google Translate API.
/// - Parameters:
///   - text: The original text to translate.
///   - targetLanguage: The ISO code of the target language (e.g. "es", "fr").
/// - Returns: The translated text or the original if translation fails.
func TranslationTool(text: String, targetLanguage: String) async -> String {
    let apiKey = googleTranslateAPIKey
    guard !apiKey.isEmpty else {
        print("❌ Missing Google Translate API key")
        return text
    }

    guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)") else {
        print("❌ Invalid URL")
        return text
    }

    let parameters: [String: Any] = [
        "q": text,
        "target": targetLanguage,
        "format": "text"
    ]

    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
        print("❌ Failed to encode request body")
        return text
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = httpBody

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("🌐 Response: \(json)")
            if let dataObj = json["data"] as? [String: Any],
               let translations = dataObj["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {
                return translatedText
            }
        }
        print("❌ Could not parse translation response")
        return text
    } catch {
        print("❌ Network/translation error: \(error.localizedDescription)")
        return text
    }
}
