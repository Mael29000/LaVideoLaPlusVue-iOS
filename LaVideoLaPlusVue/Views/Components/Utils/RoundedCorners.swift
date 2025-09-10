//
//  RoundedCorners.swift
//  Summit
//
//  Created by Maël Suard on 05/03/2025.
//

import SwiftUI

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
#Preview {
    RoundedCorners(radius: 16, corners: [.topRight, .bottomRight])
        .stroke(Color("SummitLightGray"), lineWidth: 1)

}
