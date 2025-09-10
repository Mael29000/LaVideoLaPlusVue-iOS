//
//  FadeInModifier.swift
//  Summit
//
//  Created by Maël Suard on 26/03/2025.
//

import SwiftUI

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
}
