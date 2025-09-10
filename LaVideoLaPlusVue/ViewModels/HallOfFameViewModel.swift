//
//  HallOfFameViewModel.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation

/**
 * ViewModel pour la gestion du Hall of Fame.
 *
 * Ce ViewModel fait l'interface entre le HallOfFameService et les vues (HallOfFameSheet, EnterNameSheet).
 * Il gère l'état UI, les erreurs, et fournit des méthodes pratiques pour l'interaction utilisateur.
 *
 * ## Responsabilités
 * - Charger et rafraîchir le Hall of Fame
 * - Sauvegarder de nouvelles entrées
 * - Gérer les états de chargement et d'erreur
 * - Fournir des données formatées pour l'UI
 * - Valider les scores avant sauvegarde
 *
 * ## Usage
 * ```swift
 * @StateObject private var hallOfFameViewModel = HallOfFameViewModel()
 * 
 * // Charger les données
 * Task {
 *     await hallOfFameViewModel.loadHallOfFame()
 * }
 * 
 * // Sauvegarder une entrée
 * Task {
 *     await hallOfFameViewModel.saveScore(name: "Joueur", score: 25)
 * }
 * ```
 */
@MainActor
class HallOfFameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Liste des entrées du Hall of Fame triées par score décroissant
    @Published var entries: [HallOfFameEntry] = []
    
    /// État de chargement pour l'UI
    @Published var isLoading: Bool = false
    
    /// Message d'erreur à afficher à l'utilisateur
    @Published var errorMessage: String?
    
    /// Indique si les données ont été chargées au moins une fois
    @Published var hasLoadedOnce: Bool = false
    
    /// Indique si une sauvegarde est en cours
    @Published var isSaving: Bool = false
    
    // MARK: - Private Properties
    
    private let hallOfFameService = HallOfFameService.shared
    
    // MARK: - Public Methods
    
    /**
     * Charge la liste complète du Hall of Fame.
     * Combine les données locales et API avec gestion d'erreurs.
     */
    func loadHallOfFame() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedEntries = try await hallOfFameService.fetchHallOfFame()
            
            entries = fetchedEntries
            hasLoadedOnce = true
            
            print("🏆 [HallOfFameVM] Chargé \(entries.count) entrées avec succès")
            
        } catch {
            errorMessage = "Impossible de charger le Hall of Fame"
            print("❌ [HallOfFameVM] Erreur de chargement: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /**
     * Sauvegarde un nouveau score dans le Hall of Fame.
     * Valide les données et met à jour la liste locale.
     *
     * @param name Le nom du joueur (non vide)
     * @param score Le score obtenu (> 0)
     * @param gameViewModel Le GameViewModel pour les données contextuelles
     * @return True si la sauvegarde a réussi
     */
    func saveScore(name: String, score: Int, from gameViewModel: GameViewModel) async -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              score > 0 else {
            errorMessage = "Nom ou score invalide"
            return false
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            let newEntry = HallOfFameEntry(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                score: score,
                date: Date(),
                isPersonalBest: score == gameViewModel.bestScore
            )
            
            // Sauvegarder via le service
            try await hallOfFameService.saveEntry(newEntry)
            
            // Recharger les données pour avoir la liste mise à jour
            await loadHallOfFame()
            
            print("🏆 [HallOfFameVM] Score sauvegardé avec succès : \(name) - \(score)")
            isSaving = false
            return true
            
        } catch {
            errorMessage = "Impossible de sauvegarder le score"
            print("❌ [HallOfFameVM] Erreur de sauvegarde: \(error.localizedDescription)")
            isSaving = false
            return false
        }
    }
    
    /**
     * Rafraîchit les données du Hall of Fame.
     * Utile pour le pull-to-refresh ou les mises à jour manuelles.
     */
    func refreshHallOfFame() async {
        await loadHallOfFame()
    }
    
    /**
     * Vérifie si un score mérite d'être dans le Hall of Fame.
     *
     * @param score Le score à vérifier
     * @return True si le score peut entrer dans le top 10
     */
    func isScoreWorthy(_ score: Int) async -> Bool {
        return await hallOfFameService.isScoreWorthy(score)
    }
    
    /**
     * Obtient le rang d'un score dans le classement global.
     *
     * @param score Le score à classer
     * @return Le rang (1 = meilleur)
     */
    func getRankForScore(_ score: Int) async -> Int {
        return await hallOfFameService.getRankForScore(score)
    }
    
    /**
     * Efface le message d'erreur.
     * Utile pour fermer les alertes d'erreur.
     */
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    /**
     * Indique si le Hall of Fame est vide (aucune entrée).
     */
    var isEmpty: Bool {
        return entries.isEmpty && hasLoadedOnce
    }
    
    /**
     * Indique s'il y a une erreur à afficher.
     */
    var hasError: Bool {
        return errorMessage != nil
    }
    
    /**
     * Top 3 du Hall of Fame pour affichage prioritaire.
     */
    var podiumEntries: [HallOfFameEntry] {
        return Array(entries.prefix(3))
    }
    
    /**
     * Entrées restantes après le podium.
     */
    var remainingEntries: [HallOfFameEntry] {
        return Array(entries.dropFirst(3))
    }
    
    /**
     * Nombre total d'entrées dans le Hall of Fame.
     */
    var totalEntries: Int {
        return entries.count
    }
    
    /**
     * Score le plus élevé du Hall of Fame.
     */
    var highestScore: Int? {
        return entries.first?.score
    }
    
    /**
     * Score le plus faible du Hall of Fame (10ème place).
     */
    var lowestScore: Int? {
        return entries.last?.score
    }
    
    // MARK: - Helper Methods
    
    /**
     * Trouve une entrée par nom (insensible à la casse).
     *
     * @param name Le nom à rechercher
     * @return L'entrée trouvée ou nil
     */
    func findEntry(byName name: String) -> HallOfFameEntry? {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return entries.first { entry in
            entry.name.lowercased() == normalizedName
        }
    }
    
    /**
     * Obtient le rang d'une entrée spécifique.
     *
     * @param entry L'entrée dont on veut le rang
     * @return Le rang (1-based) ou nil si non trouvée
     */
    func getRank(for entry: HallOfFameEntry) -> Int? {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return nil
        }
        return index + 1
    }
    
    /**
     * Formate un rang pour l'affichage (avec suffixes français).
     *
     * @param rank Le rang numérique
     * @return Le rang formaté ("1er", "2ème", "3ème", etc.)
     */
    func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1:
            return "1er"
        default:
            return "\(rank)ème"
        }
    }
}