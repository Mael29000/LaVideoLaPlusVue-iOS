//
//  PerformanceLevel.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Modèle unifié des niveaux de performance à l'échelle de l'application.
 *
 * Ce modèle centralise tous les aspects liés aux niveaux de performance :
 * - Plages de scores
 * - Couleurs associées
 * - Icônes et labels
 * - Logique de progression
 *
 * Utilisé par :
 * - EnhancedScoreCard
 * - PerformanceGauge
 * - EndGameScreen
 * - Système de célébrations
 */
enum PerformanceLevel: String, CaseIterable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire" 
    case advanced = "Confirmé"
    case expert = "Expert"
    case master = "Maître"
    
    // MARK: - Score Ranges
    
    var scoreRange: ClosedRange<Int> {
        switch self {
        case .beginner: return 0...3
        case .intermediate: return 4...8
        case .advanced: return 9...15
        case .expert: return 16...19
        case .master: return 20...Int.max
        }
    }
    
    static func from(score: Int) -> PerformanceLevel {
        return PerformanceLevel.allCases.first { $0.scoreRange.contains(score) } ?? .beginner
    }
    
    // MARK: - Visual Properties
    
    var primaryColor: Color {
        switch self {
        case .beginner: return .gray
        case .intermediate: return .blue
        case .advanced: return .purple  // Changé de vert à violet pour éviter confusion avec nouveau record
        case .expert: return .orange
        case .master: return .red
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .beginner: return [primaryColor.opacity(0.6), primaryColor.opacity(0.8)]
        case .intermediate: return [primaryColor.opacity(0.6), primaryColor]
        case .advanced: return [primaryColor.opacity(0.7), primaryColor]
        case .expert: return [primaryColor.opacity(0.6), primaryColor]
        case .master: return [primaryColor, .pink, .orange]
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "tortoise.fill"
        case .intermediate: return "figure.walk"
        case .advanced: return "figure.run"
        case .expert: return "bolt.fill"
        case .master: return "crown.fill"
        }
    }
    
    // MARK: - Humorous Labels
    
    var humorousLabel: String {
        switch self {
        case .beginner: return "Pas ouf"
        case .intermediate: return "À quelques refs"
        case .advanced: return "Solide"
        case .expert: return "À passé trop de temps sur YouTube"
        case .master: return "À passé trop de temps au chômage"
        }
    }
    
    // MARK: - Behavior Properties
    
    var shouldShowParticles: Bool {
        switch self {
        case .beginner, .intermediate: return false
        case .advanced, .expert, .master: return true
        }
    }
    
    var shouldBreath: Bool {
        switch self {
        case .beginner, .intermediate, .advanced: return false
        case .expert, .master: return true
        }
    }
    
    var particleThreshold: Int {
        switch self {
        case .beginner, .intermediate: return 15
        case .advanced: return 15
        case .expert: return 20
        case .master: return 36
        }
    }
    
    // MARK: - Compatibility Properties
    
    /// Alias for gradientColors to maintain compatibility
    var colors: [Color] {
        return gradientColors
    }
    
    /// Alias for humorousLabel to maintain compatibility
    var message: String {
        return humorousLabel
    }
    
    /// Emoji representation for the performance level
    var emoji: String {
        switch self {
        case .beginner: return "🐢"
        case .intermediate: return "🚀"
        case .advanced: return "⭐"
        case .expert: return "🔥" 
        case .master: return "👑"
        }
    }
    
    // MARK: - Record Colors
    
    /// Couleurs spéciales pour les nouveaux records
    static var recordColors: [Color] {
        return [.green, .mint, .teal]
    }
    
    /// Couleur principale pour les nouveaux records  
    static var recordPrimaryColor: Color {
        return .green
    }
    
    // MARK: - Gradient Helpers
    
    func createBorderGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                primaryColor.opacity(0.6),
                primaryColor
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func createBackgroundGradient() -> LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Extensions for Special Cases

extension PerformanceLevel {
    /**
     * Retourne une version plus intense pour les nouveaux records
     */
    var recordColors: [Color] {
        return [.green, .mint, .teal]
    }
    
    /**
     * Gradient spécial pour les nouveaux records
     */
    static func recordGradient() -> LinearGradient {
        LinearGradient(
            colors: [.green, .mint, .teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}