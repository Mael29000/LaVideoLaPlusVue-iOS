//
//  LaVideoLaPlusVueApp.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

@main
struct LaVideoLaPlusVueApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            // Décommenter temporairement pour nettoyer les caches
            // DebugClearCacheView()
            #endif
            ContentView()
        }
    }
}
