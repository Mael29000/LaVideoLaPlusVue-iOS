//
//  Constants.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 06/06/2025.
//

import Foundation
import SwiftUI

/**
 * Constantes centralisées pour l'application LaVideoLaPlusVue.
 *
 * Cette structure remplace les "magic numbers" éparpillés dans le code
 * et fournit des design tokens cohérents pour toute l'application.
 */
struct Constants {
    
    // MARK: - Game Rules
    
    static let maxScore = 50
    static let gameTimeLimit = 120
    
    // MARK: - Layout & Spacing
    
    struct Layout {
        static let compactPadding: CGFloat = 8
        static let standardPadding: CGFloat = 16
        static let largePadding: CGFloat = 20
        static let extraLargePadding: CGFloat = 32
        
        static let smallSpacing: CGFloat = 8
        static let standardSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 24
        static let extraLargeSpacing: CGFloat = 32
        
        static let smallCornerRadius: CGFloat = 8
        static let standardCornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 16
        static let cardCornerRadius: CGFloat = 24
        static let buttonCornerRadius: CGFloat = 25
    }
    
    // MARK: - Animation Durations
    
    struct Animation {
        static let instant: Double = 0.0
        static let quick: Double = 0.3
        static let standard: Double = 0.6
        static let slow: Double = 1.0
        static let verySlow: Double = 1.5
        static let breathing: Double = 2.5
        static let longTransition: Double = 3.0
        static let infinite: Double = .infinity
        
        // Animation delays
        static let shortDelay: Double = 0.1
        static let standardDelay: Double = 0.2
        static let longDelay: Double = 0.5
        static let veryLongDelay: Double = 0.8
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let caption: CGFloat = 12
        static let footnote: CGFloat = 13
        static let subheadline: CGFloat = 15
        static let body: CGFloat = 16
        static let callout: CGFloat = 16
        static let headline: CGFloat = 17
        static let title3: CGFloat = 20
        static let title2: CGFloat = 22
        static let title1: CGFloat = 28
        static let largeTitle: CGFloat = 32
        static let extraLargeTitle: CGFloat = 42
        
        // Game-specific typography
        static let scoreSize: CGFloat = 80
        static let newRecordScoreSize: CGFloat = 70
        static let gameOverSize: CGFloat = 42
        static let performanceGaugeSize: CGFloat = 16
    }
    
    // MARK: - Icon Sizes
    
    struct IconSize {
        static let small: CGFloat = 16
        static let standard: CGFloat = 20
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 30
        static let performance: CGFloat = 20
        static let laurelSmall: CGFloat = 30
        static let laurelMedium: CGFloat = 50
        static let laurelLarge: CGFloat = 90
        static let laurelExtraLarge: CGFloat = 160
    }
    
    // MARK: - Performance Thresholds
    
    struct Performance {
        static let beginnerMax = 3
        static let intermediateMax = 8
        static let advancedMax = 15
        static let expertMax = 19
        static let masterMin = 20
        
        static let particlesLightThreshold = 15
        static let particlesMediumThreshold = 20
        static let particlesHeavyThreshold = 36
        
        static let breathingAnimationThreshold = 16
        static let glowEffectThreshold = 30
    }
    
    // MARK: - Particle System
    
    struct Particles {
        static let lightIntensity = 50
        static let mediumIntensity = 100
        static let heavyIntensity = 200
        
        static let defaultLifetime: Double = 5.0
        static let shortLifetime: Double = 2.0
        static let longLifetime: Double = 10.0
    }
    
    // MARK: - UI Effects
    
    struct Effects {
        static let shadowRadius: CGFloat = 8
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let glowRadius: CGFloat = 20
        
        static let standardOpacity: Double = 0.1
        static let mediumOpacity: Double = 0.3
        static let highOpacity: Double = 0.6
        static let veryHighOpacity: Double = 0.9
        
        static let cardShadowOpacity: Double = 0.1
        static let backgroundOpacity: Double = 0.05
    }
    
    // MARK: - Laurel Configurations
    
    struct Laurel {
        static let smallSpacing: CGFloat = 4
        static let mediumSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 16
        static let overlappingSpacing: CGFloat = -20
        static let closeSpacing: CGFloat = -10
        static let wideSpacing: CGFloat = 40
        
        static let smallRotation: Double = 10
        static let mediumRotation: Double = 15
        static let largeRotation: Double = 20
    }
    
    // MARK: - Color Opacity Levels
    
    struct Opacity {
        static let transparent: Double = 0.0
        static let barely: Double = 0.1
        static let light: Double = 0.2
        static let medium: Double = 0.3
        static let strong: Double = 0.4
        static let veryStrong: Double = 0.6
        static let nearlyOpaque: Double = 0.8
        static let mostlyOpaque: Double = 0.9
        static let opaque: Double = 1.0
    }
}
