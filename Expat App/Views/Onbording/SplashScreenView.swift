//
//  SplashScreenView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var logoOpacity: Double = 0.0
    @State private var animatedText = ""
    
    let fullText: String = "EmigrateIn - Dein Zuhause im Ausland startet hier!"
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Image("1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 361, height: 361)
                    .opacity(logoOpacity)
                    .animation(.easeIn(duration: 1.5), value: logoOpacity)
                
                Text(animatedText)
                    .font(Font.custom("SFPro", size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .transition(.opacity)
            }
            .padding()
        }
        .onAppear {
            startLogoAnimation()
            startTextAnimation(delay: 1.0)
        }
    }
    
    private func startLogoAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            logoOpacity = 1.0
        }
    }
    
    private func startTextAnimation(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (index, character) in fullText.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    animatedText.append(character)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        SplashScreenView()
    }
}
