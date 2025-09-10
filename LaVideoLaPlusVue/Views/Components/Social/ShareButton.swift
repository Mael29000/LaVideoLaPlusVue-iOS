//
//  ShareButton.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import SwiftUI
import UIKit

/**
 * Bouton de partage avec génération d'image personnalisée des scores.
 *
 * Ce composant permet de :
 * - Générer une image stylée avec le score et les statistiques
 * - Partager via le système de partage iOS natif
 * - Inclure des éléments de branding et de gamification
 * - Adapter le design selon la performance du joueur
 *
 * ## Usage
 * ```swift
 * ShareButton(
 *     score: 42,
 *     ranking: "TOP 5%",
 *     isNewRecord: true,
 *     userProgress: achievementService.userProgress
 * )
 * ```
 */
struct ShareButton: View {
    
    // MARK: - Properties
    
    let score: Int
    let ranking: String
    let isNewRecord: Bool
    let userProgress: AchievementService.UserProgress
    
    @State private var isGeneratingImage = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    // MARK: - Performance Level (Using Unified Model)
    
    private var performanceLevel: PerformanceLevel {
        PerformanceLevel.from(score: score)
    }
    
    // Share-specific properties
    private var shareEmoji: String {
        switch performanceLevel {
        case .beginner: return "🐢"
        case .intermediate: return "🚀" 
        case .advanced: return "⭐"
        case .expert: return "🔥"
        case .master: return "👑"
        }
    }
    
    private var shareMessage: String {
        switch performanceLevel {
        case .beginner: return "Bon début sur LaVideoLaPlusVue !"
        case .intermediate: return "Belle performance sur LaVideoLaPlusVue !"
        case .advanced: return "Excellent score sur LaVideoLaPlusVue !"
        case .expert: return "Performance exceptionnelle !"
        case .master: return "Score légendaire ! 🏆"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: shareScore) {
            HStack(spacing: 12) {
                if isGeneratingImage {
                    // Animation de génération
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isGeneratingImage ? "Génération..." : "Partager")
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                performanceLevel.createBackgroundGradient()
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: performanceLevel.gradientColors.first?.opacity(0.4) ?? .clear,
                radius: 8,
                x: 0, y: 4
            )
        }
        .disabled(isGeneratingImage)
        .scaleEffect(isGeneratingImage ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isGeneratingImage)
        .sheet(isPresented: $showShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(activityItems: [
                    shareImage,
                    "\(shareMessage) Score: \(score)/50 \(shareEmoji)\n\n#LaVideoLaPlusVue #YouTube #Quiz"
                ])
            }
        }
    }
    
    // MARK: - Share Logic
    
    private func shareScore() {
        isGeneratingImage = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Générer l'image en arrière-plan
        DispatchQueue.global(qos: .userInitiated).async {
            if let generatedImage = generateShareImage() {
                DispatchQueue.main.async {
                    shareImage = generatedImage
                    isGeneratingImage = false
                    showShareSheet = true
                }
            } else {
                DispatchQueue.main.async {
                    isGeneratingImage = false
                    // Fallback : partage sans image
                    shareWithoutImage()
                }
            }
        }
    }
    
    private func shareWithoutImage() {
        let shareText = "\(shareMessage) Score: \(score)/50 \(shareEmoji)\n\n#LaVideoLaPlusVue #YouTube #Quiz"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Présenter le share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    // MARK: - Image Generation
    
    private func generateShareImage() -> UIImage? {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Background gradient
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemBackground.cgColor,
                    performanceLevel.gradientColors.first?.cgColor ?? UIColor.systemBlue.cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )
            
            if let gradient = gradient {
                cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }
            
            // Overlay semi-transparent
            cgContext.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Title
            let titleText = "LaVideoLaPlusVue"
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleText.size(withAttributes: titleAttributes)
            titleText.draw(
                at: CGPoint(
                    x: (size.width - titleSize.width) / 2,
                    y: 50
                ),
                withAttributes: titleAttributes
            )
            
            // Performance emoji (grand)
            let emoji = shareEmoji
            let emojiFont = UIFont.systemFont(ofSize: 80)
            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: emojiFont
            ]
            let emojiSize = emoji.size(withAttributes: emojiAttributes)
            emoji.draw(
                at: CGPoint(
                    x: (size.width - emojiSize.width) / 2,
                    y: 120
                ),
                withAttributes: emojiAttributes
            )
            
            // Score principal
            let scoreText = "\(score)"
            let scoreFont = UIFont.systemFont(ofSize: 72, weight: .heavy)
            let scoreAttributes: [NSAttributedString.Key: Any] = [
                .font: scoreFont,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black.withAlphaComponent(0.3),
                .strokeWidth: -2
            ]
            let scoreSize = scoreText.size(withAttributes: scoreAttributes)
            scoreText.draw(
                at: CGPoint(
                    x: (size.width - scoreSize.width) / 2,
                    y: 230
                ),
                withAttributes: scoreAttributes
            )
            
            // "/ 50"
            let maxScoreText = "/ 50"
            let maxScoreFont = UIFont.systemFont(ofSize: 24, weight: .medium)
            let maxScoreAttributes: [NSAttributedString.Key: Any] = [
                .font: maxScoreFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let maxScoreSize = maxScoreText.size(withAttributes: maxScoreAttributes)
            maxScoreText.draw(
                at: CGPoint(
                    x: (size.width - maxScoreSize.width) / 2,
                    y: 315
                ),
                withAttributes: maxScoreAttributes
            )
            
            // Performance message
            let messageText = shareMessage
            let messageFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
            let messageAttributes: [NSAttributedString.Key: Any] = [
                .font: messageFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
            
            let messageRect = CGRect(
                x: 40,
                y: 370,
                width: size.width - 80,
                height: 60
            )
            messageText.draw(in: messageRect, withAttributes: messageAttributes)
            
            // Ranking si disponible
            if !ranking.isEmpty && !isNewRecord {
                let rankingText = ranking
                let rankingFont = UIFont.systemFont(ofSize: 16, weight: .medium)
                let rankingAttributes: [NSAttributedString.Key: Any] = [
                    .font: rankingFont,
                    .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.alignment = .center
                        return style
                    }()
                ]
                
                let rankingRect = CGRect(
                    x: 40,
                    y: 440,
                    width: size.width - 80,
                    height: 30
                )
                rankingText.draw(in: rankingRect, withAttributes: rankingAttributes)
            }
            
            // Badge "Nouveau Record" si applicable
            if isNewRecord {
                let recordText = "🏆 NOUVEAU RECORD ! 🏆"
                let recordFont = UIFont.systemFont(ofSize: 18, weight: .bold)
                let recordAttributes: [NSAttributedString.Key: Any] = [
                    .font: recordFont,
                    .foregroundColor: UIColor.systemYellow,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.alignment = .center
                        return style
                    }()
                ]
                
                let recordRect = CGRect(
                    x: 40,
                    y: 440,
                    width: size.width - 80,
                    height: 30
                )
                recordText.draw(in: recordRect, withAttributes: recordAttributes)
            }
            
            // Footer avec stats
            let statsText = "Parties jouées: \(userProgress.gamesPlayed) • Meilleur: \(userProgress.bestScore)"
            let statsFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: statsFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
            
            let statsRect = CGRect(
                x: 40,
                y: 520,
                width: size.width - 80,
                height: 30
            )
            statsText.draw(in: statsRect, withAttributes: statsAttributes)
            
            // Hashtags
            let hashtagText = "#LaVideoLaPlusVue #YouTube #Quiz"
            let hashtagFont = UIFont.systemFont(ofSize: 12, weight: .medium)
            let hashtagAttributes: [NSAttributedString.Key: Any] = [
                .font: hashtagFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
            
            let hashtagRect = CGRect(
                x: 40,
                y: 560,
                width: size.width - 80,
                height: 20
            )
            hashtagText.draw(in: hashtagRect, withAttributes: hashtagAttributes)
        }
    }
}

// MARK: - ShareSheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let mockProgress = AchievementService.UserProgress(
        totalScore: 420,
        bestScore: 42,
        gamesPlayed: 15,
        currentStreak: 8,
        bestStreak: 12,
        totalPlayTime: 2400,
        firstGameDate: Date(),
        lastGameDate: Date(),
        currentXP: 4200,
        currentLevel: 5
    )
    
    VStack(spacing: 30) {
        Text("Share Button Demo")
            .font(.title2)
        
        ShareButton(
            score: 42,
            ranking: "TOP 5%",
            isNewRecord: true,
            userProgress: mockProgress
        )
        
        ShareButton(
            score: 18,
            ranking: "TOP 45%", 
            isNewRecord: false,
            userProgress: mockProgress
        )
        
        ShareButton(
            score: 8,
            ranking: "TOP 75%",
            isNewRecord: false,
            userProgress: mockProgress
        )
        
        Spacer()
    }
    .padding()
    .background(Color.black.opacity(0.1))
}