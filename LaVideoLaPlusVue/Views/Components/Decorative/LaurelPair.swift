//
//  LaurelPair.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Composant réutilisable pour afficher une paire de lauriers complémentaires.
 *
 * Ce composant centralise la logique d'affichage des lauriers qui était
 * dupliquée dans EndGameScreen, EnhancedScoreCard, PerformanceGauge.
 *
 * ## Usage
 * ```swift
 * // Lauriers simples
 * LaurelPair(size: .medium, color: .green)
 *
 * // Lauriers avec rotation pour effet couronne
 * LaurelPair(size: .large, color: .green, rotation: 20)
 *
 * // Lauriers avec animation flottante
 * LaurelPair(size: .large, color: .green, floatingAnimation: true)
 * ```
 */
struct LaurelPair: View {
    
    // MARK: - Configuration
    
    enum Size {
        case small, medium, large, extraLarge
        
        var iconSize: CGFloat {
            switch self {
            case .small: return Constants.IconSize.laurelSmall
            case .medium: return Constants.IconSize.laurelMedium
            case .large: return Constants.IconSize.laurelLarge
            case .extraLarge: return Constants.IconSize.laurelExtraLarge
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return Constants.Laurel.smallSpacing
            case .medium: return Constants.Laurel.mediumSpacing
            case .large: return Constants.Laurel.largeSpacing
            case .extraLarge: return Constants.Laurel.wideSpacing
            }
        }
    }
    
    // MARK: - Properties
    
    let size: Size
    let color: Color
    let opacity: Double
    let rotation: Double
    let spacing: CGFloat?
    let floatingAnimation: Bool
    let scaleEffect: CGFloat
    let shadowRadius: CGFloat
    
    @StateObject private var animationController = AnimationController()
    
    // MARK: - Initializers
    
    init(
        size: Size,
        color: Color = .green,
        opacity: Double = Constants.Opacity.strong,
        rotation: Double = 0,
        spacing: CGFloat? = nil,
        floatingAnimation: Bool = false,
        scaleEffect: CGFloat = 1.0,
        shadowRadius: CGFloat = 0
    ) {
        self.size = size
        self.color = color
        self.opacity = opacity
        self.rotation = rotation
        self.spacing = spacing
        self.floatingAnimation = floatingAnimation
        self.scaleEffect = scaleEffect
        self.shadowRadius = shadowRadius
    }
    
    // MARK: - Computed Properties
    
    private var actualSpacing: CGFloat {
        spacing ?? size.spacing
    }
    
    private var leftRotation: Double {
        switch rotation {
        case 0: return 0
        default: return -rotation
        }
    }
    
    private var rightRotation: Double {
        switch rotation {
        case 0: return 0
        default: return rotation
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: actualSpacing) {
            // Laurier gauche
            Image(systemName: "laurel.leading")
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(color)
                .opacity(opacity)
                .scaleEffect(scaleEffect)
                .rotationEffect(.degrees(leftRotation))
                .shadow(color: color.opacity(Constants.Opacity.light), radius: shadowRadius)
                .offset(y: floatingAnimation ? animationController.floatingOffset(phase: 0) : 0)
            
            // Laurier droit  
            Image(systemName: "laurel.trailing")
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(color)
                .opacity(opacity)
                .scaleEffect(scaleEffect)
                .rotationEffect(.degrees(rightRotation))
                .shadow(color: color.opacity(Constants.Opacity.light), radius: shadowRadius)
                .offset(y: floatingAnimation ? animationController.floatingOffset(phase: 0.5) : 0)
        }
        .onAppear {
            if floatingAnimation {
                animationController.startMeshAnimation()
            }
        }
        .onDisappear {
            animationController.stopAllAnimations()
        }
    }
}

// MARK: - Convenience Initializers

extension LaurelPair {
    
    /**
     * Lauriers pour nouveau record avec configuration optimisée.
     */
    static func newRecord(size: Size = .large) -> LaurelPair {
        LaurelPair(
            size: size,
            color: .green,
            opacity: Constants.Opacity.strong,
            rotation: Constants.Laurel.largeRotation,
            floatingAnimation: true,
            shadowRadius: Constants.Effects.shadowRadius
        )
    }
    
    /**
     * Lauriers décoratifs simples.
     */
    static func decorative(size: Size = .medium, color: Color = .green) -> LaurelPair {
        LaurelPair(
            size: size,
            color: color,
            opacity: Constants.Opacity.mostlyOpaque
        )
    }
    
    /**
     * Lauriers pour encadrer un élément (espacement négatif).
     */
    static func framing(size: Size = .large, color: Color = .green, rotation: Double = 15) -> LaurelPair {
        LaurelPair(
            size: size,
            color: color,
            opacity: Constants.Opacity.medium,
            rotation: rotation,
            spacing: Constants.Laurel.overlappingSpacing
        )
    }
    
    /**
     * Lauriers avec animation de respiration.
     */
    static func breathing(size: Size = .medium, color: Color = .green) -> LaurelPair {
        let laurel = LaurelPair(
            size: size,
            color: color,
            opacity: Constants.Opacity.mostlyOpaque
        )
        
        DispatchQueue.main.async {
            laurel.animationController.startBreathingAnimation()
        }
        
        return laurel
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("LaurelPair Demo")
            .font(.title2)
        
        // Différentes tailles
        HStack(spacing: 20) {
            VStack {
                LaurelPair(size: .small)
                Text("Small")
                    .font(.caption)
            }
            
            VStack {
                LaurelPair(size: .medium)
                Text("Medium")
                    .font(.caption)
            }
            
            VStack {
                LaurelPair(size: .large)
                Text("Large")
                    .font(.caption)
            }
        }
        
        // Configurations spéciales
        VStack(spacing: 20) {
            LaurelPair.newRecord(size: .large)
            Text("New Record")
                .font(.caption)
            
            LaurelPair.framing(size: .medium)
            Text("Framing")
                .font(.caption)
            
            LaurelPair.decorative(size: .medium, color: .blue)
            Text("Decorative Blue")
                .font(.caption)
        }
    }
    .padding()
}