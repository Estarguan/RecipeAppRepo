import SwiftUI
import OpenAISwift

struct MainView: View {
    let client: OpenAISwift

       init() {
           // Replace "YOUR_API_KEY" with your actual OpenAI API key
           let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: "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")
           client = OpenAISwift(config: config)
       }

    @State var isAuthenticated = false

    var body: some View {
       NavigationView{
            VStack {
                if isAuthenticated {
                    //Text("Hello")
                    // ProfileView()
                } else {
                    HStack{
                        Spacer()
                        NavigationLink("Login",destination:LoginView())
                        NavigationLink("Register",destination:RegisterView())
                    }
                    .padding(.trailing)
                    .frame(width:400, height:60)
                }
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
    }
}

#Preview {
    MainView()
}
