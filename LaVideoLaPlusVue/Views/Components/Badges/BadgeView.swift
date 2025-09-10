//
//  BadgeView.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Système de badges d'achievement pour gamifier l'expérience.
 *
 * Affiche des badges débloqués avec animations et effets visuels.
 * Supporte différents types de badges : score, série, temps, spéciaux.
 *
 * ## Usage
 * ```swift
 * BadgeView(
 *     badge: .firstWin,
 *     isUnlocked: true,
 *     isNew: false
 * )
 * ```
 */

// MARK: - Badge Model

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: BadgeCategory
    let rarity: BadgeRarity
    let unlockCondition: String
    let isUnlocked: Bool
    var isNew: Bool
    let unlockedDate: Date?
    
    enum BadgeCategory: String, Codable, CaseIterable {
        case score = "Score"
        case streak = "Série"
        case time = "Temps"
        case special = "Spécial"
        case social = "Social"
        
        var color: Color {
            switch self {
            case .score: return .blue
            case .streak: return .orange
            case .time: return .green
            case .special: return .purple
            case .social: return .pink
            }
        }
    }
    
    enum BadgeRarity: String, Codable, CaseIterable {
        case common = "Commun"
        case rare = "Rare"
        case epic = "Épique"
        case legendary = "Légendaire"
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
        
        var glowRadius: CGFloat {
            switch self {
            case .common: return 0
            case .rare: return 4
            case .epic: return 8
            case .legendary: return 12
            }
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let badge: Badge
    let size: BadgeSize
    
    @State private var showUnlockAnimation: Bool = false
    @State private var pulseAnimation: Bool = false
    
    enum BadgeSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 60
            case .large: return 80
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 24
            case .large: return 32
            }
        }
        
        var showDetails: Bool {
            return self != .small
        }
    }
    
    var body: some View {
        VStack(spacing: size.showDetails ? 8 : 4) {
            // Badge icon avec effets
            ZStack {
                // Background circle
                Circle()
                    .fill(badgeBackgroundGradient)
                    .frame(width: size.dimension, height: size.dimension)
                    .overlay(
                        Circle()
                            .stroke(badgeRingColor, lineWidth: 2)
                    )
                    .shadow(
                        color: badge.isUnlocked ? badge.rarity.color.opacity(0.3) : Color.clear,
                        radius: badge.rarity.glowRadius,
                        x: 0, y: 0
                    )
                
                // Icon
                Image(systemName: badge.icon)
                    .font(.system(size: size.iconSize, weight: .bold))
                    .foregroundColor(badge.isUnlocked ? .white : .gray)
                    .scaleEffect(showUnlockAnimation ? 1.2 : 1.0)
                
                // New badge indicator
                if badge.isNew && badge.isUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                        Spacer()
                    }
                }
                
                // Lock overlay for unearned badges
                if !badge.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: size.dimension, height: size.dimension)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: size.iconSize * 0.6))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
            .animation(
                badge.isNew ? 
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    .spring(response: 0.3, dampingFraction: 0.7),
                value: pulseAnimation
            )
            
            // Badge details (si space suffisant)
            if size.showDetails {
                VStack(spacing: 2) {
                    Text(badge.name)
                        .font(.system(size: size == .large ? 12 : 10, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    if size == .large && badge.isUnlocked {
                        Text(badge.description)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: size.dimension + 10)
            }
        }
        .onAppear {
            if badge.isNew {
                startPulseAnimation()
            }
            
            if badge.isUnlocked && showUnlockAnimation {
                playUnlockAnimation()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var badgeBackgroundGradient: LinearGradient {
        if badge.isUnlocked {
            return LinearGradient(
                colors: [badge.rarity.color, badge.category.color],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var badgeRingColor: Color {
        if badge.isUnlocked {
            return badge.rarity.color.opacity(0.8)
        } else {
            return .gray.opacity(0.5)
        }
    }
    
    // MARK: - Animations
    
    private func startPulseAnimation() {
        pulseAnimation = true
    }
    
    private func playUnlockAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.3)) {
            showUnlockAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showUnlockAnimation = false
            }
        }
    }
}

// MARK: - Achievement Overlay

/**
 * Overlay qui s'affiche quand un nouveau badge est débloqué.
 */
struct AchievementOverlay: View {
    let badge: Badge
    let isVisible: Bool
    let onDismiss: () -> Void
    
    @State private var animationState: AnimationState = .hidden
    
    private enum AnimationState {
        case hidden, appearing, visible, disappearing
    }
    
    var body: some View {
        if isVisible {
            ZStack {
                // Background blur
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissOverlay()
                    }
                
                // Achievement card
                VStack(spacing: 20) {
                    // "Achievement Unlocked" header
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        
                        Text("Achievement Débloqué !")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                    
                    // Badge display
                    BadgeView(badge: badge, size: .large)
                    
                    // Badge info
                    VStack(spacing: 8) {
                        Text(badge.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(badge.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        
                        // Rarity indicator
                        HStack {
                            Text("Rareté:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(badge.rarity.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(badge.rarity.color)
                        }
                    }
                    
                    // Dismiss button
                    Button("Continuer") {
                        dismissOverlay()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(25)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(badge.rarity.color, lineWidth: 2)
                        )
                )
                .scaleEffect(animationState == .visible ? 1.0 : 0.8)
                .opacity(animationState == .hidden ? 0.0 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationState)
            }
            .onAppear {
                animationState = .appearing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animationState = .visible
                }
            }
        }
    }
    
    private func dismissOverlay() {
        animationState = .disappearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Badge Collection View

/**
 * Grille de badges pour afficher la collection complète.
 */
struct BadgeCollectionView: View {
    let badges: [Badge]
    let columns: Int
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(badges) { badge in
                BadgeView(badge: badge, size: .medium)
                    .onTapGesture {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleBadge = Badge(
        id: "first_win",
        name: "Première Victoire",
        description: "Réussis ton premier score supérieur à 10",
        icon: "trophy.fill",
        category: .score,
        rarity: .rare,
        unlockCondition: "Score > 10",
        isUnlocked: true,
        isNew: true,
        unlockedDate: Date()
    )
    
    VStack(spacing: 30) {
        BadgeView(badge: sampleBadge, size: .large)
        
        BadgeCollectionView(
            badges: [sampleBadge, sampleBadge, sampleBadge, sampleBadge],
            columns: 4
        )
    }
    .padding()
}
