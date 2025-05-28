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
    
    // NEU: Funktionen für Checklist-Kategorien
    func fetchChecklistCategories() async throws -> [ChecklistCategory]
    func fetchChecklistItems(for categoryId: String) async throws -> [ChecklistItem]
    
    func fetchChecklistCategory(by id: String) async throws -> ChecklistCategory?
    
    // NEU: Funktionen für den User-Checklist-Status
    func fetchUserChecklistState(for userId: String) async throws -> UserChecklistState?
    func saveUserChecklistState(for userId: String, state: UserChecklistState) async throws
    func updateChecklistItemCompletion(userId: String, itemId: String, isCompleted: Bool) async throws
    // NEU HINZUGEFÜGT: Funktion zum Hinzufügen eines Snapshot Listeners
    func addChecklistStateSnapshotListener(
        for userId: String,
        categoryId: String?,
        completion: @escaping (Result<UserChecklistState?, Error>) -> Void
    ) -> ListenerRegistration // Gibt ListenerRegistration zurück
}
