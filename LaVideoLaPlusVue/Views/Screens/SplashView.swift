//
//  SplashView.swift
//  LaVideoLaPlusVue
//
//  Created by Maël Suard on 13/03/2025.
//


import SwiftUI

struct SplashView: View {

    var body: some View {
        
        VStack {
            AppLogo(size: 150)
            
            Text("LaVideoLaPlusVue")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.25),
                    Color(red: 0.15, green: 0.08, blue: 0.20),
                    Color(red: 0.25, green: 0.08, blue: 0.15),
                    Color(red: 0.20, green: 0.05, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
        )
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
