//
//  ChecklistCategoryListView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI
import MarkdownUI

struct ChecklistCategoryListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Für isAnonymousUser
    @StateObject var viewModel = ChecklistCategoryViewModel() // ViewModel für Kategorien
    
    @State private var showRegistrationPrompt = false
    
    let backgroundGradient = AppStyles.backgroundGradient // Zugriff auf AppStyles Gradient
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                if authViewModel.isLoading || viewModel.isLoading { // Ladezustand des AuthViewModel oder des lokalen ViewModels
                    LoadingIndicatorView(message: "Lade Checklisten...")
                    
                } else if authViewModel.isAnonymousUser { // Zugriffskontrolle für anonyme Nutzer
                    VStack(spacing: 15) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding(.bottom, 10)
                        
                        Text("Diese Funktion erfordert eine Anmeldung.")
                            .font(.headline)
                            .foregroundColor(AppStyles.primaryTextColor)
                            .multilineTextAlignment(.center)
                        
                        Text("Bitte melde dich an, um auf deine personalisierten Checklisten zugreifen zu können.")
                            .font(.callout)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Jetzt Anmelden") {
                            self.showRegistrationPrompt = true
                        }
                        .primaryButtonStyle()
                        .padding(.top, 20)
                    }
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorDisplayView(title: "Fehler beim Laden", message: errorMessage) {
                        Task { await viewModel.fetchCategories() }
                    }
                } else if viewModel.categories.isEmpty {
                    EmptyCategoriesMessageView(message: "Keine Checklisten-Kategorien gefunden,", iconName: "tray.fill")
                } else {
                    categoryListContent
                }
            }
            .navigationTitle("Checklisten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(backgroundGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            .onAppear {
                // Kategorien laden nur, wenn nicht anonym und noch nicht geladen
                if !authViewModel.isAnonymousUser && viewModel.categories.isEmpty {
                    Task { await viewModel.fetchCategories() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !authViewModel.isAnonymousUser {
                            Task { await viewModel.fetchCategories() }
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppStyles.primaryTextColor)
                    }
                    .disabled(viewModel.isLoading || authViewModel.isAnonymousUser)
                }
            }
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
                Text("Um auf personalisierte Checklisten zugreifen zu können, registriere dich bitte oder melde dich an.")
            }
        }
    }
    
    @ViewBuilder
    private var categoryListContent: some View {
        List {
            ForEach(viewModel.categories) { category in
                NavigationLink {
                    ChecklistItemsListView(categoryId: category.id ?? "")
                } label: {
                    ChecklistCategoryRowView(category: category)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .background(Color.clear)
        .scrollContentBackground(.hidden)
    }
}

// NEUE HILFS-VIEW für die einzelne Kategorie-Zeile
struct ChecklistCategoryRowView: View {
    let category: ChecklistCategory
    
    var body: some View {
        HStack(spacing: 10) {
            Text(category.title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
            
            Spacer()
            // Hier wird absichtlich keine Beschreibung angezeigt,
            // da sie in die Detailansicht verschoben wurde.
            // Der Chevron-Pfeil wird vom NavigationLink selbst hinzugefügt.
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // Aufgeteilt, um Compiler-Problem zu vermeiden
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppStyles.secondaryTextColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview("ChecklistCategoryListView") {
    ChecklistCategoryListView()
        .environmentObject(AuthenticationViewModel())
}
