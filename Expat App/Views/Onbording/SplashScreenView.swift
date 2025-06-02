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
    @State private var mapOpacity: Double = 0.0
    
    let fullText: String = "EmigrateIn - Dein smarter Weg ins Ausland"
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            Image("WorldMap")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                .opacity(mapOpacity).opacity(0.5)
                .animation(.easeIn(duration: 2.0), value: mapOpacity)
                .blendMode(.luminosity)
            
            VStack(spacing: 8) {
                Image("1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 361, height: 361)
                    .opacity(logoOpacity)
                    .animation(.easeIn(duration: 1.5), value: logoOpacity)
                
                Text(animatedText)
                    .font(.callout)
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .transition(.opacity)
            }
            .padding()
        }
        .onAppear {
            startMapAnimation()
            startLogoAnimation(delay: 0.5)
            startTextAnimation(delay: 1.0)
        }
    }
    
    // Funktion zum Starten der Weltkarten-Einblendung
    private func startMapAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Startet sehr schnell
            mapOpacity = 1.0
        }
    }
    
    private func startLogoAnimation(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
