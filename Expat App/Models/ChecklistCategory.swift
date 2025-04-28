//
//  ChecklistCategory.swift
//  Expat App
//
//  Created by Dominik Baki on 28.04.25.
//

import Foundation
import FirebaseFirestore

struct ChecklistCategory: Codable, Identifiable {
    @DocumentID var id: String?
    
    let title: String
    let description: String?
    let order: Int
    
    // Keine CodingKeys notwendig, da die Swift-Property-Namen den Firestore-Feldnamen entsprechen.
}
