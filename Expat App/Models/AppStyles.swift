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
struct AppStyles {
    // Definiert die Farben für den Verlauf zentral
    static let gradientColors: [Color] = [
        Color(red: 100/255, green: 180/255, blue: 100/255), // Helleres Grün
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
    static let secondaryTextColor = Color.white.opacity(0.8)
    static let buttonTextColor = gradientColors.last ?? .blue // Dunkelgrün
    static let buttonBackgroundColor = primaryTextColor // Helles Weiß/Grau
    static let destructiveColor = Color.red.opacity(0.8)
    static let destructiveTextColor = Color.white
}
