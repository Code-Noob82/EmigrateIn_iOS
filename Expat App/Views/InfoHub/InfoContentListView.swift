//
//  InfoContentListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI
import MarkdownUI

struct InfoContentListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel: InfoContentViewModel
    @State private var showRegistrationPrompt = false
    @State private var tappedContentItem: InfoContent? = nil
    let category: InfoCategory
    let backgroundGradient = AppStyles.backgroundGradient
    // Wichtige Konstante: Die ID der Kategorie, welche die Bundesland-Details anzeigen soll
    let STATE_INFO_CATEGORY_ID = "state_info_de"
    
    init(category: InfoCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: InfoContentViewModel(categoryId: category.id ?? "Fehlende_ID"))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            // Nur eine der folgenden Ansichten soll angezeigt werden.
            if category.id == STATE_INFO_CATEGORY_ID {
                // EXKLUSIV: Wenn es die spezielle Bundesland-Kategorie ist, zeige nur die StateDetailView.
                StateDetailView() // <-- Hier wird die StateDetailView aufgerufen!
                    .environmentObject(authViewModel) // Wichtig für den Zugriff auf selectedStateDetails
            } else if viewModel.isLoading {
                // Ansonsten, wenn es eine andere Kategorie ist und lädt...
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
                
            } else if let errorMessage = viewModel.errorMessage {
                // Ansonsten, wenn es eine andere Kategorie ist und einen Fehler hat...
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppStyles.destructiveColor)
                        .padding(.bottom, 5)
                    
                    Text("Fehler")
                        .font(.headline)
                        .foregroundColor(AppStyles.primaryTextColor)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Erneut versuchen") {
                        Task { await viewModel.fetchContent() }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(AppStyles.buttonBackgroundColor)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if viewModel.contentItems.isEmpty {
                VStack {
                    Text("Keine Inhalte für diese Kategorie gefunden.")
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Ansonsten, wenn es eine andere Kategorie ist und Inhalte hat...
                List {
                    ForEach(viewModel.contentItems) { contentItem in
                        listRow(for: contentItem)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
        // Navigation für registrierte Nutzer
        .navigationDestination(for: InfoContent.self) { specificInfoContent in
            InfoContentDetailView(contentItem: specificInfoContent)
        }
        // Alert für anonyme Nutzer
        .alert("Registrierung erforderlich", isPresented: $showRegistrationPrompt) {
            Button("Registrieren") {
                Task {
                    authViewModel.switchToRegistrationFromAnonymous()
                }
            }
            .foregroundColor(AppStyles.primaryTextColor)
            Button("Abbrechen", role: .cancel) {
                
            }
            .foregroundColor(AppStyles.destructiveColor)
        } message: {
            Text("Um die vollständigen Details sehen \nzu können, registriere dich bitte oder melde dich an.")
        }
    }
    
    // Hilfsfunktion, die entscheidet, ob ein Button oder ein NavLink angezeigt wird
    @ViewBuilder
    private func listRow(for contentItem: InfoContent) -> some View {
        // Prüft, ob der Nutzer anonym ist (über das EnvironmentObject)
        if authViewModel.isAnonymousUser {
            // Anonym: Zeigt einen Button, der den Alert auslöst
            Button {
                self.tappedContentItem = contentItem
                self.showRegistrationPrompt = true // Zeigt den Alert an
            } label: {
                listRowContent(contentItem: contentItem)
                    .contentShape(Rectangle()) // Macht die ganze Zeile klickbar
            }
            .buttonStyle(.plain) // Lässt den Button wie einen Listeneintrag aussehen
        } else {
            // Nicht anonym (registriert): Zeigt normalen NavigationLink
            NavigationLink(value: contentItem) { // Löst .navigationDestination aus
                listRowContent(contentItem: contentItem)
            }
        }
    }
    
    // Hilfsfunktion für das einheitliche Aussehen des Zeileninhalts
    private func listRowContent(contentItem: InfoContent) -> some View {
        HStack { // HStack für Text und Chevron
            VStack(alignment: .leading, spacing: 4) {
                Text(contentItem.title)
                    .font(.headline)
                    .foregroundColor(AppStyles.primaryTextColor)
                
                Markdown(String(contentItem.content.prefix(100)) +
                         (contentItem.content.count > 100 ? "..." : ""))
                .markdownTheme(.basic)
                .font(.caption)
                .foregroundColor(AppStyles.secondaryTextColor)
                .frame(maxHeight: 70)
                .clipped()
            }
            .padding(.vertical, 6)
            Spacer() // Schiebt Chevron nach rechts
            // Fügt das Chevron manuell hinzu, damit es auch beim Button da ist
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}

#Preview("Info Content List") {
    let dummyCategory = InfoCategory(
        id: "state_info_de",
        title: "Ankunft & Erste Schritte",
        subtitle: "Behörden etc.",
        iconName: "figure.wave.circle.fill",
        order: 20
    )
    InfoContentListView(category: dummyCategory)
        .environmentObject(AuthenticationViewModel())
}
