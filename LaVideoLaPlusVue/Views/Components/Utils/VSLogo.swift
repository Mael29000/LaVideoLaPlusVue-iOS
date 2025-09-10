import SwiftUI

struct VSLogo: View {
    let size: CGFloat
    
    init(size: CGFloat = 60) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text("VS")
                .font(.system(size: size * 0.35, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.8, green: 0.2, blue: 0.3),    // Rouge
                            Color(red: 0.6, green: 0.15, blue: 0.4),   // Rouge-violet
                            Color(red: 0.4, green: 0.1, blue: 0.5)     // Violet
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VSLogo(size: 40)
        VSLogo(size: 60)
        VSLogo(size: 80)
    }
    .padding()
}