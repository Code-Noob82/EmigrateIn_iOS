//
//  Embassy.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

// MARK: - Vereinfachtes Embassy Model (Zielstruktur)
struct Embassy: Codable, Identifiable, Hashable {
    let id: String // Eindeutige ID der Vertretung (z.B. "210272")
    let type: String? // z.B. "Botschaft der Bundesrepublik Deutschland"
    let countryName: String? // Land, in dem sich die Vertretung befindet
    let city: String?
    let address: String?
    let phone: String?
    let email: String?
    let url: String? // Erste Webseite aus dem Array
    let openingHours: String?
    let remark: String?
}
