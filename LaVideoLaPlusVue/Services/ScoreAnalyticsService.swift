import Foundation

/**
 * Service d'analyse des scores pour calculer le classement des joueurs.
 * 
 * Ce service calcule le pourcentage de classement d'un joueur par rapport
 * à tous les autres joueurs de l'application. Plus le pourcentage est bas,
 * meilleur est le classement (ex: TOP 5% = très bon joueur).
 * 
 * Pour l'instant, utilise des données mockées réalistes.
 * Prêt pour intégration API future.
 */
class ScoreAnalyticsService {
    static let shared = ScoreAnalyticsService()
    
    private init() {}
    
    /**
     * Calcule le pourcentage de classement pour un score donné.
     * 
     * @param score Le score du joueur
     * @return Le pourcentage de classement (1-100, plus bas = meilleur)
     * 
     * Distribution mockée basée sur une courbe réaliste :
     * - Score 1-5: TOP 70-90% (débutants)
     * - Score 6-15: TOP 30-70% (intermédiaires)  
     * - Score 16-25: TOP 10-30% (bons joueurs)
     * - Score 26-35: TOP 3-10% (excellents)
     * - Score 36+: TOP 1-3% (exceptionnels)
     */
    func getPlayerRankPercentage(score: Int) async -> Int {
        // Simuler un délai d'API réaliste
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
        
        return calculateMockPercentage(for: score)
    }
    
    /**
     * Calcule un pourcentage mockée basé sur une distribution réaliste.
     * Utilise des formules pour créer une courbe progressive crédible.
     */
    private func calculateMockPercentage(for score: Int) -> Int {
        let clampedScore = max(0, min(score, 50)) // Clamp entre 0 et 50
        
        switch clampedScore {
        case 0:
            return 100 // Aucune bonne réponse = dernier
            
        case 1...5:
            // Courbe rapide pour débutants : 90% → 70%
            let progress = Double(clampedScore - 1) / 4.0
            return Int(90 - (progress * 20))
            
        case 6...15:
            // Courbe intermédiaire : 70% → 30%
            let progress = Double(clampedScore - 6) / 9.0
            return Int(70 - (progress * 40))
            
        case 16...25:
            // Courbe bons joueurs : 30% → 10%
            let progress = Double(clampedScore - 16) / 9.0
            let eased = easeOutQuad(progress) // Ralentissement progressif
            return Int(30 - (eased * 20))
            
        case 26...35:
            // Courbe excellents : 10% → 3%
            let progress = Double(clampedScore - 26) / 9.0
            let eased = easeOutQuart(progress) // Très difficile de progresser
            return Int(10 - (eased * 7))
            
        case 36...50:
            // Élite : 3% → 1%
            let progress = Double(clampedScore - 36) / 14.0
            let eased = easeOutQuint(progress) // Extrêmement difficile
            return max(1, Int(3 - (eased * 2)))
            
        default:
            return 1 // Score exceptionnellement élevé
        }
    }
    
    // MARK: - Easing Functions pour courbes réalistes
    
    private func easeOutQuad(_ t: Double) -> Double {
        return 1 - (1 - t) * (1 - t)
    }
    
    private func easeOutQuart(_ t: Double) -> Double {
        return 1 - pow(1 - t, 4)
    }
    
    private func easeOutQuint(_ t: Double) -> Double {
        return 1 - pow(1 - t, 5)
    }
    
    /**
     * Génère un message de performance basé sur le pourcentage.
     * Utilisé pour les commentaires encourageants dans l'UI.
     */
    func getPerformanceMessage(for percentage: Int) -> String {
        switch percentage {
        case 1...3:
            return "Incroyable ! 🔥"
        case 4...10:
            return "Excellent ! 🎯"
        case 11...25:
            return "Très bien ! 👏"
        case 26...50:
            return "Pas mal ! 👍"
        case 51...75:
            return "Continue ! 💪"
        default:
            return "Essaie encore ! 🎮"
        }
    }
    
    /**
     * Détermine si un score mérite d'être célébré visuellement.
     * Utilisé pour déclencher des animations spéciales.
     */
    func shouldCelebrate(percentage: Int) -> Bool {
        return percentage <= 10 // TOP 10% mérite une célébration
    }
}