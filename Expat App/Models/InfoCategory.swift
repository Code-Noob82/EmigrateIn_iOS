//
//  InfoCategory.swift
//  Expat App
//
//  Created by Dominik Baki on 24.04.25.
//

import Foundation
import FirebaseFirestore // Enthält Codable-Support & @DocumentID via SPM - gilt für alle Models

struct InfoCategory: Codable, Identifiable {
    @DocumentID var id: String? // Mappt die Firestore Document-ID (z.B. prep_de) automatisch
    
    let title: String
    let subtitle: String? // Optional, falls bei weiterer Entwicklung in Firestore kein "subtitle" existiert.
    let iconName: String? // Swift-Code Image(systemName: category.iconName ?? "placeholder.icon")
    let order: Int
}
