//
//  InfoContent.swift
//  Expat App
//
//  Created by Dominik Baki on 24.04.25.
//

import Foundation
import FirebaseFirestore

struct InfoContent: Codable, Identifiable {
    @DocumentID var id: String?
    
    let categoryId: String
    let title: String
    let content: String
    let officialLink: String?
    let lastVerified: Timestamp // Bezieht den Zeitstempel aus der jeweiligen Document-ID (z.B. 24. April 2025 um 00:00:00 UTC+2)
    let order: Int
    
    // Keine CodingKeys notwendig, da die Swift-Property-Namen den Firestore-Feldnamen entsprechen.
}
