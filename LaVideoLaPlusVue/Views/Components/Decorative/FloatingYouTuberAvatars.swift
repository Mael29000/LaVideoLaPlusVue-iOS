import SwiftUI

/**
 * Composant d'avatars YouTuber flottants pour la page d'accueil.
 *
 * Fonctionnalités:
 * - Affiche 4 avatars simultanément avec animations fluides
 * - Trajectoires organiques avec courbes et rebonds
 * - Renouvellement automatique des avatars toutes les 8-10 secondes
 * - Adaptation aux différentes tailles d'écran
 * - Cache des images pour performances optimales
 */
struct FloatingYouTuberAvatars: View {
    @State private var avatars: [FloatingAvatar] = []
    @State private var animationTimer: Timer?
    @State private var renewalTimer: Timer?
    @State private var recentlyUsedYouTubers: [String] = [] // Cache des IDs récemment utilisés
    
    let containerHeight: CGFloat
    let containerWidth: CGFloat
    
    // MARK: - Configuration
    
    private let maxAvatars = 7 // Plus d'avatars simultanés
    private let avatarSize: CGFloat = 60
    private let animationDuration: Double = 12.0 // Durée pour traverser l'écran
    private let renewalInterval: Double = 4.0 // Renouvellement plus fréquent pour continuité
    private let maxRecentlyUsed = 20 // Éviter les 20 derniers YouTubers
    
    var body: some View {
        ZStack {
            ForEach(avatars) { avatar in
                FloatingAvatarView(
                    avatar: avatar,
                    size: avatarSize
                )
                .position(x: avatar.currentX, y: avatar.currentY)
                .opacity(avatar.opacity)
                .scaleEffect(avatar.scale)
                .animation(
                    .easeInOut(duration: 0.8),
                    value: avatar.opacity
                )
            }
        }
        .frame(width: containerWidth, height: containerHeight)
        .onAppear {
            startFloatingAnimation()
        }
        .onDisappear {
            stopAnimations()
        }
    }
    
    // MARK: - Animation Control
    
    private func startFloatingAnimation() {
        // Charger et démarrer les avatars initiaux
        Task {
            await loadInitialAvatars()
            startAnimationTimer()
            startRenewalTimer()
        }
    }
    
    private func loadInitialAvatars() async {
        do {
            let youtubers = try await getUniqueYouTubers(count: maxAvatars)
            
            await MainActor.run {
                // Créer les avatars flottants avec positions initiales
                for (index, youtuber) in youtubers.enumerated() {
                    let avatar = createFloatingAvatar(
                        youtuber: youtuber,
                        delay: Double(index) * 1.2 // Étalement plus rapide pour plus de continuité
                    )
                    avatars.append(avatar)
                    
                    // Ajouter au cache des récemment utilisés
                    addToRecentlyUsed(youtuber.id)
                }
            }
        } catch {
            print("❌ Failed to load initial avatars: \(error)")
        }
    }
    
    private func createFloatingAvatar(youtuber: YouTuberAvatarService.YouTuber, delay: Double = 0) -> FloatingAvatar {
        // Position de départ aléatoire sur le côté gauche
        let startY = CGFloat.random(in: avatarSize...(containerHeight - avatarSize))
        
        // Trajectoire courbe avec point de contrôle aléatoire
        let controlY = CGFloat.random(in: avatarSize...(containerHeight - avatarSize))
        let endY = CGFloat.random(in: avatarSize...(containerHeight - avatarSize))
        
        return FloatingAvatar(
            id: UUID(),
            youtuber: youtuber,
            startX: -avatarSize,
            startY: startY,
            controlY: controlY,
            endX: containerWidth + avatarSize,
            endY: endY,
            currentX: -avatarSize,
            currentY: startY,
            progress: 0.0,
            opacity: 0.0,
            scale: 0.5,
            delay: delay
        )
    }
    
    private func startAnimationTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateAvatarPositions()
        }
    }
    
    private func startRenewalTimer() {
        renewalTimer = Timer.scheduledTimer(withTimeInterval: renewalInterval, repeats: true) { _ in
            Task {
                await renewRandomAvatar()
            }
        }
    }
    
    private func updateAvatarPositions() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        for index in avatars.indices {
            let avatar = avatars[index]
            let elapsed = currentTime - avatar.startTime - avatar.delay
            
            if elapsed > 0 {
                // Progression de 0 à 1 sur la durée d'animation
                let progress = min(elapsed / animationDuration, 1.0)
                
                // Courbe de Bézier pour trajectoire organique
                let bezierProgress = calculateBezierPoint(
                    t: progress,
                    start: CGPoint(x: avatar.startX, y: avatar.startY),
                    control: CGPoint(x: containerWidth * 0.5, y: avatar.controlY),
                    end: CGPoint(x: avatar.endX, y: avatar.endY)
                )
                
                // Opacité avec fade in/out
                let opacity: Double
                if progress < 0.1 {
                    opacity = progress / 0.1 // Fade in
                } else if progress > 0.9 {
                    opacity = (1.0 - progress) / 0.1 // Fade out
                } else {
                    opacity = 1.0
                }
                
                // Scale avec subtle pulsation
                let baseScale = 1.0 + sin(elapsed * 2) * 0.1
                
                avatars[index] = avatar.updated(
                    currentX: bezierProgress.x,
                    currentY: bezierProgress.y,
                    progress: progress,
                    opacity: opacity,
                    scale: baseScale
                )
                
                // Supprimer l'avatar s'il est sorti de l'écran
                if progress >= 1.0 {
                    avatars.remove(at: index)
                    return
                }
            }
        }
    }
    
    private func renewRandomAvatar() async {
        // Créer de nouveaux avatars plus agressivement pour maintenir la continuité
        let targetCount = maxAvatars
        let currentCount = avatars.count
        let needToAdd = max(0, targetCount - currentCount)
        
        guard needToAdd > 0 else { return }
        
        do {
            let newYoutubers = try await getUniqueYouTubers(count: needToAdd)
            
            await MainActor.run {
                for youtuber in newYoutubers {
                    let newAvatar = createFloatingAvatar(youtuber: youtuber)
                    avatars.append(newAvatar)
                    
                    // Ajouter au cache des récemment utilisés
                    addToRecentlyUsed(youtuber.id)
                }
            }
        } catch {
            print("❌ Failed to renew avatar: \(error)")
        }
    }
    
    private func calculateBezierPoint(t: Double, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
        let u = 1.0 - t
        let tt = t * t
        let uu = u * u
        
        let x = uu * start.x + 2 * u * t * control.x + tt * end.x
        let y = uu * start.y + 2 * u * t * control.y + tt * end.y
        
        return CGPoint(x: x, y: y)
    }
    
    private func stopAnimations() {
        animationTimer?.invalidate()
        renewalTimer?.invalidate()
        animationTimer = nil
        renewalTimer = nil
    }
    
    // MARK: - YouTuber Selection with Cooldown
    
    /**
     * Récupère des YouTubers uniques en évitant ceux récemment utilisés.
     */
    private func getUniqueYouTubers(count: Int) async throws -> [YouTuberAvatarService.YouTuber] {
        let allYoutubers = try await YouTuberAvatarService.shared.loadYouTubers()
        
        // Filtrer les YouTubers récemment utilisés
        let availableYoutubers = allYoutubers.filter { youtuber in
            !recentlyUsedYouTubers.contains(youtuber.id)
        }
        
        // Si pas assez de YouTubers disponibles, réinitialiser le cache partiellement
        let finalYoutubers: [YouTuberAvatarService.YouTuber]
        if availableYoutubers.count < count {
            print("⚠️ Not enough unique YouTubers, partially clearing cache")
            // Garder seulement les 10 derniers dans le cache au lieu de 20
            recentlyUsedYouTubers = Array(recentlyUsedYouTubers.suffix(10))
            
            // Refiltrer avec le cache réduit
            let retryAvailable = allYoutubers.filter { youtuber in
                !recentlyUsedYouTubers.contains(youtuber.id)
            }
            
            finalYoutubers = Array(retryAvailable.shuffled().prefix(count))
        } else {
            finalYoutubers = Array(availableYoutubers.shuffled().prefix(count))
        }
        
        return finalYoutubers
    }
    
    /**
     * Ajoute un YouTuber au cache des récemment utilisés.
     */
    private func addToRecentlyUsed(_ youtuberId: String) {
        recentlyUsedYouTubers.append(youtuberId)
        
        // Maintenir la taille du cache à maxRecentlyUsed
        if recentlyUsedYouTubers.count > maxRecentlyUsed {
            recentlyUsedYouTubers.removeFirst()
        }
        
        print("🔄 Recently used cache: \(recentlyUsedYouTubers.count)/\(maxRecentlyUsed)")
    }
}

// MARK: - Floating Avatar Model

struct FloatingAvatar: Identifiable {
    let id: UUID
    let youtuber: YouTuberAvatarService.YouTuber
    let startX: CGFloat
    let startY: CGFloat
    let controlY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    
    var currentX: CGFloat
    var currentY: CGFloat
    var progress: Double
    var opacity: Double
    var scale: Double
    let delay: Double
    let startTime: CFAbsoluteTime
    
    init(id: UUID, youtuber: YouTuberAvatarService.YouTuber, startX: CGFloat, startY: CGFloat, 
         controlY: CGFloat, endX: CGFloat, endY: CGFloat, currentX: CGFloat, currentY: CGFloat, 
         progress: Double, opacity: Double, scale: Double, delay: Double) {
        self.id = id
        self.youtuber = youtuber
        self.startX = startX
        self.startY = startY
        self.controlY = controlY
        self.endX = endX
        self.endY = endY
        self.currentX = currentX
        self.currentY = currentY
        self.progress = progress
        self.opacity = opacity
        self.scale = scale
        self.delay = delay
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func updated(currentX: CGFloat, currentY: CGFloat, progress: Double, opacity: Double, scale: Double) -> FloatingAvatar {
        var updated = self
        updated.currentX = currentX
        updated.currentY = currentY
        updated.progress = progress
        updated.opacity = opacity
        updated.scale = scale
        return updated
    }
}

// MARK: - Individual Avatar View

struct FloatingAvatarView: View {
    let avatar: FloatingAvatar
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Cercle de background avec effet glow YouTube
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size + 8, height: size + 8)
                .blur(radius: 2)
            
            // Avatar image avec cache
            if let cachedImage = YouTuberAvatarService.shared.getCachedAvatar(for: avatar.youtuber) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            } else {
                // Placeholder pendant le chargement
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: size * 0.6))
                            .foregroundColor(.white.opacity(0.6))
                    )
                    .onAppear {
                        // Déclencher le chargement de l'avatar
                        Task {
                            await YouTuberAvatarService.shared.preloadAvatar(for: avatar.youtuber)
                        }
                    }
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color.black.ignoresSafeArea()
            
            FloatingYouTuberAvatars(
                containerHeight: geometry.size.height * 0.6,
                containerWidth: geometry.size.width
            )
        }
    }
}