//
//  ContentView.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI

// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if !hasCompletedOnboarding {
                OnboardingScreen {
                    withAnimation(.easeInOut) {
                        hasCompletedOnboarding = true
                    }
                }
            } else {
                MainAppView()
            }
        }
        .onAppear {
            #if DEBUG
            // Debug UserDefaults au démarrage
//            if let bundleID = Bundle.main.bundleIdentifier {
//                       UserDefaults.standard.removePersistentDomain(forName: bundleID)
//                       UserDefaults.standard.synchronize()
//                       print("🧼 UserDefaults reset for debug build")
//                   }
            DebugUserDefaults.debugOnAppear()
            #endif
            
            // Précharger les données en arrière-plan
            Task {
                do {
                    // Charger les vidéos et précharger les avatars
                    let _ = try await VideoService.shared.loadVideos()
                    await YouTuberAvatarService.shared.preloadTopAvatars(limit: 15)
                    print("🚀 App data preloaded successfully")
                } catch {
                    print("❌ Failed to preload app data: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
