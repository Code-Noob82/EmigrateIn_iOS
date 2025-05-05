//
//  OnboardingStepView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

// MARK: - Wiederverwendbare Onboarding Step View

// Eine wiederverwendbare View für einzelne Schritte im Onboarding-Prozess.
struct OnboardingStepView: View {
    // Daten für diesen spezifischen Onboarding-Schritt
    let imageName: String
    let headline: String
    let bodyText: String
    let pageIndex: Int // Index dieser Seite (z.B. 0, 1, 2)
    let totalPages: Int // Gesamtanzahl der Seiten
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
    
    let primaryTextColor = Color(red: 0.93, green: 0.95, blue: 0.96)
    let secondaryTextColor = Color.white.opacity(0.9)
    
    // Aktion für den Button (wird von außen übergeben)
    var buttonAction: () -> Void = {}
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.bottom, 30)
                    .foregroundColor(primaryTextColor)
                // Überschrift
                Text(headline)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
                // Beschreibungstext
                Text(bodyText)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                // Page Indicator (Punkte) - Dynamisch
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == pageIndex ? primaryTextColor : secondaryTextColor.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                Button(pageIndex == totalPages - 1 ? "Los geht's!" : "Weiter") {
                    buttonAction() // Führt die übergebene Aktion aus
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(primaryTextColor)
                .foregroundColor(gradientColors.last ?? .blue)
                .clipShape(Capsule())
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
            }
            .padding()
        }
    }
}
// MARK: - Preview

#Preview("Einzelner Step") {
    // Vorschau für einen einzelnen Schritt
    OnboardingStepView(
        imageName: "info.circle.fill",
        headline: "Infos an einem Ort",
        bodyText: "Visa, Behörden, Wohnen, Schule – behaltet den Überblick! EmigrateIn bündelt alle wichtigen Infos.",
        pageIndex: 1, // Zweite Seite
        totalPages: 4  // Vier Seiten insgesamt
    )
}

#Preview("Gesamter Flow") {
    // Vorschau für den gesamten Onboarding-Flow
    OnboardingContainerView(finishAction: {
        print("Onboarding abgeschlossen!")
    })
}
