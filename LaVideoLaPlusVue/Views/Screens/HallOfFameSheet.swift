//
//  HallOfFameSheet.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Sheet du Hall of Fame affichant les meilleurs scores sauvegardés localement.
 *
 * Cette sheet présente un classement élégant des 10 meilleurs scores avec :
 * - Animations d'apparition progressives
 * - Design premium avec couleurs et effets
 * - Gestion des cas vides (première utilisation)
 * - Indicateurs visuels pour les podiums (or, argent, bronze)
 * - Dismiss automatique sur overscroll (bounce) vers le haut
 */
struct HallOfFameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HallOfFameViewModel()
    @State private var showEntries: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isDismissing: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background YouTube sombre (identique à LobbyScreen)
                LinearGradient(
                    colors: [
                        Color(red: 0.067, green: 0.067, blue: 0.067), // YouTube dark
                        Color(red: 0.05, green: 0.05, blue: 0.05),    // Plus sombre
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Content
                    if viewModel.isLoading {
                        loadingState
                    } else if viewModel.isEmpty {
                        emptyState
                    } else {
                        hallOfFameList
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadHallOfFame()
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
            // Titre avec trophée
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                
                Text("Hall of Fame")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Sous-titre
            Text("Les légendes de LaVideoLaPlusVue")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Loading State
    
    @ViewBuilder
    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Chargement du classement...")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icône vide
            Image(systemName: "list.clipboard")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("Aucun score enregistré")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Sois le premier à dépasser\nles 20 points pour entrer\ndans la légende !")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Bouton de motivation
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
    
    // MARK: - Hall of Fame List
    
    @ViewBuilder
    private var hallOfFameList: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Contenu principal
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            HallOfFameRow(
                                entry: entry,
                                rank: index + 1,
                                isVisible: showEntries
                            )
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1), // Animation progressive
                                value: showEntries
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear
                            .onAppear {
                                // Calculer la position initiale
                                let frame = contentGeometry.frame(in: .named("scroll"))
                                scrollOffset = frame.minY
                            }
                            .onChange(of: contentGeometry.frame(in: .named("scroll")).minY) { newValue in
                                let previousOffset = scrollOffset
                                scrollOffset = newValue
                                
                                // Vérifier si on fait un overscroll vers le haut
                                if newValue > 0 && !isDismissing {
                                    // Si on dépasse 60 points, on déclenche le dismiss
                                    if newValue > 60 {
                                        isDismissing = true
                                        dismiss()
                                    }
                                }
                            }
                    }
                )
            }
            .coordinateSpace(name: "scroll")
        }
        .onAppear {
            // Déclencher l'animation d'apparition progressive
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showEntries = true
            }
        }
    }
    
    // MARK: - Data Loading handled by ViewModel
}

// MARK: - Hall of Fame Row

/**
 * Ligne individuelle du classement avec design adaptatif selon le rang.
 */
struct HallOfFameRow: View {
    let entry: HallOfFameEntry
    let rank: Int
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Rank Badge
            rankBadge
            
            // MARK: - Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(formatDate(entry.date))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // MARK: - Score
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
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0 : 50)
    }
    
    // MARK: - Rank Badge
    
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
                // Podium icons
                Image(systemName: podiumIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(podiumIconColor)
            } else {
                // Numéro de rang
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
            // Gradient doré plus contrasté pour le 1er
            return Color(red: 0.25, green: 0.22, blue: 0.08) // Fond doré sombre
        case 2:
            // Gris-bleu contrasté pour le 2ème
            return Color(red: 0.18, green: 0.18, blue: 0.25)
        case 3:
            // Orange sombre contrasté pour le 3ème
            return Color(red: 0.25, green: 0.18, blue: 0.12)
        default:
            // Gris sombre pour les autres
            return Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }
    
    private var borderColor: Color {
        switch rank {
        case 1: return .yellow.opacity(0.6) // Plus visible sur fond sombre
        case 2: return .white.opacity(0.5)  // Plus visible sur fond sombre
        case 3: return .orange.opacity(0.6) // Plus visible sur fond sombre
        default: return .white.opacity(0.15) // Bordure subtile pour tous
        }
    }
    
    private var borderWidth: CGFloat {
        return rank <= 3 ? 2.0 : 1.0 // Bordure pour tous, plus épaisse pour le podium
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
