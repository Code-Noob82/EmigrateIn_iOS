//
//  AppStyles.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

// MARK: - App Styles
// Eine Struktur, um wiederverwendbare Design-Elemente zu bündeln
// Angepasste Farben für den Verlauf, um besseren Kontrast mit hellem Text zu gewährleisten
struct AppStyles {
    static var gradientColors: [Color] = [
        Color(red: 0.1, green: 0.55, blue: 0.55), // Helleres Petrol für innen
        Color(red: 0.05, green: 0.45, blue: 0.45)   // Dunkleres Petrol für außen
    ]

    // Definiert den radialen Farbverlauf zentral
    static var backgroundGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: gradientColors),
            center: .center,
            startRadius: 20,
            endRadius: UIScreen.main.bounds.width * 0.8 // Endradius, der sich etwas an die Breite anpasst
        )
    }

    // Definiert die Textfarben zentral
    static let primaryTextColor = Color(red: 0.93, green: 0.95, blue: 0.96)
    static let secondaryTextColor = Color(white: 0.85)
    static let buttonTextColor = gradientColors.last ?? Color(red: 40, green: 100, blue: 40)
    static let buttonBackgroundColor = primaryTextColor // Fast weiß
    static let destructiveColor = Color(red: 200, green: 0, blue: 0) // Solides, dunkleres Rot
    static let destructiveTextColor = Color.white
    
    // NEU: Globale Stilwerte für Buttons
    static let commonButtonHeight: CGFloat = 50
    static let commonButtonFont = primaryTextColor
    static let commonButtonCornerRadius: CGFloat = commonButtonHeight / 2 // Für Kapselform
// Alternativ: static let commonButtonCornerRadius: CGFloat = 8 // Für abgerundete Ecken
}

extension AppStyles {
    struct PrimaryButton: ViewModifier {
        func body(content: Content) -> some View {
            content // Der Inhalt des Buttons (z.B. Text oder Label)
                .foregroundColor(AppStyles.buttonTextColor)
                .padding()
                .background(AppStyles.buttonBackgroundColor)
                .cornerRadius(AppStyles.commonButtonCornerRadius)
        }
    }
}
