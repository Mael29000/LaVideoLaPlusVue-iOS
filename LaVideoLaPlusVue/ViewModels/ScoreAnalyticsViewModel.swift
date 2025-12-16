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
    
    /// Rang exact du score actuel
    @Published var currentScoreRank: Int?
    
    /// Rang exact du meilleur score
    @Published var bestScoreRank: Int?
    
    /// Rang exact du meilleur score pour l'affichage dans le Hall of Fame (toujours affiché)
    @Published var bestScoreRankForHallOfFame: Int?
    
    /// Nombre total d'entrées dans le Hall of Fame
    @Published var totalHallOfFameEntries: Int = 0
    
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
    private let hallOfFameService = HallOfFameService.shared
    
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
            currentScoreRank = nil
            bestScoreRank = nil
            totalHallOfFameEntries = 0
            shouldCelebrate = false
            performanceMessage = ""
        }
        
        do {
            // D'abord, récupérer le nombre total d'entrées
            let entryCount = try await hallOfFameService.getTotalEntryCount()
            
            await MainActor.run {
                totalHallOfFameEntries = entryCount
            }
            
            // Toujours calculer le rang du meilleur score pour le Hall of Fame (si >= 10)
            let bestScoreHallOfFameRank = bestScore >= AppConfiguration.hallOfFameThreshold ? 
                try await hallOfFameService.getScoreRank(for: bestScore) : nil
            
            // Si on a assez d'entrées, calculer les rangs pour l'affichage principal
            if entryCount >= AppConfiguration.minimumEntriesForRanking {
                // Calculer les rangs exacts si les scores sont >= 10
                async let currentRankTask = currentScore >= AppConfiguration.hallOfFameThreshold ? 
                    hallOfFameService.getScoreRank(for: currentScore) : nil
                async let bestRankTask = bestScore >= AppConfiguration.hallOfFameThreshold ? 
                    hallOfFameService.getScoreRank(for: bestScore) : nil
                
                // Calculer les pourcentages aussi (pour d'autres usages éventuels)
                async let currentPercentage = analyticsService.getPlayerRankPercentage(score: currentScore)
                async let bestPercentage = analyticsService.getPlayerRankPercentage(score: bestScore)
                
                let (currentRank, bestRank, currentPct, bestPct) = try await (currentRankTask, bestRankTask, currentPercentage, bestPercentage)
                
                // Mise à jour de l'état sur le thread principal
                await MainActor.run {
                    currentScoreRank = currentRank
                    bestScoreRank = bestRank
                    bestScoreRankForHallOfFame = bestScoreHallOfFameRank
                    currentScorePercentage = currentPct
                    bestScorePercentage = bestPct
                    performanceMessage = PerformanceMessages.getMessage(for: currentScore)
                    shouldCelebrate = analyticsService.shouldCelebrate(percentage: currentPct)
                    isLoading = false
                }
                
                print("📊 [ScoreAnalytics] Total entrées: \(entryCount)")
                print("📊 [ScoreAnalytics] Score actuel: \(currentScore) → Rang #\(currentRank ?? 0) / TOP \(currentPct)%")
                print("📊 [ScoreAnalytics] Meilleur score: \(bestScore) → Rang #\(bestRank ?? 0) / TOP \(bestPct)%")
                print("📊 [ScoreAnalytics] Meilleur score (Hall of Fame): \(bestScore) → Rang #\(bestScoreHallOfFameRank ?? 0)")
            } else {
                // Pas assez d'entrées pour l'affichage principal, mais on a quand même le rang pour le Hall of Fame
                async let currentPercentage = analyticsService.getPlayerRankPercentage(score: currentScore)
                async let bestPercentage = analyticsService.getPlayerRankPercentage(score: bestScore)
                
                let (currentPct, bestPct) = await (currentPercentage, bestPercentage)
                
                await MainActor.run {
                    currentScorePercentage = currentPct
                    bestScorePercentage = bestPct
                    bestScoreRankForHallOfFame = bestScoreHallOfFameRank
                    performanceMessage = PerformanceMessages.getMessage(for: currentScore)
                    shouldCelebrate = analyticsService.shouldCelebrate(percentage: currentPct)
                    isLoading = false
                }
                
                print("📊 [ScoreAnalytics] Pas assez d'entrées (\(entryCount) < \(AppConfiguration.minimumEntriesForRanking))")
                print("📊 [ScoreAnalytics] Score actuel: \(currentScore) → TOP \(currentPct)%")
                print("📊 [ScoreAnalytics] Meilleur score: \(bestScore) → TOP \(bestPct)%")
                print("📊 [ScoreAnalytics] Meilleur score (Hall of Fame): \(bestScore) → Rang #\(bestScoreHallOfFameRank ?? 0)")
            }
            
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
        currentScoreRank = nil
        bestScoreRank = nil
        bestScoreRankForHallOfFame = nil
        totalHallOfFameEntries = 0
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
    
    /**
     * Texte formaté du rang exact du score actuel pour l'affichage UI.
     * Retourne le rang uniquement si on a assez d'entrées et un score >= 10.
     */
    var displayedCurrentRank: String? {
        guard totalHallOfFameEntries >= AppConfiguration.minimumEntriesForRanking,
              let rank = currentScoreRank else { return nil }
        
        return formatRank(rank)
    }
    
    /**
     * Texte formaté du rang exact du meilleur score pour l'affichage UI.
     * Retourne le rang uniquement si on a assez d'entrées et un score >= 10.
     */
    var displayedBestRank: String? {
        guard totalHallOfFameEntries >= AppConfiguration.minimumEntriesForRanking,
              let rank = bestScoreRank else { return nil }
        
        return formatRank(rank)
    }
    
    /**
     * Indique si on peut afficher des classements.
     */
    var canShowRankings: Bool {
        return totalHallOfFameEntries >= AppConfiguration.minimumEntriesForRanking
    }
    
    /**
     * Texte formaté du rang exact du meilleur score pour l'affichage dans le Hall of Fame.
     * TOUJOURS retourné si le score est >= 10 et qu'on a un rang, peu importe le nombre d'entrées.
     */
    var displayedBestRankForHallOfFame: String? {
        guard let rank = bestScoreRankForHallOfFame else { return nil }
        return formatRank(rank)
    }
    
    // MARK: - Private Methods
    
    /**
     * Formate un rang avec le bon suffixe (1er, 2ème, etc.)
     */
    private func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1:
            return "1er"
        default:
            return "\(rank)ème"
        }
    }
}
