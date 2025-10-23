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
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
            } else if !hasCompletedOnboarding {
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
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isShowingSplash = false
                }
            }
            
            // Précharger les données en arrière-plan pendant le splash
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
