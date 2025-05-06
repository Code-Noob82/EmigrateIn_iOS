//
//  ContentRepository.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import FirebaseFirestore

class ContentRepository: ContentRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func fetchInfoCategories() async throws -> [InfoCategory] {
        print("Fetching Info Categories...")
        do {
            let querySnapshot = try await db.collection("info_categories")
                .order(by: "order")
                .getDocuments()
            let categories = try querySnapshot.documents.compactMap { document -> InfoCategory? in
                try document.data(as: InfoCategory.self)
            }
            print("Fetched \(categories.count) info categories.")
            return categories
        } catch {
            print("Error fetching info categories: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchInfoContent(for categoryId: String) async throws -> [InfoContent] {
        print("Fetching Info Content for Category \(categoryId)...")
        do {
            let querySnapshot = try await db.collection("info_content")
                .whereField("categoryId", isEqualTo: categoryId)
                .order(by: "order")
                .getDocuments()
            let contentItems = try querySnapshot.documents.compactMap { document -> InfoContent? in
                try document.data(as: InfoContent.self)
            }
            print("Fetched \(contentItems.count) content items for category \(categoryId).")
            return contentItems
        } catch {
            print("Error fetching info content for category \(categoryId): \(error.localizedDescription)")
            throw error
        }
    }
}
