//
//  OnboardingCard.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let topLine: String
    let subtitle: String
    let description: String
    let mainButtonLabel: String
    let showSkip: Bool
}

struct OnboardingCardView: View {
    // MARK: - Parameters
    let currentPage: Int
    let totalPages: Int
    let item: OnboardingItem
    
    // MARK: - Callbacks
    let onMainButton: () -> Void
    let onSkip: (() -> Void)?
    let invertTitle: Bool
    
    // We already have 'showScreen' for page indicator animation
    @State private var showScreen = false
    @State private var shrinkIndicator = false
    
    // New state to handle ephemeral skip
    @State private var showEphemeralSkip = true
    
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage && !shrinkIndicator
                              ? Color("SummitPink")
                              : Color.gray.opacity(0.3))
                        .frame(
                            width: (index == currentPage && showScreen && !shrinkIndicator) ? 16 : 8,
                            height: 8
                        )
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.35)) {
                    showScreen = true
                }
            }
            
            // MARK: - Two-Line Title
            VStack(spacing: 4) {
                Text(item.topLine)
                    .font(.title)
                    .fontWeight(invertTitle ? .semibold : .bold)
                    .foregroundColor(invertTitle ? Color("SummitGray") : Color("SummitPink"))
                
                if !item.subtitle.isEmpty {
                    Text(item.subtitle)
                        .font(.title)
                        .fontWeight(invertTitle ? .bold : .semibold)
                        .foregroundColor(invertTitle ? Color("SummitPink") : Color("SummitGray"))
                }
            }
            .opacity(showScreen ? 1 : 0)
               .scaleEffect(showScreen ? 1 : 0.8)
            
            Spacer()
            
            // MARK: - Description
            Text(item.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
              .opacity(showScreen ? 1 : 0)
                .offset(showScreen ? .zero : CGSize(width: 0, height: 10))
            
            Spacer()
            
            // MARK: - Buttons Area
            VStack(spacing: 10) {
                
                
                
                // 2) Main Button (always present from beginning)
                Button(action: mainButtonPressed) {
                    Text(item.mainButtonLabel)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("SummitPink"))
                        .foregroundColor(.white)
                        .cornerRadius(.infinity)
                }
            }
            .animation(.easeInOut(duration: 1.5), value: shouldShowSkip)
            
            // 1) Optional / Ephemeral Skip
            if shouldShowSkip {
                // We conditionally show skip in the hierarchy
                Button(action: {
                    onSkip?()
                }) {
                    Text("Skip")
                        .foregroundColor(Color("SummitGray"))
                        .fontWeight(.regular)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        
        // Decide skip’s behavior on appear
        .onAppear {
            // If the item normally shows skip, do nothing special
            if item.showSkip {
                showEphemeralSkip = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.linear(duration: 1.5)) {
                        showEphemeralSkip = false
                    }
                }
            }
        }
    }
    
    /// A computed property controlling skip's presence:
    private var shouldShowSkip: Bool {
        // If the item says "showSkip" we always show skip
        // Otherwise show the ephemeral skip if `showEphemeralSkip` is true
        item.showSkip || showEphemeralSkip
    }
    
    
    // MARK: - Function for Main Button
    private func mainButtonPressed() {
        // 1) Animate shrink
        withAnimation(.easeInOut(duration: 0.75)) {
            shrinkIndicator = true
//            showScreen = false
        }
        
        // 2) After shrink finishes, move to the next page & reset
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            onMainButton()
        }
        
    }
}
// MARK: - Preview
#Preview {
    let sampleItem = OnboardingItem(
        topLine: "Unmissable",
        subtitle: "Discounts",
        description: """
            "Up to 35% discount
            and more if you create an account"
            """,
        mainButtonLabel: "Enter →",
        showSkip: false
    )
    
    OnboardingCardView(
        currentPage: 0,
        totalPages: 3,
        item: sampleItem,
        onMainButton: { print("Main tapped") },
        onSkip: { print("Skip tapped") },
        invertTitle: true
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
