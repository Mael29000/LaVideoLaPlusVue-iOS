//
//  Lobby.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

struct LobbyScreen: View {
    @EnvironmentObject var router: AppRouter
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var showCloseTransition = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient moderne
                backgroundGradient
                
                // Contenu principal avec meilleure gestion de l'espace
                VStack(spacing: 0) {
                    // Top spacer pour centrage visuel
                    Spacer()
                        .frame(minHeight: 40, maxHeight: 80)
                    
                    // Header avec logo et titre
                    headerSection
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: showContent)
                    
                    // Spacer flexible entre header et boutons
                    Spacer()
                        .frame(minHeight: 60, maxHeight: 120)
                    
                    // Section des boutons d'action
                    actionButtonsSection
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5), value: showContent)
                    
                    // Bottom spacer pour safe area
                    Spacer()
                        .frame(minHeight: 40, maxHeight: 60)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                
                // Particules décoratives
                decorativeElements
                
                
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
        }
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.12, blue: 0.25),  // Bleu marine foncé
                Color(red: 0.15, green: 0.08, blue: 0.20),  // Bleu-violet
                Color(red: 0.25, green: 0.08, blue: 0.15),  // Violet-rouge
                Color(red: 0.20, green: 0.05, blue: 0.10)   // Rouge foncé
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all)
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 30) {
            // Logo officiel de l'app avec animations
            AppLogo(size: 140)
                .shadow(color: .white.opacity(0.2), radius: 15)
                .scaleEffect(isAnimating ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Titre principal avec style moderne
            VStack(spacing: 12) {
                Text("LaVideoLaPlusVue")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                
                Text("Devine quelle vidéo a le plus de vues !")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Action Buttons Section
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Bouton principal JOUER
            playButton
            
            // Bouton secondaire Hall of Fame
            hallOfFameButton
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var playButton: some View {
        Button(action: {
            // Déclencher la transition de fermeture des portes
            showCloseTransition = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("C'est parti !")
                    .font(.system(size: 15, weight: .semibold))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(
                ZStack {
                    // Background gradient vert comme dans EndGameScreen
                    LinearGradient(
                        colors: [.green, .green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Effet shine pour effet premium
                    LinearGradient(
                        colors: [.white.opacity(0.0), .white.opacity(0.2), .white.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
            .shadow(color: .green.opacity(0.6), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showContent)
    }
    
    @ViewBuilder
    private var hallOfFameButton: some View {
        Button(action: {
            router.presentSheet(.hallOfFame)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Accéder au Hall of Fame")
                    .font(.system(size: 15, weight: .semibold))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(
                ZStack {
                    // Background gradient premium doré/orange (comme dans EndGameScreen)
                    LinearGradient(
                        colors: [.gold, .yellow.opacity(0.8), .orange.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Effet shine pour effet premium
                    LinearGradient(
                        colors: [.white.opacity(0.0), .white.opacity(0.2), .white.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
            .shadow(color: Color.yellow.opacity(0.6), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Decorative Elements
    
    @ViewBuilder
    private var decorativeElements: some View {
        // Cercles flottants décoratifs
        ForEach(0..<6, id: \.self) { index in
            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: CGFloat.random(in: 20...60))
                .position(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...700)
                )
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.3),
                    value: isAnimating
                )
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
}
