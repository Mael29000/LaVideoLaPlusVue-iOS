//
//  SimpleAppLogo.swift
//  LaVideoLaPlusVue
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

/**
 * Version simple et statique du logo de l'application.
 * 
 * Design:
 * - Format carré avec coins arrondis
 * - Background diagonal: bleu marine (gauche) et rouge (droite)
 * - Cercle blanc central avec "VS" en noir
 * - Aucune animation pour une intégration discrète dans les cartes
 */
struct SimpleAppLogo: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background diagonal statique
            diagonalBackground
            
            // Cercle central blanc
            Circle()
                .fill(.white)
                .frame(width: size * 0.65, height: size * 0.65)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Texte "VS" en noir
            vsText
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
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
                        Color.black,                              // Pure black
                        Color(red: 0.3, green: 0.3, blue: 0.3)   // Dark gray
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

// MARK: - Preview

#Preview("Simple App Logo Sizes") {
    VStack(spacing: 30) {
        Text("Simple App Logo Variations")
            .font(.title2)
            .fontWeight(.bold)
        
        HStack(spacing: 20) {
            VStack {
                SimpleAppLogo(size: 60)
                Text("Small (60pt)")
                    .font(.caption)
            }
            
            VStack {
                SimpleAppLogo(size: 120)
                Text("Medium (120pt)")
                    .font(.caption)
            }
            
            VStack {
                SimpleAppLogo(size: 180)
                Text("Large (180pt)")
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Simple vs Animated Logo") {
    HStack(spacing: 40) {
        VStack {
            SimpleAppLogo(size: 100)
            Text("Simple (Static)")
                .font(.caption)
        }
        
        VStack {
            AppLogo(size: 100)
            Text("Animated")
                .font(.caption)
        }
    }
    .padding()
    .background(Color.black)
}