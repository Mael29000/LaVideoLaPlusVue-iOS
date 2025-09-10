//
//  ScoreDisplayCard.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Composant de carte d'affichage du score principal avec animations.
 *
 * Ce composant extrait la logique d'affichage du score qui était
 * dans EndGameScreen et utilise nos nouveaux composants réutilisables.
 *
 * ## Usage
 * ```swift
 * ScoreDisplayCard(
 *     score: 42,
 *     ranking: "TOP 5%",
 *     isNewRecord: true,
 *     animated: true
 * )
 * ```
 */
struct ScoreDisplayCard: View {
    
    // MARK: - Properties
    
    let score: Int
    let ranking: String
    let isNewRecord: Bool
    let animated: Bool
    
    @State private var showContent = false
    @State private var showScore = false
    @State private var showRanking = false
    
    // MARK: - Computed Properties
    
    private var performanceLevel: PerformanceLevel {
        PerformanceLevel.from(score: score)
    }
    
    private var humorousMessage: String {
        performanceLevel.humorousLabel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.Layout.standardSpacing) {
            
            // Score principal avec lauriers pour nouveau record
            scoreSection
            
            // Séparateur
            if showContent {
                Divider()
                    .background(Color.primary.opacity(Constants.Opacity.medium))
                    .frame(maxWidth: 150)
                    .scaleEffect(showRanking ? 1.0 : 0.0)
                    .opacity(showRanking ? 1.0 : 0.0)
                    .animation(.easeInOut.delay(Constants.Animation.standard), value: showRanking)
            }
            
            // Informations de performance
            performanceSection
        }
        .padding(.vertical, Constants.Layout.extraLargePadding)
        .padding(.horizontal, Constants.Layout.cardCornerRadius)
        .background(cardBackground)
        .onAppear {
            if animated {
                startAnimationSequence()
            } else {
                showAllContent()
            }
        }
    }
    
    // MARK: - Score Section
    
    @ViewBuilder
    private var scoreSection: some View {
        ZStack {
            // Lauriers pour nouveau record
            if isNewRecord && showContent {
                LaurelPair.newRecord(size: .extraLarge)
            }
            
            // Score avec gradient mesh
            MeshGradientText.score(
                score,
                isNewRecord: isNewRecord,
                fontSize: isNewRecord ? Constants.Typography.newRecordScoreSize : Constants.Typography.scoreSize
            )
            .scaleEffect(showScore ? 1.0 : 0.6)
            .opacity(showScore ? 1.0 : 0.0)
            .animation(
                .spring(response: 1.2, dampingFraction: 0.6)
                .delay(Constants.Animation.longDelay),
                value: showScore
            )
        }
        .scaleEffect(showContent ? 1.0 : 0.8)
        .opacity(showContent ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.8, dampingFraction: 0.7),
            value: showContent
        )
    }
    
    // MARK: - Performance Section
    
    @ViewBuilder
    private var performanceSection: some View {
        VStack(spacing: Constants.Layout.compactPadding) {
            
            // Ranking si disponible
            if !ranking.isEmpty {
                Text(ranking)
                    .font(.system(size: Constants.Typography.headline, weight: .bold))
                    .foregroundColor(.primary)
                    .opacity(showRanking ? 1.0 : 0.0)
                    .animation(.easeInOut.delay(Constants.Animation.veryLongDelay), value: showRanking)
            }
            
            // Message humoristique
            Text(humorousMessage)
                .font(.system(size: Constants.Typography.body, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(showRanking ? 1.0 : 0.0)
                .animation(.easeInOut.delay(Constants.Animation.longTransition), value: showRanking)
        }
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
            .fill(.ultraThinMaterial)
            .shadow(
                color: GradientFactory.shadowColor(score: score, isNewRecord: isNewRecord),
                radius: Constants.Effects.shadowRadius,
                x: Constants.Effects.shadowOffset.width,
                y: Constants.Effects.shadowOffset.height
            )
    }
    
    // MARK: - Animations
    
    private func startAnimationSequence() {
        // Étape 1: Apparition du conteneur
        withAnimation(.spring(response: Constants.Animation.standard, dampingFraction: 0.7)) {
            showContent = true
        }
        
        // Étape 2: Apparition du score
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.standardDelay) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                showScore = true
            }
        }
        
        // Étape 3: Apparition des informations
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.longDelay) {
            withAnimation(.easeInOut) {
                showRanking = true
            }
        }
    }
    
    private func showAllContent() {
        showContent = true
        showScore = true
        showRanking = true
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        Text("ScoreDisplayCard Demo")
            .font(.title2)
        
        ScoreDisplayCard(
            score: 42,
            ranking: "TOP 5%",
            isNewRecord: true,
            animated: true
        )
        
        ScoreDisplayCard(
            score: 8,
            ranking: "TOP 65%",
            isNewRecord: false,
            animated: true
        )
    }
    .padding()
    .background(.black.opacity(0.1))
}