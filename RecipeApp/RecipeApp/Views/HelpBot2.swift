import SwiftUI

// The structure to handle the OpenAI API response
/*
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}
*/

/*
final class APICaller {
    static let shared = APICaller()
    
    private init() {}

    private let apiKey = "sk-proj-..."  // Replace with your OpenAI API key
    private let apiEndpoint = "https://api.openai.com/v1/responses"
    
    func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Start...")

        guard !input.isEmpty else {
            print("User input is empty.")
            return
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "prompt": input,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: apiEndpoint) else {
            print("Invalid API endpoint URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Error serializing request body.")
            return
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                DispatchQueue.main.async {
                    let outputText = decodedResponse.choices.first?.text ?? "No response from API."
                    completion(.success(outputText))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response."])))
                }
            }
        }.resume()
    }
}
*/

struct HelpBot2: View {
    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false  // Track loading state

    // private let client = APICaller.shared
    let formInstructions: [String: String] = [
            "Passport Renewal": """
            Step-by-step for Passport Renewal (U.S. - Form DS-82):
            1. Make sure you are eligible to renew (e.g., passport not more than 5 years expired).
            2. Complete Form DS-82 online or print and fill it manually.
            3. Include your most recent passport.
            4. Provide a new passport photo (2x2 inches, white background).
            5. Write a check or money order for the renewal fee payable to 'U.S. Department of State'.
            6. Mail everything to the address listed on the form based on your location and processing speed.
            """,
            
            "Driver License Renewal": """
            Step-by-step for Driver's License Renewal (General Steps):
            1. Check your state's DMV or service center website for eligibility to renew online.
            2. Gather required documents (old license, proof of address, ID).
            3. Complete the renewal application form (can often be done online).
            4. Pay the renewal fee via accepted payment method.
            5. If required, schedule and pass a vision test or take a new photo.
            6. Receive your new license by mail or pick it up at the center.
            """,
            
            "Health Card Renewal": """
            Step-by-step for Health Card Renewal (e.g., OHIP in Ontario):
            1. Verify if you're eligible to renew online or need to go in person.
            2. Gather two valid identity documents (e.g., driver's license, utility bill).
            3. Complete the renewal form (online or on paper).
            4. Take a new photo if required (usually every 10 years).
            5. Submit your documents and form either online or at a ServiceOntario center.
            6. Keep the temporary document until your new card arrives by mail.
            """
        ]
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
                            handleFormLookup(for: prompt)
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
    func handleFormLookup(for input: String) {
            switch input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "passport renewal":
                response = formInstructions["Passport Renewal"] ?? "Instructions not found."
            case "driver license renewal", "driver's license renewal":
                response = formInstructions["Driver License Renewal"] ?? "Instructions not found."
            case "health card renewal":
                response = formInstructions["Health Card Renewal"] ?? "Instructions not found."
            default:
                response = "Sorry, I don’t have steps for that form yet."
            }
        }
}

#Preview {
    HelpBot2()
}
