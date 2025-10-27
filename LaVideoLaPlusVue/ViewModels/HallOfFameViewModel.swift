//
//  HallOfFameViewModel.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HallOfFameViewModel: ObservableObject {
    
    @Published var entries: [HallOfFameEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasLoadedOnce: Bool = false
    @Published var isSaving: Bool = false
    @Published var isOnline: Bool = true
    @Published var playerRanking: (rank: Int, total: Int)? = nil
    @Published var isPlayerInHallOfFame: Bool = false
    
    private let supabaseService = HallOfFameService.shared
    
    init() {
        HallOfFameService.shared.$isOnline
            .receive(on: RunLoop.main)
            .assign(to: &$isOnline)
    }
    
    func loadHallOfFame() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedEntries = try await supabaseService.fetchHallOfFame()
            entries = fetchedEntries
            hasLoadedOnce = true
            
            print("🏆 Chargé \(entries.count) entrées depuis Supabase")
            
            // Si la table est vide, ce n'est pas une erreur
            if entries.isEmpty {
                print("📭 La table Hall of Fame est vide - c'est normal au début")
            }
            
            // Vérifier si le joueur actuel est dans le Hall of Fame
            checkIfPlayerInHallOfFame()
            
        } catch {
            if let hallOfFameError = error as? HallOfFameError {
                switch hallOfFameError {
                case .offline:
                    errorMessage = "Mode hors ligne - Connexion requise pour voir le classement"
                default:
                    errorMessage = hallOfFameError.localizedDescription
                }
            } else {
                errorMessage = "Impossible de charger le Hall of Fame"
            }
            print("❌ Erreur dans HallOfFameViewModel: \(error)")
            print("📝 Description détaillée: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func saveScore(name: String, score: Int, from gameViewModel: GameViewModel) async -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              score > 0 else {
            errorMessage = "Nom ou score invalide"
            return false
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            try await supabaseService.saveEntry(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                score: score
            )
            
            // Recharger les données
            await loadHallOfFame()
            
            print("🏆 Score sauvegardé : \(name) - \(score)")
            isSaving = false
            return true
            
        } catch {
            if let hallOfFameError = error as? HallOfFameError {
                switch hallOfFameError {
                case .offline:
                    errorMessage = "Score sauvegardé localement - Sera synchronisé à la reconnexion"
                    // C'est un succès partiel
                    isSaving = false
                    return true
                default:
                    errorMessage = hallOfFameError.localizedDescription
                }
            } else {
                errorMessage = "Impossible de sauvegarder le score"
            }
            print("❌ Erreur sauvegarde: \(error)")
            isSaving = false
            return false
        }
    }
    
    func refreshHallOfFame() async {
        await loadHallOfFame()
    }
    
    func isScoreWorthy(_ score: Int) async -> Bool {
        return await supabaseService.isScoreWorthy(score: score)
    }
    
    func getRankForScore(_ score: Int) async -> Int {
        // Implémentation simplifiée
        return 0
    }
    
    func loadPlayerRanking(name: String) async {
        do {
            let ranking = try await supabaseService.getPlayerRanking(for: name)
            self.playerRanking = (ranking.rank, ranking.total)
            self.entries = ranking.nearbyEntries
        } catch {
            print("❌ Erreur récupération classement: \(error)")
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    var isEmpty: Bool {
        return entries.isEmpty && hasLoadedOnce
    }
    
    var hasError: Bool {
        return errorMessage != nil
    }
    
    var podiumEntries: [HallOfFameEntry] {
        return Array(entries.prefix(3))
    }
    
    var remainingEntries: [HallOfFameEntry] {
        return Array(entries.dropFirst(3))
    }
    
    var totalEntries: Int {
        return entries.count
    }
    
    var highestScore: Int? {
        return entries.first?.score
    }
    
    var lowestScore: Int? {
        return entries.last?.score
    }
    
    func findEntry(byName name: String) -> HallOfFameEntry? {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return entries.first { entry in
            entry.name.lowercased() == normalizedName
        }
    }
    
    func getRank(for entry: HallOfFameEntry) -> Int? {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return nil
        }
        return index + 1
    }
    
    func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1:
            return "1er"
        default:
            return "\(rank)ème"
        }
    }
    
    func checkIfPlayerInHallOfFame() {
        guard let playerName = UserDefaults.standard.string(forKey: "playerName") else {
            isPlayerInHallOfFame = false
            print("🎮 Aucun nom de joueur enregistré dans UserDefaults")
            return
        }
        
        isPlayerInHallOfFame = findEntry(byName: playerName) != nil
        print("🎮 Joueur \(playerName) \(isPlayerInHallOfFame ? "est" : "n'est pas") dans le Hall of Fame")
        print("📋 Entrées actuelles: \(entries.map { $0.name })")
    }
}
