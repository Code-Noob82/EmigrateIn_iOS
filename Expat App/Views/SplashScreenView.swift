//
//  SplashScreenView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

struct SplashScreenView: View {
    let gradientColors: [Color] = [
        Color(red: 100/255, green: 180/255, blue: 100/255),
        Color(red: 40/255, green: 100/255, blue: 40/255)
    ]
    
    var backgroundGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: gradientColors),
            center: .center,
            startRadius: 50,
            endRadius: 600
        )
    }
    // Definiert die spezifische Textfarbe für "Emigrate"
    let emigrateTextColor = Color(red: 0.93, green: 0.95, blue: 0.96)
    // Definiert die spezifische Textfarbe für "In" (aus FIGMA-Design RGBA: 51, 103, 73, 1)
    let inTextColor = Color(red: 51/255, green: 103/255, blue: 73/255) // Umrechnung von 0-255 auf 0.0-1.0
    
    // Erzeugt den formatierten Text für "EmigrateIn" mit unterschiedlichen Farben
    private var appNameFormatted: AttributedString {
        var emigrateString = AttributedString("Emigrate")
        // Setzt die Farbe und Schrift für "Emigrate"
        emigrateString.foregroundColor = emigrateTextColor
        emigrateString.font = .custom("SFPro-SemiBold", size: 60)
        
        var inString = AttributedString("In")
        inString.foregroundColor = inTextColor
        inString.font = .custom("SFPro-SemiBold", size: 60)
        return emigrateString + inString // Fügt beide Teile zusammen
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text(appNameFormatted) // Verwendet die formatierten AttributedString
                Text("Gut vorbereitet auswandern – mit EmigrateIn")
                    .font(Font.custom("SFPro", size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}

#Preview {
    SplashScreenView()
}
