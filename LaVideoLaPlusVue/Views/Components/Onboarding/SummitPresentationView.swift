//
//  SummitPreview.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI

struct SummitPresentationView: View {
    let currentPage: Int
    let totalPages: Int
    let onMainButton: () -> Void
    let onSkip: (() -> Void)?
    
    let item = OnboardingItem(
        topLine: "Summit Store",
        subtitle: "",
        description: "\"Find the best gear, climb high, and roam the mountains like a chamois!\"",
        mainButtonLabel: "Continue",
        showSkip: true
    )
    
    @State private var showScreen = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("SummitOnboardingPurple"),
                    Color("SummitPink")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                if (showScreen) {
                    
                    Image("ChamoisImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .offset(y: 10)
                        .transition(.move(edge: .bottom))
                                           // Attach animation to the 'showImage' change
                      
                    
                } else {
                    Spacer()
                }
                
                OnboardingCardView(currentPage: currentPage, totalPages: totalPages, item: item, onMainButton: onMainButton, onSkip: onSkip,
                               invertTitle: false
                )
                
            }.padding(16)
                
               
            
        }.onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                showScreen = true
            }}
        
    }
}

#Preview {
    SummitPresentationView(currentPage: 0, totalPages: 3, onMainButton: {}, onSkip: {})
}
