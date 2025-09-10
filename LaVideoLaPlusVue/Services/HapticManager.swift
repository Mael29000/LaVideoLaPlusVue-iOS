//
//  HapticManager.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import UIKit
import SwiftUI

/**
 * Gestionnaire centralisé du feedback haptique avancé.
 *
 * Ce service gère :
 * - Des patterns haptiques riches et contextuels
 * - Des séquences adaptatives selon la performance
 * - L'intensité variable selon les actions
 * - La combinaison feedback haptique + audio
 * - Le respect des préférences système d'accessibilité
 *
 * ## Patterns Disponibles
 * - Interactions UI légères (tap, swipe)
 * - Feedback de jeu (correct, incorrect, révélation)
 * - Célébrations progressives (score, records, achievements)
 * - Notifications et alertes
 * - Séquences complexes et rythmées
 */
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    // MARK: - Properties
    
    @Published var isHapticEnabled: Bool = true
    @Published var intensity: Float = 1.0
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private var hapticPreferences = UserDefaults.standard
    
    // MARK: - Haptic Types
    
    enum HapticType {
        // UI Interactions
        case tap
        case lightTap
        case selection
        case swipe
        case buttonPress
        case toggle
        
        // Game Actions  
        case cardFlip
        case reveal
        case choice
        case timerTick
        case timerWarning
        
        // Feedback
        case success
        case error
        case perfect
        case bonus
        case streak
        
        // Celebrations
        case newRecord
        case celebration
        case applause
        
        // Notifications
        case warning
        case info
        case alert
        
        // Complex Patterns
        case heartbeat
        case drumroll
        case fireworks
        case cascade
    }
    
    // MARK: - Initialization
    
    private init() {
        loadPreferences()
        prepareGenerators()
    }
    
    // MARK: - Public Methods
    
    /**
     * Déclenche un feedback haptique simple.
     */
    func trigger(_ type: HapticType) {
        guard isHapticEnabled && UIDevice.current.userInterfaceIdiom == .phone else { return }
        
        switch type {
        // UI Interactions
        case .tap:
            impactLight.impactOccurred(intensity: CGFloat(0.7 * intensity))
            
        case .lightTap:
            impactLight.impactOccurred(intensity: CGFloat(0.4 * intensity))
            
        case .selection:
            selection.selectionChanged()
            
        case .swipe:
            impactLight.impactOccurred(intensity: CGFloat(0.8 * intensity))
            
        case .buttonPress:
            impactMedium.impactOccurred(intensity: CGFloat(0.9 * intensity))
            
        case .toggle:
            impactLight.impactOccurred(intensity: CGFloat(0.6 * intensity))
            
        // Game Actions
        case .cardFlip:
            playCardFlipPattern()
            
        case .reveal:
            playRevealPattern()
            
        case .choice:
            impactMedium.impactOccurred(intensity: CGFloat(0.8 * intensity))
            
        case .timerTick:
            impactLight.impactOccurred(intensity: CGFloat(0.5 * intensity))
            
        case .timerWarning:
            playTimerWarningPattern()
            
        // Feedback
        case .success:
            notification.notificationOccurred(.success)
            
        case .error:
            notification.notificationOccurred(.error)
            
        case .perfect:
            playPerfectPattern()
            
        case .bonus:
            playBonusPattern()
            
        case .streak:
            playStreakPattern()
            
        // Celebrations
        case .newRecord:
            playNewRecordPattern()
            
        case .celebration:
            playCelebrationPattern()
            
        case .applause:
            playApplausePattern()
            
        // Notifications
        case .warning:
            notification.notificationOccurred(.warning)
            
        case .info:
            impactLight.impactOccurred(intensity: CGFloat(0.6 * intensity))
            
        case .alert:
            notification.notificationOccurred(.error)
            
        // Complex Patterns
        case .heartbeat:
            playHeartbeatPattern()
            
        case .drumroll:
            playDrumrollPattern()
            
        case .fireworks:
            playFireworksPattern()
            
        case .cascade:
            playCascadePattern()
        }
    }
    
    /**
     * Feedback haptique adapté au score obtenu.
     */
    func triggerScoreFeedback(score: Int, isCorrect: Bool, isNewRecord: Bool = false) {
        guard isHapticEnabled else { return }
        
        if isNewRecord {
            trigger(.newRecord)
        } else if isCorrect {
            switch score {
            case 40...: trigger(.perfect)
            case 30...: trigger(.celebration)
            case 20...: trigger(.success)
            case 10...: trigger(.bonus)
            default: trigger(.success)
            }
        } else {
            trigger(.error)
        }
    }
    
    /**
     * Feedback pour la performance finale.
     */
    func triggerFinalPerformanceFeedback(finalScore: Int, isNewRecord: Bool) {
        guard isHapticEnabled else { return }
        
        if isNewRecord {
            trigger(.newRecord)
            return
        }
        
        switch finalScore {
        case 40...: trigger(.applause)
        case 30...: trigger(.celebration)
        case 20...: trigger(.success)
        case 10...: trigger(.success)
        default: trigger(.info)
        }
    }
    
    
    /**
     * Active/désactive le feedback haptique.
     */
    func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabled = enabled
        savePreferences()
    }
    
    /**
     * Ajuste l'intensité du feedback.
     */
    func setIntensity(_ newIntensity: Float) {
        intensity = max(0.0, min(1.0, newIntensity))
        savePreferences()
    }
    
    // MARK: - Complex Patterns
    
    private func playCardFlipPattern() {
        impactLight.impactOccurred(intensity: CGFloat(0.5 * intensity))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactLight.impactOccurred(intensity: CGFloat(0.3 * self.intensity))
        }
    }
    
    private func playRevealPattern() {
        // Pattern crescendo pour la révélation
        let delays: [Double] = [0, 0.1, 0.15, 0.2]
        let intensities: [Float] = [0.3, 0.5, 0.7, 1.0]
        
        for (index, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactLight.impactOccurred(intensity: CGFloat(intensities[index] * self.intensity))
            }
        }
    }
    
    private func playTimerWarningPattern() {
        // Pattern d'urgence rapide
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                self.impactMedium.impactOccurred(intensity: CGFloat(0.8 * self.intensity))
            }
        }
    }
    
    private func playPerfectPattern() {
        // Séquence de réussite parfaite
        impactHeavy.impactOccurred(intensity: CGFloat(1.0 * intensity))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactMedium.impactOccurred(intensity: CGFloat(0.8 * self.intensity))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.impactLight.impactOccurred(intensity: CGFloat(0.6 * self.intensity))
        }
    }
    
    private func playBonusPattern() {
        // Pattern de bonus rapide
        for i in 0..<2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.impactMedium.impactOccurred(intensity: CGFloat(0.7 * self.intensity))
            }
        }
    }
    
    private func playStreakPattern() {
        // Pattern rythmé pour les séries
        let rhythm: [Double] = [0, 0.08, 0.16, 0.32]
        
        for delay in rhythm {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactLight.impactOccurred(intensity: CGFloat(0.6 * self.intensity))
            }
        }
    }
    
    
    private func playNewRecordPattern() {
        // Séquence dramatique pour nouveau record
        let sequence: [(delay: Double, intensity: Float, generator: UIImpactFeedbackGenerator)] = [
            (0.0, 1.0, impactHeavy),
            (0.2, 0.8, impactMedium),
            (0.35, 0.6, impactLight),
            (0.5, 1.0, impactHeavy),
            (0.7, 0.9, impactMedium),
            (0.85, 0.7, impactLight),
            (1.0, 0.5, impactLight)
        ]
        
        for item in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + item.delay) {
                item.generator.impactOccurred(intensity: CGFloat(item.intensity * self.intensity))
            }
        }
    }
    
    
    private func playCelebrationPattern() {
        // Pattern festif générique
        let celebration: [Double] = [0, 0.1, 0.2, 0.4, 0.5, 0.6]
        
        for delay in celebration {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactMedium.impactOccurred(intensity: CGFloat(0.8 * self.intensity))
            }
        }
    }
    
    private func playApplausePattern() {
        // Pattern d'applaudissements
        for i in 0..<8 {
            let delay = Double(i) * 0.15 + Double.random(in: 0...0.05)
            let randomIntensity = Float.random(in: 0.6...0.9)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactLight.impactOccurred(intensity: CGFloat(randomIntensity * self.intensity))
            }
        }
    }
    
    
    
    
    private func playHeartbeatPattern() {
        // Rythme cardiaque
        let heartbeat: [Double] = [0, 0.1, 0.8, 0.9]
        
        for delay in heartbeat {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactMedium.impactOccurred(intensity: CGFloat(0.7 * self.intensity))
            }
        }
    }
    
    private func playDrumrollPattern() {
        // Roulement de tambour accéléré
        for i in 0..<10 {
            let delay = Double(i) * (0.2 - Double(i) * 0.015) // Accélération
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.impactLight.impactOccurred(intensity: CGFloat(0.5 * self.intensity))
            }
        }
    }
    
    private func playFireworksPattern() {
        // Pattern de feux d'artifice
        let explosions: [(Double, [Double])] = [
            (0.0, [0, 0.05, 0.1, 0.15]),
            (0.4, [0, 0.03, 0.06, 0.12, 0.18]),
            (0.8, [0, 0.02, 0.04, 0.08, 0.12, 0.16, 0.2])
        ]
        
        for explosion in explosions {
            for subDelay in explosion.1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + explosion.0 + subDelay) {
                    self.impactMedium.impactOccurred(intensity: CGFloat(0.8 * self.intensity))
                }
            }
        }
    }
    
    private func playCascadePattern() {
        // Effet cascade descendant
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                let descendingIntensity = 1.0 - Float(i) * 0.15
                self.impactLight.impactOccurred(intensity: CGFloat(descendingIntensity * self.intensity))
            }
        }
    }
    
    // MARK: - Setup & Preferences
    
    private func prepareGenerators() {
        // Préparer les générateurs pour des réponses plus rapides
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }
    
    private func loadPreferences() {
        isHapticEnabled = hapticPreferences.bool(forKey: "hapticEnabled")
        intensity = hapticPreferences.float(forKey: "hapticIntensity")
        
        // Valeurs par défaut
        if hapticPreferences.object(forKey: "hapticEnabled") == nil {
            isHapticEnabled = true
        }
        if hapticPreferences.float(forKey: "hapticIntensity") == 0 {
            intensity = 1.0
        }
    }
    
    private func savePreferences() {
        hapticPreferences.set(isHapticEnabled, forKey: "hapticEnabled")
        hapticPreferences.set(intensity, forKey: "hapticIntensity")
    }
}

// MARK: - SwiftUI Integration

/**
 * Modificateur SwiftUI pour ajouter facilement du feedback haptique.
 */
struct HapticFeedback: ViewModifier {
    let hapticType: HapticManager.HapticType
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _ in
                HapticManager.shared.trigger(hapticType)
            }
    }
}

extension View {
    /**
     * Ajoute un feedback haptique déclenché par un changement de valeur.
     */
    func hapticFeedback(_ type: HapticManager.HapticType, trigger: Bool) -> some View {
        self.modifier(HapticFeedback(hapticType: type, trigger: trigger))
    }
    
    /**
     * Ajoute un feedback haptique de tap.
     */
    func tapHaptic() -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(.tap)
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension HapticManager {
    /**
     * Mode silencieux pour les previews.
     */
    static var preview: HapticManager {
        let manager = HapticManager.shared
        manager.isHapticEnabled = false // Désactivé pour les previews
        return manager
    }
}
#endif