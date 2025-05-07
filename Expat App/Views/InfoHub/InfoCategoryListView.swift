//
//  InfoCategoryListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

struct InfoCategoryListView: View {
    @StateObject private var viewModel = InfoCategoryViewModel()
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
                                NavigationLink(value: category) {
                                    HStack {
                                        if let iconName = category.iconName {
                                            Image(systemName: iconName)
                                                //.foregroundColor(AppStyles.accentColor)
                                                .frame(width: 30)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(category.title)
                                                .font(.headline)
                                                .foregroundColor(AppStyles.primaryTextColor)
                                            if let subtitle = category.subtitle, !subtitle.isEmpty {
                                                Text(subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(AppStyles.secondaryTextColor)
                                            }
                                        }
                                    }
                                }
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
            
            .navigationDestination(for: InfoCategory.self) { category in
                InfoContentListView(category: category)
            }
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
        }
    }
}

#Preview("Info Category List") {
    InfoCategoryListView()
}
