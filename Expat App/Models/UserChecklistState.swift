//
//  UserChecklistState.swift
//  Expat App
//
//  Created by Dominik Baki on 28.04.25.
//

import Foundation
import FirebaseFirestore

// Repräsentiert den Zustand *aller* Checklisten *eines* Nutzers.
struct UserChecklistState: Codable {
    // Die DocumentID (UserID) wird oft nicht direkt im Model gebraucht,
    // da das Dokument gezielt über die bekannte UserID geladen wird.
    let completedItems: [String: Bool]? // Dictionary [ChecklistItem.id : isDone(immer true)]
}
