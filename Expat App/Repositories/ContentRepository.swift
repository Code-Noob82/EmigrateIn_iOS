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
    
    // MARK: - Info Categories & Content
    
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
    
    // MARK: - Checklist Categories & Items
    
    func fetchChecklistCategories() async throws -> [ChecklistCategory] {
        print("Fetching Checklist Categories...")
        do {
            // MARK: - Konsistenz-Check: Collection Name
            // Stelle sicher, dass der Collection-Name in Firestore "checklist_categories" ist
            let querySnapshot = try await db.collection("checklist_categories")
                .order(by: "order")
                .getDocuments()
            let categories = try querySnapshot.documents.compactMap { document -> ChecklistCategory? in
                try document.data(as: ChecklistCategory.self)
            }
            print("Fetched \(categories.count) checklist categories.")
            return categories
        } catch {
            print("Error fetching checklist categories: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchChecklistCategory(by id: String) async throws -> ChecklistCategory? {
        print("Fetching single Checklist Category by ID: \(id)...")
        do {
            let documentSnapshot = try await db.collection("checklist_categories").document(id).getDocument()
            
            // MARK: - KORREKTUR: Prüfe documentSnapshot.exists VOR dem Dekodieren
            guard documentSnapshot.exists else {
                print("Checklist Category with ID \(id) not found.")
                return nil // Dokument existiert nicht
            }
            
            let category = try documentSnapshot.data(as: ChecklistCategory.self)
            print("Fetched Checklist Category: \(id).")
            return category
        } catch {
            print("Error fetching single checklist category by ID \(id): \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchChecklistItems(for categoryId: String) async throws -> [ChecklistItem] {
        print("Fetching Checklist Items for Category \(categoryId)...")
        do {
            // MARK: - Konsistenz-Check: Collection Name
            let querySnapshot = try await db.collection("checklist_items")
                .whereField("categoryId", isEqualTo: categoryId)
                .order(by: "order")
                .getDocuments()
            let items = try querySnapshot.documents.compactMap { document -> ChecklistItem? in
                try document.data(as: ChecklistItem.self)
            }
            print("Fetched \(items.count) checklist items for category \(categoryId).")
            return items
        } catch {
            print("Error fetching checklist items for category \(categoryId): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - User Checklist State (Sub-Collection-Ansatz - NEU)
    
    // Setzt oder löscht den Erledigungsstatus eines Items in der 'completed_items' Sub-Collection.
    func setItemCompletionStatusInSubcollection(userId: String, itemId: String, isCompleted: Bool) async throws {
        let itemDocRef = db.collection("user_checklist_states").document(userId)
            .collection("completed_items").document(itemId)
        
        if isCompleted {
            print("DEBUG ContentRepository: Setze Item '\(itemId)' in Subcollection als erledigt für User '\(userId)'.")
            // Erstellt das Dokument oder überschreibt es. Ein leeres Dokument oder eines mit Zeitstempel ist möglich.
            try await itemDocRef.setData(["markedAt": FieldValue.serverTimestamp()]) // merge:false ist hier default und ok
        } else {
            print("DEBUG ContentRepository: Lösche Item '\(itemId)' aus Subcollection für User '\(userId)'.")
            try await itemDocRef.delete()
        }
        print("Successfully updated subcollection item \(itemId) to \(isCompleted) for user \(userId).")
    }
    
    // Fügt einen Snapshot-Listener zur 'completed_items' Sub-Collection eines Nutzers hinzu.
    // Liefert ein Set der Document-IDs (itemIds) der erledigten Items.
    func addCompletedItemsSubcollectionListener(
        for userId: String,
        completion: @escaping (Result<Set<String>, Error>) -> Void
    ) -> ListenerRegistration {
        let subcollectionRef = db.collection("user_checklist_states").document(userId)
                                 .collection("completed_items")
        
        print("DEBUG ContentRepository: Listener für Subcollection 'user_checklist_states/\(userId)/completed_items' wird hinzugefügt.")
        
        // includeMetadataChanges: true kann beim Debuggen helfen, um zu sehen, wann Daten aus Cache vs. Server kommen.
        // Für den normalen Betrieb ist es oft nicht nötig.
        return subcollectionRef.addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            if let error = error {
                print("DEBUG Subcollection Listener ERROR für User '\(userId)': \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("DEBUG Subcollection Listener WARN für User '\(userId)': querySnapshot war nil.")
                completion(.success(Set<String>())) // Leeres Set bei unerwartetem nil-Snapshot
                return
            }
            
            let metadata = snapshot.metadata
            print("DEBUG Subcollection Listener METADATA für User '\(userId)': Aus Cache: \(metadata.isFromCache), Ausstehende Schreibvorgänge: \(metadata.hasPendingWrites)")
            
            // Extrahiert die Dokument-IDs. Jede Dokument-ID ist eine itemId eines erledigten Items.
            let completedItemIds = Set(snapshot.documents.map { $0.documentID })
            
            print("DEBUG Subcollection Listener: \(completedItemIds.count) erledigte Item-IDs für User '\(userId)' empfangen: \(completedItemIds)")
            completion(.success(completedItemIds))
        }
    }
}
