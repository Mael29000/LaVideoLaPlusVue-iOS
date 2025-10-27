import Foundation
import SwiftUI

/**
 * GameViewModel gère la logique métier du jeu de comparaison de vidéos YouTube.
 * 
 * Architecture: 3 vidéos en mémoire pour des transitions fluides
 * - topVideo: Vidéo affichée en haut (position 1)
 * - bottomVideo: Vidéo affichée en bas (position 2) 
 * - preloadedVideo: Vidéo préchargée hors écran (position 3, pour l'animation suivante)
 */
@MainActor
class GameViewModel: ObservableObject {
    // État principal du jeu - observé par la Vue pour les mises à jour UI
    @Published var topVideo: Video?
    @Published var bottomVideo: Video?
    @Published var preloadedVideo: Video?
    @Published var currentScore: Int = 0
    @Published var bestScore: Int = 0
    @Published var gameState: GameState = .loading
    
    private let videoService = VideoService.shared
    
    enum GameState {
        case loading
        case playing
        case gameOver
    }
    
    init() {
        loadBestScore()
    }
    
    /**
     * Initialise une nouvelle partie en chargeant 3 vidéos uniques.
     * Stratégie: Précharger les images en mémoire pour des transitions instantanées.
     */
    func startNewGame() async {
        gameState = .loading
        currentScore = 0
        
        do {
            // Charger 3 vidéos différentes pour éviter les doublons
            let firstVideo = try await videoService.getRandomVideo()
            let secondVideo = try await videoService.getRandomVideo(excluding: firstVideo)
            let thirdVideo = try await videoService.getRandomVideo(excluding: secondVideo)
            
            // Assigner les positions initiales
            topVideo = firstVideo
            bottomVideo = secondVideo
            preloadedVideo = thirdVideo
            
            // Précharger toutes les images pour éviter les délais pendant le jeu
            await videoService.preloadImagesFor(videos: [firstVideo, secondVideo, thirdVideo])
            gameState = .playing
        } catch {
            gameState = .gameOver
        }
    }
    
    /**
     * Évalue si le choix du joueur est correct.
     * Logique: Comparer les vues de la vidéo sélectionnée avec l'autre vidéo.
     * La Vue gère l'animation et le feedback - le ViewModel ne fait que la logique pure.
     */
    func makeGuess(selectedVideo: Video) async -> Bool {
        guard let top = topVideo,
              let bottom = bottomVideo,
              gameState == .playing else { return false }
        
        // Identifier l'autre vidéo (celle qui n'a pas été sélectionnée)
        let otherVideo = selectedVideo.id == top.id ? bottom : top
        
        // Règle du jeu: la vidéo sélectionnée doit avoir plus (ou égal) de vues
        let isCorrect = selectedVideo.viewCount >= otherVideo.viewCount
        
        if isCorrect {
            currentScore += 1
            return true
        } else {
            // Game over - sauvegarder le meilleur score si nécessaire
            updateBestScore()
            return false
        }
    }
    
    /**
     * Rotation atomique des 3 vidéos pour maintenir la fluidité.
     * Called après une réponse correcte pour préparer la question suivante.
     * 
     * Logique de rotation: bottom → top, preloaded → bottom, nouvelle → preloaded
     * Le MainActor.run garantit que tous les changements sont synchrones.
     */
    func swapVideos() async {
        guard let bottom = bottomVideo,
              let preloaded = preloadedVideo else { return }
        
        // Charger une nouvelle vidéo pour remplacer celle qui va devenir 'top'
        let newVideo = try? await videoService.getRandomVideo(excluding: preloaded)
        
        // Précharger l'image de la nouvelle vidéo pendant qu'on a le temps
        if let newVideo = newVideo {
            await videoService.preloadImage(for: newVideo)
        }
        
        // Rotation atomique: tous les changements en une seule transaction UI
        await MainActor.run {
            self.topVideo = bottom        // L'ancienne bottom devient la nouvelle top
            self.bottomVideo = preloaded  // L'ancienne preloaded devient la nouvelle bottom  
            self.preloadedVideo = newVideo // La nouvelle vidéo est prête pour le prochain cycle
        }
    }
    
    /**
     * Redémarre une partie en réinitialisant complètement l'état.
     * Utilisé quand le joueur veut rejouer après un game over.
     */
    func restartGame() async {
        await startNewGame()
    }
    
    // MARK: - Score Management
    
    /**
     * Charge le meilleur score depuis UserDefaults au démarrage de l'app.
     * UserDefaults retourne 0 par défaut si aucune valeur n'existe.
     */
    private func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: "bestScore")
    }
    
    /**
     * Met à jour le meilleur score si le score actuel le dépasse.
     * Persistance automatique dans UserDefaults pour conserver entre les sessions.
     */
    private func updateBestScore() {
        if currentScore > bestScore {
            bestScore = currentScore
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
    }
    
    /**
     * Détermine si le joueur mérite d'entrer dans le Hall of Fame.
     * Condition: Score >= 10 ET nouveau record personnel.
     */
    var shouldShowHallOfFameEntry: Bool {
        return currentScore >= AppConfiguration.hallOfFameThreshold && currentScore == bestScore
    }
}
