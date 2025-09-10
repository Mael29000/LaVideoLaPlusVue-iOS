//
//  ScrollOffsetPreferenceKey.swift
//  Summit
//
//  Created by Maël Suard on 27/03/2025.
//

import SwiftUI

// MARK: - PreferenceKey for scroll offset tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
