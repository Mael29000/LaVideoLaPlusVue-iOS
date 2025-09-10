import SwiftUI

extension AnyTransition {
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .top)
        )
    }
    
    static var slideDown: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top),
            removal: .move(edge: .bottom)
        )
    }
    
    static var slideUpAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}