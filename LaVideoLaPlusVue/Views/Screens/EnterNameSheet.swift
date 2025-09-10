//
//  EnterNameSheet.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Sheet pour la saisie du nom du joueur lors de son premier score > 20.
 *
 * Cette sheet s'affiche automatiquement quand le joueur atteint un score supérieur à 20
 * pour la première fois et permet de sauvegarder son nom localement pour le Hall of Fame.
 *
 * ## Fonctionnalités
 * - Interface élégante avec félicitations
 * - Validation du nom (longueur min/max)
 * - Sauvegarde locale avec UserDefaults
 * - Animation d'apparition et de confirmation
 * - Gestion du clavier avec focus automatique
 */
struct EnterNameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var hallOfFameViewModel = HallOfFameViewModel()
    
    @State private var playerName: String = ""
    @State private var showValidationError: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    
    // MARK: - Constants
    
    private let minNameLength = 2
    private let maxNameLength = 20
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 0.99),
                        Color(red: 0.88, green: 0.92, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // MARK: - Header Section
                    celebrationHeader
                    
                    // MARK: - Form Section
                    nameInputSection
                    
                    // MARK: - Action Buttons
                    actionButtons
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                // Success overlay
                if showSuccess {
                    successOverlay
                }
            }
        }
        .presentationDetents([.fraction(0.75)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            // Focus automatique sur le champ de texte
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Le focus sera géré par SwiftUI automatiquement
            }
        }
    }
    
    // MARK: - Header with Celebration
    
    @ViewBuilder
    private var celebrationHeader: some View {
        VStack(spacing: 16) {
            // Trophée animé
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .scaleEffect(showSuccess ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true), value: showSuccess)
            
            // Félicitations
            VStack(spacing: 8) {
                Text("Félicitations ! 🎉")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Score de \(gameViewModel.currentScore) points")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.appBlue)
                
                Text("Tu entres dans le Hall of Fame !")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Name Input Section
    
    @ViewBuilder
    private var nameInputSection: some View {
        VStack(spacing: 16) {
            // Instruction
            Text("Inscris ton nom :")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Champ de saisie
            VStack(spacing: 8) {
                TextField("Ton nom ici...", text: $playerName)
                    .font(.system(size: 18, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                showValidationError ? Color.red : Color.gray.opacity(0.3),
                                lineWidth: showValidationError ? 2 : 1
                            )
                    )
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .onSubmit {
                        submitName()
                    }
                
                // Indication de longueur
                HStack {
                    if showValidationError {
                        Text("Le nom doit faire entre \(minNameLength) et \(maxNameLength) caractères")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    } else {
                        Text("\(playerName.count)/\(maxNameLength)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Bouton principal
            Button(action: submitName) {
                HStack(spacing: 12) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                    }
                    
                    Text(isSubmitting ? "Enregistrement..." : "Confirmer")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isValidName ? Color.green : Color.gray
                )
                .cornerRadius(12)
                .scaleEffect(isSubmitting ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isSubmitting)
            }
            .disabled(!isValidName || isSubmitting)
            
            // Bouton secondaire (passer)
            Button(action: skipNameEntry) {
                Text("Passer")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.vertical, 12)
            }
        }
    }
    
    // MARK: - Success Overlay
    
    @ViewBuilder
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismiss on tap
                }
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Nom enregistré ! 🎊")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Bienvenue dans le Hall of Fame, \(playerName) !")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
            .scaleEffect(showSuccess ? 1.0 : 0.5)
            .opacity(showSuccess ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccess)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidName: Bool {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.count >= minNameLength && trimmedName.count <= maxNameLength
    }
    
    // MARK: - Actions
    
    private func submitName() {
        guard isValidName else {
            showValidationError = true
            // Haptic feedback pour erreur
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showValidationError = false
            }
            return
        }
        
        isSubmitting = true
        showValidationError = false
        
        // Simuler un délai de sauvegarde
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            savePlayerName()
            
            isSubmitting = false
            showSuccess = true
            
            // Haptic feedback pour succès
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            // Fermer après 2 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
    }
    
    private func skipNameEntry() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
    
    private func savePlayerName() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sauvegarder le nom dans UserDefaults
        UserDefaults.standard.set(trimmedName, forKey: "playerName")
        
        // Utiliser le nouveau ViewModel pour sauvegarder
        Task {
            let success = await hallOfFameViewModel.saveScore(
                name: trimmedName,
                score: gameViewModel.currentScore,
                from: gameViewModel
            )
            
            if success {
                print("🏆 [HallOfFame] Nom sauvegardé : \(trimmedName) avec score \(gameViewModel.currentScore)")
            } else {
                print("❌ [HallOfFame] Échec sauvegarde : \(trimmedName)")
            }
        }
    }
    
    // MARK: - Hall of Fame logic handled by HallOfFameViewModel
}

#Preview {
    let gameViewModel = GameViewModel()
    gameViewModel.currentScore = 25
    
    return EnterNameSheet(gameViewModel: gameViewModel)
}
