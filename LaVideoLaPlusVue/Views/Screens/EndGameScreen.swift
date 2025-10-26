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
    @State private var gradientOffset: CGFloat = 0
    
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
    
    
    // Sound and haptic feedback
    private let soundManager = SoundManager.shared
    private let hapticManager = HapticManager.shared
    
    
    // MARK: - Computed Properties
    
    /**
     * Détermine si le joueur vient de battre son record personnel.
     * Condition : score actuel égal au meilleur score (nouveau record)
     */
    private var isNewRecord: Bool {
        return gameViewModel.currentScore == gameViewModel.bestScore && gameViewModel.currentScore > 0
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
        }
        .onDisappear {
            // Clean up if needed
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
                    // MARK: - Header bleu complet (unsafe area + safe area)
                    headerSection
                    
                    // MARK: - Contenu principal scrollable
                    ScrollView {
                        
                        VStack(spacing: 20) {
                            if showScoreCard {
                                // MARK: - Enhanced Score Card with particles and animations
                                ZStack {
                                    EnhancedScoreCard(
                                        score: gameViewModel.currentScore,
                                        ranking: analyticsViewModel.displayedCurrentRanking,
                                        performanceMessage: analyticsViewModel.performanceMessage.isEmpty ? "Bien joué !" : analyticsViewModel.performanceMessage,
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
        .onAppear {
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
//            .padding(.top, 10)
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
                    // Sound and haptic feedback
                    soundManager.playSound(.button)
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
    
    // MARK: - Best Score Helpers
    
    private var bestScoreIcon: Image {
        switch gameViewModel.bestScore {
        case 0...3: return Image(systemName: "tortoise.fill")
        case 4...8: return Image(systemName: "hare.fill")
        case 9...15: return Image(systemName: "star.fill")
        case 16...18: return Image(systemName: "flame.fill")
        case 19...20: return Image(systemName: "crown.fill")
        default: return Image(systemName: "trophy.fill")
        }
    }
    
    private var bestScoreIconColor: Color {
        switch gameViewModel.bestScore {
        case 0...3: return .gray
        case 4...8: return .orange
        case 9...15: return .blue
        case 16...18: return .red
        case 19...20: return .purple
        default: return .gold
        }
    }
    
    private var bestScoreGradientColors: [Color] {
        switch gameViewModel.bestScore {
        case 0...3: return [.gray.opacity(0.6), .gray]
        case 4...8: return [.orange.opacity(0.6), .orange]
        case 9...15: return [.blue.opacity(0.6), .blue]
        case 16...20: return [.red.opacity(0.6), .red]
        default: return [.red, .orange, .yellow]
        }
    }
    
    private var bestScoreHumorousLabel: String {
        switch gameViewModel.bestScore {
        case 0...3: return "Pas ouf"
        case 4...8: return "À quelques refs"
        case 9...15: return "Se débrouille"
        case 16...18: return "À passé trop de temps sur YouTube"
        case 19...20: return "Chômeur professionnel"
        default: return "Légende absolue"
        }
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
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Performance")
                            .font(.headline)
                            .foregroundColor(.white) // Blanc pour contraste sur fond sombre
                        
                   
                    }
                    
                   
                }
                
                Spacer()
                
            }
            
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
                        
                        // TOP percentage en haut à droite avec style amélioré
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 4) {
                                Text("TOP")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7)) // Blanc semi-transparent pour fond sombre
                                
                                Text(analyticsViewModel.hasValidData ? "\(analyticsViewModel.bestScorePercentage ?? 0)%" : "---%")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white) // Blanc pour contraste sur fond sombre
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
                
                // Bordure premium pour les scores élevés
                if gameViewModel.currentScore >= 20 {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.gold.opacity(0.8), .yellow.opacity(0.5), .gold.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                } else {
                    // Bordure subtile pour tous les autres scores
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                }
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
                Image(systemName: gameViewModel.currentScore >= 20 ? "crown.fill" : "list.number")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(gameViewModel.currentScore >= 20 ? "Accéder au Hall of Fame" : "Voir le classement")
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
    
    // MARK: - Ranking Helper Methods
    
    private func parseRanking(_ ranking: String) -> (place: Int?, percentage: Int?) {
        // Parse "1er" ou "2ème" etc.
        if ranking.contains("er") || ranking.contains("ème") {
            let numberString = ranking.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return (Int(numberString), nil)
        }
        
        // Parse "TOP 15%" etc.
        if ranking.contains("TOP") && ranking.contains("%") {
            let numberString = ranking.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return (nil, Int(numberString))
        }
        
        return (nil, nil)
    }
    
    private func rankingIcon(for place: Int) -> Image {
        switch place {
        case 1: return Image(systemName: "crown.fill")
        case 2, 3: return Image(systemName: "medal.fill")
        case 4...10: return Image(systemName: "star.fill")
        case 11...50: return Image(systemName: "flame.fill")
        default: return Image(systemName: "number.circle.fill")
        }
    }
    
    private func ordinalSuffix(_ number: Int) -> String {
        if number == 1 { return "re" }
        return "ème"
    }
    
    private func motivationalMessage(for score: Int) -> String {
        switch score {
        case 20...24: return "Bravo ! Vous êtes dans le classement ! 🎉"
        case 25...29: return "Excellent score ! Continuez comme ça ! 🔥"
        case 30...34: return "Performance remarquable ! 🌟"
        case 35...: return "Score légendaire ! Vous dominez le classement ! 👑"
        default: return "Félicitations ! 🎉"
        }
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
    
    // Gradient harmonisé avec les couleurs du score
    private var scoreBasedTextGradient: LinearGradient {
        if isNewRecord {
            // Couleurs vertes pour nouveau record (même que le score)
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.5), Color(red: 0.6, green: 0.8, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Utilise les mêmes couleurs de bordure que la carte de score
        switch gameViewModel.currentScore {
        case 0...3:
            // Gris sobre
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.5, green: 0.5, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4...8:
            // Bleu marine élégant
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 0.7), Color(red: 0.3, green: 0.5, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 9...15:
            // Violet indigo classe
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.7), Color(red: 0.5, green: 0.4, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 16...19:
            // Bordeaux sophistiqué
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.2, blue: 0.3), Color(red: 0.7, green: 0.3, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            // Bordeaux profond pour 20+
            return LinearGradient(
                colors: [Color(red: 0.7, green: 0.1, blue: 0.2), Color(red: 0.8, green: 0.2, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
    
    // MARK: - Helper Methods
    
    private func performanceLevelIcon(for score: Int) -> Image {
        switch score {
        case 0...10: return Image(systemName: "tortoise.fill")
        case 11...20: return Image(systemName: "hare.fill")
        case 21...30: return Image(systemName: "star.fill")
        case 31...40: return Image(systemName: "flame.fill")
        default: return Image(systemName: "crown.fill")
        }
    }
    
    private func performanceLevelColor(for score: Int) -> Color {
        switch score {
        case 0...10: return .gray
        case 11...20: return .blue
        case 21...30: return .green
        case 31...40: return .orange
        default: return .red
        }
    }
    
    private func performanceLevelText(for score: Int) -> String {
        switch score {
        case 0...10: return "Débutant"
        case 11...20: return "Intermédiaire"
        case 21...30: return "Avancé"
        case 31...40: return "Expert"
        default: return "Maître"
        }
    }
    
    private func calculateCurrentRanking() -> String? {
        if analyticsViewModel.hasValidData {
            // Simuler un classement basé sur le score
            let score = gameViewModel.currentScore
            switch score {
            case 45...: return "1er"
            case 40...44: return "dans le TOP 3"
            case 35...39: return "dans le TOP 10"
            case 30...34: return "dans le TOP 20"
            case 25...29: return "dans le TOP 50"
            case 20...24: return "dans le TOP 100"
            default: return nil
            }
        }
        return nil
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
