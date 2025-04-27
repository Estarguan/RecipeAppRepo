//import SwiftUI
//import OpenAISwift
//
//// OpenAI API response structure
//struct OpenAIResponse: Codable {
//    let choices: [Choice]
//    
//    struct Choice: Codable {
//        let text: String
//    }
//}
//
//// OpenRouter API response structure
//struct OpenRouterResponse: Codable {
//    let choices: [Choice]
//    
//    struct Choice: Codable {
//        let message: Message
//        
//        struct Message: Codable {
//            let role: String
//            let content: String
//        }
//    }
//}
//
//// APICaller for both OpenAI and OpenRouter APIs
//final class APICaller {
//    static let shared = APICaller()
//    
//    private var client: OpenAISwift? // For OpenAI
//    private let apiKey = "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" // Replace with your OpenAI or OpenRouter API key
//    
//    // For OpenRouter
//    private let apiEndpoint = "https://openrouter.ai/api/v1/chat/completions"
//
//    private init() {}
//
//    // Method to set up OpenAI client
//    func setupOpenAI(apiKey: String) {
//        let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: apiKey)
//        client = OpenAISwift(config: config)
//    }
//
//    // Method to handle OpenAI API requests
//    func getOpenAIResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
//        client?.sendCompletion(with: input) { result in
//            switch result {
//            case .success(let model):
//                var output = ""
//                if let choices = model.choices, let firstChoice = choices.first {
//                    output = firstChoice.text ?? "No response text available."
//                }
//                completion(.success(output))
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // Method to handle OpenRouter API requests
//    func getOpenRouterResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
//        let requestBody: [String: Any] = [
//            "model": "deepseek/deepseek-v3-base:free", // Replace with the model you want to use
//            "messages": [
//                ["role": "user", "content": input]
//            ]
//        ]
//        
//        guard let url = URL(string: apiEndpoint) else {
//            print("Invalid API endpoint URL.")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        
//        // Serialize the request body to JSON
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
//            print("Error serializing request body.")
//            return
//        }
//        request.httpBody = jsonData
//        
//        // Make the API request using URLSession
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//            
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    completion(.failure(NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
//                }
//                return
//            }
//            
//            // Decode the response
//            do {
//                let decodedResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
//                DispatchQueue.main.async {
//                    // Get the content of the first choice's message
//                    let outputText = decodedResponse.choices.first?.message.content ?? "No response text available."
//                    completion(.success(outputText))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response."])))
//                }
//            }
//        }.resume()
//    }
//}
//
//struct HelpBotView: View {
//    @State private var prompt: String = ""
//    @State private var response: String = ""
//    @State private var isLoading: Bool = false
//
//    private let client = APICaller.shared
//
//    // Set up OpenAI in the init method
//    init() {
//        APICaller.shared.setupOpenAI(apiKey: "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")  // Replace with your OpenAI API key
//    }
//
//    var body: some View {
//        VStack {
//            Text("Chat with OpenAI or OpenRouter")
//                .font(.largeTitle)
//                .bold()
//                .padding()
//
//            TextField("Enter your request here", text: $prompt)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            Button(action: {
//                isLoading = true
//                // Choose whether you want to use OpenAI or OpenRouter
//                client.getOpenAIResponse(input: prompt) { result in
//                    DispatchQueue.main.async {
//                        isLoading = false
//                        switch result {
//                        case .success(let text):
//                            response = text
//                        case .failure(let error):
//                            response = "Error: \(error.localizedDescription)"
//                        }
//                    }
//                }
//            }) {
//                Text("Send")
//                    .fontWeight(.bold)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding()
//
//            if isLoading {
//                ProgressView("Loading...").padding()
//            }
//
//            Text(response)
//                .padding()
//                .multilineTextAlignment(.center)
//        }
//        .padding()
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            HelpBotView()
//        }
//    }
//}
//
//@main
//struct OpenAIApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
