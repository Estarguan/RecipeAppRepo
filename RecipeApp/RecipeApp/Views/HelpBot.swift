import SwiftUI
import OpenAISwift

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

    let openAI = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(
        apiKey: "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"))

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
            placeholderText = await TranslationTool(text: "Enter your request", targetLanguage: appSettings.selectedLanguage)
            sendButtonText = await TranslationTool(text: "Send", targetLanguage: appSettings.selectedLanguage)
            defaultResponseText = await TranslationTool(text: "Response will appear here", targetLanguage: appSettings.selectedLanguage)
            loadingText = await TranslationTool(text: "Loading...", targetLanguage: appSettings.selectedLanguage)
        }
    }

    func sendMessage() async {
        do {
            let result = try await openAI.sendCompletion(
                with: prompt,
                model: .gpt3(.davinci),
                maxTokens: 16,
                temperature: 1
            )
            if let text = result.choices?.first?.text {
                response = text.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                response = "No response found."
            }
        } catch {
            response = "An error occurred."
        }
    }
}

#Preview {
    HelpBot()
        .environmentObject(AppSettings())
}
