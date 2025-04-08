//
//  MenuView.swift
//  RecipeApp
//
//  Created by Estar Guan on 2025-04-05.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack{
                VStack{
                    Text("FormFriend")
                        .font(.system(size:60))
                        .fontWeight(.bold)
                    
                    Button(action:{
                        //Switch to recipe Page
                    }){
                        Text("Start Prompt")
                            .font(.title)
                            .padding()
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .background{
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(.red)
                            }
                    }
                }
                Spacer()
            
        }
    }
}

#Preview {
    MenuView()
}
