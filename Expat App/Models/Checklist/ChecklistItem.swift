//
//  ChecklistItem.swift
//  Expat App
//
//  Created by Dominik Baki on 28.04.25.
//

import Foundation
import FirebaseFirestore

struct ChecklistItem: Codable, Identifiable {
    @DocumentID var id: String?
    
    let categoryId: String // // ID der übergeordneten Checkliste
    let text: String // Text der Aufgabe
    let details: String? // Optionale Details
    let isDoneDefault: Bool?
    let order: Int // Reihenfolge für die Anzeige
    
    // Hinweis für die Implementierung:
    // Der tatsächliche 'isDone'-Status für die UI wird im ChecklistViewModel
    // verwaltet. Dieser Status wird entweder aus 'user_checklist_states' (wenn Nutzer eingeloggt)
    // oder aus UserDefaults (wenn offline/nicht eingeloggt) geladen und gespeichert.
    
    // Keine CodingKeys notwendig, da die Swift-Property-Namen den Firestore-Feldnamen entsprechen.
}
