//
//  StateSpecificInfo.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import Foundation
import FirebaseFirestore // Für Firestore-Daten (Bundesländer)

struct StateSpecificInfo: Codable, Identifiable, Hashable { // Hashable für Picker
    @DocumentID var id: String? // Bundesland-Kürzel z.B. "BW"
    
    let stateName: String
    let apostilleInfo: String?
    let apostilleAuthorities: [ApostilleAuthority]?
    let order: Int?
}

struct ApostilleAuthority: Codable, Hashable, Identifiable { // Identifiable für ForEach (optional)
    let id = UUID() // <--- Jede Instanz bekommt eine neue, eindeutige ID
    let name: String
    let link: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, link // 'id' wird nicht aus Firestore gelesen, sondern wird mit eindeutiger ID gespeichert.
    }
}
