//
//  UserProfile.swift
//  Expat App
//
//  Created by Dominik Baki on 28.04.25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String? // Mappt die UserID automatisch auf die 'id'-Variable
    
    let displayName: String?
    let email: String
    let homeStateId: String?  // ID des Bundeslandes für Personalisierung
    let createdAt: Timestamp?
}
