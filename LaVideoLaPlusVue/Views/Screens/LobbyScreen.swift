//
//  LobbyScreen.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//  Redesigned with YouTube styling by Claude on 23/10/2025.
//

import SwiftUI

struct LobbyScreen: View {
    @EnvironmentObject var router: AppRouter
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var showCloseTransition = false
    @State private var hasPreloadedAvatars = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background YouTube style
                youtubeBackground
                
                // Contenu principal avec layout YouTube
                VStack(spacing: 0) {
                    // YouTube Header
                    youtubeHeaderSection
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    // Zone principale avec avatars flottants
                    mainContentSection(geometry: geometry)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: showContent)
                    
                    // Section des boutons d'action (partie basse)
                    actionButtonsSection
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: showContent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // MARK: - Metal Door Close Transition Overlay
                
                // Transition de fermeture des portes métalliques pour lancer le jeu
                if showCloseTransition {
                    SimpleMetalDoorCloseTransitionView {
                        // Naviguer vers le jeu après la transition
                        router.navigateTo(.game)
                    }
                    .zIndex(100) // Au-dessus de tout
                }
            }
        }
        .onAppear {
            showContent = true
            startDecorationAnimation()
            preloadAvatarsIfNeeded()
        }
    }
    
    // MARK: - YouTube Background
    
    @ViewBuilder
    private var youtubeBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.067, green: 0.067, blue: 0.067), // YouTube dark
                Color(red: 0.05, green: 0.05, blue: 0.05),    // Plus sombre
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all)
    }
    
    // MARK: - YouTube Header Section
    
    @ViewBuilder
    private var youtubeHeaderSection: some View {
        HStack {
            // App logo area (style YouTube)
            HStack(spacing: 12) {
                AppLogo(size: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("LaVideoLaPlusVue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Le jeu des vues YouTube")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - Main Content Section
    
    @ViewBuilder
    private func mainContentSection(geometry: GeometryProxy) -> some View {
        ZStack {
            // Zone des avatars flottants (zone haute étendue)
            VStack {
                FloatingYouTuberAvatars(
                    containerHeight: geometry.size.height * 0.72, // Zone étendue jusqu'aux boutons
                    containerWidth: geometry.size.width
                )
                
                Spacer()
            }
            
            // Contenu central avec titre principal
            VStack(spacing: 24) {
                Spacer()
                
                // Titre principal avec style YouTube
                VStack(spacing: 16) {
                    Text("🎬")
                        .font(.system(size: 48))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Devine quelle vidéo\na le plus de vues !")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("Compare les vidéos YouTube et teste tes connaissances")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Action Buttons Section
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Bouton principal JOUER (style YouTube)
            youtubePlayButton
            
            // Bouton secondaire Hall of Fame (style YouTube)
            youtubeHallOfFameButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    private var youtubePlayButton: some View {
        Button(action: {
            // Déclencher la transition de fermeture des portes
            showCloseTransition = true
        }) {
            HStack(spacing: 12) {
                // Icône play YouTube style
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 1) // Centrage visuel
                }
                
                Text("Commencer à jouer")
                    .font(.system(size: 16, weight: .semibold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: .red.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private var youtubeHallOfFameButton: some View {
        Button(action: {
            router.presentSheet(.hallOfFame)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("Hall of Fame")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Avatar Preloading
    
    private func preloadAvatarsIfNeeded() {
        guard !hasPreloadedAvatars else { return }
        
        Task {
            // Précharger les avatars en arrière-plan pour des performances optimales
            await YouTuberAvatarService.shared.preloadTopAvatars(limit: 20)
            await YouTuberAvatarService.shared.preloadRandomAvatars(count: 10)
            
            await MainActor.run {
                hasPreloadedAvatars = true
                print("🎯 Avatars preloaded for lobby animations")
            }
        }
    }
    
    // MARK: - Animations
    
    private func startDecorationAnimation() {
        withAnimation {
            isAnimating = true
        }
    }
}

#Preview {
    LobbyScreen()
        .environmentObject(AppRouter())
}