//
//  SupabaseModels.swift
//  LaVideoLaPlusVue
//
//  Created by Assistant on 26/10/2025.
//

import Foundation

/// Modèle pour la table hall_of_fame dans Supabase
struct SupabaseHallOfFameEntry: Codable {
    let id: Int  // Supabase utilise BIGINT par défaut
    let userName: String
    let score: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case score
        case createdAt = "created_at"
    }
    
    /// Convertir vers le modèle local HallOfFameEntry
    func toLocalEntry(rank: Int? = nil) -> HallOfFameEntry {
        return HallOfFameEntry(
            name: userName,
            score: score,
            date: createdAt,
            isPersonalBest: false // Sera déterminé par le ViewModel
        )
    }
}

/// Modèle pour l'insertion dans Supabase
struct SupabaseHallOfFameInsert: Codable {
    let userName: String
    let score: Int
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case score
    }
}

/// Réponse pour obtenir le rang d'un score
struct ScoreRankResponse: Codable {
    let rank: Int
    let totalPlayers: Int
}

/// Entrée de synchronisation hors ligne
struct OfflineHallOfFameEntry: Codable {
    let id: UUID
    let userName: String
    let score: Int
    let date: Date
    let syncToken: String
    var attempts: Int
    
    init(userName: String, score: Int) {
        self.id = UUID()
        self.userName = userName
        self.score = score
        self.date = Date()
        self.syncToken = UUID().uuidString
        self.attempts = 0
    }
}