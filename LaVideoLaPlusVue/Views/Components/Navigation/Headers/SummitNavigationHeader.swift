//
//  SummitNavigationHeader.swift
//  Summit
//
//  Created by Maël Suard on 15/04/2025.
//


import SwiftUI

struct SummitNavigationHeader: ViewModifier {
    var title: String

    
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large) // Use .inline for a compact title
//            .navigationBarTitleDisplayMode(.)
            // Add the trailing menu button in the toolbar
           
            // Apply an opaque white background to the navigation bar
            .toolbarBackground(Color.white, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
            

    }
}

// MARK: - Preview
struct SummitNavigationHeader_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView{
                Text("Hello, World!")
                    .modifier(SummitNavigationHeader(title: "La vidéo la plus vue"))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


extension View {
    func summitNavigationHeader(title: String, onMenuButtonTapped: @escaping () -> Void, onCartButtonTapped: @escaping () -> Void, badgeCount: Int) -> some View {
        self.modifier(SummitNavigationHeader(title: title))
    }
}
