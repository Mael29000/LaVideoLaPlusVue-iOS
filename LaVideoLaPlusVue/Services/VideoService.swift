import Foundation
import UIKit

/**
 * VideoService gère le chargement des données vidéo et le cache d'images.
 * 
 * Responsabilités:
 * - Charger et parser le fichier JSON contenant les données des vidéos YouTube
 * - Fournir des vidéos aléatoires en évitant les doublons
 * - Gérer un cache d'images pour des transitions instantanées
 * 
 * Architecture Singleton pour partager les données et le cache entre toutes les vues.
 */
class VideoService {
    static let shared = VideoService()
    private var allVideos: [Video] = []
    private var imageCache: [String: UIImage] = [:] // Cache UIImage pour éviter les délais AsyncImage
    
    private init() {}
    
    /**
     * Charge et parse le fichier JSON des vidéos YouTube.
     * Pattern lazy loading: ne charge qu'une seule fois, puis retourne le cache.
     */
    func loadVideos() async throws -> [Video] {
        // Si déjà chargé, retourner le cache pour éviter les rechargements
        if !allVideos.isEmpty {
            print("📚 Videos already loaded: \(allVideos.count)")
            return allVideos
        }
        
        // Localiser le fichier data.json dans le bundle de l'app
        print("📂 Looking for data.json in Bundle...")
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            print("❌ data.json not found in bundle")
            throw VideoServiceError.fileNotFound
        }
        
        // Charger et décoder le JSON en objets Video Swift
        print("✅ Found data.json at: \(url.path)")
        let data = try Data(contentsOf: url)
        print("📊 JSON data loaded: \(data.count) bytes")
        
        let videos = try JSONDecoder().decode([Video].self, from: data)
        print("🎬 Decoded \(videos.count) videos")
        
        // Sauvegarder en cache pour les prochains appels
        allVideos = videos
        return videos
    }
    
    /**
     * Retourne une vidéo aléatoire en excluant optionnellement une vidéo spécifique.
     * Utilisé pour éviter de re-proposer la même vidéo consécutivement.
     */
    func getRandomVideo(excluding: Video? = nil) async throws -> Video {
        let videos = try await loadVideos()
        
        guard !videos.isEmpty else {
            throw VideoServiceError.notEnoughVideos
        }
        
        var availableVideos = videos
        
        // Filtrer la vidéo exclue si fournie (éviter les doublons immédiats)
        if let excludedVideo = excluding {
            availableVideos = videos.filter { $0.id != excludedVideo.id }
        }
        
        guard !availableVideos.isEmpty else {
            // Fallback: si toutes les vidéos sont exclues, retourner n'importe laquelle
            return videos.randomElement()!
        }
        
        return availableVideos.randomElement()!
    }
    
    /**
     * Version overloadée qui exclut plusieurs vidéos à la fois.
     * Optimisée avec Set pour des lookups O(1) au lieu de O(n).
     */
    func getRandomVideo(excluding excludedVideos: [Video]) async throws -> Video {
        let videos = try await loadVideos()
        
        guard !videos.isEmpty else {
            throw VideoServiceError.notEnoughVideos
        }
        
        // Set optimisé pour les vérifications d'appartenance rapides
        let excludedIds = Set(excludedVideos.map { $0.id })
        let availableVideos = videos.filter { !excludedIds.contains($0.id) }
        
        guard !availableVideos.isEmpty else {
            // Fallback: si toutes les vidéos sont exclues, retourner n'importe laquelle
            return videos.randomElement()!
        }
        
        return availableVideos.randomElement()!
    }
    
    // MARK: - Image Cache System
    
    /**
     * Précharge une image en mémoire pour éviter les délais pendant les transitions.
     * Le cache UIImage permet un affichage instantané vs AsyncImage qui doit télécharger.
     */
    func preloadImage(for video: Video) async {
        guard let url = video.thumbnailURL,
              imageCache[video.id] == nil else { return } // Skip si déjà en cache
        
        do {
            // Télécharger l'image en arrière-plan
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // Sauvegarder en cache sur le thread principal
                await MainActor.run {
                    imageCache[video.id] = image
                    print("✅ Image cached for: \(video.id.prefix(8))")
                }
            }
        } catch {
            print("❌ Failed to cache image for \(video.id): \(error)")
        }
    }
    
    /**
     * Accès synchrone au cache d'images pour affichage instantané.
     * Retourne nil si l'image n'est pas encore en cache.
     */
    func getCachedImage(for video: Video) -> UIImage? {
        return imageCache[video.id]
    }
    
    /**
     * Précharge plusieurs images en parallèle pour initialiser le cache.
     * TaskGroup permet de télécharger toutes les images simultanément.
     */
    func preloadImagesFor(videos: [Video]) async {
        await withTaskGroup(of: Void.self) { group in
            for video in videos {
                group.addTask {
                    await self.preloadImage(for: video)
                }
            }
        }
    }
}

enum VideoServiceError: Error, LocalizedError {
    case fileNotFound
    case notEnoughVideos
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Fichier de données introuvable"
        case .notEnoughVideos:
            return "Pas assez de vidéos disponibles"
        case .decodingError:
            return "Erreur de décodage des données"
        }
    }
}