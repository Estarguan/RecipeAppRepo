import SwiftUI
import OpenAISwift

// Optionally, if you store your API key in Info.plist or a global variable,
// you might have something like this in GlobalVariables.swift:
// let openAIApiKey: String = {
//     Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String ?? ""
// }()

let openAIApiKey = "Add api key here"

struct HelpBot: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false

    // Translated UI strings
    @State private var placeholderText: String = "Enter your request"
    @State private var sendButtonText: String = "Send"
    @State private var defaultResponseText: String = "Response will appear here"
    @State private var loadingText: String = "Loading..."

    var body: some View {
        Group {
            VStack {
                Text(response.isEmpty ? defaultResponseText : response)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 600)
                    .background(Color("ColorLightGray"))
                    .cornerRadius(25)

                Spacer()

                ZStack {
                    TextField(placeholderText, text: $prompt)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(Color("ColorLightGray"))
                        .cornerRadius(25)
                        .autocorrectionDisabled(true)

                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                isLoading = true
                                await sendMessage()
                                isLoading = false
                            }
                        }) {
                            Text(sendButtonText)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .truncationMode(.tail)
                                .padding()
                                .background(Color("ColorBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .padding(.trailing, 20)
                    }
                }

                if isLoading {
                    ProgressView(loadingText).padding()
                }
            }
        }
        .padding()
        .task {
            // Load translated UI strings based on selected language
            placeholderText = await TranslationTool(text: "Enter your request", targetLanguage: appSettings.selectedLanguage)
            sendButtonText = await TranslationTool(text: "Send", targetLanguage: appSettings.selectedLanguage)
            defaultResponseText = await TranslationTool(text: "Response will appear here", targetLanguage: appSettings.selectedLanguage)
            loadingText = await TranslationTool(text: "Loading...", targetLanguage: appSettings.selectedLanguage)
        }
    }

    // Use a direct URLSession call to access the chat completions endpoint for GPT-4 Turbo
    func sendMessage() async {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            response = "Invalid API URL."
            return
        }

        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(openAIApiKey)"
        ]

        let systemPrompt = """
        You are a friendly human assistant helping Canadian immigrants. Only answer relevant immigration or government questions and say you can't help otherwise. Always respond in the language of the prompt.
        """

        let body: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 350,
            "temperature": 0.7
        ]

        do {
            let requestData = try JSONSerialization.data(withJSONObject: body, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = requestData

            let (data, _) = try await URLSession.shared.data(for: request)

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let text = message["content"] as? String {
                response = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            } else {
                response = "No response found in OpenAI reply."
            }
        } catch {
            print("OpenAI chat error: \(error.localizedDescription)")
            response = "An error occurred: \(error.localizedDescription)"
        }
    }

}

#Preview {
    HelpBot()
        .environmentObject(AppSettings())
}
