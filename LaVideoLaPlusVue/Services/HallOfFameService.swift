//
//  HallOfFameService.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation

/**
 * Service de gestion du Hall of Fame avec stockage local et synchronisation future API.
 *
 * Ce service gère :
 * - Le stockage local des scores (UserDefaults)
 * - Les données mockées pour le développement
 * - L'interface prête pour la future API
 * - La fusion des données locales et distantes
 *
 * ## Architecture
 * - Singleton pour cohérence globale
 * - Méthodes async prêtes pour l'API
 * - Données mockées réalistes
 * - Gestion d'erreurs complète
 */
class HallOfFameService {
    static let shared = HallOfFameService()
    
    private init() {}
    
    // MARK: - Constants
    
    private let localStorageKey = "hallOfFame"
    private let maxEntries = 10
    
    // MARK: - Public Methods
    
    /**
     * Récupère la liste complète du Hall of Fame.
     * Combine les données locales avec les données mockées de l'API.
     *
     * @return Liste des entrées triées par score décroissant
     */
    func fetchHallOfFame() async throws -> [HallOfFameEntry] {
        // Simuler un délai API réaliste
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 secondes
        
        // Récupérer les données locales
        let localEntries = loadLocalEntries()
        
        // Récupérer les données mockées de l'API
        let apiEntries = await fetchMockedApiEntries()
        
        // Fusionner et trier
        let allEntries = mergeEntries(local: localEntries, api: apiEntries)
        
        print("🏆 [HallOfFame] Chargé \(allEntries.count) entrées (\(localEntries.count) locales, \(apiEntries.count) API)")
        
        return allEntries
    }
    
    /**
     * Sauvegarde une nouvelle entrée dans le Hall of Fame.
     * Sauvegarde localement et prépare pour synchronisation API.
     *
     * @param entry La nouvelle entrée à sauvegarder
     */
    func saveEntry(_ entry: HallOfFameEntry) async throws {
        // Sauvegarder localement d'abord
        saveLocalEntry(entry)
        
        // Simuler l'envoi à l'API
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
        
        // TODO: Envoyer à l'API réelle quand disponible
        await syncToApi(entry)
        
        print("🏆 [HallOfFame] Entrée sauvegardée : \(entry.name) - \(entry.score) points")
    }
    
    /**
     * Vérifie si un score mérite d'être dans le Hall of Fame.
     *
     * @param score Le score à vérifier
     * @return True si le score entre dans le top 10
     */
    func isScoreWorthy(_ score: Int) async -> Bool {
        do {
            let currentEntries = try await fetchHallOfFame()
            
            // Si moins de 10 entrées, le score est toujours worthy
            if currentEntries.count < maxEntries {
                return true
            }
            
            // Vérifier si le score bat le plus faible du top 10
            let lowestScore = currentEntries.last?.score ?? 0
            return score > lowestScore
            
        } catch {
            // En cas d'erreur, être optimiste
            return score > 20
        }
    }
    
    /**
     * Obtient le rang d'un score dans le classement global.
     *
     * @param score Le score à classer
     * @return Le rang (1 = meilleur, 999+ = hors classement)
     */
    func getRankForScore(_ score: Int) async -> Int {
        do {
            let allEntries = try await fetchHallOfFame()
            
            // Compter combien d'entrées ont un score supérieur
            let betterScores = allEntries.filter { $0.score > score }.count
            
            return betterScores + 1
            
        } catch {
            // En cas d'erreur, retourner un rang conservateur
            return score > 30 ? 1 : score > 20 ? 5 : 999
        }
    }
    
    // MARK: - Local Storage
    
    private func loadLocalEntries() -> [HallOfFameEntry] {
        guard let data = UserDefaults.standard.data(forKey: localStorageKey),
              let entries = try? JSONDecoder().decode([HallOfFameEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    private func saveLocalEntry(_ entry: HallOfFameEntry) {
        var existingEntries = loadLocalEntries()
        existingEntries.append(entry)
        
        // Trier et garder les 10 meilleurs
        existingEntries.sort { $0.score > $1.score }
        let topEntries = Array(existingEntries.prefix(maxEntries))
        
        // Sauvegarder
        if let encoded = try? JSONEncoder().encode(topEntries) {
            UserDefaults.standard.set(encoded, forKey: localStorageKey)
        }
    }
    
    // MARK: - API Mocking
    
    /**
     * Simule les données de l'API avec des entrées réalistes.
     * Ces données seront remplacées par de vraies données API plus tard.
     */
    private func fetchMockedApiEntries() async -> [HallOfFameEntry] {
        // Simuler un délai réseau variable
        let randomDelay = Double.random(in: 200...600) // 0.2 à 0.6 secondes
        try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000))
        
        // Données mockées réalistes avec vrais noms français
        let mockedEntries = [
            HallOfFameEntry(name: "Alexandre", score: 45, date: Date().addingTimeInterval(-3600 * 24 * 2), isPersonalBest: true),
            HallOfFameEntry(name: "Marine", score: 38, date: Date().addingTimeInterval(-3600 * 12), isPersonalBest: true),
            HallOfFameEntry(name: "Thomas", score: 35, date: Date().addingTimeInterval(-3600 * 6), isPersonalBest: true),
            HallOfFameEntry(name: "Camille", score: 32, date: Date().addingTimeInterval(-3600 * 48), isPersonalBest: false),
            HallOfFameEntry(name: "Julien", score: 29, date: Date().addingTimeInterval(-3600 * 24), isPersonalBest: true),
            HallOfFameEntry(name: "Emma", score: 27, date: Date().addingTimeInterval(-3600 * 18), isPersonalBest: true),
            HallOfFameEntry(name: "Nicolas", score: 25, date: Date().addingTimeInterval(-3600 * 36), isPersonalBest: false),
            HallOfFameEntry(name: "Sophie", score: 23, date: Date().addingTimeInterval(-3600 * 8), isPersonalBest: true),
        ]
        
        // Simuler parfois des erreurs réseau (5% de chance)
        if Double.random(in: 0...1) < 0.05 {
            // Simuler une erreur réseau
            return []
        }
        
        return mockedEntries
    }
    
    /**
     * Simule la synchronisation avec l'API.
     * Prépare l'interface pour la vraie API.
     */
    private func syncToApi(_ entry: HallOfFameEntry) async {
        // Simuler l'envoi à l'API
        let randomDelay = Double.random(in: 300...800)
        try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000))
        
        // TODO: Implémenter l'envoi réel à l'API
        // Par exemple :
        // - POST /api/hall-of-fame/entries
        // - Authentification du joueur
        // - Validation côté serveur
        // - Gestion des erreurs réseau
        
        print("📡 [API Mock] Entrée synchronisée vers l'API : \(entry.name)")
    }
    
    // MARK: - Data Merging
    
    /**
     * Fusionne les données locales et API en évitant les doublons.
     * Privilégie les données locales en cas de conflit.
     */
    private func mergeEntries(local: [HallOfFameEntry], api: [HallOfFameEntry]) -> [HallOfFameEntry] {
        var mergedEntries: [HallOfFameEntry] = []
        
        // Ajouter toutes les entrées locales
        mergedEntries.append(contentsOf: local)
        
        // Ajouter les entrées API qui ne sont pas en doublon
        for apiEntry in api {
            let isDuplicate = local.contains { localEntry in
                localEntry.name.lowercased() == apiEntry.name.lowercased() && 
                localEntry.score == apiEntry.score
            }
            
            if !isDuplicate {
                mergedEntries.append(apiEntry)
            }
        }
        
        // Trier par score décroissant et garder les 10 meilleurs
        mergedEntries.sort { $0.score > $1.score }
        return Array(mergedEntries.prefix(maxEntries))
    }
}

// MARK: - Error Types

enum HallOfFameError: LocalizedError {
    case networkError
    case invalidData
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Impossible de se connecter au serveur"
        case .invalidData:
            return "Données reçues invalides"
        case .serverError:
            return "Erreur du serveur"
        }
    }
}