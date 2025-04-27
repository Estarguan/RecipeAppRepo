//import SwiftUI
//
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
//final class APICaller {
//    static let shared = APICaller()
//
//    private init() {}
//
//    // API Key for OpenRouter authorization
//    private let apiKey = "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"
//    private let apiEndpoint = "https://openrouter.ai/api/v1/chat/completions"
//    
//    // Function to send the prompt to OpenRouter's API and fetch the response
//    func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
//        print("Start...")
//
//        guard !input.isEmpty else {
//            print("User input is empty.")
//            return
//        }
//        
//        // Prepare the request body
//        let requestBody: [String: Any] = [
//            "model": "deepseek/deepseek-v3-base:free",  // Replace with the model you want to use
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
//        request.addValue("<YOUR_SITE_URL>", forHTTPHeaderField: "HTTP-Referer") // Optional. Replace with your site URL
//        request.addValue("<YOUR_SITE_NAME>", forHTTPHeaderField: "X-Title") // Optional. Replace with your site name
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
//            // Print raw response data for debugging
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw response: \(jsonString)")
//            }
//            
//            // Decode the response
//            do {
//                let decodedResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
//                DispatchQueue.main.async {
//                    // Get the content of the first choice's message
//                    let outputText = decodedResponse.choices.first?.message.content ?? "No response from API."
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
//struct Test: View {
//    @State private var prompt: String = ""
//    @State private var response: String = ""
//    @State private var isLoading: Bool = false  // Track loading state
//
//    private let client = APICaller.shared
//
//    var body: some View {
//        VStack {
//            Text("Chat with AI")
//                .font(.largeTitle)
//                .bold()
//                .padding()
//
//            TextField("Enter your request here", text: $prompt)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            Button(action: {
//                // Show loading indicator while making the API request
//                isLoading = true
//                // Call the API when the button is pressed
//                client.getResponse(input: prompt) { result in
//                    DispatchQueue.main.async {
//                        isLoading = false // Hide loading indicator when done
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
//            // Show a loading spinner when the API request is being made
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
//#Preview{
//    Test()
//}
