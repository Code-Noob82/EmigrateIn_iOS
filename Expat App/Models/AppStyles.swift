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
        Color(red: 74/255, green: 138/255, blue: 74/255), // Helleres Grün
        Color(red: 40/255, green: 100/255, blue: 40/255)   // Dunkleres Grün
    ]

    // Definiert den radialen Farbverlauf zentral
    static var backgroundGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: gradientColors),
            center: .center,
            startRadius: 50,
            endRadius: 600
        )
    }

    // Definiert die Textfarben zentral
    static let primaryTextColor = Color(red: 0.93, green: 0.95, blue: 0.96)
    static let secondaryTextColor = Color(white: 0.85)
    static let buttonTextColor = gradientColors.last ?? Color(red: 40/255, green: 100/255, blue: 40/255)
    static let buttonBackgroundColor = primaryTextColor // Fast weiß
    static let destructiveColor = Color(red: 200/255, green: 0/255, blue: 0/255) // Solides, dunkleres Rot
    static let destructiveTextColor = Color.white
}
