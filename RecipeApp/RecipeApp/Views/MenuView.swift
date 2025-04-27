

import SwiftUI



struct MenuView: View {
    @EnvironmentObject var appStore: AppStore  // Access the injected object
    @State private var name: String = "Guest"  // Default to "Guest"
    @State private var isAuthenticated = false
    @State private var isHomeActive: Bool = true  // To check if we are on the home page



    var body: some View {

        NavigationStack {

            ZStack(alignment: .top) {  // ZStack with alignment to manage placement

                // Background color (light gray or something similar to match design)

                Color("ColorLightGray")

                    .edgesIgnoringSafeArea(.all)  // Ensure the background stretches across the entire screen



                // Black Circular Area at the Top (only showing bottom third)

                ZStack {

                    // Create a large black circle with only the bottom third visible

                    Circle()

                        .fill(Color("ColorBlack"))

                        .frame(width: 500, height: 500)

                        .offset(y: -245)  // Move the circle down to show only the bottom third

                    

                    // White Circle behind the Polaris Symbol

                    Circle()

                        .fill(Color.white)

                        .frame(width: 170, height: 170)

                        .offset(y: -190)  // Position it so only the bottom third of the black circle is visible



                    // Polaris symbol inside the circle

                    VStack {

                        Image("PolarisSymbol")

                            .resizable()

                            .scaledToFit()

                            .frame(width: 120, height: 120)

                            .offset(y: -132)



                        Text("Polaris") // Title below the Polaris Symbol

                            .font(.system(size: 40, weight: .heavy))

                            .foregroundColor(Color("ColorLightGray"))

                            .offset(y: -130)

                    }

                }

                .padding(.top, 40) // Adjust space from the top of the screen



                // Black rounded rectangular bar with "Hello, Guest :)" and "Sign in?" button

                HStack {

                    Text("Hello, ") // Static "Hello, "

                        .font(.title2)

                        .fontWeight(.semibold)

                        .foregroundColor(Color("ColorWhite"))

                        .padding(.leading, 20)



                    Text(name) // Dynamic name, which is bold

                        .font(.title2)

                        .fontWeight(.bold)  // Bold for the "Guest"

                        .foregroundColor(Color("ColorWhite"))



                    Text(" :)") // Static ":)"

                        .font(.title2)

                        .fontWeight(.semibold)

                        .foregroundColor(Color("ColorWhite"))

                        .padding(.leading, 5)



                    Spacer()


                    if !isAuthenticated{
                        NavigationLink(destination: CreateAccountView()) {

                            Text("Sign in?")

                                .fontWeight(.semibold)

                                .padding(8)

                                .background(Color("ColorBlue"))

                                .foregroundColor(.white)

                                .cornerRadius(10)

                                .padding(.trailing, 20)

                        }

                    }
                    
                }

                .frame(maxWidth: 380, minHeight: 50)

                .background(RoundedRectangle(cornerRadius: 15).fill(Color("ColorBlack")))

                .offset(y: 320) // Adjust the position of the greeting bar



                // Action buttons below the greeting

                VStack(spacing: 20) {

                    NavigationLink(destination: FormView()) {

                        Text("+ Add Form")

                            .font(.system(size: 40, weight: .bold))

                            .foregroundColor(Color("ColorBlack"))

                            .padding()

                            .frame(maxWidth: 360, minHeight: 80)

                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorDarkGray")))

                    }



                    NavigationLink(destination: HelpBot()) {

                        Text("Extra Help")

                            .font(.system(size: 40, weight: .bold))

                            .foregroundColor(Color("ColorBlack"))

                            .padding()

                            .frame(maxWidth: 360, minHeight: 80)

                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorDarkGray")))

                    }

                }

                .padding(.horizontal, 30) // Horizontal padding for action buttons

                .offset(y: 400)  // Adjust the position of the action buttons



                // Bottom Navigation Bar (rectangular blue bar with icons and text)

                HStack {

                    // Home Icon with Text

                    VStack {

                        Button(action: {

                            // Do nothing as we are already on the Home page

                        }) {

                            Image(systemName: "house.fill")

                                .font(.system(size: 25))

                                .foregroundColor(isHomeActive ? Color("ColorBlack") : .white) // Highlight the home icon

                                .padding(12)

                        }

                        Text("Home")

                            .font(.footnote)

                            .foregroundColor(isHomeActive ? Color("ColorBlack") : .white) // Highlight the "Home" text

                    }



                    Spacer()



                    // Saved Icon with Text

                    VStack {

                        NavigationLink(destination: SavedView()) {

                            Image(systemName: "star.fill")

                                .font(.system(size: 25))

                                .foregroundColor(.white)

                                .padding(12)

                        }

                        Text("Saved")

                            .font(.footnote)

                            .foregroundColor(.white)

                    }



                    Spacer()



                    // Help Icon with Text (New Help Button)

                    VStack {

                        NavigationLink(destination: HelpBot()) { // Link to HelpBot

                            Image(systemName: "questionmark.circle.fill")

                                .font(.system(size: 25))

                                .foregroundColor(.white)

                                .padding(12)

                        }

                        Text("Help")

                            .font(.footnote)

                            .foregroundColor(.white)

                    }



                    Spacer()



                    // Profile Icon with Text

                    VStack {

                        NavigationLink(destination: ProfileView()) {

                            Image(systemName: "person.fill")

                                .font(.system(size: 25))

                                .foregroundColor(.white)

                                .padding(12)

                        }

                        Text("Profile")

                            .font(.footnote)

                            .foregroundColor(.white)

                    }

                }

                .frame(maxWidth: 350) // Limit the width of the bar

                .padding(.horizontal, 20) // Add padding to the sides

                .padding(.vertical, 10)

                .background(RoundedRectangle(cornerRadius: 25).fill(Color("ColorBlue")))

                .shadow(radius: 5)

                .offset(y: 630) // Adjust position of the bottom navigation bar

            }

        }.task {
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                }
            }
        }

    }

}



#Preview {

    MenuView()

}

