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
    
    // MARK: - NEUE FUNKTIONEN FÜR CHECKLISTEN
    func fetchChecklistCategories() async throws -> [ChecklistCategory] {
        print("Fetching Checklist Categories...")
        do {
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
    
    func fetchChecklistItems(for categoryId: String) async throws -> [ChecklistItem] {
        print("Fetching Checklist Items for Category \(categoryId)...")
        do {
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
    
    func fetchUserChecklistState(for userId: String) async throws -> UserChecklistState {
        print("Fetching user checklist state for user: \(userId)...")
        do {
            let documentSnapshot = try await db.collection("user_checklist_states").document(userId).getDocument()
            
            guard documentSnapshot.exists else {
                // Wenn das Dokument nicht existiert, werfen wir einen spezifischen Fehler.
                throw NSError(domain: "ContentRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User checklist state document not found."])
            }
            
            let state = try documentSnapshot.data(as: UserChecklistState.self)
            print("Fetched user checklist state for user: \(userId).")
            return state
        } catch {
            print("Error fetching user checklist state for user \(userId): \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveUserChecklistState(for userId: String, state: UserChecklistState) async throws {
        print("Saving user checklist state for user: \(userId)...")
        do {
            // 'merge: true' ist wichtig, um nur die 'completedItems' zu aktualisieren
            // und bestehende Felder im Dokument nicht zu überschreiben.
            try db.collection("user_checklist_states").document(userId).setData(from: state, merge: true)
            print("User checklist state saved for user: \(userId).")
        } catch {
            print("Error saving user checklist state for user \(userId): \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateChecklistItemCompletion(userId: String, itemId: String, isCompleted: Bool) async throws {
        print("Updating completion status for item \(itemId) for user \(userId) to \(isCompleted)...")
        do {
            let userChecklistStateRef = db.collection("user_checklist_states").document(userId)
            
            let fieldToUpdate = "completedItems.\(itemId)" // Punktnotation für Dictionary-Feld
            
            if isCompleted {
                // Wenn true, setzen wir den Wert auf true
                try await userChecklistStateRef.setData(["completedItems": [itemId: true]], merge: true)
            } else {
                // Wenn false, löschen wir das Feld aus dem Map (effizienter für Firestore)
                try await userChecklistStateRef.updateData([fieldToUpdate: FieldValue.delete()])
            }
            print("Successfully updated item \(itemId) completion to \(isCompleted) for user \(userId).")
        } catch {
            print("Error updating checklist item completion: \(error.localizedDescription)")
            throw error
        }
    }
    
    // NEU HINZUGEFÜGT: Implementierung der Snapshot Listener Funktion
    func addChecklistStateSnapshotListener(
        for userId: String,
        completion: @escaping (Result<UserChecklistState?, Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection("user_checklist_states").document(userId)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    // Dies sollte nicht passieren, wenn error nil ist
                    completion(.failure(NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document snapshot is nil"])))
                    return
                }
                
                if document.exists {
                    do {
                        let state = try document.data(as: UserChecklistState.self)
                        completion(.success(state))
                    } catch {
                        completion(.failure(error)) // Dekodierungsfehler
                    }
                } else {
                    completion(.success(nil)) // Dokument existiert nicht
                }
            }
    }
}
