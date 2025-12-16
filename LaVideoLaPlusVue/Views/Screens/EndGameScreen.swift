//
//  EndGameScreen.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

struct EndGameScreen: View {
    @EnvironmentObject var router: AppRouter
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var analyticsViewModel = ScoreAnalyticsViewModel()
    
    @State private var showOpenTransition = true
    @State private var showCloseTransition = false
    
    // Animation states for progressive reveal
    @State private var showMainContent = false
    @State private var showScoreCard = false
    @State private var showBestScoreCard = false
    @State private var showHallOfFameCard = false
    @State private var showButtons = false
    @State private var showParticles = false
    
    // Header animation states
    @State private var showGameOverText = false
    @State private var showDino = false
    
    // EnterNameSheet pour le Hall of Fame
    @State private var showEnterNameSheet = false
    @State private var hasCheckedHallOfFameEligibility = false
    
    // Message satirique pour nouveau record (mémorisé pour éviter les changements)
    @State private var newRecordMessage: String = ""
    // Message de performance normal (mémorisé pour éviter les changements)
    @State private var performanceMessage: String = ""
    
    // Sound and haptic feedback
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    
    
    // MARK: - Computed Properties
    
    /**
     * Détermine si le joueur vient de battre son record personnel.
     * Condition : score actuel strictement supérieur au précédent meilleur score
     */
    private var isNewRecord: Bool {
        return gameViewModel.currentScore > gameViewModel.previousBestScore && gameViewModel.currentScore > 0
    }
    
    var body: some View {
        ZStack {
            // Contenu principal de l'écran de fin de partie
            endGameContent
            
            // MARK: - Metal Door Transitions Overlays
            
            // Transition d'ouverture des portes métalliques au démarrage
            if showOpenTransition {
                MetalDoorOpenTransitionView {
                    // Animation d'ouverture terminée
                    showOpenTransition = false
                }
                .zIndex(100) // Au-dessus de tout
            }
            
            // Transition de fermeture des portes métalliques pour recommencer
            if showCloseTransition {
                SimpleMetalDoorCloseTransitionView {
                    // Redémarrer le jeu et naviguer
                    Task {
                        await gameViewModel.restartGame()
                        router.navigateTo(.game)
                    }
                }
                .zIndex(100) // Au-dessus de tout
            }
        }
        .onAppear {
            // Générer les messages une seule fois pour éviter les changements
            if isNewRecord && newRecordMessage.isEmpty {
                newRecordMessage = NewRecordMessages.getMessage(for: gameViewModel.currentScore)
            } else if !isNewRecord && performanceMessage.isEmpty {
                performanceMessage = PerformanceMessages.getMessage(for: gameViewModel.currentScore)
            }
            
            // Calculer les classements pour le score actuel ET le meilleur score
            Task {
                await analyticsViewModel.calculateRankings(
                    currentScore: gameViewModel.currentScore,
                    bestScore: gameViewModel.bestScore
                )
            }
            
            // Start progressive reveal
            startProgressiveReveal()
            
            // Play appropriate celebration sound
            soundManager.playCelebration(finalScore: gameViewModel.currentScore)
            hapticManager.triggerFinalPerformanceFeedback(
                finalScore: gameViewModel.currentScore,
                isNewRecord: isNewRecord
            )
            
            // Vérifier si le joueur peut entrer au Hall of Fame
            checkHallOfFameEligibility()
        }
        .onDisappear {
            // Clean up - réinitialiser les messages pour la prochaine partie
            newRecordMessage = ""
            performanceMessage = ""
        }
        .sheet(isPresented: $showEnterNameSheet) {
            EnterNameSheet(gameViewModel: gameViewModel)
        }
    }
    
    /**
     * Contenu principal de l'écran de fin de partie.
     * Design exact selon l'image fournie.
     */
    @ViewBuilder
    private var endGameContent: some View {
        GeometryReader { geometry in
            ZStack {
                // Background YouTube sombre (même que LobbyScreen)
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
                
                VStack(spacing: 0) {
                    // MARK: - Header section
                    headerSection
                    
                    // MARK: - Contenu principal scrollable
                    ScrollView {
                        
                        VStack(spacing: 20) {
                            if showScoreCard {
                                // MARK: - Enhanced Score Card with particles and animations
                                ZStack {
                                    EnhancedScoreCard(
                                        score: gameViewModel.currentScore,
                                        ranking: analyticsViewModel.canShowRankings && gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold ? 
                                                (analyticsViewModel.displayedCurrentRank ?? "") : "",
                                        performanceMessage: isNewRecord ? newRecordMessage : performanceMessage,
                                        isNewRecord: isNewRecord,
                                        animated: true
                                    )
                                    
                                    // Particle system overlay for scores 15+
                                    if showParticles && gameViewModel.currentScore >= 15 {
                                        ParticleSystem.forScore(
                                            gameViewModel.currentScore,
                                            isActive: showParticles,
                                            isNewRecord: isNewRecord
                                        )
                                        .allowsHitTesting(false)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                            
                            if showBestScoreCard {
                                // MARK: - Carte meilleur score avec progression intégrée
                                enhancedBestScoreCard
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            
                            // MARK: - Hall of Fame Access Card
                            if showHallOfFameCard {
                                hallOfFameAccessCard
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            
                            // Espace pour les boutons sticky
                            Spacer()
                                .frame(height: 120) // Espace pour les boutons en bas
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .background(Color.clear) // Transparent pour laisser voir le gradient sombre
                    
                    // MARK: - Boutons sticky en bas
                    newGameSection
                        .background(Color.clear) // Transparent pour laisser voir le gradient sombre
                        .padding(.bottom, 0) // Let the system handle bottom safe area
                }
            }
        }
    }
    
    /**
     * Section header bleue complète (unsafe + safe area) avec gradient unifié.
     */
    @ViewBuilder
    private var headerSection: some View {
        // Bandeau GAME OVER (zone safe area)
        HStack(alignment: .center, spacing: 16) {
                // GAME OVER avec police arcade
                Text("GAME OVER")
                    .font(.custom("Bungee-Regular", size: 42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gameOverTextColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .tracking(4)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)
                    .scaleEffect(showGameOverText ? 1.0 : 0.8)
                    .opacity(showGameOverText ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showGameOverText)
                
                // Dinosaure
                Image("Dino-white")
                    .font(.system(size: 32))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    .scaleEffect(showDino ? 1.0 : 0.5)
                    .opacity(showDino ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showDino)
            }
            .ignoresSafeArea(edges: .top)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 90)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: headerGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    
    /**
     * Section nouvelle partie avec choix utilisateur.
     */
    @ViewBuilder
    private var newGameSection: some View {
        VStack(spacing: 20) {
            // Question
            Text("Une nouvelle partie ?")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white) // Blanc pour contraste sur fond sombre
            
            // Boutons
            HStack(spacing: 16) {
                // Bouton "Je stop" - retour à l'accueil
                Button(action: {
                    // Retourner à l'écran d'accueil
                    router.navigationStack.removeAll()
                    router.path = NavigationPath()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Je stop")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Bouton "C'est parti !" - nouvelle partie
                Button(action: {
                    // Haptic feedback only (no sound)
                    hapticManager.trigger(.buttonPress)
                    
                    // Déclencher la transition de fermeture des portes
                    showCloseTransition = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                        Text("C'est parti !")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    // MARK: - Progressive Reveal Animation
    
    /**
     * Démarre la séquence d'animations progressives.
     */
    private func startProgressiveReveal() {
        // Header animations first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showGameOverText = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDino = true
            }
        }
        
        // Initial content after door transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showMainContent = true
            }
        }
        
        // Score card appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showScoreCard = true
            }
            
            // Trigger particles for scores 15+
            if gameViewModel.currentScore >= 15 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showParticles = true
                }
            }
        }
        
        // Performance gauge and progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                showBestScoreCard = true
            }
        }
        
        // Hall of Fame card appears after the first two cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHallOfFameCard = true
            }
        }
        
        // Final elements
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButtons = true
            }
        }
    }
    
    // MARK: - Enhanced Best Score Card
    
    @ViewBuilder
    private var enhancedBestScoreCard: some View {
        VStack(spacing: 16) {
            // Header avec score dans le laurier et TOP en haut à droite
            Text("Performance")
                .font(.headline)
                .foregroundColor(.white) // Blanc pour contraste sur fond sombre
            
            // Performance gauge avec légendes humoristiques
            PerformanceGauge(
                score: gameViewModel.currentScore,
                animated: true,
                showLabels: true,
                isNewRecord: isNewRecord
            )
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.15, blue: 0.2), // Gris-bleu foncé
                            Color(red: 0.12, green: 0.12, blue: 0.18)  // Plus sombre
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: performanceCardBorderColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: performanceCardShadowColor, radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Hall of Fame Access Card
    
    @ViewBuilder
    private var hallOfFameAccessCard: some View {
        ZStack {
            VStack(spacing: 16) {
                // Header avec laurier
                ZStack {
                    HStack {
                        Text("🏆 Hall of Fame")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white) // Blanc pour contraste sur fond sombre
                        
                        Spacer()
                    }
                }
                
                // Contenu principal avec logique de ranking intelligente
                VStack(spacing: 12) {
                    HStack(spacing: 32){
                        
                        VStack(spacing: 12){
                            
                            // Score dans le laurier avec effet de glow
                            ZStack {
                                // Lauriers complémentaires formant un cercle autour du meilleur score
                                HStack(spacing: 12) {
                                    Image(systemName: "laurel.leading")
                                        .font(.system(size: 50, weight: .semibold))
                                        .foregroundColor(.green)
                                        .opacity(0.9)
                                        .scaleEffect(gameViewModel.bestScore >= 30 ? 1.05 : 1.0)
                                        .shadow(color: .green.opacity(0.2), radius: gameViewModel.bestScore >= 30 ? 4 : 0)
                                        .rotationEffect(.degrees(-20))
                                    
                                    Image(systemName: "laurel.trailing")
                                        .font(.system(size: 50, weight: .semibold))
                                        .foregroundColor(.green)
                                        .opacity(0.9)
                                        .scaleEffect(gameViewModel.bestScore >= 30 ? 1.05 : 1.0)
                                        .shadow(color: .green.opacity(0.2), radius: gameViewModel.bestScore >= 30 ? 4 : 0)
                                        .rotationEffect(.degrees(20))
                                }
                                
                                // Score au centre, style minimaliste avec effet
                                Text("\(gameViewModel.bestScore)")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white) // Blanc pour contraste sur fond sombre
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1) // Ombre noire pour contraste
                                    .offset(y: -5)
                            }
                            
                            Text("Meilleur score")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8)) // Blanc semi-transparent
                                
                        }
                        
                        // Classement ou message en haut à droite
                        VStack(alignment: .trailing, spacing: 6) {
                            Group {
                                if gameViewModel.bestScore >= AppConfiguration.hallOfFameThreshold {
                                    
                                        // Afficher le rang exact (toujours visible pour le Hall of Fame)
                                        Text(analyticsViewModel.displayedBestRankForHallOfFame ?? "---")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    
                                    
                                } else {
                                    // Score trop bas
                                    VStack(alignment: .center, spacing: 2) {
                                        Text("Atteignez 10 points")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("pour intégrer")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("le Hall of Fame")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .offset(y: -20)
                        }
                    }

                    
                    // Divider élégant
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.3), .clear], // Blanc semi-transparent pour fond sombre
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                    
                    // Premium button
                    premiumHallOfFameButton
                }
            }
            .padding(20)
        }
        .background(
            ZStack {
                // Fond principal sombre contrasté
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.18, blue: 0.25), // Gris-bleu foncé
                                Color(red: 0.15, green: 0.15, blue: 0.22)  // Plus sombre
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Bordure dorée toujours présente
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold ? 
                                [.gold.opacity(0.8), .yellow.opacity(0.5), .gold.opacity(0.8)] :
                                [.gold.opacity(0.5), .yellow.opacity(0.3), .gold.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold ? 2.5 : 1.5
                    )
            }
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
        )
    }
    
    @ViewBuilder
    private var premiumHallOfFameButton: some View {
        Button(action: {
            router.presentSheet(.hallOfFame)
        }) {
            HStack(spacing: 12) {
                Image(systemName: gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold ? "crown.fill" : "list.number")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold ? "Accéder au Hall of Fame" : "Voir les meilleurs en attendant")
                    .font(.system(size: 15, weight: .semibold))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Background gradient premium - toujours doré/orange
                    LinearGradient(
                        colors: [.gold, .yellow.opacity(0.8), .orange.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Effet shine toujours présent pour effet premium
                    LinearGradient(
                        colors: [.white.opacity(0.0), .white.opacity(0.2), .white.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(14)
            .shadow(
                color: Color.yellow.opacity(0.4),
                radius: 8,
                x: 0, y: 4
            )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: gameViewModel.currentScore)
    }
    
    
    // MARK: - Header Performance Colors (basées sur la jauge de performance)
    
    private var headerGradientColors: [Color] {
        let performanceLevel = PerformanceLevel.from(score: gameViewModel.currentScore)
        
        if isNewRecord {
            // Couleurs spéciales pour nouveau record
            return [.green, .mint, .teal]
        } else {
            // Utiliser directement les couleurs du modèle sans modification
            return performanceLevel.gradientColors
        }
    }
    
    private var gameOverTextColors: [Color] {
        if isNewRecord {
            // Blanc pour contraste sur vert
            return [.white, .white.opacity(0.95)]
        }
        
        switch gameViewModel.currentScore {
        case 0...5:
            // Blanc sur gris
            return [.white, .white.opacity(0.9)]
        case 6...10:
            // Blanc sur bleu
            return [.white, .white.opacity(0.95)]
        case 11...15:
            // Blanc sur orange
            return [.white, .white.opacity(0.9)]
        case 16...19:
            // Blanc sur rouge
            return [.white, .white.opacity(0.95)]
        default:
            // Blanc sur rouge intense
            return [.white, .white.opacity(0.9)]
        }
    }
    
    
    // Couleurs de bordure pour la carte performance (utilise le modèle unifié)
    private var performanceCardBorderColors: [Color] {
        if isNewRecord {
            // Couleurs de nouveau record
            return PerformanceLevel.recordColors.map { $0.opacity(0.4) }
        }
        
        let performanceLevel = PerformanceLevel.from(score: gameViewModel.currentScore)
        return [performanceLevel.primaryColor.opacity(0.3), performanceLevel.primaryColor.opacity(0.2)]
    }
    
    // Couleur d'ombre pour la carte performance (utilise le modèle unifié)
    private var performanceCardShadowColor: Color {
        if isNewRecord {
            return PerformanceLevel.recordPrimaryColor.opacity(0.1)
        }
        
        let performanceLevel = PerformanceLevel.from(score: gameViewModel.currentScore)
        return performanceLevel.primaryColor.opacity(0.1)
    }
    
    
    // MARK: - Hall of Fame Eligibility Check
    
    /**
     * Vérifie si le joueur est éligible pour entrer au Hall of Fame et déclenche l'EnterNameSheet.
     * Conditions : Score >= 20, nouveau record personnel, et nom pas encore enregistré.
     */
    private func checkHallOfFameEligibility() {
        guard !hasCheckedHallOfFameEligibility else { return }
        hasCheckedHallOfFameEligibility = true
        
        // Vérifier les conditions pour le Hall of Fame
        let isEligible = gameViewModel.currentScore >= AppConfiguration.hallOfFameThreshold && 
                        gameViewModel.currentScore > gameViewModel.previousBestScore
        
        // Vérifier si le nom n'a pas déjà été enregistré
        let hasName = UserDefaults.standard.string(forKey: "playerName") != nil
        
        if isEligible && !hasName {
            // Attendre que l'animation initiale soit terminée
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showEnterNameSheet = true
            }
        }
    }

}



#Preview("Score Normal") {
    let gameViewModel = GameViewModel()
    gameViewModel.currentScore = 15
    gameViewModel.bestScore = 28
    
    return EndGameScreen(gameViewModel: gameViewModel)
        .environmentObject(AppRouter())
}

#Preview("Nouveau Record!") {
    let gameViewModel = GameViewModel()
    gameViewModel.currentScore = 35  // Score actuel = meilleur score = nouveau record
    gameViewModel.bestScore = 35     // Même score = nouveau record
    
    return EndGameScreen(gameViewModel: gameViewModel)
        .environmentObject(AppRouter())
}

#Preview("Score Élevé") {
    let gameViewModel = GameViewModel()
    gameViewModel.currentScore = 25
    gameViewModel.bestScore = 30
    
    return EndGameScreen(gameViewModel: gameViewModel)
        .environmentObject(AppRouter())
}

#Preview("Score Débutant") {
    let gameViewModel = GameViewModel()
    gameViewModel.currentScore = 2
    gameViewModel.bestScore = 15
    
    return EndGameScreen(gameViewModel: gameViewModel)
        .environmentObject(AppRouter())
}
