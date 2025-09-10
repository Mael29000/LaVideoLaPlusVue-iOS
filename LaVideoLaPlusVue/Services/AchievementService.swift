//
//  AchievementService.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation
import UIKit
import SwiftUI

/**
 * Service de gestion des achievements et du système de badges.
 *
 * Ce service gère :
 * - Le déblocage automatique des badges selon les performances
 * - La persistance des achievements en local
 * - Le système de niveaux et XP
 * - Les notifications de nouveaux déblocages
 *
 * ## Architecture
 * - Singleton pour cohérence globale
 * - Persistance avec UserDefaults
 * - Calculs XP et niveaux automatiques
 * - Badges pré-configurés avec conditions
 */
class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    private init() {
        loadUserProgress()
    }
    
    // MARK: - Constants
    
    private let userProgressKey = "userProgress"
    private let badgesKey = "unlockedBadges"
    private let xpPerScore = 10 // XP gagné par point de score
    private let baseXPForLevel = 1000 // XP de base pour le niveau 1
    
    // MARK: - User Progress Model
    
    struct UserProgress: Codable {
        var totalScore: Int = 0
        var bestScore: Int = 0
        var gamesPlayed: Int = 0
        var currentStreak: Int = 0
        var bestStreak: Int = 0
        var totalPlayTime: TimeInterval = 0
        var firstGameDate: Date?
        var lastGameDate: Date?
        var currentXP: Int = 0
        var currentLevel: Int = 1
    }
    
    // MARK: - Properties
    
    @Published private(set) var userProgress = UserProgress()
    @Published private(set) var unlockedBadges: [String: Badge] = [:]
    @Published private(set) var newlyUnlockedBadges: [Badge] = []
    
    // MARK: - Pre-defined Badges
    
    private lazy var allBadges: [Badge] = [
        // Score Badges
        Badge(
            id: "first_score",
            name: "Premiers Pas",
            description: "Obtiens ton premier point",
            icon: "play.fill",
            category: .score,
            rarity: .common,
            unlockCondition: "Score ≥ 1",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "apprentice",
            name: "Apprenti",
            description: "Atteins 10 points",
            icon: "graduationcap.fill",
            category: .score,
            rarity: .common,
            unlockCondition: "Score ≥ 10",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "skilled",
            name: "Compétent",
            description: "Atteins 25 points",
            icon: "star.fill",
            category: .score,
            rarity: .rare,
            unlockCondition: "Score ≥ 25",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "expert",
            name: "Expert",
            description: "Atteins 40 points",
            icon: "crown.fill",
            category: .score,
            rarity: .epic,
            unlockCondition: "Score ≥ 40",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "legendary",
            name: "Légende",
            description: "Atteins 60 points",
            icon: "bolt.fill",
            category: .score,
            rarity: .legendary,
            unlockCondition: "Score ≥ 60",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        
        // Streak Badges
        Badge(
            id: "hot_start",
            name: "Bon Départ",
            description: "Réussis 5 bonnes réponses d'affilée",
            icon: "flame.fill",
            category: .streak,
            rarity: .common,
            unlockCondition: "Série ≥ 5",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "on_fire",
            name: "En Feu",
            description: "Réussis 10 bonnes réponses d'affilée",
            icon: "flame.fill",
            category: .streak,
            rarity: .rare,
            unlockCondition: "Série ≥ 10",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "unstoppable",
            name: "Inarrêtable",
            description: "Réussis 20 bonnes réponses d'affilée",
            icon: "flame.fill",
            category: .streak,
            rarity: .legendary,
            unlockCondition: "Série ≥ 20",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        
        // Time Badges
        Badge(
            id: "dedicated",
            name: "Dévoué",
            description: "Joue pendant plus d'1 heure au total",
            icon: "clock.fill",
            category: .time,
            rarity: .common,
            unlockCondition: "Temps total ≥ 1h",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "marathon",
            name: "Marathonien",
            description: "Joue pendant plus de 5 heures au total",
            icon: "figure.run",
            category: .time,
            rarity: .rare,
            unlockCondition: "Temps total ≥ 5h",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        
        // Special Badges
        Badge(
            id: "first_game",
            name: "Nouveau Joueur",
            description: "Termine ta première partie",
            icon: "person.fill.checkmark",
            category: .special,
            rarity: .common,
            unlockCondition: "1 partie terminée",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "persistent",
            name: "Persévérant",
            description: "Joue 10 parties",
            icon: "repeat.circle.fill",
            category: .special,
            rarity: .rare,
            unlockCondition: "10 parties jouées",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        ),
        Badge(
            id: "record_breaker",
            name: "Briseur de Records",
            description: "Bats ton record personnel 5 fois",
            icon: "chart.line.uptrend.xyaxis",
            category: .special,
            rarity: .epic,
            unlockCondition: "5 nouveaux records",
            isUnlocked: false,
            isNew: false,
            unlockedDate: nil
        )
    ]
    
    // MARK: - Public Methods
    
    /**
     * Met à jour les statistiques après une partie et vérifie les nouveaux badges.
     */
    func updateProgress(
        score: Int,
        isNewRecord: Bool,
        streak: Int,
        playTime: TimeInterval
    ) {
        userProgress.totalScore += score
        userProgress.bestScore = max(userProgress.bestScore, score)
        userProgress.gamesPlayed += 1
        userProgress.currentStreak = streak
        userProgress.bestStreak = max(userProgress.bestStreak, streak)
        userProgress.totalPlayTime += playTime
        userProgress.lastGameDate = Date()
        
        if userProgress.firstGameDate == nil {
            userProgress.firstGameDate = Date()
        }
        
        // Mise à jour XP et niveau
        updateXPAndLevel(scoreGained: score)
        
        // Vérification des nouveaux badges
        checkForNewBadges()
        
        // Sauvegarde
        saveUserProgress()
    }
    
    /**
     * Obtient tous les badges (débloqués et non-débloqués).
     */
    func getAllBadges() -> [Badge] {
        return allBadges.map { badge in
            if let unlockedBadge = unlockedBadges[badge.id] {
                return unlockedBadge
            } else {
                return badge
            }
        }
    }
    
    /**
     * Obtient seulement les badges débloqués.
     */
    func getUnlockedBadges() -> [Badge] {
        return Array(unlockedBadges.values).sorted { badge1, badge2 in
            guard let date1 = badge1.unlockedDate,
                  let date2 = badge2.unlockedDate else {
                return false
            }
            return date1 > date2 // Plus récents en premier
        }
    }
    
    /**
     * Marque les nouveaux badges comme vus.
     */
    func markNewBadgesAsSeen() {
        newlyUnlockedBadges.removeAll()
        
        // Mettre à jour les badges pour les marquer comme non-nouveaux
        for badgeId in unlockedBadges.keys {
            unlockedBadges[badgeId]?.isNew = false
        }
        
        saveBadges()
    }
    
    /**
     * Calcule l'XP requis pour un niveau donné.
     */
    func xpRequiredForLevel(_ level: Int) -> Int {
        // Progression exponentielle : niveau 1 = 1000 XP, niveau 2 = 1500 XP, etc.
        return baseXPForLevel + (level - 1) * 500
    }
    
    /**
     * Calcule l'XP restant pour le niveau suivant.
     */
    func xpForNextLevel() -> Int {
        let xpForNext = xpRequiredForLevel(userProgress.currentLevel + 1)
        let xpForCurrent = xpRequiredForLevel(userProgress.currentLevel)
        return xpForNext - xpForCurrent
    }
    
    /**
     * Calcule l'XP accumulé dans le niveau actuel.
     */
    func currentLevelProgress() -> Int {
        let xpForCurrentLevel = xpRequiredForLevel(userProgress.currentLevel)
        return max(0, userProgress.currentXP - xpForCurrentLevel)
    }
    
    // MARK: - Private Methods
    
    private func updateXPAndLevel(scoreGained: Int) {
        let xpGained = scoreGained * xpPerScore
        userProgress.currentXP += xpGained
        
        // Vérifier si on monte de niveau
        while userProgress.currentXP >= xpRequiredForLevel(userProgress.currentLevel + 1) {
            userProgress.currentLevel += 1
            print("🎉 Niveau \(userProgress.currentLevel) atteint!")
        }
    }
    
    private func checkForNewBadges() {
        for badge in allBadges {
            // Skip si déjà débloqué
            if unlockedBadges[badge.id] != nil { continue }
            
            // Vérifier les conditions
            let shouldUnlock = checkBadgeCondition(badge)
            
            if shouldUnlock {
                unlockBadge(badge)
            }
        }
    }
    
    private func checkBadgeCondition(_ badge: Badge) -> Bool {
        switch badge.id {
        // Score badges
        case "first_score": return userProgress.bestScore >= 1
        case "apprentice": return userProgress.bestScore >= 10
        case "skilled": return userProgress.bestScore >= 25
        case "expert": return userProgress.bestScore >= 40
        case "legendary": return userProgress.bestScore >= 60
            
        // Streak badges
        case "hot_start": return userProgress.bestStreak >= 5
        case "on_fire": return userProgress.bestStreak >= 10
        case "unstoppable": return userProgress.bestStreak >= 20
            
        // Time badges
        case "dedicated": return userProgress.totalPlayTime >= 3600 // 1 heure
        case "marathon": return userProgress.totalPlayTime >= 18000 // 5 heures
            
        // Special badges
        case "first_game": return userProgress.gamesPlayed >= 1
        case "persistent": return userProgress.gamesPlayed >= 10
        case "record_breaker":
            // Ce badge nécessite un compteur spécial pour les records battus
            // Pour l'instant, on utilise une approximation
            return userProgress.gamesPlayed >= 5 && userProgress.bestScore > 20
            
        default: return false
        }
    }
    
    private func unlockBadge(_ badge: Badge) {
        let unlockedBadge = Badge(
            id: badge.id,
            name: badge.name,
            description: badge.description,
            icon: badge.icon,
            category: badge.category,
            rarity: badge.rarity,
            unlockCondition: badge.unlockCondition,
            isUnlocked: true,
            isNew: true,
            unlockedDate: Date()
        )
        
        unlockedBadges[badge.id] = unlockedBadge
        newlyUnlockedBadges.append(unlockedBadge)
        
        print("🏆 Badge débloqué : \(badge.name)")
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        saveBadges()
    }
    
    // MARK: - Persistence
    
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: userProgressKey)
        }
    }
    
    private func loadUserProgress() {
        guard let data = UserDefaults.standard.data(forKey: userProgressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return
        }
        
        userProgress = progress
        loadBadges()
    }
    
    private func saveBadges() {
        let badgesArray = Array(unlockedBadges.values)
        if let encoded = try? JSONEncoder().encode(badgesArray) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }
    
    private func loadBadges() {
        guard let data = UserDefaults.standard.data(forKey: badgesKey),
              let badges = try? JSONDecoder().decode([Badge].self, from: data) else {
            return
        }
        
        unlockedBadges = Dictionary(uniqueKeysWithValues: badges.map { ($0.id, $0) })
    }
}
