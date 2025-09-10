import SwiftUI

// MARK: - Simple Metal Door Close Transition

/**
 * Animation de fermeture des portes métalliques basée sur l'original.
 * Utilise les mêmes portes complexes mais sans bouton d'erreur rouge.
 * Affiche juste le logo VS au centre une fois les portes fermées.
 */
struct SimpleMetalDoorCloseTransitionView: View {
    
    // MARK: - Properties
    
    @State private var animationProgress: Double = 0
    @State private var animationTimer: Timer?
    @State private var buttonTransition: Double = 0  // 0 = rien, 1 = logo VS
    
    let onComplete: () -> Void
    
    // MARK: - Constants
    
    private let animationDuration: Double = 1.5
    private let frameRate: Double = 60.0
    private let buttonAnimationStartThreshold: Double = 0.6  // Le logo apparaît à 60% de l'animation
    
    // MARK: - Body
    
    var body: some View {
        // Architecture double GeometryReader pour capturer les safe areas correctement
        GeometryReader { safeAreaGeometry in
            GeometryReader { fullScreenGeometry in
                SimpleMetalDoorCloseOverlay(
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
    
    private func startCloseAnimation() {
        print("🚪 [SimpleMetalDoorClose] Démarrage de l'animation de fermeture")
        
        // Feedback haptique de début - effet "verrouillage"
        triggerStartHaptics()
        
        let startTime = Date()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / animationDuration, 1.0)
            
            DispatchQueue.main.async {
                animationProgress = progress
                
                print("🚪 [SimpleMetalDoorClose] Progress: \(String(format: "%.2f", progress))%")
                
                // Animation terminée
                if progress >= 1.0 {
                    timer.invalidate()
                    scheduleCompletion()
                }
            }
        }
    }
    
    private func triggerStartHaptics() {
        let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        heavyImpact.impactOccurred()
        
        // Second impact pour l'effet de "lancement"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        }
    }
    
    private func scheduleCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🚪 [SimpleMetalDoorClose] Animation terminée, navigation vers GameScreen")
            onComplete()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Simple Metal Door Close Overlay

/**
 * Overlay contenant les formes des portes métalliques et le bouton central.
 *
 * ## Responsabilités
 * - Rendre les deux portes horizontales avec leurs effets visuels
 * - Gérer la transformation du bouton central (sans bouton rouge)
 * - Coordonner les positions basées sur les safe areas
 */
private struct SimpleMetalDoorCloseOverlay: View {
    
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
    
    // MARK: - Door Rendering (copié de l'original)
    
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
    
    // MARK: - Central Button Rendering
    
    /**
     * Rend le logo VS central présent dès le début (pas de bouton rouge).
     */
    @ViewBuilder
    private func renderCentralButton(centerX: CGFloat, centerY: CGFloat) -> some View {
        ZStack {
            // Logo VS toujours visible (pas de transition depuis un bouton rouge)
            VSLogo(size: 80)
                .opacity(1.0)  // Toujours visible
                .scaleEffect(1.0)  // Taille normale constante
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