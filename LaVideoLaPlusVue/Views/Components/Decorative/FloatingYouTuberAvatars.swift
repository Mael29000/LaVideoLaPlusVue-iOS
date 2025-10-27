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
    @State private var transformedYoutuber: YouTuberAvatarService.YouTuber? // Pour l'effet transformAll
    
    let containerHeight: CGFloat
    let containerWidth: CGFloat
    
    // MARK: - Configuration
    
    private let maxAvatars = 7 // Plus d'avatars simultanés
    private let avatarSize: CGFloat = 60
    private let animationDuration: Double = 12.0 // Durée pour traverser l'écran
    private let renewalInterval: Double = 2.5 // Renouvellement encore plus fréquent
    private let maxRecentlyUsed = 20 // Éviter les 20 derniers YouTubers
    
    var body: some View {
        ZStack {
            ForEach(avatars) { avatar in
                FloatingAvatarView(
                    avatar: transformedYoutuber != nil ? 
                        avatar.withTransformedYoutuber(transformedYoutuber!) : avatar,
                    size: avatarSize,
                    onTransformAll: { youtuber in
                        transformAllAvatars(to: youtuber)
                    },
                    onSpeedModify: { avatarId, newSpeed in
                        modifyAvatarSpeed(avatarId: avatarId, newSpeed: newSpeed)
                    }
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
                // Créer les avatars flottants avec positions initiales désynchronisées
                for (index, youtuber) in youtubers.enumerated() {
                    let avatar = createFloatingAvatar(
                        youtuber: youtuber,
                        delay: Double.random(in: 0...(Double(index) * 2.0)) // Délais complètement aléatoires
                    )
                    avatars.append(avatar)
                    
                    // Ajouter au cache des récemment utilisés
                    addToRecentlyUsed(youtuber.id)
                }
            }
        } catch {
            // Erreur silencieuse - pas critique
        }
    }
    
    private func createFloatingAvatar(youtuber: YouTuberAvatarService.YouTuber, delay: Double = 0) -> FloatingAvatar {
        // Zones d'évitement pour le contenu central (texte + icône)
        let centerZoneTop = containerHeight * 0.35    // Début de la zone centrale
        let centerZoneBottom = containerHeight * 0.65 // Fin de la zone centrale
        let avoidanceMargin: CGFloat = 50 // Marge autour de la zone centrale
        
        // Choisir aléatoirement : zone haute ou zone basse
        let useTopZone = Bool.random()
        
        let (startY, controlY, endY): (CGFloat, CGFloat, CGFloat)
        
        if useTopZone {
            // Zone haute : au-dessus du texte central
            let topZoneEnd = centerZoneTop - avoidanceMargin
            startY = CGFloat.random(in: avatarSize...max(avatarSize + 20, topZoneEnd))
            controlY = CGFloat.random(in: avatarSize...max(avatarSize + 20, topZoneEnd))
            endY = CGFloat.random(in: avatarSize...max(avatarSize + 20, topZoneEnd))
        } else {
            // Zone basse : en dessous du texte central
            let bottomZoneStart = centerZoneBottom + avoidanceMargin
            let bottomLimit = containerHeight - avatarSize
            startY = CGFloat.random(in: min(bottomZoneStart, bottomLimit - 20)...bottomLimit)
            controlY = CGFloat.random(in: min(bottomZoneStart, bottomLimit - 20)...bottomLimit)
            endY = CGFloat.random(in: min(bottomZoneStart, bottomLimit - 20)...bottomLimit)
        }
        
        // Délai aléatoire pour désynchroniser
        let randomDelay = delay + Double.random(in: 0...3.0)
        
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
            delay: randomDelay
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
                // Progression de 0 à 1 sur la durée d'animation avec vitesse individuelle
                let totalSpeed = avatar.baseAnimationSpeed * avatar.speedMultiplier
                let adjustedDuration = animationDuration / totalSpeed
                let progress = min(elapsed / adjustedDuration, 1.0)
                
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
                
                // Scale avec pulsation individuelle basée sur la vitesse
                let pulsationFrequency = 2.0 * totalSpeed
                let baseScale = 1.0 + sin(elapsed * pulsationFrequency) * 0.1
                
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
                    // Délai aléatoire pour chaque nouvel avatar
                    let randomDelay = Double.random(in: 0...4.0)
                    let newAvatar = createFloatingAvatar(youtuber: youtuber, delay: randomDelay)
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
        
        // Cache mis à jour silencieusement
    }
    
    // MARK: - Transform All Effect
    
    private func transformAllAvatars(to youtuber: YouTuberAvatarService.YouTuber) {
        transformedYoutuber = youtuber
        
        // Remettre à la normale après 3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                transformedYoutuber = nil
            }
        }
    }
    
    private func modifyAvatarSpeed(avatarId: UUID, newSpeed: Double) {
        if let index = avatars.firstIndex(where: { $0.id == avatarId }) {
            let currentAvatar = avatars[index]
            
            // Supprimer l'avatar actuel
            avatars.remove(at: index)
            
            // Créer un nouvel avatar identique mais avec une nouvelle vitesse
            // et en partant de sa position actuelle
            let newAvatar = FloatingAvatar(
                id: UUID(), // Nouvel ID
                youtuber: currentAvatar.youtuber,
                startX: currentAvatar.currentX, // Partir de la position actuelle
                startY: currentAvatar.currentY,
                controlY: currentAvatar.controlY,
                endX: currentAvatar.endX,
                endY: currentAvatar.endY,
                currentX: currentAvatar.currentX,
                currentY: currentAvatar.currentY,
                progress: 0.0, // Remettre à zéro
                opacity: currentAvatar.opacity,
                scale: currentAvatar.scale,
                delay: 0.0 // Pas de délai, commence immédiatement
            )
            
            // Appliquer la nouvelle vitesse
            var updatedAvatar = newAvatar
            updatedAvatar.speedMultiplier = newSpeed
            
            // Ajouter le nouvel avatar
            avatars.append(updatedAvatar)
        }
    }
}

// MARK: - Floating Avatar Model

struct FloatingAvatar: Identifiable {
    let id: UUID
    var youtuber: YouTuberAvatarService.YouTuber
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
    var startTime: CFAbsoluteTime // Maintenant mutable pour permettre les ajustements de vitesse
    let baseAnimationSpeed: Double // Vitesse de base constante
    var speedMultiplier: Double // Multiplicateur de vitesse (peut changer sans téléportation)
    
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
        self.baseAnimationSpeed = Double.random(in: 0.8...1.3) // Vitesse de base variable pour chaque avatar
        self.speedMultiplier = 1.0 // Multiplicateur par défaut
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
    
    func withTransformedYoutuber(_ newYoutuber: YouTuberAvatarService.YouTuber) -> FloatingAvatar {
        var updated = self
        updated.youtuber = newYoutuber
        return updated
    }
    
    func withUpdatedSpeedMultiplier(_ multiplier: Double) -> FloatingAvatar {
        var updated = self
        updated.speedMultiplier = multiplier
        return updated
    }
}

// MARK: - Interactive Effects

enum InteractiveEffect: CaseIterable {
    case grow
    case shrink
    case superFast
    case superSlow
    case transformAll
    
    static func random() -> InteractiveEffect {
        return InteractiveEffect.allCases.randomElement()!
    }
}


// MARK: - Individual Avatar View

struct FloatingAvatarView: View {
    let avatar: FloatingAvatar
    let size: CGFloat
    let onTransformAll: ((YouTuberAvatarService.YouTuber) -> Void)?
    let onSpeedModify: ((UUID, Double) -> Void)?
    
    @State private var isInteracting = false
    @State private var activeEffect: InteractiveEffect?
    @State private var effectScale: CGFloat = 1.0
    @State private var effectOpacity: Double = 1.0
    @State private var permanentScale: CGFloat = 1.0
    
    init(avatar: FloatingAvatar, size: CGFloat, onTransformAll: ((YouTuberAvatarService.YouTuber) -> Void)? = nil, onSpeedModify: ((UUID, Double) -> Void)? = nil) {
        self.avatar = avatar
        self.size = size
        self.onTransformAll = onTransformAll
        self.onSpeedModify = onSpeedModify
    }
    
    var body: some View {
        // Avatar principal
        avatarContent
            .scaleEffect(effectScale * permanentScale)
            .opacity(effectOpacity)
            .onTapGesture {
                triggerRandomEffect()
            }
    }
    
    @ViewBuilder
    private var avatarContent: some View {
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
    
    private func triggerRandomEffect() {
        guard !isInteracting else { return }
        
        let effect = InteractiveEffect.random()
        activeEffect = effect
        isInteracting = true
        
        applyEffect(effect)
        
        // Reset après l'effet
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            resetEffect()
        }
    }
    
    private func applyEffect(_ effect: InteractiveEffect) {
        switch effect {
        case .grow:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                permanentScale = 2.0 // Permanent, ne revient pas à la normale
            }
            
        case .shrink:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                permanentScale = 0.3 // Permanent aussi
            }
            
        case .superFast:
            // Modifier la vitesse de l'avatar pour qu'il aille vraiment plus vite
            modifyAvatarSpeed(3.0) // 3x plus rapide
            withAnimation(.easeInOut(duration: 0.2)) {
                effectScale = 1.2
            }
            
        case .superSlow:
            // Modifier la vitesse de l'avatar pour qu'il aille vraiment plus lentement
            modifyAvatarSpeed(0.3) // 3x plus lent
            withAnimation(.easeInOut(duration: 0.5)) {
                effectScale = 0.8
            }
            
        case .transformAll:
            // Déclencher la transformation de tous les avatars
            onTransformAll?(avatar.youtuber)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                effectScale = 1.3
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5)) {
                effectScale = 1.0
            }
        }
    }
    
    private func resetEffect() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            effectScale = 1.0
            effectOpacity = 1.0
            // Ne pas reset permanentScale - il reste permanent !
        }
        
        isInteracting = false
        activeEffect = nil
    }
    
    private func modifyAvatarSpeed(_ newSpeed: Double) {
        onSpeedModify?(avatar.id, newSpeed)
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