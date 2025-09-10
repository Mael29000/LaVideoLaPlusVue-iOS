//
//  SoundManager.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import AVFoundation
import SwiftUI

/**
 * Gestionnaire centralisé des sons et effets audio du jeu.
 *
 * Ce service gère :
 * - Les effets sonores des interactions (tap, swipe, révélation)
 * - Les sons de feedback pour les bonnes/mauvaises réponses
 * - Les célébrations audio pour les scores élevés
 * - La musique d'ambiance adaptative
 * - Le contrôle du volume et les préférences utilisateur
 *
 * ## Architecture
 * - Singleton pour cohérence globale
 * - Préchargement des sons fréquents
 * - Gestion intelligente de la mémoire
 * - Respect des préférences système (mode silencieux)
 */
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    // MARK: - Properties
    
    @Published var isSoundEnabled: Bool = true
    @Published var volume: Float = 0.7
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var soundPreferences = UserDefaults.standard
    
    // MARK: - Sound Types
    
    enum SoundType: String, CaseIterable {
        // UI Interactions
        case tap = "tap"
        case swipe = "swipe" 
        case button = "button"
        case transition = "transition"
        
        // Game Actions
        case cardFlip = "card_flip"
        case reveal = "reveal"
        case choice = "choice"
        case timer = "timer"
        
        // Feedback
        case success = "success"
        case error = "error"
        case perfect = "perfect"
        case bonus = "bonus"
        
        // Celebrations
        case applause = "applause"
        case fanfare = "fanfare"
        case newRecord = "new_record"
        
        // Ambient
        case backgroundMusic = "background_music"
        case tension = "tension"
        
        var fileName: String {
            switch self {
            // UI Interactions - utilisation de sons système iOS
            case .tap: return "system_tap"
            case .swipe: return "system_swipe"
            case .button: return "system_button"
            case .transition: return "system_transition"
            
            // Game Actions - sons personnalisés (simulés)
            case .cardFlip: return "card_flip.wav"
            case .reveal: return "reveal.wav"
            case .choice: return "choice.wav"
            case .timer: return "timer.wav"
            
            // Feedback
            case .success: return "success.wav"
            case .error: return "error.wav"
            case .perfect: return "perfect.wav"
            case .bonus: return "bonus.wav"
            
            // Celebrations
            case .applause: return "applause.wav"
            case .fanfare: return "fanfare.wav"
            case .newRecord: return "new_record.wav"
            
            // Ambient
            case .backgroundMusic: return "background.mp3"
            case .tension: return "tension.mp3"
            }
        }
        
        var volume: Float {
            switch self {
            case .tap, .swipe, .button: return 0.3
            case .cardFlip, .reveal, .choice: return 0.5
            case .success, .perfect: return 0.8
            case .error: return 0.6
            case .bonus: return 0.9
            case .applause, .fanfare, .newRecord: return 1.0
            case .backgroundMusic: return 0.2
            case .tension: return 0.4
            case .timer, .transition: return 0.7
            }
        }
        
        var isLooping: Bool {
            switch self {
            case .backgroundMusic, .tension: return true
            default: return false
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        loadPreferences()
        setupAudioSession()
        preloadFrequentSounds()
    }
    
    // MARK: - Public Methods
    
    /**
     * Joue un son spécifié.
     */
    func playSound(_ soundType: SoundType, force: Bool = false) {
        guard isSoundEnabled || force else { return }
        
        // Pour les sons système, utiliser les API système
        if soundType.fileName.hasPrefix("system_") {
            playSystemSound(soundType)
            return
        }
        
        // Pour les sons personnalisés, utiliser AVAudioPlayer (simulé)
        playCustomSound(soundType)
    }
    
    /**
     * Joue un son de feedback basé sur la performance.
     */
    func playScoreFeedback(score: Int, isCorrect: Bool, isNewRecord: Bool = false) {
        if isNewRecord {
            playSound(.newRecord)
            
            // Séquence de célébration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.playSound(.applause)
            }
        } else if isCorrect {
            switch score {
            case 40...: playSound(.perfect)
            case 25...: playSound(.success)
            case 15...: playSound(.bonus)
            default: playSound(.success)
            }
        } else {
            playSound(.error)
        }
    }
    
    /**
     * Joue une célébration audio selon le score final.
     */
    func playCelebration(finalScore: Int) {
        switch finalScore {
        case 40...:
            playSound(.fanfare)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playSound(.applause)
            }
        case 30...:
            playSound(.perfect)
        case 20...:
            playSound(.success)
        default:
            break
        }
    }
    
    /**
     * Démarre la musique d'ambiance.
     */
    func startBackgroundMusic() {
        guard isSoundEnabled else { return }
        playSound(.backgroundMusic)
    }
    
    /**
     * Arrête la musique d'ambiance.
     */
    func stopBackgroundMusic() {
        stopSound(.backgroundMusic)
    }
    
    /**
     * Ajuste le volume global.
     */
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        
        // Appliquer à tous les lecteurs actifs
        for player in audioPlayers.values {
            player.volume = volume
        }
        
        savePreferences()
    }
    
    /**
     * Active/désactive les sons.
     */
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        
        if !enabled {
            stopAllSounds()
        }
        
        savePreferences()
    }
    
    /**
     * Arrête un son spécifique.
     */
    func stopSound(_ soundType: SoundType) {
        audioPlayers[soundType.rawValue]?.stop()
        audioPlayers.removeValue(forKey: soundType.rawValue)
    }
    
    /**
     * Arrête tous les sons.
     */
    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        audioPlayers.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erreur configuration AVAudioSession: \(error)")
        }
    }
    
    private func preloadFrequentSounds() {
        let frequentSounds: [SoundType] = [.tap, .success, .error, .reveal]
        
        for soundType in frequentSounds {
            if !soundType.fileName.hasPrefix("system_") {
                preloadSound(soundType)
            }
        }
    }
    
    private func preloadSound(_ soundType: SoundType) {
        // En réalité, on chargerait le fichier audio depuis le bundle
        // Pour cette démo, on simule avec un player vide
        let key = soundType.rawValue
        
        // Simulation du chargement
        do {
            // let url = Bundle.main.url(forResource: soundType.fileName, withExtension: nil)
            // let player = try AVAudioPlayer(contentsOf: url)
            
            // Simulation d'un player configuré
            let player = try AVAudioPlayer(data: Data(), fileTypeHint: nil)
            player.volume = soundType.volume * volume
            player.numberOfLoops = soundType.isLooping ? -1 : 0
            player.prepareToPlay()
            
            audioPlayers[key] = player
        } catch {
            print("Impossible de précharger le son \(soundType.fileName): \(error)")
        }
    }
    
    private func playSystemSound(_ soundType: SoundType) {
        // Utilisation d'effets système iOS (feedback haptique accompagnant)
        switch soundType {
        case .tap:
            // Son de tap léger
            AudioServicesPlaySystemSound(1104) // Keyboard tap
            
        case .swipe:
            // Son de swipe
            AudioServicesPlaySystemSound(1107) // Screen capture
            
        case .button:
            // Son de bouton
            AudioServicesPlaySystemSound(1105) // Camera shutter (simulation)
            
        case .transition:
            // Son de transition
            AudioServicesPlaySystemSound(1108) // Begin recording
            
        default:
            break
        }
    }
    
    private func playCustomSound(_ soundType: SoundType) {
        let key = soundType.rawValue
        
        // Si le son n'est pas préchargé, le charger maintenant
        if audioPlayers[key] == nil {
            preloadSound(soundType)
        }
        
        guard let player = audioPlayers[key] else {
            print("Impossible de jouer le son \(soundType.fileName)")
            return
        }
        
        // Configurer et jouer
        player.currentTime = 0
        player.volume = soundType.volume * volume
        player.play()
        
        // Nettoyer après lecture (sauf pour les sons en boucle)
        if !soundType.isLooping {
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) {
                if !player.isPlaying {
                    self.audioPlayers.removeValue(forKey: key)
                }
            }
        }
    }
    
    private func loadPreferences() {
        isSoundEnabled = soundPreferences.bool(forKey: "soundEnabled")
        volume = soundPreferences.float(forKey: "soundVolume")
        
        // Valeurs par défaut
        if soundPreferences.object(forKey: "soundEnabled") == nil {
            isSoundEnabled = true
        }
        if soundPreferences.float(forKey: "soundVolume") == 0 {
            volume = 0.7
        }
    }
    
    private func savePreferences() {
        soundPreferences.set(isSoundEnabled, forKey: "soundEnabled")
        soundPreferences.set(volume, forKey: "soundVolume")
    }
}

// MARK: - SwiftUI Integration

/**
 * Modificateur SwiftUI pour ajouter facilement des effets sonores.
 */
struct SoundEffect: ViewModifier {
    let soundType: SoundManager.SoundType
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _ in
                SoundManager.shared.playSound(soundType)
            }
    }
}

extension View {
    /**
     * Ajoute un effet sonore déclenché par un changement de valeur.
     */
    func soundEffect(_ soundType: SoundManager.SoundType, trigger: Bool) -> some View {
        self.modifier(SoundEffect(soundType: soundType, trigger: trigger))
    }
    
    /**
     * Ajoute un effet sonore de tap.
     */
    func tapSound() -> some View {
        self.onTapGesture {
            SoundManager.shared.playSound(.tap)
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension SoundManager {
    /**
     * Mode démo pour les previews.
     */
    static var preview: SoundManager {
        let manager = SoundManager.shared
        manager.isSoundEnabled = false // Désactivé pour les previews
        return manager
    }
}
#endif