import SwiftUI
import OpenAISwift
struct HelpBot: View {
    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false  // Track loading state

 let openAI = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: "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"))

    var body: some View {
        Group {
            VStack {
                Text(response.isEmpty ? "Response will appear here" : response)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 600)
                    .background(Color("ColorLightGray"))
                    .cornerRadius(25)

                Spacer()
                
                ZStack {
                    TextField("Enter your request", text: $prompt)
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
                            Text("Send")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color("ColorBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .padding(.trailing, 20)
                    }
                }

                if isLoading {
                    ProgressView("Loading...").padding()
                }
            }
        }
        .padding()
    }
    func sendMessage() async {
        do {
            let result = try await openAI.sendCompletion(
                with: prompt,
                model: .gpt3(.davinci), // optional `OpenAIModelType`
                maxTokens: 16,          // optional `Int?`
                temperature: 1          // optional `Double?`
            )
            print("DEBUG - Full result: \(result)") // Debug output

            if let text = result.choices?.first?.text {
                response = text.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                response = "No response found."
            }
        } catch {
            // ...
        }
    }
}

#Preview {
    HelpBot()
}
