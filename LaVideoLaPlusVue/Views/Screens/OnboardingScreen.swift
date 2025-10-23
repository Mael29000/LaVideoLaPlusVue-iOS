//
//  OnboardingScreen.swift
//  LaVideoLaPlusVue
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct OnboardingScreen: View {
    @State private var currentStep = 0
    let onComplete: () -> Void
    
    private let steps = [
        OnboardingStep(
            title: "Bienvenue dans LaVideoLaPlusVue !",
            description: "Devinez quelle vidéo YouTube a le plus de vues entre deux options. Testez vos connaissances et devenez un expert !",
            icon: "play.rectangle.fill",
            color: Color(.appRed)
        ),
        OnboardingStep(
            title: "Comment jouer ?",
            description: "Vous verrez deux vidéos côte à côte. Appuyez sur la vidéo qui a le plus de vues. Plus vous avez de bonnes réponses, plus votre score augmente !",
            icon: "gamecontroller.fill",
            color: .youtubeBlue
        ),
        OnboardingStep(
            title: "Hall of Fame",
            description: "Enregistrez vos meilleurs scores et comparez-vous aux autres joueurs. Votre nom apparaîtra dans le classement si vous faites un bon score !",
            icon: "crown.fill",
            color: .youtubeGold
        )
    ]
    
    var body: some View {
        ZStack {
            // Background YouTube style
            youtubeBackground
            
            VStack(spacing: 0) {
                // Header avec logo YouTube
                youtubeHeader
                
                Spacer()
                
                // Contenu principal avec carte YouTube
                youtubeCard
                
                Spacer()
                
                // Bottom navigation YouTube style
                youtubeBottomNavigation
            }
        }
    }
    
    // MARK: - YouTube Background
    @ViewBuilder
    private var youtubeBackground: some View {
        LinearGradient(
            colors: [
                Color.youtubeDark,
                Color.youtubeDark.opacity(0.95),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - YouTube Header
    @ViewBuilder
    private var youtubeHeader: some View {
        HStack {
            // App logo area
            HStack(spacing: 8) {
                AppLogo(size: 24)
                
                Text("LaVideoLaPlusVue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Progress indicator YouTube style
            Text("\(currentStep + 1)/\(steps.count)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - YouTube Card
    @ViewBuilder
    private var youtubeCard: some View {
        VStack(spacing: 24) {
            // Icon YouTube style
            ZStack {
                if currentStep == 0 {
                    // Pas de cercles pour le logo de l'app - version simple
                    SimpleAppLogo(size: 70)
                } else {
                    // Cercles colorés pour les autres étapes
                    Circle()
                        .fill(steps[currentStep].color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(steps[currentStep].color.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(steps[currentStep].color)
                }
            }
            .shadow(color: steps[currentStep].color.opacity(0.3), radius: 20)
            
            VStack(spacing: 16) {
                // Titre avec style YouTube
                Text(steps[currentStep].title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Description avec style YouTube
                Text(steps[currentStep].description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [steps[currentStep].color.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - YouTube Bottom Navigation
    @ViewBuilder
    private var youtubeBottomNavigation: some View {
        VStack(spacing: 16) {
            // Progress dots YouTube style
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index <= currentStep ? steps[currentStep].color : Color.white.opacity(0.3))
                        .frame(width: index == currentStep ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }
            .padding(.bottom, 8)
            
            // Bouton YouTube style
            Button(action: nextStep) {
                HStack(spacing: 12) {
               
                    
                    Text( "Continuer")
                        .font(.system(size: 16, weight: .semibold))
                    
                    
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [steps[currentStep].color, steps[currentStep].color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: steps[currentStep].color.opacity(0.4), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            onComplete()
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Onboarding Colors Extension
extension Color {
    static let youtubeDark = Color(red: 0.067, green: 0.067, blue: 0.067)
    static let youtubeBlue = Color(red: 0.125, green: 0.698, blue: 1.0)
    static let youtubeGold = Color(red: 1.0, green: 0.843, blue: 0.0)
}

#Preview {
    OnboardingScreen(onComplete: {})
}
