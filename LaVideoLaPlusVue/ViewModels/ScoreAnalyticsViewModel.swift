import Foundation

/**
 * ViewModel pour l'analyse des scores et du classement des joueurs.
 *
 * Ce ViewModel fait l'interface entre le ScoreAnalyticsService et l'UI de l'EndGameScreen.
 * Il gère l'état de chargement, les données de classement et les messages de performance
 * selon l'architecture MVVM de l'application.
 *
 * ## Responsabilités
 * - Calculer le classement d'un joueur par rapport aux autres
 * - Fournir des messages de performance personnalisés
 * - Gérer l'état de chargement pendant les calculs
 * - Déterminer si un score mérite une célébration
 *
 * ## Usage
 * ```swift
 * @StateObject private var analyticsViewModel = ScoreAnalyticsViewModel()
 *
 * // Dans onAppear ou après un score
 * Task {
 *     await analyticsViewModel.calculateRanking(for: playerScore)
 * }
 * ```
 */
@MainActor
class ScoreAnalyticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Pourcentage de classement du score actuel (1-100, plus bas = meilleur)
    @Published var currentScorePercentage: Int?
    
    /// Pourcentage de classement du meilleur score (1-100, plus bas = meilleur)
    @Published var bestScorePercentage: Int?
    
    /// Message de performance basé sur le classement du score actuel
    @Published var performanceMessage: String = ""
    
    /// État de chargement pendant les calculs API
    @Published var isLoading: Bool = false
    
    /// Erreur survenue pendant les calculs
    @Published var error: String?
    
    /// Indique si le score mérite une célébration visuelle
    @Published var shouldCelebrate: Bool = false
    
    // MARK: - Private Properties
    
    private let analyticsService = ScoreAnalyticsService.shared
    
    // MARK: - Public Methods
    
    /**
     * Calcule les classements pour le score actuel ET le meilleur score.
     *
     * Cette méthode fait deux appels API parallèles pour calculer :
     * - Le classement du score actuel (pour affichage et message de performance)
     * - Le classement du meilleur score (pour la carte "meilleur score")
     *
     * @param currentScore Le score de la partie actuelle
     * @param bestScore Le meilleur score historique du joueur
     */
    func calculateRankings(currentScore: Int, bestScore: Int) async {
        guard currentScore >= 0 && bestScore >= 0 else {
            error = "Scores invalides"
            return
        }
        
        // Réinitialiser l'état précédent
        await MainActor.run {
            isLoading = true
            error = nil
            currentScorePercentage = nil
            bestScorePercentage = nil
            shouldCelebrate = false
            performanceMessage = ""
        }
        
        do {
            // Calculer les deux classements en parallèle pour optimiser les performances
            async let currentPercentage = analyticsService.getPlayerRankPercentage(score: currentScore)
            async let bestPercentage = analyticsService.getPlayerRankPercentage(score: bestScore)
            
            let (currentResult, bestResult) = await (currentPercentage, bestPercentage)
            
            // Mise à jour de l'état sur le thread principal
            await MainActor.run {
                currentScorePercentage = currentResult
                bestScorePercentage = bestResult
                performanceMessage = analyticsService.getPerformanceMessage(for: currentResult)
                shouldCelebrate = analyticsService.shouldCelebrate(percentage: currentResult)
                isLoading = false
            }
            
            print("📊 [ScoreAnalytics] Score actuel: \(currentScore) → TOP \(currentResult)%")
            print("📊 [ScoreAnalytics] Meilleur score: \(bestScore) → TOP \(bestResult)%")
            print("📊 [ScoreAnalytics] Message: \(performanceMessage)")
            
        } catch {
            await MainActor.run {
                self.error = "Impossible de calculer les classements"
                self.isLoading = false
            }
            
            print("❌ [ScoreAnalytics] Erreur: \(error.localizedDescription)")
        }
    }
    
    /**
     * Calcule le classement d'un joueur pour un score donné (méthode légacy).
     * 
     * @deprecated Utiliser calculateRankings(currentScore:bestScore:) pour calculer les deux scores
     */
    func calculateRanking(for score: Int) async {
        await calculateRankings(currentScore: score, bestScore: score)
    }
    
    /**
     * Réinitialise complètement l'état du ViewModel.
     * Utilisé lors du redémarrage d'une partie ou du changement d'écran.
     */
    func reset() {
        currentScorePercentage = nil
        bestScorePercentage = nil
        performanceMessage = ""
        isLoading = false
        error = nil
        shouldCelebrate = false
    }
    
    // MARK: - Computed Properties
    
    /**
     * Texte formaté du classement du score actuel pour l'affichage UI.
     * Retourne "TOP X%" ou un message de chargement/erreur.
     */
    var displayedCurrentRanking: String {
        if isLoading {
            return "Calcul..."
        } else if let error = error {
            return "Erreur"
        } else if let percentage = currentScorePercentage {
            return "TOP \(percentage)%"
        } else {
            return "---"
        }
    }
    
    /**
     * Texte formaté du classement du meilleur score pour l'affichage UI.
     * Retourne "TOP X%" ou un message de chargement/erreur.
     */
    var displayedBestRanking: String {
        if isLoading {
            return "Calcul..."
        } else if let error = error {
            return "Erreur"
        } else if let percentage = bestScorePercentage {
            return "TOP \(percentage)%"
        } else {
            return "---"
        }
    }
    
    /**
     * Indique si les données de classement sont prêtes à être affichées.
     */
    var hasValidData: Bool {
        return !isLoading && error == nil && currentScorePercentage != nil && bestScorePercentage != nil
    }
    
    /**
     * Couleur suggérée pour l'affichage du classement selon la performance.
     */
    var rankingColor: String {
        guard let percentage = currentScorePercentage else { return "gray" }
        
        switch percentage {
        case 1...10:
            return "gold"      // Excellent
        case 11...25:
            return "silver"    // Très bien
        case 26...50:
            return "bronze"    // Correct
        default:
            return "gray"      // À améliorer
        }
    }
}