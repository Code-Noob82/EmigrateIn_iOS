//
//  Ebassy.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

// MARK: - Data Models für Auswärtiges Amt API

// 1. Top-Level-Struktur der API-Antwort
struct EmbassyDataWrapper: Codable {
    let response: EmbassyResponseData
}

// 2. Inhalt des "response"-Objekts
struct EmbassyResponseData: Codable {
    let lastModified: Int
    let countryGroups: [String: EmbassyCountryGroup]
    
    private enum StaticCodingKeys: String, CodingKey {
        case lastModified
    }
    
    private struct DynamicCountryCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    init(from decoder: Decoder) throws {
        let staticContainer = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.lastModified = try staticContainer.decode(Int.self, forKey: .lastModified)
        
        let dynamicContainer = try decoder.container(keyedBy: DynamicCountryCodingKey.self)
        var groups = [String: EmbassyCountryGroup]()
        for key in dynamicContainer.allKeys {
            if key.stringValue != "lastModified" && key.stringValue != "contentList" {
                if let countryKey = DynamicCountryCodingKey(stringValue: key.stringValue) {
                    let countryGroup = try dynamicContainer.decode(EmbassyCountryGroup.self, forKey: countryKey)
                    groups[key.stringValue] = countryGroup
                }
            }
        }
        self.countryGroups = groups
    }
}

// 3. Struktur für eine Ländergruppe (z.B. Zypern mit ID "210268")
struct EmbassyCountryGroup: Codable {
    let lastModified: Int
    let country: String
    let representatives: [String: EmbassyRepresentativeInfo]
    let contentList: [String]
    
    private enum StaticCodingKeys: String, CodingKey {
        case lastModified, country, contentList
    }
    
    private struct DynamicRepresentativeCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    init(from decoder: Decoder) throws {
        let staticContainer = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.lastModified = try staticContainer.decode(Int.self, forKey: .lastModified)
        self.country = try staticContainer.decode(String.self, forKey: .country)
        self.contentList = try staticContainer.decode([String].self, forKey: .contentList)
        
        let dynamicContainer = try decoder.container(keyedBy: DynamicRepresentativeCodingKeys.self)
        var reps = [String: EmbassyRepresentativeInfo]()
        for key in dynamicContainer.allKeys {
            if key.stringValue != "lastModified" && key.stringValue != "country" && key.stringValue != "contentList" {
                if let representativesKey = DynamicRepresentativeCodingKeys(stringValue: key.stringValue) {
                    let representativeInfo = try dynamicContainer.decode(EmbassyRepresentativeInfo.self, forKey: representativesKey)
                    reps[key.stringValue] = representativeInfo
                }
            }
        }
        self.representatives = reps
    }
}

// 4. Struktur für die Details einer einzelnen Vertretung
struct EmbassyRepresentativeInfo: Codable, Hashable {
    let lastModified: Int
    let description: String?
    let leader: String?
    let city: String?
    let country: String?
    let address: String?
    let phone: String?
    let email: String?
    let website: [String?]
    let open: String?
    let remark: String?
    let emergencyPhone: String?
    let contact: String?
    let misc: String?
    let departments: String?
    let locales: String?
    let fax: String?
    let postal: String?
    let county: String?
    
    enum CodingKeys: String, CodingKey {
        case lastModified, description, leader, city, country, address, phone, website, open, remark, emergencyPhone, contact, misc, departments, locales, fax, postal, county
        case email = "mail"
    }
}
