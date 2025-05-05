//
//  InfoCategoryViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import FirebaseFirestore

class InfoCategoryViewModel: ObservableObject {
    @Published var categoties: [InfoCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let repository: ContentRepositoryProtocol
    
    init(repository: ContentRepositoryProtocol = ContentRepository()) {
        self.repository = repository
        Task {
            await fetchCategories()
        }
    }
    
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.categoties = try await repository.fetchInfoCategories()
        } catch {
            self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
