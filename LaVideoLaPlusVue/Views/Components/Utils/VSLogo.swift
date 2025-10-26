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
                .font(.system(size: size * 0.35, weight: .black))
                .fontWeight(.black)
                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2)) // Noir pastel
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