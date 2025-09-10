import SwiftUI

extension Color {
    init(hex: String) {
        // Strip the leading "#" if it exists
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        // Ensure the string has 6 or 8 characters
        guard hex.count == 6 || hex.count == 8 else {
            self = .clear // Fallback to clear color on invalid input
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let red, green, blue, alpha: Double
        if hex.count == 6 {
            // If no alpha provided, default it to 1
            red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = Double(rgbValue & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            // If alpha is provided (8 characters)
            red = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            green = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgbValue & 0x000000FF) / 255.0
        }
        
        
        // Initialize the color
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
