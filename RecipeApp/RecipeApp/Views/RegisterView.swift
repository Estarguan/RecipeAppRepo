import SwiftUI
import Supabase

struct RegisterView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    @State var signedUp = false

    // Placeholder text
    @State private var emailPlaceholder: String = "Enter your email"
    @State private var passwordPlaceholder: String = "Enter your password"

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color("ColorLightGray")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Top section with logo and Canadian flag
                    HStack {
                        Image("PolarisSymbol")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.top, 10)
                        Spacer()
                        Image("CanadianFlag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 30)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 40)

                    // Title
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .font(.system(size: 70, weight: .heavy))
                        .foregroundColor(Color("ColorBlue"))
                        .padding(.top, 40)

                    Spacer()

                    // Email input field
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text(emailPlaceholder)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .padding(.leading, 18)
                        }
                        TextField("", text: $email)
                            .padding()
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("ColorBlack"))
                            .autocapitalization(.none)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("ColorBlue"), lineWidth: 3)
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)

                    // Password input field
                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text(passwordPlaceholder)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .padding(.leading, 18)
                        }
                        SecureField("", text: $password)
                            .padding()
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("ColorBlack"))
                            .autocapitalization(.none)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("ColorBlue"), lineWidth: 3)
                    )
                    .frame(height: 60)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    Spacer()

                    // Sign Up button
                    Button(action: { signUpButtonTapped() }) {
                        Text("Sign Up")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorBlack"))
                            .frame(width: 250, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("ColorBlue"), Color("ColorWhite")]),
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    if isLoading {
                        ProgressView()
                    }

                    NavigationLink(
                        destination: MainView(),
                        isActive: $signedUp
                    ) {
                        EmptyView()
                    }

                    // Error message
                    if let result {
                        switch result {
                        case .success:
                            Text("Successfully signed up.")
                        case .failure(let error):
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }

    func signUpButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signUp(email: email, password: password)
                result = .success(())
                signedUp = true
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    RegisterView()
}
