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
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Fehler")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Erneut versuchen") {
                            Task { await viewModel.fetchCategories() }
                        }
                        .padding(.top)
                    }
                    .padding()
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien gefunden.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            NavigationLink(value: category) {
                                HStack {
                                    if let iconName = category.iconName {
                                        Image(systemName: iconName)
                                            .foregroundColor(.accentColor)
                                            .frame(width: 30)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(category.title).font(.headline)
                                        if let subtitle = category.subtitle, !subtitle.isEmpty {
                                            Text(subtitle).font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //.listStyle(.grouped)
                }
            }
            .navigationTitle("Info Hub")
            .navigationDestination(for: InfoCategory.self) { category in
                InfoContentListView(category: category)
            }
        }
        
    }
}

#Preview("Info Category List") {
    InfoCategoryListView()
}
