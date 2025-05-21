//
//  EmptyCategoriesMessageView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI

struct EmptyCategoriesMessageView: View {
    let message: String // Die anzuzeigende Nachricht (z.B. "Keine Kategorien gefunden.")
    let iconName: String // Der SF Symbol Name (z.B. "tray.fill")
    
    var body: some View {
        VStack(spacing: 15) { // Abstand zwischen Icon und Text
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(AppStyles.secondaryTextColor) // Sekundäre Textfarbe
                .padding(.bottom, 5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(AppStyles.secondaryTextColor) // Sekundäre Textfarbe
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Füllt den gesamten verfügbaren Platz aus
    }
}

// MARK: - Previews
#Preview("Empty Categories Message") {
    EmptyCategoriesMessageView(message: "Keine Checklisten-Kategorien gefunden.", iconName: "tray.fill")
        .background(AppStyles.backgroundGradient.ignoresSafeArea())
}

#Preview("Empty Content Message") {
    EmptyCategoriesMessageView(message: "Keine Inhalte für diese Kategorie.", iconName: "doc.text.magnifyingglass")
        .background(AppStyles.backgroundGradient.ignoresSafeArea())
}
