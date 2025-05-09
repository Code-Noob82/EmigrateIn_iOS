//
//  InfoContentView.swift
//  Expat App
//
//  Created by Dominik Baki on 09.05.25.
//

import SwiftUI
import FirebaseFirestore
import MarkdownUI

struct InfoContentDetailView: View {
    let contentItem: InfoContent
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(contentItem.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .padding(.bottom, 5)
                    
                    Markdown(contentItem.content) // Hier wird der vollständige Inhalt Markdown formatiert angezeigt
                        .markdownTheme(.basic)
                        .lineSpacing(5)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .textSelection(.disabled) // Verbietet dem Nutzer, Text zu kopieren
                        //.tint(AppStyles.accentColor)
                    
                    if let linkString = contentItem.officialLink, !linkString.isEmpty, let url =
                        URL(string: linkString) {
                        Divider()
                            .overlay(AppStyles.secondaryTextColor.opacity(0.5))
                        // Link öffnet die URL im Standardbrowser
                        Link(destination: url) {
                            Label("Offizielle Quelle prüfen", systemImage: "safari.fill")
                                .font(.headline)
                                //.foregroundColor(AppStyles.accentColor)
                        }
                        .padding(.top, 10)
                    }
                    // Anzeige des letzten Prüfdatums
                    Divider()
                    Text("Informationen zuletzt geprüft: \(contentItem.lastVerified.dateValue(), style: .date)")
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle(contentItem.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
    }
}

#Preview("Info Content Details mit Markdown") {
    let sampleContentWithMarkdown = InfoContent(
        id: "previewMarkdown",
        categoryId: "sampleCategory",
        title: "Beispieltitel mit Markdown",
        content: """
            ### Wichtige Dokumente & Beglaubigungen
            Eine sorgfältige Vorbereitung der Dokumente ist entscheidend.
            
            ### 1. Ausweisdokumente
            * Gültiger deutscher **Pass/Personalausweis** für *jedes* Familienmitglied.
            * Gültigkeit für gesamten Aufenthalt prüfen!
            * Original + Kopie bereithalten
            
            #### 2. Familienurkunden
            * **Geburtsurkunden (Kinder):** Internationale Version empfohlen, sonst Original + Übersetzung + Apostille.
            * **Heiratsurkunde:** Internationale Version empfohlen, sonst Original + Übersetzung + Apostille.

            [Ein Beispiel-Link](https://www.example.com)
            """,
        officialLink: "https://www.example.com",
        lastVerified: Timestamp(date: Date()),
        order: 1
    )
    return NavigationStack {
        InfoContentDetailView(contentItem: sampleContentWithMarkdown)
    }
}
