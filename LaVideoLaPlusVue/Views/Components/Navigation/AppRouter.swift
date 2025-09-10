//
//  AppRouter.swift
//  Summit
//
//  Created by Maël Suard on 12/04/2025.
//

import SwiftUI

class AppRouter: ObservableObject {
    
    // Navigation state using array for easier access
    @Published var navigationStack: [AppDestination] = []
    
    // Keep path for compatibility but sync with navigationStack
    @Published var path = NavigationPath()
    
    // Current destination computed property
    var currentDestination: AppDestination? {
        return navigationStack.last
    }

    
    // Active sheets
    @Published var activeSheet: AppDestination?
    
 
    

    
    // Navigation actions
    func navigateTo(_ destination: AppDestination) {
        navigationStack.append(destination)
        path.append(destination)
    }
    

    



    
    
    func goBack() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
        if !path.isEmpty {
            path.removeLast()
        }
    }
    

    
    func presentSheet(_ destination: AppDestination?) {
        activeSheet = destination
    }
    
    
   
}
// Define all possible destinations in the app
enum AppDestination: Hashable, Identifiable {
    case lobby
    case game
    case endGame
    case hallOfFame
    case enterName
    
    var id: Self { self}
}
