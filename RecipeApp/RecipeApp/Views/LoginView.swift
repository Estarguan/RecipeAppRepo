import SwiftUI

import Supabase



struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    @State var signedIn = false
    var body: some View {

        NavigationStack {
            ZStack {
                // Background color
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)  // Ensure the background stretches across the entire screen
                VStack {
                    // Top section with logo and Canadian flag
                    HStack {
                        Image("PolarisSymbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Logo size
                            .padding(.top, 10)
                        Spacer()
                        Image("CanadianFlag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 30) // Flag size
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 40)

                    // Title with large, bold "Login" text
                    Text("Login")
                        .fontWeight(.bold)
                        .font(.system(size: 70, weight: .heavy))
                        .foregroundColor(Color("ColorBlue"))
                        .padding(.top, 40)
                    Spacer()

                    // Email input field with gradient background
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                        .foregroundColor(Color("ColorBlack"))
                        .padding(.horizontal, 30)
                        .autocapitalization(.none)

                    // Password input field with gradient background

                    SecureField("Enter your password", text: $password)

                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]), startPoint: .leading, endPoint: .trailing))

                        .cornerRadius(25)
                        .foregroundColor(Color("ColorWhite"))
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .autocapitalization(.none)

                    Spacer()

                    // Sign In button with gradient background

                    
                    Button("Sign in") {
                        signInButtonTapped()
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("ColorBlack"))
                    .frame(width: 250, height: 50)
                    .background(LinearGradient(gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.top, 20)
                    if isLoading {
                        ProgressView()
                    }
                    NavigationLink(
                           destination: MainView(),
                           isActive: $signedIn
                       ) {
                           EmptyView() // Invisible link that is activated by isActive
                       }
                

                if let result {
                    
                    switch result {
                    case .success:
                        Text("Successfully signed in.")
                    case .failure(let error):
                        Text(error.localizedDescription).foregroundStyle(.red)
                    }
                }
                


                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                // You can add any additional setup or logic when the view appears
            }
        }
    }



    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signIn(email: email, password: password)
                result = .success(())
                signedIn = true
            } catch {
                result = .failure(error)
            }
        }
    }
}



#Preview {
    LoginView()
}
