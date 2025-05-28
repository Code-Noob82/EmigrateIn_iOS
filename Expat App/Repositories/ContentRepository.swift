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
    
    // MARK: - User Checklist State
    
    // MARK: - Anpassung: Rückgabetyp zu UserChecklistState?
    func fetchUserChecklistState(for userId: String) async throws -> UserChecklistState? {
        print("Fetching user checklist state for user: \(userId)...")
        do {
            let documentSnapshot = try await db.collection("user_checklist_states").document(userId).getDocument()
            
            // MARK: - KORREKTUR: `try?` zum Erzeugen eines Optionalen
            let state = try? documentSnapshot.data(as: UserChecklistState.self)
            
            if state != nil { // Jetzt ist dies eine gültige Prüfung, da state optional ist
                print("Fetched user checklist state for user: \(userId).")
            } else {
                print("User checklist state document for user \(userId) not found or could not be decoded.")
            }
            return state
        } catch {
            print("Error fetching user checklist state for user \(userId): \(error.localizedDescription)")
            throw error
        }
    }
    
    func saveUserChecklistState(for userId: String, state: UserChecklistState) async throws {
        print("Saving user checklist state for user: \(userId)...")
        do {
            // MARK: - Konsistenz-Check: Collection Name
            // `merge: true` ist wichtig, damit nur das 'completedItems' Feld (oder was auch immer im State-Objekt ist)
            // aktualisiert wird und bestehende Felder im Dokument nicht überschrieben werden.
            // Beachte: Wenn `UserChecklistState` NUR `completedItems` hat, ist `setData(from: state, merge: true)` gut.
            // Wenn es andere Felder hätte, die NICHT überschrieben werden sollen, wäre es besser, nur `completedItems` zu aktualisieren.
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
            // MARK: - Konsistenz-Check: Collection Name
            let userChecklistStateRef = db.collection("user_checklist_states").document(userId)
            
            let fieldToUpdate = "completedItems.\(itemId)" // Punktnotation für Dictionary-Feld
            
            if isCompleted {
                // Wenn true, setzen wir den Wert auf true im Map
                // Dies erstellt das Dokument, falls es nicht existiert, und fügt das Feld hinzu.
                try await userChecklistStateRef.setData([fieldToUpdate: true], merge: true)
            } else {
                // Wenn false, löschen wir das Feld aus dem Map.
                // Das ist der korrekte Weg, ein Feld aus einem Map/Dictionary zu entfernen.
                try await userChecklistStateRef.updateData([fieldToUpdate: FieldValue.delete()])
            }
            print("Successfully updated item \(itemId) completion to \(isCompleted) for user \(userId).")
        } catch {
            print("Error updating checklist item completion: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Anpassung: addChecklistStateSnapshotListener Signatur & Implementierung
    func addChecklistStateSnapshotListener(
        for userId: String,
        categoryId: String?, // Hier ist die `categoryId` (optional)
        completion: @escaping (Result<UserChecklistState?, Error>) -> Void
    ) -> ListenerRegistration {
        // MARK: - Konsistenz-Check: Collection Name
        let docRef = db.collection("user_checklist_states").document(userId)
        
        return docRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Wenn das Dokument existiert, versuchen wir zu dekodieren, sonst liefern wir nil
            do {
                let userState = try documentSnapshot?.data(as: UserChecklistState.self)
                completion(.success(userState))
            } catch {
                completion(.failure(error)) // Dekodierungsfehler
            }
        }
    }
}
