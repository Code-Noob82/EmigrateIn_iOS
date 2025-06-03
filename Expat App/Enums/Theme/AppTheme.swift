//
//  AppTheme.swift
//  Expat App
//
//  Created by Dominik Baki on 03.06.25.
//

import Foundation

// Enum für die Theme-Auswahl
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Hell"
    case dark = "Dunkel"

    var id: String { self.rawValue }

    // Entsprechendes SF Symbol für das Theme
    var icon: String {
        switch self {
        case .system:
            return "iphone" // oder "display"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}
