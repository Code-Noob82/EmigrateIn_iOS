//
//  ApiError.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

// MARK: - API Error Enum
enum ApiError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error) // Für internes Logging
    case networkError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ein technisches Problem ist aufgetreten. Die App konnte die benötigten Informationen nicht korrekt anfordern. Bitte versuchen Sie es später erneut."
            
        case .invalidResponse:
            return "Die Antwort des Servers war unerwartet oder fehlerhaft. Bitte versuchen Sie es später erneut."
            
        case .decodingError:
            return "Die empfangenen Informationen konnten nicht verarbeitet werden, da sie ein unerwartetes Format haben. Bitte versuchen Sie es später erneut."
            
        case .networkError:
            return "Es konnte keine Verbindung hergestellt werden. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut. Möglicherweise ist der Server auch vorübergehend nicht erreichbar."
            
        case .noData:
            return "Für Ihre Anfrage konnten keine Informationen gefunden oder geladen werden. Bitte versuchen Sie es später noch einmal."
        }
    }
    
    // Dies wird vom System verwendet, wenn der Fehler z.B. in einem UIAlertController angezeigt wird.
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Bitte überprüfen Sie Ihre WLAN- oder Mobilfunkverbindung und stellen Sie sicher, dass der Flugmodus deaktiviert ist."
        case .invalidURL, .invalidResponse, .decodingError, .noData:
            return "Bitte versuchen Sie die Aktion später erneut. Sollte das Problem weiterhin bestehen, kontaktieren Sie bitte den Support."
        }
    }
}
