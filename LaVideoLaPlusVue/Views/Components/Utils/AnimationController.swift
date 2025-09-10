//
//  AnimationController.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI
import Foundation

/**
 * Contrôleur centralisé pour les animations timer-based répétitives.
 *
 * Ce contrôleur évite la duplication de logique d'animation qui était
 * présente dans EndGameScreen, EnhancedScoreCard, ParticleSystem, etc.
 *
 * ## Usage
 * ```swift
 * @StateObject private var animationController = AnimationController()
 *
 * // Animation mesh gradient
 * animationController.startMeshAnimation()
 *
 * // Animation de respiration
 * animationController.startBreathingAnimation()
 *
 * // Utiliser la phase dans vos vues
 * .offset(y: sin(animationController.meshPhase * 0.4) * 6)
 * ```
 */
class AnimationController: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var meshPhase: CGFloat = 0
    @Published var breathingPhase: CGFloat = 0
    @Published var pulsePhase: CGFloat = 0
    @Published var rotationPhase: CGFloat = 0
    
    // MARK: - Private Properties
    
    private var meshTimer: Timer?
    private var breathingTimer: Timer?
    private var pulseTimer: Timer?
    private var rotationTimer: Timer?
    
    // MARK: - Mesh Animation
    
    /**
     * Démarre une animation mesh gradient fluide.
     */
    func startMeshAnimation(frameRate: Double = 60.0) {
        stopMeshAnimation()
        
        meshTimer = Timer.scheduledTimer(withTimeInterval: 1.0/frameRate, repeats: true) { _ in
            DispatchQueue.main.async {
                self.meshPhase += 0.02
                if self.meshPhase > .pi * 2 {
                    self.meshPhase = 0
                }
            }
        }
    }
    
    /**
     * Arrête l'animation mesh gradient.
     */
    func stopMeshAnimation() {
        meshTimer?.invalidate()
        meshTimer = nil
    }
    
    // MARK: - Breathing Animation
    
    /**
     * Démarre une animation de respiration lente.
     */
    func startBreathingAnimation(duration: Double = 2.5) {
        stopBreathingAnimation()
        
        let interval = 1.0 / 60.0
        let increment = (2 * .pi) / (duration * 60)
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.breathingPhase += increment
                if self.breathingPhase > .pi * 2 {
                    self.breathingPhase = 0
                }
            }
        }
    }
    
    /**
     * Arrête l'animation de respiration.
     */
    func stopBreathingAnimation() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
    
    // MARK: - Pulse Animation
    
    /**
     * Démarre une animation de pulsation.
     */
    func startPulseAnimation(duration: Double = 1.0) {
        stopPulseAnimation()
        
        let interval = 1.0 / 60.0
        let increment = (2 * .pi) / (duration * 60)
        
        pulseTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.pulsePhase += increment
                if self.pulsePhase > .pi * 2 {
                    self.pulsePhase = 0
                }
            }
        }
    }
    
    /**
     * Arrête l'animation de pulsation.
     */
    func stopPulseAnimation() {
        pulseTimer?.invalidate()
        pulseTimer = nil
    }
    
    // MARK: - Rotation Animation
    
    /**
     * Démarre une animation de rotation continue.
     */
    func startRotationAnimation(speed: Double = 1.0) {
        stopRotationAnimation()
        
        let interval = 1.0 / 60.0
        let increment = (2 * .pi * speed) / 60.0
        
        rotationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.rotationPhase += increment
                if self.rotationPhase > .pi * 2 {
                    self.rotationPhase = 0
                }
            }
        }
    }
    
    /**
     * Arrête l'animation de rotation.
     */
    func stopRotationAnimation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
    
    // MARK: - Lifecycle
    
    /**
     * Arrête toutes les animations actives.
     */
    func stopAllAnimations() {
        stopMeshAnimation()
        stopBreathingAnimation()
        stopPulseAnimation()
        stopRotationAnimation()
    }
    
    deinit {
        stopAllAnimations()
    }
}

// MARK: - Convenience Extensions

extension AnimationController {
    
    /**
     * Valeur de respiration normalisée (0.8 à 1.2).
     */
    var breathingScale: CGFloat {
        0.8 + (sin(breathingPhase) + 1) * 0.2
    }
    
    /**
     * Valeur de pulsation normalisée (0.9 à 1.1).
     */
    var pulseScale: CGFloat {
        0.9 + (sin(pulsePhase) + 1) * 0.1
    }
    
    /**
     * Offset flottant pour les éléments mesh.
     */
    func floatingOffset(amplitude: CGFloat = 6, phase: CGFloat = 0) -> CGFloat {
        sin(meshPhase + phase) * amplitude
    }
    
    /**
     * Rotation en degrés basée sur la phase de rotation.
     */
    var rotationDegrees: Double {
        rotationPhase * 180 / .pi
    }
}

// MARK: - Static Helpers

extension AnimationController {
    
    /**
     * Crée un contrôleur avec animation mesh pré-démarrée.
     */
    static func withMeshAnimation() -> AnimationController {
        let controller = AnimationController()
        controller.startMeshAnimation()
        return controller
    }
    
    /**
     * Crée un contrôleur avec animation de respiration pré-démarrée.
     */
    static func withBreathingAnimation() -> AnimationController {
        let controller = AnimationController()
        controller.startBreathingAnimation()
        return controller
    }
}