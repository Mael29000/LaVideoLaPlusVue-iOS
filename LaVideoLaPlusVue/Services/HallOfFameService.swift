//
//  HallOfFameService.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation
import Supabase
import Network

class HallOfFameService: ObservableObject {
    static let shared = HallOfFameService()
    
    @Published var isOnline = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private let offlineQueueKey = "offlineHallOfFameQueue"
    
    init() {
        setupNetworkMonitoring()
        Task {
            await syncOfflineEntries()
        }
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    Task {
                        await self?.syncOfflineEntries()
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func fetchHallOfFame() async throws -> [HallOfFameEntry] {
        guard isOnline else {
            throw HallOfFameError.offline
        }
        
        do {
            print("🔄 Tentative de récupération du Hall of Fame...")
            print("📍 URL: \(SupabaseConfig.projectURL)")
            print("📊 Table: \(SupabaseConfig.hallOfFameTable)")
            
            let entries: [SupabaseHallOfFameEntry] = try await SupabaseConfig.client
                .from(SupabaseConfig.hallOfFameTable)
                .select()
                .order("score", ascending: false)
                .limit(SupabaseConfig.defaultLimit)
                .execute()
                .value
            
            print("✅ Récupéré \(entries.count) entrées")
            
            return entries.enumerated().map { index, entry in
                let localEntry = entry.toLocalEntry(rank: index + 1)
                return localEntry
            }
        } catch {
            print("❌ Erreur fetch Hall of Fame: \(error)")
            print("🔍 Type d'erreur: \(type(of: error))")
            print("📝 Description: \(error.localizedDescription)")
            throw HallOfFameError.fetchFailed
        }
    }
    
    func saveEntry(name: String, score: Int) async throws {
        let insert = SupabaseHallOfFameInsert(
            userName: name,
            score: score
        )
        
        print("🚀 Tentative de sauvegarde: \(name) - \(score)")
        print("🌐 Statut en ligne: \(isOnline)")
        
        if isOnline {
            do {
                print("📡 Envoi à Supabase...")
                let response = try await SupabaseConfig.client
                    .from(SupabaseConfig.hallOfFameTable)
                    .insert(insert)
                    .execute()
                
                print("✅ Score sauvegardé avec succès: \(name) - \(score)")
                print("📝 Réponse Supabase: \(response)")
            } catch {
                print("❌ Erreur sauvegarde Supabase: \(error)")
                print("🔍 Type d'erreur: \(type(of: error))")
                print("📋 Description complète: \(error.localizedDescription)")
                // Sauvegarder hors ligne
                saveOfflineEntry(name: name, score: score)
                throw HallOfFameError.saveFailed
            }
        } else {
            // Mode hors ligne
            print("📴 Mode hors ligne - Sauvegarde locale")
            saveOfflineEntry(name: name, score: score)
            throw HallOfFameError.offline
        }
    }
    
    func isScoreWorthy(score: Int) async -> Bool {
        // Vérifier le seuil minimum
        guard score >= AppConfiguration.hallOfFameThreshold else {
            return false
        }
        
        // Si hors ligne, on considère que oui si > seuil
        guard isOnline else {
            return true
        }
        
        do {
            // Compter le nombre d'entrées
            let count: Int = try await SupabaseConfig.client
                .from(SupabaseConfig.hallOfFameTable)
                .select("*", head: true, count: .exact)
                .execute()
                .count ?? 0
            
            // Si moins de 100 entrées, c'est worthy
            if count < SupabaseConfig.defaultLimit {
                return true
            }
            
            // Sinon, vérifier si le score bat le 100ème
            let lowestScore: [SupabaseHallOfFameEntry] = try await SupabaseConfig.client
                .from(SupabaseConfig.hallOfFameTable)
                .select()
                .order("score", ascending: false)
                .limit(1)
                .range(from: 99, to: 99)
                .execute()
                .value
            
            return lowestScore.isEmpty || score > lowestScore[0].score
        } catch {
            print("❌ Erreur vérification score: \(error)")
            return true // En cas d'erreur, on laisse passer
        }
    }
    
    func getPlayerRanking(for playerName: String) async throws -> (rank: Int, total: Int, nearbyEntries: [HallOfFameEntry]) {
        guard isOnline else {
            throw HallOfFameError.offline
        }
        
        do {
            // Récupérer toutes les entrées triées
            let allEntries: [SupabaseHallOfFameEntry] = try await SupabaseConfig.client
                .from(SupabaseConfig.hallOfFameTable)
                .select()
                .order("score", ascending: false)
                .execute()
                .value
            
            // Trouver le rang du joueur
            guard let playerIndex = allEntries.firstIndex(where: { $0.userName == playerName }) else {
                throw HallOfFameError.playerNotFound
            }
            
            let rank = playerIndex + 1
            let total = allEntries.count
            
            // Obtenir les 50 avant et 50 après
            let startIndex = max(0, playerIndex - 50)
            let endIndex = min(allEntries.count - 1, playerIndex + 50)
            
            let nearbyEntries = Array(allEntries[startIndex...endIndex]).enumerated().map { index, entry in
                let localEntry = HallOfFameEntry(
                    name: entry.userName,
                    score: entry.score,
                    date: entry.createdAt,
                    isPersonalBest: entry.userName == playerName
                )
                return localEntry
            }
            
            return (rank, total, nearbyEntries)
        } catch {
            print("❌ Erreur récupération classement: \(error)")
            throw HallOfFameError.fetchFailed
        }
    }
    
    private func saveOfflineEntry(name: String, score: Int) {
        let entry = OfflineHallOfFameEntry(userName: name, score: score)
        
        var queue = getOfflineQueue()
        queue.append(entry)
        
        if let encoded = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(encoded, forKey: offlineQueueKey)
            print("💾 Score sauvegardé hors ligne: \(name) - \(score)")
        }
    }
    
    private func getOfflineQueue() -> [OfflineHallOfFameEntry] {
        guard let data = UserDefaults.standard.data(forKey: offlineQueueKey),
              let queue = try? JSONDecoder().decode([OfflineHallOfFameEntry].self, from: data) else {
            return []
        }
        return queue
    }
    
    private func syncOfflineEntries() async {
        guard isOnline else { return }
        
        var queue = getOfflineQueue()
        guard !queue.isEmpty else { return }
        
        print("🔄 Début synchronisation de \(queue.count) entrées")
        
        var failedEntries: [OfflineHallOfFameEntry] = []
        
        for entry in queue {
            do {
                let insert = SupabaseHallOfFameInsert(
                    userName: entry.userName,
                    score: entry.score
                )
                
                try await SupabaseConfig.client
                    .from(SupabaseConfig.hallOfFameTable)
                    .insert(insert)
                    .execute()
                
                print("✅ Synchronisé: \(entry.userName) - \(entry.score)")
            } catch {
                print("❌ Échec: \(entry.userName) - \(error)")
                var failedEntry = entry
                failedEntry.attempts += 1
                if failedEntry.attempts < 3 {
                    failedEntries.append(failedEntry)
                }
            }
        }
        
        // Mettre à jour la queue avec seulement les échecs
        if let encoded = try? JSONEncoder().encode(failedEntries) {
            UserDefaults.standard.set(encoded, forKey: offlineQueueKey)
        }
        
        print("✅ Synchronisation terminée. \(failedEntries.count) échecs restants")
    }
}

enum HallOfFameError: LocalizedError {
    case offline
    case fetchFailed
    case saveFailed
    case playerNotFound
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return "Pas de connexion Internet"
        case .fetchFailed:
            return "Impossible de récupérer le classement"
        case .saveFailed:
            return "Impossible de sauvegarder le score"
        case .playerNotFound:
            return "Joueur introuvable dans le classement"
        }
    }
}