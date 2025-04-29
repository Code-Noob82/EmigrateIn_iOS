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
    // Andere Felder wie apostilleInfo etc. werden hier nicht direkt benötigt
}
