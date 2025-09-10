//
//  EnhancedScoreCard.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Carte de score améliorée avec effets visuels avancés et animations.
 *
 * Cette carte remplace l'ancienne carte de score avec :
 * - Système de particules intégré
 * - Animations de morphing pour les gros scores
 * - Gradients dynamiques basés sur la performance
 * - Effets de profondeur et materials
 * - Micro-interactions et feedback haptique
 *
 * ## Usage
 * ```swift
 * EnhancedScoreCard(
 *     score: 25,
 *     ranking: "TOP 15%",
 *     performanceMessage: "Excellent !",
 *     isNewRecord: false,
 *     animated: true
 * )
 * ```
 */
struct EnhancedScoreCard: View {
    
    // MARK: - Properties
    
    let score: Int
    let ranking: String
    let performanceMessage: String
    let isNewRecord: Bool
    let animated: Bool
    
    @State private var cardScale: CGFloat = 0.8
    @State private var scoreScale: CGFloat = 0.5
    @State private var showParticles: Bool = false
    @State private var breathingAnimation: Bool = false
    @State private var meshAnimationPhase: CGFloat = 0
    @State private var showContent: Bool = false
    
    // MARK: - Performance Level (Using Unified Model)
    
    private var performanceLevel: PerformanceLevel {
        PerformanceLevel.from(score: score)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background avec effet de profondeur
            cardBackground
            
            // Système de particules (si score élevé)
            if showParticles && performanceLevel.shouldShowParticles {
                ParticleSystem.forScore(score, isActive: showParticles, isNewRecord: isNewRecord)
                    .clipped()
            }
            
            // Contenu principal
            cardContent
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
        .scaleEffect(cardScale)
        .shadow(
            color: scoreCardShadowColor,
            radius: 8,
            x: 0, y: 4
        )
        .onAppear {
            if animated {
                startEntryAnimation()
            } else {
                cardScale = 1.0
                scoreScale = 1.0
                showContent = true
                if performanceLevel.shouldShowParticles { showParticles = true }
            }
        }
        .onTapGesture {
            playTapAnimation()
        }
    }
    
    // MARK: - Card Background
    
    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                // Bordure colorée identique à la carte performance
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: scoreCardBorderColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
    
    // MARK: - Card Content
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(spacing: 20) {
            // Score principal avec effets
            scoreDisplay
            
            // Ranking et performance
            performanceInfo
            
            Divider()
                .opacity(0.5)
            
            // Message de performance
            messageSection
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Score Display
    
    @ViewBuilder
    private var scoreDisplay: some View {
        ZStack {
            // Record indicator (lauriers complémentaires formant un cercle) si nouveau record
            if isNewRecord {
                HStack(spacing: 16) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundColor(.green)
                        .opacity(0.3)
                        .rotationEffect(.degrees(-20))
                        
                    
                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundColor(.green)
                        .opacity(0.3)
                        .rotationEffect(.degrees(20))
                        
                }.offset(y: sin(meshAnimationPhase * 0.4) * 6)
                .onAppear {
                    startMeshAnimation()
                }
            }
            
            // Score avec gradient animé
            Text("\(score)")
                .font(.custom("Bungee-Regular", size: isNewRecord ? 70 : 80))
                .foregroundStyle(
                    scoreGradient
                )
                .scaleEffect(scoreScale)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                .overlay(
                    // Shine effect pour les gros scores
                    Text("\(score)")
                        .font(.custom("Bungee-Regular", size: isNewRecord ? 70 : 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(score >= 15 ? 0.4 : 0.2),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(scoreScale)
                )
        }
    }
    
    // MARK: - Performance Info
    
    @ViewBuilder
    private var performanceInfo: some View {
        VStack(spacing: 8) {
            // Record indicator ou ranking
            if isNewRecord {
                    
                    
                    Text("Nouveau Record !")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                
            } else {
                Text(ranking)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
        }
    }
    
    // MARK: - Message Section
    
    @ViewBuilder
    private var messageSection: some View {
        HStack {

            
            Text(performanceMessage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
       
        }
    }
    
    // MARK: - Computed Properties
    
    private var scoreGradient: LinearGradient {
        if isNewRecord {
            return PerformanceLevel.recordGradient()
        } else {
            // Utilise les couleurs de la jauge de performance
            return performanceLevel.createBackgroundGradient()
        }
    }
    
    // Couleurs de bordure harmonisées avec la carte performance
    private var scoreCardBorderColors: [Color] {
        if isNewRecord {
            // Vert avec touches dorées pour nouveau record
            return [Color(red: 0.2, green: 0.8, blue: 0.5).opacity(0.4), Color(red: 0.6, green: 0.8, blue: 0.2).opacity(0.3)]
        }
        
        switch score {
        case 0...3:
            // Gris sobre
            return [Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.3), Color(red: 0.5, green: 0.5, blue: 0.5).opacity(0.2)]
        case 4...8:
            // Bleu marine élégant
            return [Color(red: 0.2, green: 0.4, blue: 0.7).opacity(0.3), Color(red: 0.3, green: 0.5, blue: 0.8).opacity(0.2)]
        case 9...15:
            // Violet indigo classe
            return [Color(red: 0.4, green: 0.3, blue: 0.7).opacity(0.3), Color(red: 0.5, green: 0.4, blue: 0.8).opacity(0.2)]
        case 16...19:
            // Bordeaux sophistiqué
            return [Color(red: 0.6, green: 0.2, blue: 0.3).opacity(0.3), Color(red: 0.7, green: 0.3, blue: 0.4).opacity(0.2)]
        default:
            // Bordeaux profond pour 20+
            return [Color(red: 0.7, green: 0.1, blue: 0.2).opacity(0.3), Color(red: 0.8, green: 0.2, blue: 0.3).opacity(0.2)]
        }
    }
    
    // Couleur d'ombre harmonisée avec la carte performance
    private var scoreCardShadowColor: Color {
        if isNewRecord {
            // Vert pour nouveau record
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
    
    private var performanceIcon: Image {
        return Image(systemName: performanceLevel.icon)
    }
    
    // MARK: - Animations
    
    private func startEntryAnimation() {
        // Animation séquentielle pour l'entrée
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            cardScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                scoreScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if performanceLevel.shouldShowParticles {
                showParticles = true
            }
            
            if performanceLevel.shouldBreath {
                breathingAnimation = true
            }
        }
    }
    
    private func playTapAnimation() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animation de tap
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scoreScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scoreScale = 1.0
            }
        }
        
        // Flash des particules
        if performanceLevel.shouldShowParticles {
            showParticles = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showParticles = true
            }
        }
    }
    
    private func startMeshAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            meshAnimationPhase += 0.02
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("Enhanced Score Cards")
            .font(.title)
        
        EnhancedScoreCard(
            score: 42,
            ranking: "TOP 5%",
            performanceMessage: "Performance légendaire ! 🔥",
            isNewRecord: true,
            animated: true
        )
        
        EnhancedScoreCard(
            score: 1,
            ranking: "TOP 45%",
            performanceMessage: "Pas mal ! Continue comme ça 👍",
            isNewRecord: false,
            animated: true
        )
    }
    .padding()
}
