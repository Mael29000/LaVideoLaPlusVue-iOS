//
//  AppLogoDiagonalOnly.swift
//  LaVideoLaPlusVue
//
//  Created by Claude on 25/10/2025.
//

import SwiftUI

/**
 * Version du logo diagonal SANS le texte "VS" pour éviter le flou lors du scaling.
 * Le texte VS est géré séparément pour rester toujours net.
 */
struct AppLogoDiagonalOnly: View {
    let size: CGFloat
    @State private var isRotating = false
    @State private var isPulsating = false
    
    var body: some View {
        ZStack {
            // Background diagonal animé
            diagonalBackground
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isRotating)
            
            // Cercle central blanc (sans texte VS)
            Circle()
                .fill(.white)
                .frame(width: size * 0.65, height: size * 0.65)
                .scaleEffect(isPulsating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsating)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
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
                .fill(Color(red: 0.15, green: 0.25, blue: 0.45)) // Bleu original #26407A
                
                // Côté rouge (droite)
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.6, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.9, green: 0.2, blue: 0.3)) // Rouge original #E6334D
            }
        }
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
    }
}

// MARK: - Preview

#Preview("App Logo Diagonal Only") {
    VStack(spacing: 30) {
        Text("Logo Diagonal Sans Texte VS")
            .font(.title2)
            .fontWeight(.bold)
        
        HStack(spacing: 20) {
            VStack {
                AppLogoDiagonalOnly(size: 60)
                Text("Small (60pt)")
                    .font(.caption)
            }
            
            VStack {
                AppLogoDiagonalOnly(size: 120)
                Text("Medium (120pt)")
                    .font(.caption)
            }
            
            VStack {
                AppLogoDiagonalOnly(size: 180)
                Text("Large (180pt)")
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}