//
//  LobbyScreen.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//  Redesigned with YouTube styling by Claude on 23/10/2025.
//

import SwiftUI

/**
 * Écran principal du lobby avec animation splash intégrée.
 * 
 * Animation en 3 phases :
 * 1. Apparition centrée du logo (splash)
 * 2. Transition animée vers la position header
 * 3. Révélation du contenu LobbyScreen
 */
struct LobbyScreen: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var namespaceContainer: NamespaceContainer
    @State private var showCloseTransition = false
    @State private var hasPreloadedAvatars = false
    
    // Phase d'animation
    @State private var animationPhase: AnimationPhase = .initial
    
    // États d'animation pour la transition fluide
    @State private var showPulse: Bool = false
    @State private var showLoadingIndicator: Bool = true
    @State private var lobbyContentOpacity: Double = 0.0
    
    enum AnimationPhase {
        case initial     // Logo invisible
        case splash      // Logo centré visible avec pulsation
        case transition  // Logo en mouvement vers header
        case completed   // Logo en position header finale
    }
    
    // Configuration des phases d'animation
    private let splashDuration: Double = 1.0
    private let transitionDuration: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background YouTube sombre CONSTANT
                youtubeBackground
                
                // Structure avec contenu animé + lobby qui apparaît
                ZStack {
                    // Contenu animé (logo + texte) - toujours au premier plan
                    animatedContent
                        .zIndex(2)
                    
                    // Contenu du lobby qui apparaît progressivement en arrière plan
                    if lobbyContentOpacity > 0 {
                        VStack(spacing: 0) {
                            // Espace pour le header - plus précis
                            Spacer()
                                .frame(height: 120) // Hauteur adaptée au nouveau padding
                            
                            lobbyMainContent(geometry: geometry)
                                .opacity(lobbyContentOpacity)
                        }
                        .zIndex(1) // En arrière-plan
                    }
                }
                
                // Indicateur de chargement centré (phase splash)
                if showLoadingIndicator {
                    VStack {
                        Spacer()
                        loadingIndicator
                            .padding(.bottom, 50)
                    }
                }
                
                // MARK: - Metal Door Close Transition Overlay
                if showCloseTransition {
                    SimpleMetalDoorCloseTransitionView {
                        router.navigateTo(.game)
                    }
                    .zIndex(100) // Au-dessus de tout
                }
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            startSplashAnimation()
            preloadAvatarsIfNeeded()
        }
    }
    
    // MARK: - Background
    
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
    
    // MARK: - Splash Content (centré puis devient header)
    
    @ViewBuilder
    private var animatedContent: some View {
        GeometryReader { geometry in
            // Layout unique qui évolue selon la phase
            // Un seul logo persistant qui anime position et taille
            ZStack {
                // Textes en arrière-plan
                VStack(alignment: textAlignment, spacing: textSpacing) {
                    Text("LaVideoLaPlusVue")
                        .font(.system(size: textMainSize, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Le jeu des vues YouTube")
                        .font(.system(size: textSecondarySize, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(textOpacity)
                .position(x: textPositionX(geometry: geometry), y: textPositionY(geometry: geometry))
                .matchedGeometryEffect(id: "appTitleGroup", in: namespaceContainer.namespace)
                .zIndex(0) // Textes en arrière-plan
                .allowsHitTesting(false) // Éviter les conflits d'interaction
                
                // Logo au premier plan
                AppLogo(size: 80) // Taille native grande pour éviter le flou
                    .scaleEffect(logoScale) // Scale down vers plus petit
                    .scaleEffect(showPulse ? 1.05 : 1.0)
                    .animation(
                        showPulse ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default,
                        value: showPulse
                    )
                    .position(x: logoPositionX(geometry: geometry), y: logoPositionY(geometry: geometry))
                    .matchedGeometryEffect(id: "appLogo", in: namespaceContainer.namespace)
                    .zIndex(1) // Logo au premier plan
                    .animation(.easeOut(duration: 0.75), value: animationPhase)
            }
        }
        // Animation globale pour synchroniser parfaitement logo et texte
//        .animation(.easeOut(duration: transitionDuration), value: animationPhase)
    }
    
    // Propriétés calculées pour les tailles et états
    
    private var logoScale: CGFloat {
        switch animationPhase {
        case .initial: return 1.0 // Déjà à 80pt (même taille que LaunchScreen)
        case .splash: return 1.0 // 80pt taille naturelle  
        case .transition: return 0.4 // Scale down vers taille finale (32/80 = 0.4)
        case .completed: return 0.4 // Taille finale 32pt
        }
    }
    
    private var textAlignment: HorizontalAlignment {
        switch animationPhase {
        case .initial, .splash:
            return .center
        case .transition, .completed:
            return .leading
        }
    }
    
    private func logoPositionX(geometry: GeometryProxy) -> CGFloat {
        switch animationPhase {
        case .initial, .splash:
            return geometry.size.width / 2 // Centré
        case .transition, .completed:
            return 20 + 16 // padding + logo/2 (aligné avec boutons)
        }
    }
    
    private func logoPositionY(geometry: GeometryProxy) -> CGFloat {
        switch animationPhase {
        case .initial, .splash:
            return geometry.size.height / 2 - 60 // Plus haut pour éviter les textes
        case .transition, .completed:
            return 70 + 16 // padding top + logo/2
        }
    }
    
    private func textPositionX(geometry: GeometryProxy) -> CGFloat {
        switch animationPhase {
        case .initial, .splash:
            return geometry.size.width / 2 // Centré
        case .transition, .completed:
            return 20 + 32 + 12 + 80 // padding + logo + spacing + espace réduit
        }
    }
    
    private func textPositionY(geometry: GeometryProxy) -> CGFloat {
        switch animationPhase {
        case .initial, .splash:
            return geometry.size.height / 2 + 40 // Plus loin sous le logo
        case .transition, .completed:
            return 70 + 16 // Même niveau que le logo
        }
    }
    
    private var logoOpacity: Double {
        switch animationPhase {
        case .initial: return 1.0 // Logo déjà visible (transition seamless depuis LaunchScreen)
        case .splash: return 1.0
        case .transition: return 1.0
        case .completed: return 1.0
        }
    }
    
    private var textOpacity: Double {
        switch animationPhase {
        case .initial: return 1.0 // Texte déjà visible (comme dans LaunchScreen)
        case .splash: return 1.0
        case .transition: return 1.0
        case .completed: return 1.0
        }
    }
    
    private var textMainSize: CGFloat {
        switch animationPhase {
        case .initial, .splash: return 24
        case .transition, .completed: return 18
        }
    }
    
    private var textSecondarySize: CGFloat {
        switch animationPhase {
        case .initial, .splash: return 16
        case .transition, .completed: return 12
        }
    }
    
    private var logoToTextSpacing: CGFloat {
        switch animationPhase {
        case .initial, .splash: return 16
        case .transition: return 8
        case .completed: return 0
        }
    }
    
    private var textSpacing: CGFloat {
        switch animationPhase {
        case .initial, .splash: return 8
        case .transition, .completed: return 2
        }
    }
    
    // MARK: - Lobby Main Content
    
    @ViewBuilder
    private func lobbyMainContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Zone principale avec avatars et contenu central
            ZStack {
                // Zone des avatars flottants
                VStack {
                    FloatingYouTuberAvatars(
                        containerHeight: geometry.size.height * 0.6,
                        containerWidth: geometry.size.width
                    )
                    Spacer()
                }
                
                // Contenu central avec titre principal
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("🎬")
                            .font(.system(size: 48))
                        
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
            
            // Boutons d'action en bas
            VStack(spacing: 16) {
                // Bouton principal JOUER
                lobbyPlayButton
                
                // Bouton Hall of Fame
                lobbyHallOfFameButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
    private var lobbyPlayButton: some View {
        Button(action: {
            // Déclencher la transition de fermeture des portes
            showCloseTransition = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 1)
                
                Text("Commencer à jouer")
                    .font(.system(size: 16, weight: .semibold))
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
    private var lobbyHallOfFameButton: some View {
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
    
    // MARK: - Loading Indicator
    
    @ViewBuilder
    private var loadingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Chargement...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Animation Logic
    
    private func startSplashAnimation() {
        // Phase 1: Démarrer directement en splash (logo déjà présent)
        animationPhase = .splash // Pas d'animation pour éviter l'effet de scale
        
        // Démarrer la pulsation après un court délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showPulse = true
        }
        
        // Phase 2: Transition vers header (après splashDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
            startTransitionToHeader()
        }
    }
    
    private func startTransitionToHeader() {
        // Arrêter la pulsation
        showPulse = false
        
        // Cacher l'indicateur de chargement
        withAnimation(.easeOut(duration: 0.3)) {
            showLoadingIndicator = false
        }
        
        // Une seule animation fluide pour aller directement au résultat final
        withAnimation(.easeOut(duration: transitionDuration)) {
            animationPhase = .completed
        }
        
        // Phase révélation du contenu lobby (après que l'animation header soit vraiment terminée)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            revealLobbyContent()
        }
    }
    
    private func revealLobbyContent() {
        // Faire apparaître le contenu du lobby autour du header
        withAnimation(.easeInOut(duration: 0.8)) {
            lobbyContentOpacity = 1.0
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
}

#Preview {
    @Namespace var namespace
    
    return LobbyScreen()
        .environmentObject(AppRouter())
        .environmentObject(NamespaceContainer(namespace))
}
