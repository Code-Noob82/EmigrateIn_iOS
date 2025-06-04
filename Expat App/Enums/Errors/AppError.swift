//
//  AppError.swift
//  Expat App
//
//  Created by Dominik Baki on 04.06.25.
//

import Foundation
import FirebaseAuth

// MARK: - Global App Error Definition
enum AppError: Error, LocalizedError, Identifiable {
    case networkConnection
    case accountDeletionFailed(originalError: Error)
    case displayNameUpdateFailed(originalError: Error)
    case stateSelectionSaveFailed(originalError: Error)
    case generalLoginFailed(originalError: Error)
    case generalSignUpFailed(originalError: Error)
    case passwordResetFailed(originalError: Error)
    case fetchStatesFailed(originalError: Error)
    case fetchProfileFailed(originalError: Error)
    case fetchStateDetailsFailed(originalError: Error)
    case anonymousSignInFailed(originalError: Error)
    case googleSignInFailed(originalError: Error, isCancelled: Bool = false)
    case createInitialProfileFailed(originalError: Error)
    case reauthenticationFailed(originalError: Error)
    case signOutFailed(originalError: Error)
    case generalError(message: String) // Für nicht-spezifische Fehler, die dennoch angezeigt werden sollen
    case unknownError(originalError: Error? = nil)

    var id: String {
        // Eindeutige ID für jeden Fehlerfall
        switch self {
        case .networkConnection: return "networkConnection"
        case .accountDeletionFailed: return "accountDeletionFailed"
        case .displayNameUpdateFailed: return "displayNameUpdateFailed"
        case .stateSelectionSaveFailed: return "stateSelectionSaveFailed"
        case .generalLoginFailed: return "generalLoginFailed"
        case .generalSignUpFailed: return "generalSignUpFailed"
        case .passwordResetFailed: return "passwordResetFailed"
        case .fetchStatesFailed: return "fetchStatesFailed"
        case .fetchProfileFailed: return "fetchProfileFailed"
        case .fetchStateDetailsFailed: return "fetchStateDetailsFailed"
        case .anonymousSignInFailed: return "anonymousSignInFailed"
        case .googleSignInFailed: return "googleSignInFailed"
        case .createInitialProfileFailed: return "createInitialProfileFailed"
        case .reauthenticationFailed: return "reauthenticationFailed"
        case .signOutFailed: return "signOutFailed"
        case .generalError(let message): return "generalError_\(message.hash)"
        case .unknownError: return "unknownError"
        }
    }

    var errorTitle: String {
        switch self {
        case .networkConnection: return "Verbindungsfehler"
        case .accountDeletionFailed: return "Fehler beim Löschen"
        case .displayNameUpdateFailed: return "Namensänderung fehlgeschlagen"
        case .stateSelectionSaveFailed: return "Speichern fehlgeschlagen"
        case .generalLoginFailed: return "Anmeldefehler"
        case .generalSignUpFailed: return "Registrierungsfehler"
        case .passwordResetFailed: return "Passwort zurücksetzen"
        case .fetchStatesFailed: return "Laden der Bundesländer"
        case .fetchProfileFailed: return "Laden des Profils"
        case .fetchStateDetailsFailed: return "Laden der Details"
        case .anonymousSignInFailed: return "Anonyme Anmeldung"
        case .googleSignInFailed: return "Google Anmeldung"
        case .createInitialProfileFailed: return "Profil erstellen"
        case .reauthenticationFailed: return "Erneute Authentifizierung"
        case .signOutFailed: return "Abmeldefehler"
        case .generalError: return "Hinweis"
        case .unknownError: return "Unerwarteter Fehler"
        }
    }

    var errorDescription: String? { // Entspricht LocalizedError.errorDescription
        switch self {
        case .networkConnection:
            return "Bitte überprüfe deine Internetverbindung und versuche es erneut."
        case .googleSignInFailed(_, let isCancelled):
            if isCancelled { return "Die Google-Anmeldung wurde abgebrochen." }
            return _mapFirebaseErrorToString(self) // originalError ist Teil des Enums
        case .accountDeletionFailed(let originalError),
             .displayNameUpdateFailed(let originalError),
             .stateSelectionSaveFailed(let originalError),
             .generalLoginFailed(let originalError),
             .generalSignUpFailed(let originalError),
             .passwordResetFailed(let originalError),
             .fetchStatesFailed(let originalError),
             .fetchProfileFailed(let originalError),
             .fetchStateDetailsFailed(let originalError),
             .anonymousSignInFailed(let originalError),
             .createInitialProfileFailed(let originalError),
             .reauthenticationFailed(let originalError),
             .signOutFailed(let originalError):
            return _mapFirebaseErrorToString(originalError)
        case .generalError(let message):
            return message
        case .unknownError(let originalError):
            if let originalError = originalError {
                return "Ein unerwarteter Fehler ist aufgetreten: \(_mapFirebaseErrorToString(originalError))"
            }
            return "Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es später erneut."
        }
    }
    
    // Interne Hilfsfunktion zum Mappen von Firebase-Fehlern.
    // Nimmt jetzt direkt einen Error entgegen.
    private func _mapFirebaseErrorToString(_ error: Error) -> String {
        let nsError = error as NSError
        if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            switch authErrorCode {
            case .invalidEmail: return "Das E-Mail-Format ist ungültig."
            case .emailAlreadyInUse: return "Diese E-Mail-Adresse wird bereits verwendet."
            case .weakPassword: return "Das Passwort ist zu schwach (mind. 6 Zeichen)."
            case .wrongPassword: return "Das eingegebene Passwort ist falsch."
            case .userNotFound: return "Kein Konto mit dieser E-Mail gefunden."
            case .userDisabled: return "Dieses Benutzerkonto wurde deaktiviert."
            case .networkError: return "Netzwerkfehler. Bitte überprüfe deine Internetverbindung."
            case .requiresRecentLogin: return "Diese Aktion erfordert eine kürzliche Anmeldung. Bitte logge dich erneut ein und versuche es direkt."
            case .tooManyRequests: return "Zu viele Anfragen. Bitte versuche es später erneut."
            case .userMismatch: return "Die Anmeldeinformationen stimmen nicht mit dem angemeldeten Benutzer überein."
            // Fügen Sie hier weitere spezifische AuthErrorCode-Fälle hinzu, falls nötig
            default:
                // Gibt detailliertere Informationen für ungemappte Auth-Fehler
                return "Ein Authentifizierungsfehler ist aufgetreten (Code: \(authErrorCode.rawValue)). Details: \(nsError.localizedDescription)"
            }
        }
        // Fallback für Fehler, die nicht direkt von AuthErrorCode kommen (z.B. Firestore Fehler)
        return nsError.localizedDescription
    }
}
