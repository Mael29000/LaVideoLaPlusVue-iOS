//
//  HallOfFameSheet.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

struct HallOfFameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HallOfFameViewModel()
    @State private var showEntries: Bool = false
    @State private var hasLoadedInitially: Bool = false
    @State private var rowsVisible: Bool = false
    @State private var selectedPlayerName: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.067, green: 0.067, blue: 0.067),
                        Color(red: 0.05, green: 0.05, blue: 0.05),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // État de connexion
                    if !viewModel.isOnline {
                        offlineWarning
                    }
                    
                    // Content
                    if viewModel.isLoading || !hasLoadedInitially {
                        loadingState
                    } else if !viewModel.isOnline {
                        offlineState
                    } else if viewModel.hasError {
                        errorState
                    } else if viewModel.isEmpty {
                        emptyState
                    } else if hasLoadedInitially && !viewModel.isPlayerInHallOfFame && !showEntries {
                        // S'assurer que les données sont chargées avant d'afficher cet écran
                        playerNotInHallOfFameState
                    } else if hasLoadedInitially && (viewModel.isPlayerInHallOfFame || showEntries) {
                        // Afficher le classement si le joueur y est ou s'il a cliqué pour voir
                        hallOfFameContent
                    } else {
                        // État de transition - ne rien afficher pendant le chargement initial
                        Color.clear
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadHallOfFame()
                // Après le chargement, si le joueur est dans le Hall of Fame, afficher directement les entrées
                if viewModel.isPlayerInHallOfFame {
                    showEntries = true
                }
                hasLoadedInitially = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Fermer") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                
                Text("Hall of Fame")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if let playerName = selectedPlayerName,
               let ranking = viewModel.playerRanking {
                Text("Tu es \(formatRank(ranking.rank)) sur \(ranking.total) joueurs")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.yellow)
            } else {
                Text("Top 100 mondial")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Offline Warning
    
    @ViewBuilder
    private var offlineWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 14))
            
            Text("Mode hors ligne - Les données peuvent être obsolètes")
                .font(.system(size: 14))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange, lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - States
    
    @ViewBuilder
    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Connexion au serveur...")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var offlineState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("Pas de connexion")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Le Hall of Fame nécessite\nune connexion Internet")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                if !viewModel.entries.isEmpty {
                    Text("Affichage des données en cache")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.refreshHallOfFame()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                    
                    Text("Réessayer")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var errorState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 80))
                .foregroundColor(.red.opacity(0.8))
            
            VStack(spacing: 12) {
                Text("Erreur")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.errorMessage ?? "Une erreur est survenue")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.refreshHallOfFame()
                }
            }) {
                Text("Réessayer")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "list.clipboard")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("Aucun score enregistré")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Dépasse les 10 points\npour rejoindre les légendes !")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 18))
                    
                    Text("Commencer à jouer")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var playerNotInHallOfFameState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("Tu n'es pas encore dans le Hall of Fame")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Vous n'êtes pas encore présent, battez le score de 10 pour rejoindre les légendes")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showEntries = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 18))
                    
                    Text("Voir les légendes de la vidéo la plus vue")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .white.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Hall of Fame Content
    
    @ViewBuilder
    private var hallOfFameContent: some View {
        VStack(spacing: 16) {
            // Options de vue
            if let playerName = UserDefaults.standard.string(forKey: "playerName") {
                HStack(spacing: 16) {
                    Button(action: {
                        selectedPlayerName = nil
                        Task {
                            await viewModel.loadHallOfFame()
                        }
                    }) {
                        Text("Top 100")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedPlayerName == nil ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedPlayerName == nil ? Color.yellow : Color.white.opacity(0.2)
                            )
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        selectedPlayerName = playerName
                        Task {
                            await viewModel.loadPlayerRanking(name: playerName)
                        }
                    }) {
                        Text("Mon classement")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedPlayerName != nil ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedPlayerName != nil ? Color.yellow : Color.white.opacity(0.2)
                            )
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
            
            // Liste
            hallOfFameList
        }
    }
    
    @ViewBuilder
    private var hallOfFameList: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            HallOfFameRow(
                                entry: entry,
                                rank: getRankForEntry(entry, at: index),
                                isVisible: rowsVisible,
                                isHighlighted: entry.name == selectedPlayerName
                            )
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.05),
                                value: rowsVisible
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .refreshable {
                await viewModel.refreshHallOfFame()
            }
        }
        .onAppear {
            // Animation d'apparition pour la liste
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                rowsVisible = true
            }
        }
    }
    
    private func getRankForEntry(_ entry: HallOfFameEntry, at index: Int) -> Int {
        if selectedPlayerName != nil, let ranking = viewModel.playerRanking {
            // En mode classement personnel, calculer le vrai rang
            // Si rank est 253 et qu'on montre 50 avant/après, index 0 = rang 203
            let startRank = max(1, ranking.rank - 50)
            return startRank + index
        } else {
            // En mode top 100
            return index + 1
        }
    }
    
    private func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1:
            return "1er"
        default:
            return "\(rank)ème"
        }
    }
}

// MARK: - Hall of Fame Row

struct HallOfFameRow: View {
    let entry: HallOfFameEntry
    let rank: Int
    let isVisible: Bool
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            rankBadge
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(formatDate(entry.date))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.score)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(scoreColor)
                
                Text("points")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        )
        .scaleEffect(isVisible ? (isHighlighted ? 1.02 : 1.0) : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0 : 50)
        .shadow(
            color: isHighlighted ? Color.yellow.opacity(0.4) : .clear,
            radius: isHighlighted ? 10 : 0
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isHighlighted ? Color.yellow : .clear,
                    lineWidth: isHighlighted ? (rank <= 3 ? 2.5 : 3) : 0
                )
        )
    }
    
    @ViewBuilder
    private var rankBadge: some View {
        ZStack {
            Circle()
                .fill(rankBadgeColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(rankBorderColor, lineWidth: 2)
                )
            
            if rank <= 3 {
                Image(systemName: podiumIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(podiumIconColor)
            } else {
                Text("\(rank)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var rankBadgeColor: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        case 2:
            return LinearGradient(colors: [Color(red: 0.8, green: 0.8, blue: 0.8), Color(red: 0.6, green: 0.6, blue: 0.6)], startPoint: .top, endPoint: .bottom)
        case 3:
            return LinearGradient(colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.3, blue: 0.1)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var rankBorderColor: Color {
        switch rank {
        case 1: return .yellow.opacity(0.8)
        case 2: return Color(red: 0.9, green: 0.9, blue: 0.9)
        case 3: return Color(red: 0.9, green: 0.6, blue: 0.3)
        default: return .white.opacity(0.3)
        }
    }
    
    private var podiumIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal"
        default: return ""
        }
    }
    
    private var podiumIconColor: Color {
        switch rank {
        case 1: return .white
        case 2: return .black
        case 3: return .white
        default: return .white
        }
    }
    
    private var backgroundColor: Color {
        switch rank {
        case 1:
            return Color(red: 0.25, green: 0.22, blue: 0.08)
        case 2:
            return Color(red: 0.18, green: 0.18, blue: 0.25)
        case 3:
            return Color(red: 0.25, green: 0.18, blue: 0.12)
        default:
            return Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }
    
    private var borderColor: Color {
        // Si l'entrée est mise en évidence ET est dans le top 3, pas de bordure de base
        if isHighlighted && rank <= 3 {
            return .clear
        }
        
        switch rank {
        case 1: return .yellow.opacity(0.6)
        case 2: return .white.opacity(0.5)
        case 3: return .orange.opacity(0.6)
        default: return .white.opacity(0.15)
        }
    }
    
    private var borderWidth: CGFloat {
        // Si l'entrée est mise en évidence ET est dans le top 3, pas de bordure de base
        if isHighlighted && rank <= 3 {
            return 0
        }
        return rank <= 3 ? 2.0 : 1.0
    }
    
    private var scoreColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .white
        case 3: return .orange
        default: return .white.opacity(0.9)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

#Preview {
    HallOfFameSheet()
}