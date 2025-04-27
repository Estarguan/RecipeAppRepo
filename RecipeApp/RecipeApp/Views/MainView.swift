import SwiftUI

struct MainView: View {
    
    @State var isAuthenticated = false
    
    var body: some View {
       NavigationView{
            VStack {
                HStack{
                    NavigationLink("Change Language", destination:AuthenticationView())
                        .padding(.leading)
                    if isAuthenticated {
                        
                        Spacer()
                        Button("Sign out", role: .destructive) {
                            Task {
                                try? await supabase.auth.signOut()
                                isAuthenticated = false
                            }
                        }
                    } else {
                        Spacer()
                        NavigationLink("Login",destination:LoginView())
                        NavigationLink("Register",destination:RegisterView())
                        
                            
                    }
                }
                .padding(.trailing)
                .frame(width:400, height:60)
                MenuView()
            }
            .task {
                for await state in supabase.auth.authStateChanges {
                    if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                        isAuthenticated = state.session != nil
                    }
                }
            }
        }
        
       .navigationBarBackButtonHidden(true)
    }
}

class AppStore: ObservableObject {
    @Published var isAuthenitcated: Bool = false
}

#Preview {
    MainView()
}
