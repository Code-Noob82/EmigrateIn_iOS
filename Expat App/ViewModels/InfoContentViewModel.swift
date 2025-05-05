//
//  InfoContentViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import FirebaseFirestore

class InfoContentViewModel: ObservableObject {
    @Published var contentItems: [InfoContent] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let repository: ContentRepositoryProtocol
    private let categoryId: String
    
    init(categoryId: String, repository: ContentRepositoryProtocol = ContentRepository()) {
        self.categoryId = categoryId
        self.repository = repository
        Task {
            await fetchContent()
        }
    }
    
    func fetchContent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.contentItems = try await repository.fetchInfoContent(for: categoryId)
        } catch {
            self.errorMessage = "Fehler beim Laden der Inhalte für Kategorie \(categoryId): \(error.localizedDescription)"
        }
        isLoading = false
    }
}
