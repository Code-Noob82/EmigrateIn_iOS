//
//  OnboardingData.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import Foundation

// MARK: - Onboarding Views

// Definiert die Inhalte für die einzelnen Schritte
struct OnboardingData: Identifiable {
    let id = UUID()
    let imageName: String
    let headline: String
    let bodyText: String
}

// Daten für die Onboarding-Schritte
let onboardingSteps: [OnboardingData] = [
    OnboardingData(imageName: "figure.wave.circle.fill",
                   headline: "Willkommen bei EmigrateIn!",
                   bodyText: "Euer Begleiter für den Familienstart im Ausland. Wir machen den Umzug einfacher – Schritt für Schritt."),
    OnboardingData(imageName: "list.bullet.clipboard.fill",
                   headline: "Infos & Checklisten an einem Ort",
                   bodyText: "Visa, Behörden, Wohnen, Schule – behaltet den Überblick! EmigrateIn bündelt wichtige Infos und Aufgaben für Euren Start auf Zypern."),
    OnboardingData(imageName: "house.fill",
                   headline: "Findet Euer neues Zuhause",
                   bodyText: "Erhaltet Tipps zur Wohnungssuche, versteht Mietverträge und erfahrt mehr über die Wohnkosten in verschiedenen Regionen Zyperns."),
    OnboardingData(imageName: "checkmark.seal.fill",
                   headline: "Startet vorbereitet ins Abenteuer!",
                   bodyText: "Mit klaren Anleitungen und interaktiven Checklisten meistert Ihr die Bürokratie und die ersten Schritte mit mehr Sicherheit.")
]
