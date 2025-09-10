//
//  HallOfFameEntry.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation

/**
 * Modèle pour une entrée du Hall of Fame.
 *
 * Représente un score enregistré avec toutes les informations nécessaires
 * pour l'affichage dans le classement et la persistance locale.
 */
struct HallOfFameEntry: Codable, Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let date: Date
    let isPersonalBest: Bool
    
    /**
     * Initialise une nouvelle entrée du Hall of Fame.
     *
     * @param name Le nom du joueur
     * @param score Le score obtenu
     * @param date La date de l'exploit
     * @param isPersonalBest Indique si c'est un record personnel
     */
    init(name: String, score: Int, date: Date, isPersonalBest: Bool) {
        self.name = name
        self.score = score
        self.date = date
        self.isPersonalBest = isPersonalBest
    }
}