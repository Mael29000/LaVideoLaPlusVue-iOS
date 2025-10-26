import SwiftUI

// MARK: - Metal Door Open Transition

/**
 * Animation d'ouverture des portes métalliques pour révéler l'EndGameScreen.
 *
 * ## Effet visuel
 * Deux portes horizontales s'ouvrent depuis le centre vers les bords :
 * - **Porte supérieure** : Bleu métallique, remonte du centre vers le haut
 * - **Porte inférieure** : Rouge métallique, descend du centre vers le bas
 * - **Logo VS** : Disparaît progressivement pendant l'ouverture
 * - **Contenu révélé** : L'EndGameScreen apparaît derrière les portes
 *
 * ## Timing de l'animation
 * - **Durée totale** : 2.0 secondes (plus lent que la fermeture)
 * - **Phase 1 (0-50%)** : Disparition progressive du logo VS
 * - **Phase 2 (0-100%)** : Ouverture progressive des portes
 * - **Easing** : ease-out-quart pour un mouvement fluide et naturel
 *
 * ## Architecture technique
 * - Double GeometryReader pour gérer les safe areas correctement
 * - Timer manuel 60 FPS pour un contrôle précis de l'animation
 * - Shapes personnalisées pour les portes avec encoches circulaires
 * - Overlays avec gradients métalliques et effets de rayures
 */
struct MetalDoorOpenTransitionView: View {
    
    // MARK: - Properties
    
    @State private var animationProgress: Double = 0
    @State private var animationTimer: Timer?
    @State private var logoTransition: Double = 1  // 1 = logo visible, 0 = logo disparu
    
    let onComplete: () -> Void
    
    // MARK: - Constants
    
    private let animationDuration: Double = 2.0
    private let frameRate: Double = 60.0
    private let logoFadeThreshold: Double = 0.05  // Le logo disparaît dans les 20% premiers (plus rapide)
    
    // MARK: - Body
    
    var body: some View {
        // Architecture double GeometryReader pour capturer les safe areas correctement
        GeometryReader { safeAreaGeometry in
            GeometryReader { fullScreenGeometry in
                MetalDoorOpenOverlay(
                    progress: animationProgress,
                    fullScreenGeometry: fullScreenGeometry,
                    safeAreaGeometry: safeAreaGeometry,
                    logoTransition: logoTransition
                )
            }
            .ignoresSafeArea(.all)  // Les portes couvrent tout l'écran incluant les safe areas
        }
        .onAppear { startOpenAnimation() }
        .onDisappear { stopAnimation() }
    }
    
    // MARK: - Animation Control
    
    /**
     * Démarre l'animation d'ouverture avec feedback haptique doux et timer manuel.
     *
     * L'ouverture utilise un feedback plus subtil que la fermeture pour créer
     * une sensation de "révélation" plutôt que de "verrouillage".
     */
    private func startOpenAnimation() {
        print("🚪 [MetalDoorOpen] Démarrage de l'animation d'ouverture")
        
        // Feedback haptique de début - plus doux pour l'ouverture
        triggerStartHaptics()
        
        let startTime = Date()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / animationDuration, 1.0)
            
            DispatchQueue.main.async {
                animationProgress = progress
                
                // Animation du logo : disparaît dans les 20% premiers
                if progress <= logoFadeThreshold {
                    let logoPhaseProgress = progress / logoFadeThreshold
                    logoTransition = 1.0 - logoPhaseProgress  // 1 → 0
                } else {
                    logoTransition = 0
                }
                
                print("🚪 [MetalDoorOpen] Progress: \(String(format: "%.2f", progress))%, Logo: \(String(format: "%.2f", logoTransition))")
                
                // Animation terminée
                if progress >= 1.0 {
                    timer.invalidate()
                    scheduleCompletion()
                }
            }
        }
    }
    
    /**
     * Déclenche les retours haptiques de début d'animation (plus doux que la fermeture).
     */
    private func triggerStartHaptics() {
        let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        mediumImpact.impactOccurred()
    }
    
    /**
     * Programme la finalisation de l'animation avec un délai.
     */
    private func scheduleCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🚪 [MetalDoorOpen] Animation d'ouverture terminée")
            onComplete()
        }
    }
    
    /**
     * Arrête le timer d'animation lors de la disparition de la vue.
     */
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Metal Door Open Overlay

/**
 * Overlay contenant les formes des portes métalliques qui s'ouvrent et le logo VS qui disparaît.
 *
 * ## Responsabilités
 * - Rendre les deux portes horizontales avec leurs effets visuels d'ouverture
 * - Gérer la disparition du logo VS central
 * - Coordonner les positions basées sur les safe areas
 */
private struct MetalDoorOpenOverlay: View {
    
    // MARK: - Properties
    
    let progress: Double
    let fullScreenGeometry: GeometryProxy    // Taille écran complet avec safe areas
    let safeAreaGeometry: GeometryProxy      // Taille zone visible sans safe areas
    let logoTransition: Double
    
    // MARK: - Body
    
    var body: some View {
        // Calculs de positionnement basés sur les safe areas
        let safeCenterX = safeAreaGeometry.size.width * 0.5
        let safeCenterY = safeAreaGeometry.size.height * 0.5
        let centerOffsetY = safeAreaGeometry.safeAreaInsets.top
        let visualCenterY = safeCenterY + centerOffsetY
        
        ZStack {
            // MARK: - Top Door (Blue Metal)
            renderTopDoor(visualCenterY: visualCenterY)
            
            // MARK: - Bottom Door (Red Metal)
            renderBottomDoor(visualCenterY: visualCenterY)
            
            // MARK: - Central Logo (Disappearing)
            renderCentralLogo(centerX: safeCenterX, centerY: visualCenterY)
        }
        .frame(width: fullScreenGeometry.size.width, height: fullScreenGeometry.size.height)
        .clipped()
    }
    
    // MARK: - Door Rendering
    
    /**
     * Rend la porte supérieure bleue qui remonte vers le haut.
     */
    @ViewBuilder
    private func renderTopDoor(visualCenterY: CGFloat) -> some View {
        Group {
            // Forme principale avec dégradé métallique bleu
            TopHorizontalDoorOpen(
                progress: progress,
                screenSize: fullScreenGeometry.size,
                visualCenterY: visualCenterY
            )
            .fill(
                Color(red: 0.15, green: 0.25, blue: 0.45) // Blue: #26407A
            )
            .overlay(
                // Rayures métalliques pour l'effet de texture
                TopHorizontalDoorOpen(
                    progress: progress,
                    screenSize: fullScreenGeometry.size,
                    visualCenterY: visualCenterY
                )
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 2])
                )
            )
            .shadow(color: .black.opacity(0.8), radius: 20, x: 5, y: 5)
        }
    }
    
    /**
     * Rend la porte inférieure rouge qui descend vers le bas.
     */
    @ViewBuilder
    private func renderBottomDoor(visualCenterY: CGFloat) -> some View {
        Group {
            // Forme principale avec dégradé métallique rouge
            BottomHorizontalDoorOpen(
                progress: progress,
                screenSize: fullScreenGeometry.size,
                visualCenterY: visualCenterY
            )
            .fill(
                Color(red: 0.9, green: 0.2, blue: 0.3) // Red: #E6334D
            )
            .overlay(
                // Rayures métalliques pour l'effet de texture
                BottomHorizontalDoorOpen(
                    progress: progress,
                    screenSize: fullScreenGeometry.size,
                    visualCenterY: visualCenterY
                )
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 2])
                )
            )
            .shadow(color: .black.opacity(0.8), radius: 20, x: -5, y: -5)
        }
    }
    
    /**
     * Rend le logo VS central qui disparaît progressivement.
     */
    @ViewBuilder
    private func renderCentralLogo(centerX: CGFloat, centerY: CGFloat) -> some View {
        if logoTransition > 0 {
            VSLogo(size: 60)
                .opacity(logoTransition)
                .scaleEffect(0.8 + logoTransition )
                .position(x: centerX, y: centerY)
                .zIndex(10)  // Au-dessus des portes
        }
    }
}

// MARK: - Door Shapes for Opening

/**
 * Forme de la porte supérieure horizontale qui remonte (ouverture).
 *
 * ## Comportement
 * - **Animation** : Remonte du centre visuel vers le haut (y=0)
 * - **Avec encoche** : Demi-cercle creusé vers le bas pour accommoder le logo VS
 * - **Progression** : ease-out-quart pour un mouvement fluide
 */
private struct TopHorizontalDoorOpen: Shape {
    let progress: Double
    let screenSize: CGSize
    let visualCenterY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let easedProgress = AnimationEasing.easeOutQuart(progress)
        let centerY = visualCenterY
        
        // La porte remonte : y=centerY → y=0
        let currentY = centerY - (centerY * easedProgress)
        
        // Rayon de l'encoche pour accueillir le logo VS de 60px
        let notchRadius: CGFloat = 40
        let centerX = screenSize.width * 0.5
        
        // Rectangle avec encoche circulaire
        if easedProgress < 1.0 {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: currentY))
            
            // Bord avec encoche circulaire
            path.addLine(to: CGPoint(x: centerX + notchRadius, y: currentY))
            
            // Demi-cercle d'encoche (arc concave vers le bas)
            path.addArc(
                center: CGPoint(x: centerX, y: currentY),
                radius: notchRadius,
                startAngle: .zero,
                endAngle: .radians(-.pi),
                clockwise: true
            )
            
            path.addLine(to: CGPoint(x: 0, y: currentY))
            path.closeSubpath()
        }
        
        return path
    }
}

/**
 * Forme de la porte inférieure horizontale qui descend (ouverture).
 *
 * ## Comportement
 * - **Animation** : Descend du centre visuel vers le bas (y=height)
 * - **Avec encoche** : Demi-cercle creusé vers le haut pour accommoder le logo VS
 * - **Progression** : ease-out-quart pour un mouvement fluide
 */
private struct BottomHorizontalDoorOpen: Shape {
    let progress: Double
    let screenSize: CGSize
    let visualCenterY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let easedProgress = AnimationEasing.easeOutQuart(progress)
        let centerY = visualCenterY
        
        // La porte descend : y=centerY → y=height
        let currentY = centerY + (rect.height - centerY) * easedProgress
        
        // Rayon de l'encoche pour accueillir le logo VS de 60px
        let notchRadius: CGFloat = 40
        let centerX = screenSize.width * 0.5
        
        // Rectangle avec encoche circulaire
        if easedProgress < 1.0 {
            path.move(to: CGPoint(x: 0, y: currentY))
            
            // Bord avec encoche circulaire
            path.addLine(to: CGPoint(x: centerX - notchRadius, y: currentY))
            
            // Demi-cercle d'encoche (arc concave vers le haut)
            path.addArc(
                center: CGPoint(x: centerX, y: currentY),
                radius: notchRadius,
                startAngle: .radians(.pi),
                endAngle: .zero,
                clockwise: true
            )
            
            path.addLine(to: CGPoint(x: rect.width, y: currentY))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - Animation Easing

/**
 * Fonctions d'easing pour les animations fluides.
 */
private enum AnimationEasing {
    /**
     * Ease-out-quart : accélération rapide puis décélération progressive.
     * Parfait pour les mouvements d'ouverture naturels et fluides.
     */
    static func easeOutQuart(_ t: Double) -> Double {
        return 1 - pow(1 - t, 4)
    }
}

// MARK: - Preview

#Preview("Metal Door Open") {
    ZStack {
        // Contenu de fond pour voir l'effet d'ouverture
        LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        Text("CONTENU RÉVÉLÉ")
            .font(.largeTitle)
            .foregroundColor(.white)
        
        MetalDoorOpenTransitionView {
            print("Transition d'ouverture terminée!")
        }
    }
}
