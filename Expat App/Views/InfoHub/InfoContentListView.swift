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
    let stateSpecificInfo: StateSpecificInfo?
    
    init(category: InfoCategory, stateSpecificInfo: StateSpecificInfo?) {
        self.category = category
        _viewModel = StateObject(wrappedValue: InfoContentViewModel(categoryId: category.id ?? "Fehlende_ID"))
        self.stateSpecificInfo = stateSpecificInfo
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppStyles.primaryTextColor)
                    
                } else if let errorMessage = viewModel.errorMessage {
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
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.contentItems.isEmpty {
                    VStack() {
                        if let stateInfo = stateSpecificInfo {
                            Text("Details für \(stateInfo.stateName)")
                                .font(.headline)
                                .foregroundColor(AppStyles.primaryTextColor)
                                .padding()
                            
                            // Hier alle weiteren Infos aus stateInfo
                        } else {
                            Text("Keine Inhalte für diese Kategorie gefunden.")
                                .foregroundColor(AppStyles.secondaryTextColor)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
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
        id: "arrival_cy",
        title: "Ankunft & Erste Schritte",
        subtitle: "Behörden etc.",
        iconName: "figure.wave.circle.fill",
        order: 20
    )
    let dummyStateInfo = StateSpecificInfo(
        stateName: "Baden-Württemberg",
        apostilleInfo: "Vorschau",
        apostilleAuthorities: [],
        order: 99
    )
    InfoContentListView(category: dummyCategory, stateSpecificInfo: dummyStateInfo)
        .environmentObject(AuthenticationViewModel())
}
