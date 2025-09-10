//
//  MeshGradientText.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Composant de texte avec gradient mesh animé.
 *
 * Ce composant extrait la logique complexe de mesh gradient qui était
 * présente dans EndGameScreen (120+ lignes) et la rend réutilisable.
 *
 * ## Usage
 * ```swift
 * // Score avec mesh gradient
 * MeshGradientText(
 *     text: "42",
 *     fontSize: 90,
 *     gradientType: .newRecord
 * )
 *
 * // Game Over avec gradient performance
 * MeshGradientText(
 *     text: "GAME OVER",
 *     fontSize: 42,
 *     gradientType: .performance(score: 18)
 * )
 * ```
 */
struct MeshGradientText: View {
    
    // MARK: - Configuration
    
    enum GradientType {
        case performance(score: Int)
        case newRecord
        case gameOver(score: Int, isNewRecord: Bool)
        case custom(colors: [Color])
    }
    
    // MARK: - Properties
    
    let text: String
    let fontSize: CGFloat
    let fontName: String
    let gradientType: GradientType
    let animated: Bool
    let shadowEnabled: Bool
    
    @StateObject private var animationController = AnimationController()
    
    // MARK: - Initializers
    
    init(
        text: String,
        fontSize: CGFloat = Constants.Typography.scoreSize,
        fontName: String = "Bungee-Regular",
        gradientType: GradientType,
        animated: Bool = true,
        shadowEnabled: Bool = true
    ) {
        self.text = text
        self.fontSize = fontSize
        self.fontName = fontName
        self.gradientType = gradientType
        self.animated = animated
        self.shadowEnabled = shadowEnabled
    }
    
    // MARK: - Computed Properties
    
    private var gradientColors: [Color] {
        switch gradientType {
        case .performance(let score):
            let level = PerformanceLevel.from(score: score)
            return level.gradientColors
            
        case .newRecord:
            return PerformanceLevel.recordColors
            
        case .gameOver(let score, let isNewRecord):
            if isNewRecord {
                return [.white, .white.opacity(0.9)]
            } else {
                let level = PerformanceLevel.from(score: score)
                return level.gradientColors
            }
            
        case .custom(let colors):
            return colors
        }
    }
    
    private var meshGradient: LinearGradient {
        if animated, #available(iOS 18.0, *) {
            return animatedMeshGradient
        } else {
            return staticGradient
        }
    }
    
    private var staticGradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @available(iOS 18.0, *)
    private var animatedMeshGradient: LinearGradient {
        let phase = animationController.meshPhase
        let expandedColors = createExpandedColorArray(from: gradientColors, phase: phase)
        
        return LinearGradient(
            colors: expandedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(text)
            .font(.custom(fontName, size: fontSize))
            .foregroundStyle(meshGradient)
            .shadow(
                color: shadowEnabled ? .black.opacity(0.2) : .clear,
                radius: shadowEnabled ? 4 : 0,
                x: shadowEnabled ? 2 : 0,
                y: shadowEnabled ? 2 : 0
            )
            .overlay(
                // Effet de brillance pour les gros scores
                shineOverlay
            )
            .onAppear {
                if animated {
                    animationController.startMeshAnimation()
                }
            }
            .onDisappear {
                animationController.stopAllAnimations()
            }
    }
    
    // MARK: - Shine Effect
    
    @ViewBuilder
    private var shineOverlay: some View {
        if shouldShowShine {
            Text(text)
                .font(.custom(fontName, size: fontSize))
                .foregroundStyle(shineGradient)
        }
    }
    
    private var shouldShowShine: Bool {
        switch gradientType {
        case .performance(let score):
            return score >= Constants.Performance.particlesLightThreshold
        case .newRecord:
            return true
        case .gameOver:
            return false
        case .custom:
            return false
        }
    }
    
    private var shineGradient: LinearGradient {
        let intensity = getShineIntensity()
        return LinearGradient(
            colors: [
                Color.white.opacity(0.0),
                Color.white.opacity(intensity),
                Color.white.opacity(0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func getShineIntensity() -> Double {
        switch gradientType {
        case .performance(let score):
            return score >= Constants.Performance.particlesLightThreshold ? 0.4 : 0.2
        case .newRecord:
            return 0.5
        default:
            return 0.2
        }
    }
    
    // MARK: - Mesh Gradient Logic
    
    private func createExpandedColorArray(from colors: [Color], phase: CGFloat) -> [Color] {
        let time = phase * 0.5
        
        switch colors.count {
        case 1:
            return createSingleColorMesh(base: colors[0], time: time)
        case 2:
            return createTwoColorMesh(color1: colors[0], color2: colors[1], time: time)
        case 3:
            return createThreeColorMesh(color1: colors[0], color2: colors[1], color3: colors[2], time: time)
        default:
            return createMultiColorMesh(colors: colors, time: time)
        }
    }
    
    private func createSingleColorMesh(base: Color, time: CGFloat) -> [Color] {
        let variation1 = base.opacity(0.8 + sin(time) * 0.2)
        let variation2 = base.opacity(0.6 + cos(time * 1.5) * 0.4)
        return [base, variation1, variation2, base]
    }
    
    private func createTwoColorMesh(color1: Color, color2: Color, time: CGFloat) -> [Color] {
        let blend1 = blendColors(color1, color2, ratio: 0.3 + sin(time) * 0.2)
        let blend2 = blendColors(color1, color2, ratio: 0.7 + cos(time * 1.3) * 0.2)
        return [color1, blend1, blend2, color2]
    }
    
    private func createThreeColorMesh(color1: Color, color2: Color, color3: Color, time: CGFloat) -> [Color] {
        let blend1 = blendColors(color1, color2, ratio: 0.5 + sin(time) * 0.3)
        let blend2 = blendColors(color2, color3, ratio: 0.5 + cos(time * 1.2) * 0.3)
        let blend3 = blendColors(color1, color3, ratio: 0.4 + sin(time * 0.8) * 0.2)
        return [color1, blend1, color2, blend2, color3, blend3]
    }
    
    private func createMultiColorMesh(colors: [Color], time: CGFloat) -> [Color] {
        var result: [Color] = []
        for i in 0..<colors.count {
            result.append(colors[i])
            if i < colors.count - 1 {
                let nextIndex = (i + 1) % colors.count
                let blend = blendColors(
                    colors[i],
                    colors[nextIndex],
                    ratio: 0.5 + sin(time + CGFloat(i)) * 0.3
                )
                result.append(blend)
            }
        }
        return result
    }
    
    private func blendColors(_ color1: Color, _ color2: Color, ratio: CGFloat) -> Color {
        // Blend simplifié - en pratique, utiliser une librairie de couleur
        return Color(
            red: (color1.cgColor?.components?[0] ?? 0) * (1 - ratio) + (color2.cgColor?.components?[0] ?? 0) * ratio,
            green: (color1.cgColor?.components?[1] ?? 0) * (1 - ratio) + (color2.cgColor?.components?[1] ?? 0) * ratio,
            blue: (color1.cgColor?.components?[2] ?? 0) * (1 - ratio) + (color2.cgColor?.components?[2] ?? 0) * ratio
        )
    }
}

// MARK: - Convenience Initializers

extension MeshGradientText {
    
    /**
     * Texte de score avec gradient basé sur la performance.
     */
    static func score(
        _ value: Int,
        isNewRecord: Bool = false,
        fontSize: CGFloat = Constants.Typography.scoreSize
    ) -> MeshGradientText {
        MeshGradientText(
            text: "\(value)",
            fontSize: fontSize,
            gradientType: isNewRecord ? .newRecord : .performance(score: value)
        )
    }
    
    /**
     * Texte Game Over avec gradient harmonisé.
     */
    static func gameOver(
        score: Int,
        isNewRecord: Bool = false
    ) -> MeshGradientText {
        MeshGradientText(
            text: "GAME OVER",
            fontSize: Constants.Typography.gameOverSize,
            gradientType: .gameOver(score: score, isNewRecord: isNewRecord)
        )
    }
    
    /**
     * Nouveau record avec animation spéciale.
     */
    static func newRecord(
        score: Int,
        fontSize: CGFloat = Constants.Typography.newRecordScoreSize
    ) -> MeshGradientText {
        MeshGradientText(
            text: "\(score)",
            fontSize: fontSize,
            gradientType: .newRecord,
            animated: true
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("MeshGradientText Demo")
            .font(.title2)
        
        MeshGradientText.score(42, isNewRecord: true)
        
        MeshGradientText.gameOver(score: 18, isNewRecord: false)
        
        MeshGradientText(
            text: "EXPERT",
            fontSize: 24,
            gradientType: .performance(score: 18)
        )
        
        MeshGradientText(
            text: "CUSTOM",
            fontSize: 32,
            gradientType: .custom(colors: [.purple, .pink, .orange])
        )
    }
    .padding()
    .background(.black.opacity(0.1))
}