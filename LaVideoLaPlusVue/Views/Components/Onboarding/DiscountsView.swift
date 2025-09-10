//
//  Discount.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI


struct DiscountsView: View {
    let currentPage: Int
    let totalPages: Int
    let onMainButton: () -> Void
    let onSkip: (() -> Void)?
    
    let item = OnboardingItem(
        topLine: "Unmissable",
        subtitle: "Discounts",
        description: "“Up to 35% discount and more if you create an account”",
        mainButtonLabel: "Enter →",
        showSkip: false
    )
    
    @State private var showScreen = false
    @State private var angle: Double = 45
    
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
                withAnimation(.linear(duration: 2.5)) {
                    angle = 205
                }}
            
                ZStack {
                    
                        
                        Image("SkisImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 500)
                            .offset(showScreen ? .zero : CGSize(width: 0, height: -150))
                            

                        
     
                    VStack {
                                    Spacer()
                    OnboardingCardView(currentPage: currentPage, totalPages: totalPages, item: item, onMainButton: onMainButton, onSkip: onSkip,
                                   invertTitle: true
                    )
                    
                }.padding(16)}
                
               
            
        }.onAppear {
            withAnimation(.easeInOut(duration: 1.75)) {
                showScreen = true
            }}
        
    }
}



#Preview {
    DiscountsView(currentPage: 1, totalPages: 3, onMainButton: {}, onSkip: {})
}
