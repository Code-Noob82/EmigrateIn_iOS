//
//  SplashScreenView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

struct SplashScreenView: View {
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.1, green: 0.55, blue: 0.55), Color(red: 0.05, green: 0.45, blue: 0.45)]),
        startPoint: .topTrailing, // Startpunkt oben rechts
        endPoint: .bottomLeading // Endpunkt unten links
    )
    
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
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

#Preview {
    SplashScreenView()
}
