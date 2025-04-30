//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by Estar Guan on 2025-04-05.
//

import SwiftUI

@main
struct RecipeAppApp: App {
    @StateObject private var appSettings = AppSettings()
    @StateObject private var appStore = AppStore()

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(appSettings)  // ✅ Required for language settings
                .environmentObject(appStore)     // ✅ Required if used in other views
        }
    }
}
