//
//  AppConfiguration.swift
//  LaVideoLaPlusVue
//
//  Created by Assistant on 26/10/2025.
//

import Foundation

/// Configuration globale de l'application
struct AppConfiguration {
    /// Seuil minimum pour entrer au Hall of Fame
    static let hallOfFameThreshold = 10
    
    /// Nombre maximum d'entrées dans le Hall of Fame
    static let hallOfFameMaxEntries = 100
    
    /// Durée du cache offline en secondes
    static let offlineCacheDuration: TimeInterval = 3600 // 1 heure
}