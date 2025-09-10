//
//  StatefulPreviewWrapper.swift
//  Summit
//
//  Created by Maël Suard on 28/04/2025.
//


import SwiftUI

/// A wrapper that maintains state between preview refreshes
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}