import SwiftUI

// MARK: - Metal Door Close Transition

/**
 * Animation de fermeture des portes métalliques pour la transition Game → EndGame.
 *
 * ## Effet visuel
 * Deux portes horizontales se ferment vers le centre de l'écran :
 * - **Porte supérieure** : Bleu métallique, descend du haut vers le centre
 * - **Porte inférieure** : Rouge métallique, monte du bas vers le centre
 * - **Bouton central** : Transform du bouton d'erreur rouge vers le logo VS
 * - **Encoches circulaires** : Découpes dans les portes pour accommoder le bouton
 *
 * ## Timing de l'animation
 * - **Durée totale** : 1.5 secondes
 * - **Phase 1 (0-60%)** : Fermeture des portes uniquement
 * - **Phase 2 (60-100%)** : Transformation du bouton rouge → logo VS
 * - **Easing** : ease-out-quart pour un effet naturel sans rebond
 *
 * ## Architecture technique
 * - Double GeometryReader pour gérer les safe areas correctement
 * - Timer manuel 60 FPS pour éviter les optimisations SwiftUI
 * - Shapes personnalisées pour les portes avec encoches circulaires
 * - Overlays avec gradients métalliques et effets de rayures
 */
struct MetalDoorCloseTransitionView: View {
    
    // MARK: - Properties
    
    @State private var animationProgress: Double = 0
    @State private var animationTimer: Timer?
    @State private var buttonTransition: Double = 0  // 0 = bouton rouge, 1 = logo VS
    
    let onComplete: () -> Void
    
    // MARK: - Constants
    
    private let animationDuration: Double = 1.5
    private let frameRate: Double = 60.0
    private let buttonAnimationStartThreshold: Double = 0.6  // Le bouton change à 60% de l'animation
    
    // MARK: - Body
    
    var body: some View {
        // Architecture double GeometryReader pour capturer les safe areas correctement
        GeometryReader { safeAreaGeometry in
            GeometryReader { fullScreenGeometry in
                MetalDoorCloseOverlay(
                    progress: animationProgress,
                    fullScreenGeometry: fullScreenGeometry,
                    safeAreaGeometry: safeAreaGeometry,
                    buttonTransition: buttonTransition
                )
            }
            .ignoresSafeArea(.all)  // Les portes couvrent tout l'écran incluant les safe areas
        }
        .onAppear { startCloseAnimation() }
        .onDisappear { stopAnimation() }
    }
    
    // MARK: - Animation Control
    
    /**
     * Démarre l'animation de fermeture avec feedback haptique et timer manuel.
     *
     * Le timer manuel évite les optimisations SwiftUI qui peuvent faire sauter
     * l'animation de 0 à 1 directement, garantissant un rendu fluide à 60 FPS.
     */
    private func startCloseAnimation() {
        print("🚪 [MetalDoorClose] Démarrage de l'animation de fermeture")
        
        // Feedback haptique de début - effet "verrouillage"
        triggerStartHaptics()
        
        let startTime = Date()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / animationDuration, 1.0)
            
            DispatchQueue.main.async {
                animationProgress = progress
                
                // Animation du bouton : démarre quand les portes sont à 60% fermées
                if progress >= buttonAnimationStartThreshold {
                    let buttonPhaseProgress = (progress - buttonAnimationStartThreshold) / (1.0 - buttonAnimationStartThreshold)
                    buttonTransition = buttonPhaseProgress
                }
                
                print("🚪 [MetalDoorClose] Progress: \(String(format: "%.2f", progress))%, Button: \(String(format: "%.2f", buttonTransition))")
                
                // Animation terminée
                if progress >= 1.0 {
                    timer.invalidate()
                    scheduleCompletion()
                }
            }
        }
    }
    
    /**
     * Déclenche les retours haptiques de début d'animation.
     */
    private func triggerStartHaptics() {
        let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        heavyImpact.impactOccurred()
        
        // Second impact pour l'effet de "lancement"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        }
    }
    
    /**
     * Programme la finalisation de l'animation avec un délai.
     */
    private func scheduleCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🚪 [MetalDoorClose] Animation terminée, navigation vers EndGame")
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

// MARK: - Metal Door Close Overlay

/**
 * Overlay contenant les formes des portes métalliques et le bouton central.
 *
 * ## Responsabilités
 * - Rendre les deux portes horizontales avec leurs effets visuels
 * - Gérer la transformation du bouton central
 * - Coordonner les positions basées sur les safe areas
 */
private struct MetalDoorCloseOverlay: View {
    
    // MARK: - Properties
    
    let progress: Double
    let fullScreenGeometry: GeometryProxy    // Taille écran complet avec safe areas
    let safeAreaGeometry: GeometryProxy      // Taille zone visible sans safe areas
    let buttonTransition: Double
    
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
            
            // MARK: - Central Button Animation
            renderCentralButton(centerX: safeCenterX, centerY: visualCenterY)
        }
        .frame(width: fullScreenGeometry.size.width, height: fullScreenGeometry.size.height)
        .clipped()
    }
    
    // MARK: - Door Rendering
    
    /**
     * Rend la porte supérieure bleue avec ses effets métalliques.
     */
    @ViewBuilder
    private func renderTopDoor(visualCenterY: CGFloat) -> some View {
        Group {
            // Forme principale avec dégradé métallique bleu
            TopHorizontalDoor(
                progress: progress,
                screenSize: fullScreenGeometry.size,
                visualCenterY: visualCenterY
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.4),    // Bleu foncé métallique
                        Color(red: 0.05, green: 0.15, blue: 0.35), // Plus sombre au centre
                        Color(red: 0.08, green: 0.18, blue: 0.38)  // Variation pour relief
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Rayures métalliques pour l'effet de texture
                TopHorizontalDoor(
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
     * Rend la porte inférieure rouge avec ses effets métalliques.
     */
    @ViewBuilder
    private func renderBottomDoor(visualCenterY: CGFloat) -> some View {
        Group {
            // Forme principale avec dégradé métallique rouge
            BottomHorizontalDoor(
                progress: progress,
                screenSize: fullScreenGeometry.size,
                visualCenterY: visualCenterY
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.8, green: 0.3, blue: 0.3),    // Rouge métallique
                        Color(red: 0.9, green: 0.25, blue: 0.25),  // Plus lumineux
                        Color(red: 0.75, green: 0.35, blue: 0.35)  // Variation pour relief
                    ],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            )
            .overlay(
                // Rayures métalliques pour l'effet de texture
                BottomHorizontalDoor(
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
     * Rend le bouton central avec sa transformation rouge → logo VS.
     */
    @ViewBuilder
    private func renderCentralButton(centerX: CGFloat, centerY: CGFloat) -> some View {
        ZStack {
            // Bouton d'erreur rouge (disparaît progressivement)
            Circle()
                .fill(Color.red)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )
                .opacity(1.0 - buttonTransition)
                .scaleEffect(1.0 - buttonTransition * 0.2)  // Rétrécit en disparaissant
            
            // Logo VS (apparaît progressivement)
            VSLogo(size: 80)
                .opacity(buttonTransition)
                .scaleEffect(0.8 + buttonTransition * 0.2)  // Grandit en apparaissant
        }
        .position(x: centerX, y: centerY)
        .zIndex(10)  // Au-dessus des portes
    }
}

// MARK: - Door Shapes

/**
 * Forme de la porte supérieure horizontale avec encoche circulaire.
 *
 * ## Comportement
 * - **Animation** : Descend du haut (y=0) vers le centre visuel
 * - **Encoche** : Demi-cercle creusé vers le bas pour le bouton
 * - **Progression** : ease-out-quart pour un mouvement naturel
 */
private struct TopHorizontalDoor: Shape {
    let progress: Double
    let screenSize: CGSize
    let visualCenterY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let easedProgress = AnimationEasing.easeOutQuart(progress)
        let centerX = screenSize.width * 0.5
        let centerY = visualCenterY
        
        // La porte descend : y=0 → y=centerY
        let currentY = centerY * easedProgress
        
        // Rayon de l'encoche pour accueillir le bouton de 80px
        let notchRadius: CGFloat = 40
        
        if easedProgress > 0 {
            // Rectangle principal de la porte
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
 * Forme de la porte inférieure horizontale avec encoche circulaire.
 *
 * ## Comportement
 * - **Animation** : Monte du bas (y=height) vers le centre visuel
 * - **Encoche** : Demi-cercle creusé vers le haut pour le bouton
 * - **Progression** : ease-out-quart pour un mouvement naturel
 */
private struct BottomHorizontalDoor: Shape {
    let progress: Double
    let screenSize: CGSize
    let visualCenterY: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let easedProgress = AnimationEasing.easeOutQuart(progress)
        let centerX = screenSize.width * 0.5
        let centerY = visualCenterY
        
        // La porte monte : y=height → y=centerY
        let currentY = rect.height - (rect.height - centerY) * easedProgress
        
        // Rayon de l'encoche pour accueillir le bouton de 80px
        let notchRadius: CGFloat = 40
        
        if easedProgress > 0 {
            // Rectangle principal de la porte
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
     * Parfait pour les mouvements de fermeture naturels sans rebond.
     */
    static func easeOutQuart(_ t: Double) -> Double {
        return 1 - pow(1 - t, 4)
    }
}

// MARK: - Preview

#Preview("Metal Door Close") {
    MetalDoorCloseTransitionView {
        print("Transition de fermeture terminée!")
    }
}
