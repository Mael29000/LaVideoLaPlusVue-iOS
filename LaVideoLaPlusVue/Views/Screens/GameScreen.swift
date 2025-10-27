//
//  GameScreen.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

struct GameScreen: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var router: AppRouter
    
    init(gameViewModel: GameViewModel) {
        self.viewModel = gameViewModel
    }
    
    // Animation state
    @State private var dragOffset: CGFloat = 0
    @State private var isTransitioning = false
    @State private var showBottomVideoCount = false
    @State private var animatedBottomCount = 0
    @State private var feedbackType: FeedbackType? = nil
    @State private var waitingForGameOverTap = false
    @State private var showMetalDoorTransition = false
    @State private var showOpenTransition = true
    @State private var scorePulseScale: CGFloat = 1.0
    
    // Computed properties pour l'effet de record battu
    private var isBeatingRecord: Bool {
        viewModel.currentScore >= viewModel.bestScore && viewModel.currentScore > 0
    }
    
    private var scoreColor: Color {
        // Utiliser un jaune doré plus visible que le vert
        if isBeatingRecord {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Jaune doré
        } else {
            return .white
        }
    }
    
    enum FeedbackType {
        case correct
        case incorrect
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background that fills entire screen including unsafe areas
                Color.black
                    .ignoresSafeArea(.all)
                
                // Main content that respects safe areas
                ZStack {
                    switch viewModel.gameState {
                    case .loading:
                        ProgressView("Chargement...")
                            .foregroundColor(.white)
                        
                    case .playing:
                        gameContent(geometry: geometry)
                        
                    case .gameOver:
                        Color.clear
                    }
                    
                    // MARK: - Metal Door Transitions Overlays
                    
                    // Transition d'ouverture au démarrage du jeu
                    if showOpenTransition {
                        MetalDoorOpenTransitionView {
                            // Animation d'ouverture terminée
                            showOpenTransition = false
                        }
                        .zIndex(100) // Au-dessus de tout
                    }
                    
                    // Transition de fermeture vers EndGame
                    if showMetalDoorTransition {
                        MetalDoorCloseTransitionView {
                            // Navigation vers EndGame à la fin de la transition
                            router.navigateTo(.endGame)
                        }
                        .zIndex(100) // Au-dessus de tout
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.startNewGame()
            }
        }
    }
    
    /**
     * Contenu principal du jeu avec layout vertical des vidéos.
     *
     * Architecture de l'écran:
     * - 3 VideoCards empilées: top (50%), bottom (50%), preloaded (hors-écran)
     * - System d'offset vertical pour l'animation de slide
     * - Overlays pour logo VS et score avec z-index appropriés
     */
    @ViewBuilder
    private func gameContent(geometry: GeometryProxy) -> some View {
        ZStack {
            // MARK: - Main Video Stack
            
            VStack(spacing: 0) {  // Spacing 0 pour collage parfait entre vidéos
                
                // Vidéo du haut (position 1) - toujours visible, compteur affiché
                if let video = viewModel.topVideo {
                    VideoCard(
                        video: video,
                        showViewCount: true,                         // Toujours montrer le nombre de vues
                        animatedCount: nil,                          // Pas d'animation (valeur statique)
                        height: geometry.size.height * 0.5          // 50% de la hauteur d'écran
                    ) {
                        performGuessAnimation(selectedVideo: video, screenHeight: geometry.size.height)
                    }
                } else {
                    Color.black.frame(height: geometry.size.height * 0.5)  // Placeholder pendant le chargement
                }
                
                // Vidéo du bas (position 2) - compteur animé conditionnel
                if let video = viewModel.bottomVideo {
                    VideoCard(
                        video: video,
                        showViewCount: showBottomVideoCount,         // Contrôlé par l'état d'animation
                        animatedCount: animatedBottomCount,          // Valeur animée progressive
                        height: geometry.size.height * 0.5
                    ) {
                        performGuessAnimation(selectedVideo: video, screenHeight: geometry.size.height)
                    }
                } else {
                    Color.black.frame(height: geometry.size.height * 0.5)
                }
                
                // Vidéo préchargée (position 3) - hors écran, prête pour l'animation
                if let video = viewModel.preloadedVideo {
                    VideoCard(
                        video: video,
                        showViewCount: false,                        // Jamais visible (hors écran)
                        animatedCount: nil,
                        height: geometry.size.height * 0.5
                    ) {}  // Pas d'interaction (hors écran)
                } else {
                    Color.black.frame(height: geometry.size.height * 0.5)
                }
            }
            .offset(y: dragOffset)  // Animation de slide: décale toute la stack verticalement
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        .clipped()  // Important: masque la vidéo préchargée qui dépasse
        
        // MARK: - UI Overlays
        
        .overlay(
            // Feedback de réussite/échec centré avec z-index 10
            VStack {
                Spacer()
                if feedbackType != nil {
                    adaptiveLogo  // Affiche uniquement les feedbacks
                }
                Spacer()
            }
            .zIndex(10)
        )
        .overlay(
            // Score en bas à gauche avec z-index 15 (au-dessus du logo)
            VStack {
                Spacer()
                scoreDisplay
                    .padding(.bottom, 20)  // Espace depuis le bord inférieur réduit pour safe areas
            }
            .zIndex(15),
            alignment: .bottom
        )
    }
    
    // MARK: - Game Logic
    
    private func performGuessAnimation(selectedVideo: Video, screenHeight: CGFloat) {
        if waitingForGameOverTap {
            // Déclencher la transition "portes métalliques" au lieu de naviguer directement
            showMetalDoorTransition = true
            return
        }
        
        guard !isTransitioning else { return }
        
        Task {
            let isCorrect = await viewModel.makeGuess(selectedVideo: selectedVideo)
            
            isTransitioning = true
            showBottomVideoCount = true
            await animateViewCount()
            
            // Show visual feedback and haptic response
            feedbackType = isCorrect ? .correct : .incorrect
            triggerHapticFeedback(isCorrect: isCorrect)
            
            if isCorrect {
                // Wait, animate slide, then swap videos
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    dragOffset = -screenHeight * 0.5
                }
                
                try? await Task.sleep(nanoseconds: 600_000_000)
                
                await MainActor.run {
                    Task {
                        await viewModel.swapVideos()
                        await MainActor.run {
                            dragOffset = 0
                            isTransitioning = false
                            showBottomVideoCount = false
                            // Attendre que l'animation de disparition du feedback se termine (1.3s total)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                feedbackType = nil
                            }
                        }
                    }
                }
            } else {
                // Game over - wait for second tap
                await MainActor.run {
                    waitingForGameOverTap = true
                    isTransitioning = false
                }
            }
        }
    }
    
    private func triggerHapticFeedback(isCorrect: Bool) {
        if isCorrect {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } else {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
                heavyImpact.impactOccurred()
            }
        }
    }
    
    // MARK: - Animations
    
    /**
     * Animation progressive du compteur de vues de la vidéo du bas.
     * Utilise une fonction d'easing pour un effet visuel fluide de "comptage".
     *
     * Logique: Divise l'animation en 30 étapes sur 0.8 secondes pour un rendu rapide.
     */
    private func animateViewCount() async {
        guard let bottomVideo = viewModel.bottomVideo else { return }
        
        let targetCount = bottomVideo.viewCount  // Valeur finale à atteindre
        let startCount = animatedBottomCount     // Valeur de départ (souvent 0)
        let duration: Double = 1.0               // Durée d'animation pour test
        let steps = 30                           // Nombre d'étapes optimisé
        
        // Boucle d'animation: chaque step met à jour le compteur
        for i in 0...steps {
            let progress = Double(i) / Double(steps)           // Progression linéaire 0→1
            let easedProgress = easeInOut(progress)            // Progression avec easing
            let currentCount = startCount + Int(Double(targetCount - startCount) * easedProgress)
            
            // Mise à jour UI sur le thread principal
            await MainActor.run {
                animatedBottomCount = currentCount
            }
            
            // Pause entre chaque frame (0.8s / 30 steps = ~27ms par frame)
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000 / Double(steps)))
        }
    }
    
    /**
     * Fonction d'easing "ease-in-out" pour une animation naturelle.
     * Démarre lentement, accélère au milieu, puis ralentit à la fin.
     */
    private func easeInOut(_ t: Double) -> Double {
        return t * t * (3.0 - 2.0 * t)
    }
    
    // MARK: - UI Components
    
    /**
     * Affichage du score en bas à gauche de l'écran.
     * Layout: Score actuel et meilleur score empilés verticalement.
     */
    private var scoreDisplay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("SCORE: \(viewModel.currentScore)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(scoreColor)
                        .scaleEffect(isBeatingRecord ? 1.1 : 1.0)
                        .scaleEffect(scorePulseScale)
                .padding(.horizontal, isBeatingRecord ? 8 : 0)
                .padding(.vertical, isBeatingRecord ? 4 : 0)
                .background(
                    Group {
                        if isBeatingRecord {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.yellow.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(scoreColor.opacity(0.6), lineWidth: 1.5)
                                )
                        }
                    }
                )
                .shadow(color: isBeatingRecord ? scoreColor.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentScore)
                .onChange(of: viewModel.currentScore) { oldValue, newValue in
                    // Animation de croissance à chaque augmentation du score
                    if newValue > oldValue {
                        // Pulse du score
                        withAnimation(.easeOut(duration: 0.1)) {
                            scorePulseScale = 1.3
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                            scorePulseScale = 1.0
                        }
                        
                        // Pas d'animation supplémentaire pour l'étoile
                    }
                }
                
                Text("BEST: \(viewModel.bestScore)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer() // Pousse le contenu vers la gauche
        }
        .padding(.horizontal, 20)
    }
    
    /**
     * Feedback visuel de réussite/échec uniquement (plus de logo VS).
     */
    @ViewBuilder
    private var adaptiveLogo: some View {
        if let feedback = feedbackType {
            // Feedback visuel: checkmark vert ou X rouge animé
            FeedbackCircle(isCorrect: feedback == .correct)
        }
    }
}

/**
 * Composant séparé pour les feedbacks avec animations autonomes
 */
struct FeedbackCircle: View {
    let isCorrect: Bool
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0.0
    @State private var shouldDisappear = false
    
    var body: some View {
        ZStack {
            // Background circulaire coloré selon le résultat
            Circle()
                .fill(isCorrect ? Color.green : Color.red)
                .frame(width: isCorrect ? 70 : 80, height: isCorrect ? 70 : 80)
            
            // Icône de validation (checkmark ou X)
            Image(systemName: isCorrect ? "checkmark" : "xmark")
                .font(.system(size: isCorrect ? 35 : 40, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(shouldDisappear ? 2.0 : scale)
        .opacity(shouldDisappear ? 0.0 : opacity)
        .onAppear {
            // Animation d'entrée
            withAnimation(.easeInOut(duration: 0.2)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Animation continue selon le type
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if isCorrect {
    
                    
                    // Auto-disparition avec animation pour les réussites uniquement
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        startDisappearAnimation()
                    }
                } 
            }
        }
        .scaleEffect(isAnimating ? (isCorrect ? 1.1 : 0.9) : 1.0)
    }
    
    private func startDisappearAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            shouldDisappear = true
        }
    }
}

/**
 * Composant réutilisable représentant une carte vidéo interactive.
 *
 * Fonctionnalités:
 * - Affichage de thumbnail avec cache optimisé pour transitions instantanées
 * - Overlay gradient pour lisibilité du texte
 * - Animation optionnelle du compteur de vues
 * - Gestion du fallback AsyncImage si pas de cache
 */
struct VideoCard: View {
    let video: Video
    let showViewCount: Bool          // Contrôle l'affichage du compteur de vues
    var animatedCount: Int? = nil    // Valeur animée optionnelle pour le compteur
    let height: CGFloat              // Hauteur dynamique (50% de l'écran)
    let onTap: () -> Void           // Callback lors du tap utilisateur
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // MARK: - Background Layer
                
                // Image de fond avec système de cache prioritaire
                GeometryReader { geo in
                    if let cachedImage = VideoService.shared.getCachedImage(for: video) {
                        // Utilisation de l'image cachée pour affichage instantané
                        Image(uiImage: cachedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: height)
                            .clipped()
                    } else {
                        // Fallback AsyncImage si pas encore en cache
                        AsyncImage(url: video.thumbnailURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: height)
                                .clipped()
                        } placeholder: {
                            // Placeholder pendant le chargement
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geo.size.width, height: height)
                        }
                    }
                }
                .frame(height: height)
                
                // MARK: - Overlay Layer
                
                // Gradient sombre pour améliorer la lisibilité du texte
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.6), Color.clear, Color.black.opacity(0.8)],
                            startPoint: .top,      // Plus sombre en haut (titre)
                            endPoint: .bottom      // Plus sombre en bas (compteur)
                        )
                    )
                
                // MARK: - Content Layer
                
                // Contenu textuel superposé à l'image
                VStack {
                    // Section titre en haut
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)                           // Limite à 2 lignes pour éviter le débordement
                            .shadow(color: .black, radius: 2)       // Ombre pour contraste sur images claires
                        
                        Text(video.channelTitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black, radius: 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)  // Alignement à gauche
                    .padding(.horizontal, 20)
                    .padding(.top, 40)                                // Espace depuis le haut réduit pour safe areas
                    
                    Spacer() // Pousse le contenu vers les extrémités
                    
                    // Section compteur de vues au centre (si activé)
                    if showViewCount {
                        VStack(spacing: 4) {
                            Text(displayedViewCount)
                                .font(.system(size: 36, weight: .black, design: .monospaced))  // Monospace pour alignement stable
                                .foregroundColor(.yellow)                                      // Couleur distinctive
                                .shadow(color: .black, radius: 3)                             // Ombre forte pour visibilité
                                .contentTransition(.numericText())                            // Animation fluide des chiffres
                            
                            Text("VUES")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white.opacity(1))
                                .shadow(color: .black, radius: 1)
                        }
                    }
                    
                    Spacer() // Équilibre l'espacement vertical
                }
            }
            .frame(height: height)
        }
        .buttonStyle(PlainButtonStyle())  // Supprime les effets de highlight par défaut
        .frame(height: height)            // Impose la hauteur dynamique
    }
    
    // MARK: - Helper Methods
    
    /**
     * Détermine quelle valeur afficher pour le compteur de vues.
     * Priorité: valeur animée > valeur formatée statique de la vidéo.
     */
    private var displayedViewCount: String {
        if let animatedCount = animatedCount {
            return formatViewCount(animatedCount)  // Utilise la valeur d'animation en cours
        } else {
            return video.formattedViewCount        // Utilise la valeur pré-formatée du modèle
        }
    }
    
    /**
     * Formate un nombre de vues avec séparateur d'espaces pour la lisibilité.
     * Ex: 1234567 → "1 234 567"
     */
    private func formatViewCount(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "         // Espace comme séparateur (standard français)
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
}

#Preview {
    GameScreen(gameViewModel: GameViewModel())
        .environmentObject(AppRouter())
}

// Preview pour tester uniquement les feedbacks
#Preview("Feedback Test") {
    FeedbackTestView()
}

/**
 * Vue de test pour les feedbacks avec boutons de contrôle
 */
struct FeedbackTestView: View {
    @State private var showSuccessFeedback = false
    @State private var showErrorFeedback = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 50) {
                Text("Test des Feedbacks")
                    .font(.title)
                    .foregroundColor(.white)
                
                // Zone d'affichage du feedback
                ZStack {
                    if showSuccessFeedback {
                        FeedbackCircle(isCorrect: true)
                    }
                    
                    if showErrorFeedback {
                        FeedbackCircle(isCorrect: false)
                    }
                }
                .frame(height: 100)
                
                // Boutons de contrôle
                HStack(spacing: 30) {
                    Button("Succès") {
                        showErrorFeedback = false
                        showSuccessFeedback = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Échec") {
                        showSuccessFeedback = false
                        showErrorFeedback = true
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Reset") {
                        showSuccessFeedback = false
                        showErrorFeedback = false
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}
