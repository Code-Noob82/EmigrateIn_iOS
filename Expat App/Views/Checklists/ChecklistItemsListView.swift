//
//  ChecklistItemsListView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI

struct ChecklistItemsListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Für Authentifizierungsstatus
    @StateObject var viewModel: ChecklistViewModel // Wird für diese View initialisiert
    
    let categoryId: String // Die ID der Kategorie, die von der vorherigen View übergeben wird
    let backgroundGradient = AppStyles.backgroundGradient
    
    // Initializer für @StateObject, um categoryId zu übergeben
    init(categoryId: String) {
        self.categoryId = categoryId
        _viewModel = StateObject(wrappedValue: ChecklistViewModel(categoryId: categoryId))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient // Hintergrundgradient
                .ignoresSafeArea()
            
            Group {
                // Ladezustand des ViewModels
                if viewModel.isLoading {
                    ProgressView("Lade Checklisten-Items...")
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
                            Task { await viewModel.fetchChecklistItems() } // Items neu laden
                        }
                        .padding(.top)
                        .buttonStyle(.borderedProminent)
                        .tint(AppStyles.buttonBackgroundColor)
                    }
                    .padding()
                } else if viewModel.items.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray.fill")
                            .font(.largeTitle)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding(.bottom, 5)
                        Text("Keine Items in dieser Checkliste gefunden.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                    }
                    .padding()
                } else {
                    // Liste der Checklisten-Items
                    List {
                        ForEach(viewModel.items) { item in
                            ChecklistItemView(viewModel: viewModel, item: item) // Die einzelne Item-View
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        // Navigations-Titel basierend auf der Kategorie-ID oder dem ersten Item
        .navigationTitle(viewModel.items.first?.categoryId ?? "Checkliste") // Besser: Kategorietitel dynamisch laden
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
        .onAppear {
            // Die Items werden bereits im init des ViewModels geladen.
            // Hier könnten zusätzliche Aktionen ausgeführt werden, z.B. wenn sich die categoryId ändern würde.
            // In diesem Fall reicht die Init-Logik im ViewModel.
            print("ChecklistItemsListView appeared for category: \(categoryId)")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await viewModel.fetchChecklistItems() } // Items neu laden
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppStyles.primaryTextColor)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

//#Preview("ChecklistItemsListView") {
//    ChecklistItemsListView(categoryId: "some_test_category_id")
//        .environmentObject(AuthenticationViewModel())
//}
