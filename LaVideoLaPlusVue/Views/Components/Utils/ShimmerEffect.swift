//
//  ShimmerEffect.swift
//  Summit
//
//  Created by Maël Suard on 13/02/2025.
//

import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var opacity: Double = 0.3

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerEffect())
    }
}
