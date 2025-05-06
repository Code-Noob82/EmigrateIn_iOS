//
//  Color.swift
//  Expat App
//
//  Created by Dominik Baki on 06.05.25.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    var isDark: Bool {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        // Versuche, die UIColor-Repräsentation zu bekommen
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Fallback, falls die Farbe nicht einfach in RGB konvertiert werden kann
            // (z.B. einige Systemfarben oder komplexere Farbdefinitionen).
            // Hier könntest du eine Standardannahme treffen oder versuchen,
            // bekannte SwiftUI-Farben wie .black, .white etc. direkt zu prüfen.
            // Für eine einfache Annahme:
            print("Warnung: Konnte Helligkeit für Farbe nicht bestimmen. Nehme 'nicht dunkel' an.")
            return false
        }

        // Formel zur Berechnung der Luminanz (Helligkeit)
        // (siehe https://www.w3.org/TR/WCAG20/#relativeluminancedef)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        // Schwellenwert, um zu entscheiden, ob die Farbe als "dunkel" gilt
        // (0.5 ist ein gängiger Wert, kann aber angepasst werden)
        return luminance < 0.5
    }
}
