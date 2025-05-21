//
//  InfoCategoryViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class InfoCategoryViewModel: ObservableObject {
    @Published var categories: [InfoCategory] = []
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
        guard !isLoading else {
            print("Fetch skipped: Already loading.")
            return
        }
        guard categories.isEmpty else {
            print("Fetch skipped: Categories already popuplated.")
            return
        }
        isLoading = true
        errorMessage = nil
        print("Fetching Info Categories...")
        
        do {
            self.categories = try await repository.fetchInfoCategories()
        } catch {
            self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
