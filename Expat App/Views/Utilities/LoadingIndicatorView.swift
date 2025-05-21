//
//  LoadingIndicatorView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI

struct LoadingIndicatorView: View {
    let message: String // Nachricht, die unter dem ProgressView angezeigt wird
    
    var body: some View {
        VStack(spacing: 15) { // Abstand zwischen ProgressView und Text
            ProgressView()
                .controlSize(.large) // Macht den Indikator etwas größer
                .tint(AppStyles.primaryTextColor) // Farbe des Indikators
            
            Text(message)
                .font(.body)
                .foregroundColor(AppStyles.primaryTextColor) // Textfarbe aus AppStyles
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Füllt den gesamten verfügbaren Platz aus
        // Optional: Einen leichten Hintergrund, wenn sie über einem komplexen Hintergrund liegen
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Preview
#Preview("Loading Indicator") {
    LoadingIndicatorView(message: "Lade Daten...")
        .background(AppStyles.backgroundGradient.ignoresSafeArea()) // Test auf dem Gradienten-Hintergrund
}
