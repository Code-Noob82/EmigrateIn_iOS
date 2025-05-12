//
//  EmbassyRepositoryProtocol.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

// MARK: - Embassy Repository
protocol EmbassyRepositoryProtocol {
    // Gibt die Hauptbotschaft für einen bestimmten Ländercode zurück (z.B. "CY" für Zypern)
    // Der countryCode hier bezieht sich auf das Land, für das wir die Vertretung suchen (z.B. Zypern)
    func fetchGermanEmbassy(forCountryName targetCountryName: String) async throws -> Embassy?
}
