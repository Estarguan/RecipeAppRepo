//
//  RegisterView.swift
//  RecipeApp
//
//  Created by Estar Guan on 2025-04-05.
//

import SwiftUI

struct RegisterView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
            }
            
            Section {
                Button("Sign up") {
                    signUpButtonTapped()
                }
                if isLoading {
                    ProgressView()
                }
            }
            
            if let result {
                            Section {
                                switch result {
                                case .success:
                                    Text("Account created successfully! 🎉")
                                case .failure(let error):
                                    Text(error.localizedDescription).foregroundStyle(.red)
                                }
                            }
                        }
        }
    }
    
    func signUpButtonTapped(){
        Task{
            isLoading = true
            defer { isLoading = false }
            do {
                try await supabase.auth.signUp(email: email, password: password)
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    RegisterView()
}
