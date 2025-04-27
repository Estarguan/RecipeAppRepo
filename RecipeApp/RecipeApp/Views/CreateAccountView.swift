import SwiftUI

import OpenAISwift



struct CreateAccountView: View {
    @State var language = "en"
    @State var isLanguageSelected = false

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
                    // Title with really bold text
                    Text("Create an Account")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(Color("ColorBlue"))
                        .padding(.top, 20)
                    Spacer()
                    // Phone and Person images side by side with no space between
                    HStack(spacing: 20) { // Remove any space between the images
                        Image("Phone")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 340)
                        Image("Person")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .padding(.trailing, 10)

                    }
                    .padding(.top, 30)
                    Spacer()
                    // ZStack to overlay the buttons over the PaperThing
                    ZStack(alignment: .center) { // Ensures the buttons are centered
                        // PaperThing background image
                        Image("PaperThing")
                            .resizable()
                            .scaledToFill()  // Use scaledToFill to make the image stretch to fill the width
                            .frame(maxWidth: .infinity, maxHeight: 260)  // Ensure it takes up the full width
                            .clipped() // Optional: Ensures no part of the image exceeds the bounds
                        VStack {
                            // Register and Login buttons
                            NavigationLink(destination: RegisterView()){
                                Text("Register")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("ColorWhite"))
                                    .frame(width: 250, height: 50)
                                    .background(Color("ColorBlue"))
                                    .cornerRadius(10)
                                    .padding(.bottom, 20)
                            }
                            .contentShape(Rectangle())
                            NavigationLink("Login", destination: LoginView())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("ColorBlue"))
                                .frame(width: 250, height: 50)
                                .background(Color("ColorWhite"))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}



#Preview {

    CreateAccountView()

}
