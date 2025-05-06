//
//  InfoContentListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct InfoContentListView: View {
    @StateObject private var viewModel: InfoContentViewModel
    let category: InfoCategory
    
    init(category: InfoCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: InfoContentViewModel(categoryId: category.id ?? ""))
    }
    
    var body: some View {
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
                    Task { await viewModel.fetchContent() }
                }
                .padding(.top)
            }
            .padding()
        } else if viewModel.contentItems.isEmpty {
            Text("Keine Inhalte für diese Kategorie gefunden.")
                .foregroundColor(.secondary)
        } else {
            List {
                ForEach(viewModel.contentItems) { contentItem in
                    NavigationLink(value: contentItem) {
                        Text(contentItem.title)
                    }
                }
            }
        }
    }
}

#Preview("Info Content List") {
    let previewCategory = InfoCategory(id: "arrival_cy", title: "Ankunft & Erste Schritte", subtitle: "Behörden etc.", iconName: "figure.wave.circle.fill", order: 20)
    InfoContentListView(category: previewCategory)
}
