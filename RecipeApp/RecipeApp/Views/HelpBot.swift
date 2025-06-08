import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
}

let openAIApiKey = "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"

struct HelpBot: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var prompt: String = ""
    @State private var messages: [Message] = []
    @State private var isLoading: Bool = false

    // UI strings
    @State private var placeholderText: String = "Talk to Orion"
    @State private var sendButtonText: String = "Send"
    @State private var loadingText: String = "Loading..."

    // Scroll to latest message
    @Namespace private var bottomID

    // Initial message to translate
    private let initialMessageKey = "Hi! I’m Orion. How can I help you out?"

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color("ColorBlue")
                    .ignoresSafeArea(edges: .top)
                VStack {
                    HStack(spacing: 16) {
                        Spacer(minLength: 0)
                        Text("Orion")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color("ColorWhite"))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Image("Orion")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 4) // Nudges the row up
                    Spacer() // Pushes content up
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 80)
            .shadow(radius: 2)

            // Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .padding(.horizontal)
                        }
                        // Invisible anchor for auto-scroll
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.vertical, 16)
                }
                .background(Color("ColorLightGray"))
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
            }

            // Input Area
            HStack(spacing: 12) {
                TextField(placeholderText, text: $prompt)
                    .foregroundColor(Color("ColorBlack"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color("ColorWhite"))
                    .cornerRadius(20)
                    .autocorrectionDisabled(true)
                    .disabled(isLoading)

                Button(action: {
                    if prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return }
                    let userMsg = Message(role: "user", content: prompt)
                    messages.append(userMsg)
                    isLoading = true
                    let userPrompt = prompt
                    prompt = ""
                    Task {
                        let response = await sendMessage(prompt: userPrompt)
                        messages.append(Message(role: "assistant", content: response))
                        isLoading = false
                    }
                }) {
                    Text(sendButtonText)
                        .fontWeight(.bold)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color("ColorBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .disabled(isLoading)
            }
            .padding()
            .background(Color("ColorLightGray").shadow(radius: 1))

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView(loadingText).padding(.vertical, 6)
                    Spacer()
                }
                .background(Color("ColorLightGray"))
            }
        }
        .background(Color("ColorDarkGray").ignoresSafeArea())
        .task {
            // Translate all UI strings and the initial message on appear
            async let translatedPlaceholder = TranslationTool(text: "Talk to Orion", targetLanguage: appSettings.selectedLanguage)
            async let translatedSend = TranslationTool(text: "Send", targetLanguage: appSettings.selectedLanguage)
            async let translatedLoading = TranslationTool(text: "Loading...", targetLanguage: appSettings.selectedLanguage)
            async let translatedInitial = TranslationTool(text: initialMessageKey, targetLanguage: appSettings.selectedLanguage)

            placeholderText = await translatedPlaceholder
            sendButtonText = await translatedSend
            loadingText = await translatedLoading

            if messages.isEmpty {
                let translatedMessage = await translatedInitial
                messages = [Message(role: "assistant", content: translatedMessage)]
            }
        }
        .onChange(of: appSettings.selectedLanguage) { newLang in
            Task {
                async let translatedPlaceholder = TranslationTool(text: "Talk to Orion", targetLanguage: newLang)
                async let translatedSend = TranslationTool(text: "Send", targetLanguage: newLang)
                async let translatedLoading = TranslationTool(text: "Loading...", targetLanguage: newLang)
                async let translatedInitial = TranslationTool(text: initialMessageKey, targetLanguage: newLang)

                placeholderText = await translatedPlaceholder
                sendButtonText = await translatedSend
                loadingText = await translatedLoading

                // If first message is the assistant's initial message, update its translation
                if !messages.isEmpty && messages[0].role == "assistant" {
                    let translatedMessage = await translatedInitial
                    messages[0] = Message(role: "assistant", content: translatedMessage)
                }
            }
        }
    }

    // MARK: - Networking code
    func sendMessage(prompt: String) async -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return "Invalid API URL."
        }
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(openAIApiKey)"
        ]
        let systemPrompt = """
        You are a friendly human assistant helping Canadian immigrants named Orion. Only answer relevant immigration or government questions and say you can't help otherwise. Always respond in the language of the prompt.
        """

        // Keep only the last 10 messages (5 exchanges)
        let trimmedMessages = messages.suffix(10)
        let chatHistory: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ] + trimmedMessages.map { ["role": $0.role, "content": $0.content] } + [
            ["role": "user", "content": prompt]
        ]

        let body: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": chatHistory,
            "max_tokens": 500,
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
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return "No response found in OpenAI reply."
            }
        } catch {
            print("OpenAI chat error: \(error.localizedDescription)")
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Chat Bubble View
struct ChatBubble: View {
    let message: Message

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer() }
            if isUser {
                Text(message.content)
                    .padding(14)
                    .foregroundColor(Color("ColorWhite"))
                    .background(Color("ColorBlue"))
                    .cornerRadius(20)
                    .frame(maxWidth: 300, alignment: .trailing)
                    .shadow(radius: 1)
            } else {
                // Render assistant messages with Markdown support
                Text(.init(message.content))
                    .padding(14)
                    .foregroundColor(Color("ColorBlack"))
                    .background(Color("ColorLightGray"))
                    .cornerRadius(20)
                    .frame(maxWidth: 300, alignment: .leading)
                    .shadow(radius: 1)
            }
            if !isUser { Spacer() }
        }
    }
}

// Preview
#Preview {
    HelpBot()
        .environmentObject(AppSettings())
}
