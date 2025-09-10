//
//  AppLogo.swift
//  LaVideoLaPlusVue
//
//  Created by Claude on 09/12/2025.
//

import SwiftUI

/**
 * Logo officiel de l'application reproduisant le design diagonal avec animations.
 *
 * Design:
 * - Background diagonal: bleu marine (gauche) et rouge (droite)
 * - Cercle blanc central avec "VS" en gradient rouge-violet
 * - Animations: rotation du background et pulsation du cercle
 */
struct AppLogo: View {
    let size: CGFloat
    @State private var isRotating = false
    @State private var isPulsating = false
    @State private var showLogo = false
    
    var body: some View {
        ZStack {
            // Background diagonal animé
            diagonalBackground
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isRotating)
            
            // Cercle central blanc avec animation de pulsation
            Circle()
                .fill(.white)
                .frame(width: size * 0.65, height: size * 0.65)
                .scaleEffect(isPulsating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsating)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Texte "VS" avec gradient
            vsText
                .scaleEffect(showLogo ? 1.0 : 0.5)
                .opacity(showLogo ? 1.0 : 0.0)
                .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.3), value: showLogo)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background diagonal
    
    @ViewBuilder
    private var diagonalBackground: some View {
        GeometryReader { geometry in
            ZStack {
                // Côté bleu marine (gauche)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.6, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.25, blue: 0.45),  // Bleu marine
                            Color(red: 0.10, green: 0.20, blue: 0.40)   // Bleu marine foncé
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Côté rouge (droite)
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.6, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.2, blue: 0.3),   // Rouge vif
                            Color(red: 0.8, green: 0.15, blue: 0.25)  // Rouge foncé
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
            }
        }
    }
    
    // MARK: - Texte VS
    
    @ViewBuilder
    private var vsText: some View {
        Text("VS")
            .font(.system(size: size * 0.25, weight: .black, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.8, green: 0.2, blue: 0.3),    // Rouge
                        Color(red: 0.6, green: 0.15, blue: 0.4),   // Rouge-violet
                        Color(red: 0.4, green: 0.1, blue: 0.5)     // Violet
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Démarrer la rotation lente du background
        withAnimation {
            isRotating = true
        }
        
        // Démarrer la pulsation du cercle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isPulsating = true
            }
        }
        
        // Apparition du logo VS
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                showLogo = true
            }
        }
    }
}

// MARK: - Preview

#Preview("App Logo Sizes") {
    VStack(spacing: 30) {
        Text("App Logo Variations")
            .font(.title2)
            .fontWeight(.bold)
        
        HStack(spacing: 20) {
            VStack {
                AppLogo(size: 60)
                Text("Small (60pt)")
                    .font(.caption)
            }
            
            VStack {
                AppLogo(size: 120)
                Text("Medium (120pt)")
                    .font(.caption)
            }
            
            VStack {
                AppLogo(size: 180)
                Text("Large (180pt)")
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("App Logo on Dark") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        AppLogo(size: 200)
    }
}