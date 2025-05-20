//
//  InfoCategoryListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

struct InfoCategoryListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var viewModel = InfoCategoryViewModel()
    @State private var showRegistrationPrompt = false
    @State private var tappedCategory: InfoCategory?
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        NavigationStack {
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
                                .foregroundColor(AppStyles.destructiveTextColor)
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
                                Task { await viewModel.fetchCategories() }
                            }
                            .padding(.top)
                            .buttonStyle(.borderedProminent)
                            .tint(AppStyles.buttonBackgroundColor)
                        }
                        .padding()
                    } else if viewModel.categories.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray.fill")
                                .font(.largeTitle)
                                .foregroundColor(AppStyles.secondaryTextColor)
                                .padding(.bottom, 5)
                            
                            Text("Keine Kategorien gefunden.")
                                .foregroundColor(AppStyles.secondaryTextColor)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(viewModel.categories) { category in
                                listItem(for: category)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                }
                //.background(Color.clear)
            }
            .navigationTitle("Info Kategorien")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(backgroundGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            .task {
                if viewModel.categories.isEmpty && viewModel.errorMessage == nil {
                    await viewModel.fetchCategories()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchCategories() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppStyles.primaryTextColor)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationDestination(for: InfoCategory.self) { selectedCategory in
                InfoContentListView(category: selectedCategory, stateSpecificInfo: authViewModel.selectedStateDetails)
            }
        }
    }
    
    @ViewBuilder
    private func listItem(for category: InfoCategory) -> some View {
        // Für alle Nutzer, ob anonym oder nicht, soll die Navigation zur InfoContentListView möglich sein.
        // Die Registrierungspflicht kommt erst bei der InfoContentDetailView.
        NavigationLink(value: category) {
            listItemContent(category: category)
        }
    }
    
    private func listItemContent(category: InfoCategory) -> some View {
        HStack {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .frame(width: 30)
            }
            VStack(alignment: .leading) {
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(AppStyles.secondaryTextColor)
                if let subtitle = category.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    private func getInfoContent(for category: InfoCategory) -> [InfoContent]? {
        return nil
    }
}

#Preview("Info Category List") {
    InfoCategoryListView()
        .environmentObject(AuthenticationViewModel())
}
