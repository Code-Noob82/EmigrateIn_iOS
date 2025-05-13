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
    // Ruft eine Liste aller eindeutigen Ländernamen von der API ab.
    func fetchAllCountryNames() async throws -> [String]
    // Ruft eine Liste aller Vertretungen (Botschaften, Konsulate etc.) für ein bestimmtes Land ab.
    func fetchAllRepresentationsInCountry(countryName: String) async throws -> [Embassy]
}
