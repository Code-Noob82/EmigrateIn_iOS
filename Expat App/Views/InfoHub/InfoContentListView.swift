//
//  InfoContentListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

struct InfoContentListView: View {
    @StateObject private var viewModel: InfoContentViewModel
    let category: InfoCategory
    let backgroundGradient = AppStyles.backgroundGradient
    
    init(category: InfoCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: InfoContentViewModel(categoryId: category.id ?? "Fehlende_ID"))
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
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding(.bottom, 5)
                        
                        Text("Keine Inhalte für diese Kategorie gefunden.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.contentItems) { contentItem in
                            NavigationLink(value: contentItem) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contentItem.title)
                                        .font(.headline)
                                        .foregroundColor(AppStyles.primaryTextColor)
                                    Text(String(contentItem.content.prefix(100)) + "...")
                                        .font(.caption)
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                }
                                .padding(.vertical, 6)
                            }
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
        .navigationDestination(for: InfoContent.self) { specificInfoContent in
            // InfoContentDetailView(contentItem: specificInfoContent)
        }
        .task {
            if viewModel.contentItems.isEmpty && viewModel.errorMessage == nil {
                await viewModel.fetchContent()
            }
        }
    }
}

#Preview("Info Content List") {
    let previewCategory = InfoCategory(id: "arrival_cy", title: "Ankunft & Erste Schritte", subtitle: "Behörden etc.", iconName: "figure.wave.circle.fill", order: 20)
    InfoContentListView(category: previewCategory)
}
