//
//  OnboardingScreens.swift
//  Summit
//
//  Created by Maël Suard on 08/01/2025.
//

import SwiftUI

struct OnboardingScreen: View {
    
    let onFinish: () -> Void
   
    // 2) Track which page we're on (0-based)
    @State private var currentPage: Int = 0
    let totalPages = 3
    
    var body: some View {
               ZStack {
                   switch currentPage {
                   case 0:
                       SummitPresentationView(
                           currentPage: currentPage,
                           totalPages: totalPages,
                           onMainButton: {
                               // Move to page 1
                                   currentPage = 1
                           },
                           onSkip: onFinish
                       )
                       
                   case 1:
                       Winter2025View(
                           currentPage: currentPage,
                           totalPages: totalPages,
                           onMainButton: {
                               // Move to page 2
                                   currentPage = 2
                           },
                           onSkip: onFinish
                       )
                       
                   case 2:
                       DiscountsView(
                           currentPage: currentPage,
                           totalPages: totalPages,
                           onMainButton: {
                               // Possibly finish onboarding, or navigate to main app
                               print("End of Onboarding")
                               onFinish()
                               // e.g. currentPage = 0 to loop back, or dismiss
                           },
                           onSkip: onFinish
                       )
                       
                   default:
                       // Fallback — shouldn't happen with only 3 screens
                       EmptyView()
                   }
               }
           }
    
    
       
    }


// MARK: - Preview
#Preview {
    OnboardingScreen(onFinish: {})
}
