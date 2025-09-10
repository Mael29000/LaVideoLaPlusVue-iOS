//
//  PerformanceGauge.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Jauge de performance animée qui visualise le niveau de score atteint.
 *
 * Cette jauge affiche visuellement :
 * - Le niveau de performance atteint (Débutant → Maître)
 * - Une barre de progression colorée
 * - Des seuils visuels pour chaque niveau
 * - Animation fluide de remplissage
 *
 * ## Usage
 * ```swift
 * PerformanceGauge(
 *     score: 25,
 *     animated: true,
 *     showLabels: true
 * )
 * ```
 */
struct PerformanceGauge: View {
    
    // MARK: - Types (Using Unified Model)
    // PerformanceLevel is now imported from Models/PerformanceLevel.swift
    
    // MARK: - Properties
    
    let score: Int
    let animated: Bool
    let showLabels: Bool
    let isNewRecord: Bool
    
    // MARK: - Initializers
    
    init(score: Int, animated: Bool, showLabels: Bool) {
        self.score = score
        self.animated = animated
        self.showLabels = showLabels
        self.isNewRecord = false
    }
    
    init(score: Int, animated: Bool, showLabels: Bool, isNewRecord: Bool) {
        self.score = score
        self.animated = animated
        self.showLabels = showLabels
        self.isNewRecord = isNewRecord
    }
    
    @State private var animatedProgress: Double = 0
    @State private var showLevelText: Bool = false
    
    // MARK: - Computed Properties
    
    private var currentLevel: PerformanceLevel {
        PerformanceLevel.from(score: score)
    }
    
    private var progress: Double {
        let maxScore = 20.0 // Score maximum pour la jauge (0-20)
        return min(Double(score) / maxScore, 1.0)
    }
    
    // Labels humoristiques basés sur le score (ou message de félicitations pour nouveau record)
    private var humorousLabel: String {
        if isNewRecord {
            return "Félicitations ! 🎉"
        }
        if score > 35 {
            return "Tu triches ?"
        }
        return currentLevel.humorousLabel
    }
    
    private var gradientColors: [Color] {
        // Si c'est un nouveau record, utiliser les couleurs spéciales vertes
        if isNewRecord {
            return PerformanceLevel.recordColors
        }
        
        let levels = PerformanceLevel.allCases
        let currentIndex = levels.firstIndex(of: currentLevel) ?? 0
        
        if currentIndex == 0 {
            return [currentLevel.primaryColor.opacity(0.3), currentLevel.primaryColor]
        } else {
            let previousLevel = levels[currentIndex - 1]
            return [previousLevel.primaryColor, currentLevel.primaryColor]
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Header avec niveau actuel
            if showLabels {
                levelHeader
            }
            
            // Barre de progression principale
            mainGauge
            
            // Seuils de niveaux
            if showLabels {
                levelIndicators
            }
        }
        .onAppear {
            if animated {
                startAnimation()
            } else {
                animatedProgress = progress
                showLevelText = true
            }
        }
    }
    
    // MARK: - Level Header
    
    @ViewBuilder
    private var levelHeader: some View {
        HStack(alignment: .top) {
            // Icône du niveau (lauriers complémentaires pour nouveau record)
            if isNewRecord {
                HStack(spacing: 4) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(PerformanceLevel.recordPrimaryColor)
                        .scaleEffect(showLevelText ? 1.0 : 0.5)
                        .opacity(showLevelText ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showLevelText)
                    
                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(PerformanceLevel.recordPrimaryColor)
                        .scaleEffect(showLevelText ? 1.0 : 0.5)
                        .opacity(showLevelText ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showLevelText)
                }
            } else {
                Image(systemName: currentLevel.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(currentLevel.primaryColor)
                    .scaleEffect(showLevelText ? 1.0 : 0.5)
                    .opacity(showLevelText ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showLevelText)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isNewRecord ? "Nouveau Record!" : currentLevel.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isNewRecord ? PerformanceLevel.recordPrimaryColor : currentLevel.primaryColor)
                
                // Label humoristique au lieu des points
                Text(humorousLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points à droite au lieu du pourcentage
            if score >= 0 {
                Text("\(score) points")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(showLevelText ? 1.0 : 0.0)
                    .animation(.easeInOut.delay(0.5), value: showLevelText)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: 300)
    }
    
    // MARK: - Main Gauge
    
    @ViewBuilder
    private var mainGauge: some View {
        ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray5))
                .frame(height: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
            
            // Progress fill
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 12)
                .scaleEffect(x: animatedProgress, y: 1.0, anchor: .leading)
                .overlay(
                    // Shine effect
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 12)
                        .scaleEffect(x: animatedProgress, y: 1.0, anchor: .leading)
                )
        }
    }
    
    // MARK: - Level Indicators
    
    @ViewBuilder
    private var levelIndicators: some View {
        HStack {
            // Échelle 0-20 avec jalons principaux
            ForEach([0, 5, 10, 15, 20], id: \.self) { milestone in
                VStack(spacing: 4) {
                    // Indicateur de seuil
                    Circle()
                        .fill(score >= milestone ? (isNewRecord ? PerformanceLevel.recordPrimaryColor : currentLevel.primaryColor) : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .scaleEffect(score >= milestone ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: score)
                    
                    // Label du jalon
                    Text("\(milestone)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if milestone != 20 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        // Animation de la barre de progression
        withAnimation(.easeOut(duration: 1.5)) {
            animatedProgress = progress
        }
        
        // Animation du texte de niveau (après un délai)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showLevelText = true
            }
        }
    }
}

// MARK: - XP Progress Bar

/**
 * Barre de progression XP pour le système de niveaux.
 */
struct XPProgressBar: View {
    let currentXP: Int
    let xpForNextLevel: Int
    let level: Int
    
    @State private var animatedProgress: Double = 0
    
    private var progress: Double {
        Double(currentXP) / Double(xpForNextLevel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header avec niveau et XP
            HStack {
                Text("Niveau \(level)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(currentXP) / \(xpForNextLevel) XP")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // Barre de progression XP
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray6))
                    .frame(height: 8)
                
                // Progress
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 8)
                    .scaleEffect(x: animatedProgress, y: 1.0, anchor: .leading)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        Text("Performance Gauge Demo")
            .font(.title2)
        
        PerformanceGauge(
            score: 20,
            animated: true,
            showLabels: true
        )
        
        PerformanceGauge(
            score: 42,
            animated: true,
            showLabels: true,
            isNewRecord: true
        )
        
        XPProgressBar(
            currentXP: 750,
            xpForNextLevel: 1000,
            level: 8
        )
    }
    .padding()
}
