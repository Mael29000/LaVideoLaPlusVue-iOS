//
//  Winter2025.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI

struct Winter2025View: View {
    
    let currentPage: Int
    let totalPages: Int
    let onMainButton: () -> Void
    let onSkip: (() -> Void)?
    
    let item = OnboardingItem(
        topLine: "Winter 2025",
        subtitle: "Collection",
        description: "\"The perfect gear to experience the mountains in style and comfort.\"",
        mainButtonLabel: "Continue",
        showSkip: true
    )
    
    @State private var angle: Double = -45
    @State private var showImage = false
    @State private var rotateImage = false
    @State private var screenClosed = false
    
    
    var body: some View {
        ZStack {

            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("SummitOnboardingPurple"),
                    Color("SummitPink")
                ]),
                startPoint: rotatingStartPoint(angle: angle),
                                endPoint: rotatingEndPoint(angle: angle)
            )
            
            .ignoresSafeArea()
            .onAppear {
                // Animate from 0° to 360° repeatedly
                withAnimation(.linear(duration: 1.75)) {
                    angle = 45
                }}
            
            
            VStack {
                Spacer()
//                if (showScreen) {
                ZStack {
                            if showImage || screenClosed {
                                Image("BackflipImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .offset(y: -10)
                                    .transition(.move(edge: .bottom))
                                    .rotationEffect(.degrees(rotateImage ? 0 : -90))
                            }
                        }
                        .onAppear {
                            // 1. Animate insertion from bottom
                            withAnimation(.easeInOut(duration: 1.75)) {
                                showImage = true
                            }
                            // 2. After insertion completes, animate rotation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 1.7)) {
                                    rotateImage = true
                                }
                            }
                        }
                    
//                } else {
//                    Spacer()
//                }
                
                OnboardingCardView(currentPage: currentPage, totalPages: totalPages, item: item, onMainButton: onMainButton, onSkip: onSkip,
                               invertTitle: false
                
                )
                
            }.padding(16)
                
               
            
        }
        
    }

    
    

}

/// Center-based startPoint that moves in a circle around (0.5, 0.5).
func rotatingStartPoint(angle: Double) -> UnitPoint {
    // Convert degrees to radians
    let radians = angle * .pi / 180
    
    // Use 0.5 + 0.5 * cos(...) to range from 0 to 1
    let x = 0.5 + 0.5 * cos(radians)
    let y = 0.5 + 0.5 * sin(radians)
    
    return UnitPoint(x: x, y: y)
}

/// The opposite point on the circle for the endPoint
func rotatingEndPoint(angle: Double) -> UnitPoint {
    let radians = angle * .pi / 180
    let x = 0.5 - 0.5 * cos(radians)
    let y = 0.5 - 0.5 * sin(radians)
    
    return UnitPoint(x: x, y: y)
}

#Preview {
    Winter2025View(currentPage: 1, totalPages: 3, onMainButton: {}, onSkip: {})
}
