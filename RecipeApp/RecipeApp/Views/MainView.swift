//
//  MainView.swift
//  RecipeApp
//
//  Created by Estar Guan on 2025-04-05.
//

import SwiftUI

struct MainView: View {
    @State var isAuthenticated = false
    var body: some View {
     
        Group {
          if isAuthenticated {
              Text("Hello")
            //ProfileView()
          } else {
              MenuView()
          }
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

#Preview {
    MainView()
}
