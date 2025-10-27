//
//  SupabaseConfig.swift
//  LaVideoLaPlusVue
//
//  Created by Assistant on 26/10/2025.
//

import Foundation
import Supabase

/// Configuration centralisée pour Supabase
struct SupabaseConfig {
    static let projectURL = Secrets.supabaseURL
    static let anonKey = Secrets.supabaseAnonKey
    
    /// Client Supabase singleton
    static let client: SupabaseClient = {
        guard let url = URL(string: projectURL) else {
            fatalError("Invalid Supabase project URL")
        }
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }()
    
    /// Nom de la table Hall of Fame
    static let hallOfFameTable = "hall_of_fame"
    
    /// Limite par défaut pour le classement
    static let defaultLimit = 100
    
    /// Score minimum pour entrer au Hall of Fame
    static let minimumScoreThreshold = 10
}