//
//  HeightPreservingTabView.swift
//  Summit
//
//  Created by Maël Suard on 22/03/2025.
//

import SwiftUI

private struct TabViewMinHeightPreference: PreferenceKey {
  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    // It took me so long to debug this line
    value = max(value, nextValue())
  }
}

struct HeightPreservingTabView<Selection: Hashable, Content: View>: View {
    var selection: Binding<Selection>?
    @ViewBuilder var content: () -> Content
    @State private var minHeight: CGFloat = 1  // non-zero to start measuring

    var body: some View {
        TabView(selection: selection) {
            content()
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: TabViewMinHeightPreference.self,
                                                value: geo.frame(in: .local).height)
                    }
                )
        }
        .frame(minHeight: minHeight)  // enforce the measured height
        .onPreferenceChange(TabViewMinHeightPreference.self) { minHeight = $0 }
    }
}
