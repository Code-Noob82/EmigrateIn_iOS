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
    
    let categoryId: String
    let text: String
    let details: String?
    let order: Int
    
    // Das Feld 'isDoneDefault' aus Firestore wird hier nicht unbedingt benötigt,
    // da der tatsächliche Erledigt-Status pro Nutzer verwaltet wird.
}
