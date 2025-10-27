//
//  DebugUserDefaults.swift
//  LaVideoLaPlusVue
//
//  Utilitaire pour debug et gestion des UserDefaults
//

import Foundation

struct DebugUserDefaults {
    
    static func printAllValues() {
        print("=== UserDefaults Debug ===")
        print("bestScore: \(UserDefaults.standard.integer(forKey: "bestScore"))")
        print("playerName: \(UserDefaults.standard.string(forKey: "playerName") ?? "nil")")
        print("=========================")
    }
    
    static func resetBestScore() {
        UserDefaults.standard.removeObject(forKey: "bestScore")
        UserDefaults.standard.synchronize()
        print("✅ Best score réinitialisé à 0")
    }
    
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: "bestScore")
        UserDefaults.standard.removeObject(forKey: "playerName")
        UserDefaults.standard.synchronize()
        print("✅ Toutes les données UserDefaults réinitialisées")
    }
    
    static func clearOfflineQueue() {
        UserDefaults.standard.removeObject(forKey: "offlineHallOfFameQueue")
        UserDefaults.standard.synchronize()
        print("🧙 Queue hors ligne vidée")
    }
    
    static func clearAllCaches() {
        // UserDefaults
        resetAll()
        clearOfflineQueue()
        
        // Cache des images (si applicable)
        URLCache.shared.removeAllCachedResponses()
        
        print("🧹 Tous les caches nettoyés")
    }
    
    static func debugOnAppear() {
        #if DEBUG
        print("\n🚀 === App Launch Debug ===")
        printAllValues()
        
        // Décommenter pour réinitialiser automatiquement en DEBUG
        // resetBestScore()
        
        print("========================\n")
        #endif
    }
}