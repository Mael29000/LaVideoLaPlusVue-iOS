import Foundation
import UIKit

/**
 * YouTuberAvatarService gère la récupération et le cache des avatars de YouTubers.
 *
 * Responsabilités:
 * - Extraire les avatars uniques depuis les données vidéo enrichies
 * - Gérer un cache d'images des avatars pour l'affichage
 * - Fournir des avatars aléatoires pour les animations
 * - Précharger les avatars les plus populaires
 */
class YouTuberAvatarService {
    static let shared = YouTuberAvatarService()
    
    private var uniqueYouTubers: [YouTuber] = []
    private var avatarCache: [String: UIImage] = [:]
    
    private init() {}
    
    // MARK: - YouTuber Model
    
    struct YouTuber: Identifiable, Hashable {
        let id: String // channelId
        let name: String // channelTitle
        let avatarUrl: String
        
        var avatarURL: URL? {
            return URL(string: avatarUrl)
        }
    }
    
    // MARK: - Data Loading
    
    /**
     * Extrait tous les YouTubers uniques depuis les données vidéo.
     * Utilise le VideoService existant pour récupérer les données enrichies.
     */
    func loadYouTubers() async throws -> [YouTuber] {
        // Si déjà chargé, retourner le cache
        if !uniqueYouTubers.isEmpty {
            print("👤 YouTubers already loaded: \(uniqueYouTubers.count)")
            return uniqueYouTubers
        }
        
        // Récupérer toutes les vidéos via le service existant
        let videos = try await VideoService.shared.loadVideos()
        
        // Extraire les YouTubers uniques avec leurs avatars
        var youTubersDict: [String: YouTuber] = [:]
        
        for video in videos {
            // Ignorer les vidéos sans avatar
            guard let avatarUrl = video.channelAvatarUrl else { continue }
            
            // Créer ou mettre à jour l'entrée YouTuber
            let youtuber = YouTuber(
                id: video.channelId,
                name: video.channelTitle,
                avatarUrl: avatarUrl
            )
            
            youTubersDict[video.channelId] = youtuber
        }
        
        uniqueYouTubers = Array(youTubersDict.values)
        print("👤 Loaded \(uniqueYouTubers.count) unique YouTubers with avatars")
        
        return uniqueYouTubers
    }
    
    /**
     * Retourne un nombre spécifique de YouTubers aléatoires.
     * Idéal pour les animations d'avatars flottants.
     */
    func getRandomYouTubers(count: Int) async throws -> [YouTuber] {
        let youtubers = try await loadYouTubers()
        
        guard !youtubers.isEmpty else {
            throw YouTuberAvatarServiceError.noYouTubersAvailable
        }
        
        let requestedCount = min(count, youtubers.count)
        return Array(youtubers.shuffled().prefix(requestedCount))
    }
    
    /**
     * Retourne les YouTubers les plus populaires basés sur le nombre de vidéos.
     * Utile pour prioriser le préchargement des avatars.
     */
    func getTopYouTubers(limit: Int = 10) async throws -> [YouTuber] {
        let videos = try await VideoService.shared.loadVideos()
        let youtubers = try await loadYouTubers()
        
        // Compter le nombre de vidéos par YouTuber
        var videoCounts: [String: Int] = [:]
        for video in videos {
            videoCounts[video.channelId, default: 0] += 1
        }
        
        // Trier les YouTubers par popularité
        let sortedYouTubers = youtubers.sorted { first, second in
            let firstCount = videoCounts[first.id] ?? 0
            let secondCount = videoCounts[second.id] ?? 0
            return firstCount > secondCount
        }
        
        return Array(sortedYouTubers.prefix(limit))
    }
    
    // MARK: - Avatar Cache System
    
    /**
     * Précharge l'avatar d'un YouTuber en mémoire.
     */
    func preloadAvatar(for youtuber: YouTuber) async {
        guard let url = youtuber.avatarURL,
              avatarCache[youtuber.id] == nil else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    avatarCache[youtuber.id] = image
                    print("✅ Avatar cached for: \(youtuber.name)")
                }
            }
        } catch {
            print("❌ Failed to cache avatar for \(youtuber.name): \(error)")
        }
    }
    
    /**
     * Accès synchrone au cache d'avatars.
     */
    func getCachedAvatar(for youtuber: YouTuber) -> UIImage? {
        return avatarCache[youtuber.id]
    }
    
    /**
     * Précharge les avatars des YouTubers les plus populaires.
     * À appeler au démarrage de l'app pour optimiser les performances.
     */
    func preloadTopAvatars(limit: Int = 20) async {
        do {
            let topYouTubers = try await getTopYouTubers(limit: limit)
            
            await withTaskGroup(of: Void.self) { group in
                for youtuber in topYouTubers {
                    group.addTask {
                        await self.preloadAvatar(for: youtuber)
                    }
                }
            }
            
            print("🎯 Preloaded \(topYouTubers.count) top YouTuber avatars")
        } catch {
            print("❌ Failed to preload top avatars: \(error)")
        }
    }
    
    /**
     * Précharge des avatars aléatoires pour les animations.
     */
    func preloadRandomAvatars(count: Int = 10) async {
        do {
            let randomYouTubers = try await getRandomYouTubers(count: count)
            
            await withTaskGroup(of: Void.self) { group in
                for youtuber in randomYouTubers {
                    group.addTask {
                        await self.preloadAvatar(for: youtuber)
                    }
                }
            }
            
            print("🎲 Preloaded \(randomYouTubers.count) random YouTuber avatars")
        } catch {
            print("❌ Failed to preload random avatars: \(error)")
        }
    }
}

// MARK: - Errors

enum YouTuberAvatarServiceError: Error, LocalizedError {
    case noYouTubersAvailable
    case cacheError
    
    var errorDescription: String? {
        switch self {
        case .noYouTubersAvailable:
            return "Aucun YouTuber avec avatar disponible"
        case .cacheError:
            return "Erreur de cache des avatars"
        }
    }
}