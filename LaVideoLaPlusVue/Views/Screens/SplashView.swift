//
//  SplashView.swift
//  Summit
//
//  Created by Maël Suard on 13/03/2025.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        
        VStack {
            Image("ChamoisImage") // Replace with your actual logo asset
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("Summit Store")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("SummitBlack"))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
           // MainView() // Your main app view
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
