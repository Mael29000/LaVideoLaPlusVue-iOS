//
//  ParticleSystem.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI

/**
 * Système de particules avancé pour les célébrations de scores.
 *
 * Ce composant génère différents types de particules selon le contexte :
 * - Particules dorées pour les bons scores (25+)
 * - Confettis colorés pour les nouveaux records
 * - Étoiles scintillantes pour les scores exceptionnels (40+)
 *
 * ## Usage
 * ```swift
 * ParticleSystem(
 *     type: .golden,
 *     isActive: showCelebration,
 *     intensity: .high
 * )
 * ```
 */
struct ParticleSystem: View {
    
    // MARK: - Types
    
    enum ParticleType {
        case golden      // Particules dorées qui tombent
        case confetti    // Confettis multicolores
        case stars       // Étoiles scintillantes
        case fireworks   // Explosion de particules
    }
    
    enum Intensity {
        case low, medium, high
        
        var particleCount: Int {
            switch self {
            case .low: return 10      // 15+ : Léger, pas trop impressionnant
            case .medium: return 25   // 20+ : On commence vraiment à avoir des particules
            case .high: return 60     // 36+ et records : Incroyable, quelque chose de fou
            }
        }
        
        var animationDuration: Double {
            switch self {
            case .low: return 3.0
            case .medium: return 4.0
            case .high: return 5.0
            }
        }
    }
    
    // MARK: - Properties
    
    let type: ParticleType
    let isActive: Bool
    let intensity: Intensity
    
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    
    // MARK: - Particle Model
    
    private struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var rotation: Double
        var rotationSpeed: Double
        var scale: Double
        var opacity: Double
        var color: Color
        var lifespan: Double
        var age: Double = 0
        
        var isAlive: Bool {
            age < lifespan
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    particleView(particle)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .onAppear {
                if isActive {
                    startParticleSystem(in: geometry)
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    startParticleSystem(in: geometry)
                } else {
                    stopParticleSystem()
                }
            }
        }
    }
    
    // MARK: - Particle Views
    
    @ViewBuilder
    private func particleView(_ particle: Particle) -> some View {
        switch type {
        case .golden:
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow, Color.orange],
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        
        case .confetti:
            RoundedRectangle(cornerRadius: 2)
                .fill(particle.color)
                .frame(width: 6, height: 12)
        
        case .stars:
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundColor(particle.color)
                .shadow(color: particle.color, radius: 4)
        
        case .fireworks:
            Circle()
                .fill(particle.color)
                .frame(width: 4, height: 4)
                .overlay(
                    Circle()
                        .stroke(particle.color.opacity(0.5), lineWidth: 2)
                        .scaleEffect(1.5)
                )
        }
    }
    
    // MARK: - Particle System Logic
    
    private func startParticleSystem(in geometry: GeometryProxy) {
        generateParticles(in: geometry)
        
        let frameRate: TimeInterval = 1.0 / 60.0
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { _ in
            updateParticles(in: geometry)
        }
        
        // Arrêter après la durée d'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + intensity.animationDuration) {
            stopParticleSystem()
        }
    }
    
    private func stopParticleSystem() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        withAnimation(.easeOut(duration: 1.0)) {
            particles.removeAll()
        }
    }
    
    private func generateParticles(in geometry: GeometryProxy) {
        particles.removeAll()
        
        for _ in 0..<intensity.particleCount {
            let particle = createParticle(in: geometry)
            particles.append(particle)
        }
    }
    
    private func createParticle(in geometry: GeometryProxy) -> Particle {
        let size = geometry.size
        
        switch type {
        case .golden:
            return Particle(
                position: CGPoint(
                    x: Double.random(in: 0...size.width),
                    y: -20
                ),
                velocity: CGVector(
                    dx: Double.random(in: -30...30),
                    dy: Double.random(in: 50...120)
                ),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -180...180),
                scale: Double.random(in: 0.5...1.2),
                opacity: Double.random(in: 0.7...1.0),
                color: [Color.yellow, Color.orange, Color.yellow].randomElement()!,
                lifespan: Double.random(in: 3.0...5.0)
            )
            
        case .confetti:
            return Particle(
                position: CGPoint(
                    x: size.width * 0.5,
                    y: size.height * 0.3
                ),
                velocity: CGVector(
                    dx: Double.random(in: -150...150),
                    dy: Double.random(in: -100...50)
                ),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -360...360),
                scale: Double.random(in: 0.6...1.0),
                opacity: 1.0,
                color: [.red, .blue, .green, .purple, .orange, .pink].randomElement()!,
                lifespan: Double.random(in: 2.0...4.0)
            )
            
        case .stars:
            return Particle(
                position: CGPoint(
                    x: Double.random(in: 0...size.width),
                    y: Double.random(in: 0...size.height)
                ),
                velocity: CGVector(dx: 0, dy: 0),
                rotation: 0,
                rotationSpeed: Double.random(in: -90...90),
                scale: Double.random(in: 0.3...0.8),
                opacity: Double.random(in: 0.6...1.0),
                color: [.white, .yellow, .cyan].randomElement()!,
                lifespan: Double.random(in: 1.5...3.0)
            )
            
        case .fireworks:
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 100...200)
            
            return Particle(
                position: CGPoint(x: size.width * 0.5, y: size.height * 0.4),
                velocity: CGVector(
                    dx: cos(angle) * speed,
                    dy: sin(angle) * speed
                ),
                rotation: 0,
                rotationSpeed: 0,
                scale: Double.random(in: 0.8...1.2),
                opacity: 1.0,
                color: [.red, .blue, .green, .purple, .orange, .yellow].randomElement()!,
                lifespan: Double.random(in: 1.0...2.5)
            )
        }
    }
    
    private func updateParticles(in geometry: GeometryProxy) {
        let deltaTime: Double = 1.0 / 60.0
        
        for i in particles.indices {
            particles[i].age += deltaTime
            
            // Mise à jour de la position
            particles[i].position.x += particles[i].velocity.dx * deltaTime
            particles[i].position.y += particles[i].velocity.dy * deltaTime
            
            // Mise à jour de la rotation
            particles[i].rotation += particles[i].rotationSpeed * deltaTime
            
            // Gravité pour certains types
            if type == .golden || type == .confetti {
                particles[i].velocity.dy += 150 * deltaTime // Gravité
                particles[i].velocity.dx *= 0.98 // Friction de l'air
            }
            
            // Fade out avec l'âge
            let lifeRatio = particles[i].age / particles[i].lifespan
            if lifeRatio > 0.7 {
                let fadeRatio = (lifeRatio - 0.7) / 0.3
                particles[i].opacity = 1.0 - fadeRatio
            }
            
            // Scintillement pour les étoiles
            if type == .stars {
                particles[i].opacity = 0.3 + 0.7 * abs(sin(particles[i].age * 4))
                particles[i].scale = 0.3 + 0.5 * abs(cos(particles[i].age * 3))
            }
        }
        
        // Supprimer les particules mortes
        particles.removeAll { !$0.isAlive }
    }
}

// MARK: - Convenience Extensions

extension ParticleSystem {
    /**
     * Initializer de convenance pour score-based particles.
     */
    static func forScore(_ score: Int, isActive: Bool, isNewRecord: Bool = false) -> ParticleSystem {
        // Nouveau record = maximum de particules
        if isNewRecord {
            return ParticleSystem(type: .fireworks, isActive: isActive, intensity: .high)
        }
        
        switch score {
        case 36...:
            // 36+ : Incroyable, quelque chose d'incroyable
            return ParticleSystem(type: .fireworks, isActive: isActive, intensity: .high)
        case 20...35:
            // 20+ : On commence vraiment à avoir des particules
            return ParticleSystem(type: .confetti, isActive: isActive, intensity: .medium)
        case 15...19:
            // 15+ : Léger, pas trop impressionnant
            return ParticleSystem(type: .golden, isActive: isActive, intensity: .low)
        default:
            return ParticleSystem(type: .golden, isActive: false, intensity: .low)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            Text("🎉 Particle System Demo")
                .font(.title)
                .foregroundColor(.white)
            
            ParticleSystem(
                type: .confetti,
                isActive: true,
                intensity: .high
            )
            .frame(height: 300)
        }
    }
}
