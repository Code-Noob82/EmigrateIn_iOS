//
//  EmbassyRepository.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

class EmbassyRepository: EmbassyRepositoryProtocol {
    private let apiURL = "https://www.auswaertiges-amt.de/opendata/representativesInCountry"
    
    func fetchGermanEmbassy(forCountryName targetCountryName: String) async throws -> Embassy? {
        print("EmbassyRepository: Fetching embassy for country name '\(targetCountryName)' from \(apiURL)...")
        
        guard let url = URL(string: apiURL) else {
            throw ApiError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("EmbassyRepository: Invalid HTTP response: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                throw ApiError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiWrapper = try decoder.decode(EmbassyDataWrapper.self, from: data)
            
            // Durchsucht alle Ländergruppen in der Antwort
            for (_, countryGroup) in apiWrapper.response.countryGroups {
                // Prüft, ob der Ländername der Gruppe mit unserem Ziel übereinstimmt
                // (Groß-/Kleinschreibung ignorieren und auf Teilübereinstimmung prüfen)
                if countryGroup.country.lowercased().contains(targetCountryName.lowercased()) {
                    // Durchsucht die Vertretungen in dieser Ländergruppe
                    for (representativeID, representativeInfo) in countryGroup.representatives {
                        // Sucht nach dem Typ "Botschaft"
                        if let typeDescription = representativeInfo.description,
                           typeDescription.lowercased().contains("botschaft") || typeDescription.lowercased().contains("embassy") {
                            
                            // Botschaft gefunden, erstellt und gibt das Embassy-Objekt zurück
                            let embassy = Embassy(
                                id: representativeID, // Die ID ist der Schlüssel des Dictionary-Eintrags
                                type: representativeInfo.description,
                                countryName: representativeInfo.country, // Das Land, in dem die Botschaft ist
                                city: representativeInfo.city,
                                address: representativeInfo.address,
                                phone: representativeInfo.phone,
                                email: representativeInfo.email, // Gemappt von "mail"
                                url: representativeInfo.website?.first.flatMap { $0 }, // Nimmt die erste URL aus dem Array
                                openingHours: representativeInfo.open,
                                remark: representativeInfo.remark
                            )
                            print("EmbassyRepository: Found embassy for '\(targetCountryName)': \(embassy.type ?? "N/A") in \(embassy.city ?? "N/A") (ID: \(embassy.id))")
                            return embassy
                        }
                    }
                }
            }
            
            print("EmbassyRepository: No 'Botschaft' found for '\(targetCountryName)' in API response.")
            return nil // Keine passende Botschaft gefunden
            
        } catch let decodingError as DecodingError {
            // Detaillierte Ausgabe des Decoding-Fehlers
            print("EmbassyRepository: Decoding Error --------------------")
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("Key not found: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError.localizedDescription)")
            }
            print("----------------------------------------------------")
            throw ApiError.decodingError(decodingError)
        } catch {
            print("EmbassyRepository: Network or other error - \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
    
    func fetchAllRepresentationsInCountry(countryName: String) async throws -> [Embassy] {
        print("EmbassyRepository: Fetching ALL representations for country name: '\(countryName)' from \(apiURL)...")
        
        guard let url = URL(string: apiURL) else {
            throw ApiError.invalidURL
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("EmbassyRepository: Invalid HTTP response for all representations: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                throw ApiError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiWrapper = try decoder.decode(EmbassyDataWrapper.self, from: data)
            
            var foundRepresentations: [Embassy] = []
            
            for (_, countryGroup) in apiWrapper.response.countryGroups {
                if countryGroup.country.lowercased().contains(countryName.lowercased()) {
                    for (representativeID, representativeInfo) in countryGroup.representatives {
                        let representation = Embassy(
                            id: representativeID,
                            type: representativeInfo.description,
                            countryName: representativeInfo.country,
                            city: representativeInfo.city,
                            address: representativeInfo.address,
                            phone: representativeInfo.phone,
                            email: representativeInfo.email,
                            url: representativeInfo.website?.first?.flatMap { $0 },
                            openingHours: representativeInfo.open,
                            remark: representativeInfo.remark
                            
                            
                        )
                        foundRepresentations.append(representation)
                    }
                    if !foundRepresentations.isEmpty {
                        print("EmbassyRepository: Found \(foundRepresentations.count) representations for \'(countryName)' in group '\(countryGroup.country)'.")
                        return foundRepresentations.sorted { ($0.city ?? "").lowercased() < ($1.city ?? "").lowercased() }
                    }
                }
            }
            print("EmbassyRepository: No country group matching '\(countryName)' found for all representations, or it had no representatives.")
            return []
        } catch let decodingError as DecodingError {
            // Detaillierte Ausgabe des Decoding-Fehlers
            print("EmbassyRepository: Decoding Error --------------------")
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("Key not found: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError.localizedDescription)")
            }
            print("----------------------------------------------------")
            throw ApiError.decodingError(decodingError)
        } catch {
            print("EmbassyRepository: Network or other fetching all representations - \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
    
    func fetchAllCountryNames() async throws -> [String] {
        print("EmbassyRepository: Fetching all country names from \(apiURL)...")
        guard let url = URL(string: apiURL) else {
            throw ApiError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("EmbassyRepository: Invalid HTTP response for country names: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                throw ApiError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiWrapper = try decoder.decode(EmbassyDataWrapper.self, from: data)
            
            // Extrahiert die Ländernamen, entfernt Duplikate und sortiert sie.
            // Die API-Struktur ist apiWrapper.response.countryGroups (ein Dictionary),
            // wobei jeder Wert ein EmbassyCountryGroup-Objekt mit einer 'country'-Eigenschaft ist.
            let countryNames = Array(Set(apiWrapper.response.countryGroups.values.map { $0.country })).sorted()
            
            print("EmbassyRepository: Found \(countryNames.count) unique country names.")
            if countryNames.isEmpty {
                print("EmbassyRepository: Warning - no country names extracted from API response.")
            }
            return countryNames
            
        } catch let decodingError as DecodingError {
            print("EmbassyRepository: Decoding Error while fetching country names --------------------")
            // Hier könntest du dieselbe detaillierte Fehlerbehandlung wie in fetchGermanEmbassy einfügen
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("Key not found: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError.localizedDescription)")
            }
            print("---------------------------------------------------------------------------")
            throw ApiError.decodingError(decodingError)
        } catch {
            print("EmbassyRepository: Network or other error fetching country names - \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
}
