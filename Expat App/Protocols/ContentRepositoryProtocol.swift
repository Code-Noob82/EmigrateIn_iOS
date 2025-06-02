//
//  ContentRepositoryProtocol.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import FirebaseFirestore

protocol ContentRepositoryProtocol {
    func fetchInfoCategories() async throws -> [InfoCategory]
    func fetchInfoContent(for categoryId: String) async throws -> [InfoContent]
    
    // MARK: - Checklist Categories & Items
    func fetchChecklistCategories() async throws -> [ChecklistCategory]
    func fetchChecklistCategory(by id: String) async throws -> ChecklistCategory?
    func fetchChecklistItems(for categoryId: String) async throws -> [ChecklistItem]
    
    // MARK: - User Checklist State (Sub-Collection-Ansatz - NEU)
    func setItemCompletionStatusInSubcollection(userId: String, itemId: String, isCompleted: Bool) async throws
    
    func addCompletedItemsSubcollectionListener(
        for userId: String,
        completion: @escaping (Result<Set<String>, Error>) -> Void
    ) -> ListenerRegistration
}
