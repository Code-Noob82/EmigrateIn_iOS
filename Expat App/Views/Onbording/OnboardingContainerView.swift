//
//  OnboardingContainerView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

// MARK: - Onboarding Container View

// Diese View verwaltet die einzelnen Onboarding-Schritte in einem TabView
struct OnboardingContainerView: View {
    // State-Variable, um die aktuell angezeigte Seite zu verfolgen
    @State private var currentPage = 0
    
    // Aktion, die ausgeführt wird, wenn der letzte Button ("Los geht's!") gedrückt wird
    var finishAction: () -> Void
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Erzeugt für jeden Datensatz eine OnboardingStepView
            ForEach(Array(onboardingSteps.enumerated()), id: \.element.id) { index, stepData in
                OnboardingStepView(
                    imageName: stepData.imageName,
                    headline: stepData.headline,
                    bodyText: stepData.bodyText,
                    pageIndex: index, // Übergibt den aktuellen Index
                    totalPages: onboardingSteps.count, // Übergibt die Gesamtanzahl
                    buttonAction: { // Definiert die Aktion für den Button
                        if index < onboardingSteps.count - 1 {
                            // Gehe zur nächsten Seite (mit Animation)
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Letzte Seite: Führt die Abschlussaktion aus
                            finishAction()
                        }
                    }
                )
                .tag(index) // Wichtig für die TabView-Auswahl
            }
        }
        // Verwendet den Page-Stil für die TabView (Punkte unten)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Versteckt die Standard-Punkte
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
