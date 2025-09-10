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
    
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
             
                
                appNavigation
                              
            }
            
          
        }
        .onAppear {
            // Load initial data when the app appears
            Task {
                await hallOfFameViewModel.loadHallOfFame() // Fetch hall of fame data
            }
        }
//        .ignoresSafeArea()
        .animation(.easeInOut, value: isMenuVisible)
        .environmentObject(router)
        .environmentObject(NamespaceContainer(mainNamespace))  .environmentObject(hallOfFameViewModel)

        .sheet(item: $router.activeSheet) { destination in
            // Sheet content based on destination
            sheetContent(for: destination)
        }
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

    
 
    

    
    // Sheet content based on destination
    @ViewBuilder
    private func sheetContent(for destination: AppDestination) -> some View {
            switch destination {
            case .hallOfFame:
                HallOfFameSheet()
                    .presentationDragIndicator(.visible)
            case .enterName:
                EnterNameSheet(gameViewModel: gameViewModel)
                    .presentationDetents([.fraction(0.75)])
                
            default:
                EmptyView()
            }
        
    }
}

#Preview {
    MainAppView().environmentObject(AppRouter())//.environmentObject(NamespaceContainer())
        
}
