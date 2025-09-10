//
//  GradientFactory.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Factory centralisé pour la création de gradients dans l'application.
 *
 * Ce factory évite la duplication de logique de gradients qui était
 * présente dans EndGameScreen, EnhancedScoreCard, PerformanceGauge, etc.
 *
 * ## Usage
 * ```swift
 * // Gradient basé sur le score
 * let gradient = GradientFactory.scoreBasedGradient(score: 15)
 *
 * // Gradient pour nouveau record
 * let recordGradient = GradientFactory.newRecordGradient()
 *
 * // Gradient de performance
 * let perfGradient = GradientFactory.performanceGradient(level: .expert)
 * ```
 */
struct GradientFactory {
    
    // MARK: - Score-Based Gradients
    
    /**
     * Crée un gradient basé sur le score du joueur.
     */
    static func scoreBasedGradient(score: Int, isNewRecord: Bool = false) -> LinearGradient {
        if isNewRecord {
            return newRecordGradient()
        }
        
        let performanceLevel = PerformanceLevel.from(score: score)
        return performanceGradient(level: performanceLevel)
    }
    
    /**
     * Gradient spécial pour les nouveaux records.
     */
    static func newRecordGradient() -> LinearGradient {
        return LinearGradient(
            colors: PerformanceLevel.recordColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /**
     * Gradient basé sur un niveau de performance.
     */
    static func performanceGradient(level: PerformanceLevel) -> LinearGradient {
        return LinearGradient(
            colors: level.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Border Gradients
    
    /**
     * Crée un gradient pour les bordures de cartes.
     */
    static func cardBorderGradient(score: Int, isNewRecord: Bool = false) -> LinearGradient {
        let colors = cardBorderColors(score: score, isNewRecord: isNewRecord)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /**
     * Couleurs de bordure harmonisées avec la carte performance.
     */
    static func cardBorderColors(score: Int, isNewRecord: Bool = false) -> [Color] {
        if isNewRecord {
            // Vert avec touches pour nouveau record
            return [
                Color(red: 0.2, green: 0.8, blue: 0.5).opacity(0.4),
                Color(red: 0.6, green: 0.8, blue: 0.2).opacity(0.3)
            ]
        }
        
        switch score {
        case 0...3:
            // Gris sobre
            return [
                Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.3),
                Color(red: 0.5, green: 0.5, blue: 0.5).opacity(0.2)
            ]
        case 4...8:
            // Bleu marine élégant
            return [
                Color(red: 0.2, green: 0.4, blue: 0.7).opacity(0.3),
                Color(red: 0.3, green: 0.5, blue: 0.8).opacity(0.2)
            ]
        case 9...15:
            // Violet indigo classe
            return [
                Color(red: 0.4, green: 0.3, blue: 0.7).opacity(0.3),
                Color(red: 0.5, green: 0.4, blue: 0.8).opacity(0.2)
            ]
        case 16...19:
            // Bordeaux sophistiqué
            return [
                Color(red: 0.6, green: 0.2, blue: 0.3).opacity(0.3),
                Color(red: 0.7, green: 0.3, blue: 0.4).opacity(0.2)
            ]
        default:
            // Bordeaux profond pour 20+
            return [
                Color(red: 0.7, green: 0.1, blue: 0.2).opacity(0.3),
                Color(red: 0.8, green: 0.2, blue: 0.3).opacity(0.2)
            ]
        }
    }
    
    // MARK: - Shadow Colors
    
    /**
     * Couleur d'ombre harmonisée avec la performance.
     */
    static func shadowColor(score: Int, isNewRecord: Bool = false) -> Color {
        if isNewRecord {
            return Color(red: 0.2, green: 0.8, blue: 0.5).opacity(0.1)
        }
        
        switch score {
        case 0...3:
            return Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.1)
        case 4...8:
            return Color(red: 0.2, green: 0.4, blue: 0.7).opacity(0.1)
        case 9...15:
            return Color(red: 0.4, green: 0.3, blue: 0.7).opacity(0.1)
        case 16...19:
            return Color(red: 0.6, green: 0.2, blue: 0.3).opacity(0.1)
        default:
            return Color(red: 0.7, green: 0.1, blue: 0.2).opacity(0.1)
        }
    }
    
    // MARK: - Text Gradients
    
    /**
     * Gradient pour le texte "Game Over" basé sur la performance.
     */
    static func gameOverTextGradient(score: Int, isNewRecord: Bool = false) -> LinearGradient {
        if isNewRecord {
            // Blanc pour contraste sur vert
            return LinearGradient(
                colors: [.white, .white.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Utilise les couleurs de performance pour harmonie
            return scoreBasedGradient(score: score)
        }
    }
    
    /**
     * Gradient pour le score principal.
     */
    static func scoreTextGradient(score: Int, isNewRecord: Bool = false) -> LinearGradient {
        if isNewRecord {
            return newRecordGradient()
        } else {
            let performanceLevel = PerformanceLevel.from(score: score)
            return performanceLevel.createBackgroundGradient()
        }
    }
}