//
//  MainApp.swift
//  Summit
//
//  Created by Maël Suard on 10/01/2025.
//


import SwiftUI




struct MainAppView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var gameViewModel = GameViewModel()
    @Namespace var mainNamespace

    @StateObject private var hallOfFameViewModel = HallOfFameViewModel()
 
    @State private var isMenuVisible = false
    
    // État pour notre modal custom
    @State private var showCustomModal = false
    @State private var currentModalDestination: AppDestination?
    
    // Pas besoin d'état de splash screen - LobbyScreen gère tout
    
    
    
    var body: some View {
        ZStack {
            // Background noir constant pour éviter tout flash blanc
            LinearGradient(
                colors: [
                    Color(red: 0.067, green: 0.067, blue: 0.067), // YouTube dark
                    Color(red: 0.05, green: 0.05, blue: 0.05),    // Plus sombre
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Contenu principal de l'app
            VStack(spacing: 0) {
                appNavigation
            }
            
            // Modal custom overlay
            if showCustomModal, let destination = currentModalDestination {
                CustomModalOverlay(isPresented: $showCustomModal) {
                    customModalContent(for: destination)
                }
                .zIndex(999)
            }
            
            // Plus de SplashScreen séparé - LobbyScreen gère l'animation
        }
        .onAppear {
            // Load initial data when the app appears
            Task {
                await hallOfFameViewModel.loadHallOfFame() // Fetch hall of fame data
            }
            
            // Plus besoin de gestion de loading - LobbyScreen s'en charge
        }
        .onChange(of: router.activeSheet) { newValue in
            // Synchroniser avec notre modal custom
            if let destination = newValue {
                currentModalDestination = destination
                showCustomModal = true
                // Réinitialiser le router pour éviter les conflits
                DispatchQueue.main.async {
                    router.activeSheet = nil
                }
            }
        }
        .onChange(of: showCustomModal) { newValue in
            if !newValue {
                currentModalDestination = nil
            }
        }
//        .ignoresSafeArea()
        .animation(.easeInOut, value: isMenuVisible)
        .environmentObject(router)
        .environmentObject(NamespaceContainer(mainNamespace))  .environmentObject(hallOfFameViewModel)
    }
    
    // Simple view switching without NavigationStack
    private var appNavigation: some View {
        ZStack {
            // Show current view based on the last destination in navigationStack
            if router.navigationStack.isEmpty {
                LobbyScreen()
            } else if let currentDestination = router.currentDestination {
                destinationView(for: currentDestination)
                    .transition(.opacity) // Simple fade transition instead of slide
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.navigationStack.count)
        //.ignoresSafeArea(.all) // Ignore all safe areas for full screen control
    }
    
        
    
    
    // Helper function to create the appropriate view for a destination
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .lobby:
            LobbyScreen()
            
        case .game:
            GameScreen(gameViewModel: gameViewModel)
            
        case .endGame:
            EndGameScreen(gameViewModel: gameViewModel)
            
        case .hallOfFame:
            HallOfFameSheet()
        case .enterName:
            EnterNameSheet(gameViewModel: gameViewModel)
            
        }
     
    }

    
 
    

    
    // Custom modal content based on destination
    @ViewBuilder
    private func customModalContent(for destination: AppDestination) -> some View {
        switch destination {
        case .hallOfFame:
            HallOfFameSheet()
        case .enterName:
            EnterNameSheet(gameViewModel: gameViewModel)
        default:
            EmptyView()
        }
    }
    
    // Plus de gestion Splash Screen - tout est dans LobbyScreen maintenant
}

#Preview {
    MainAppView().environmentObject(AppRouter())//.environmentObject(NamespaceContainer())
        
}
