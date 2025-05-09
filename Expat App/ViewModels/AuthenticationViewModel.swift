//
//  AuthenticationViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn // Import für Google
import GoogleSignInSwift // SwiftUI Helper für Google Sign-In

// MARK: - AuthenticationViewModel
// Dieses ViewModel steuert den gesamten Auth-Fluss
// Es interagiert mit Firebase Auth und Firestore (über Services)
@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var selectedStateId: String? = nil // Für Bundesland-Auswahl
    @Published var germanStates: [StateSpecificInfo] = [] // Liste aller Bundesländer
    
    @Published var errorMessage: String? = nil // Für Fehlermeldungen
    @Published var isLoading = false // Für Ladeindikatoren
    
    @Published var currentAuthView: AuthViewType = .login // Startet initial mit Login
    @Published var showStateSelection = false // Steuert Anzeige der Bundesland-Auswahl
    @Published var isAuthenticated = false // Ist der Nutzer angemeldet?
    
    @Published var isAnonymousUser = false
    @Published var successMessage: String? = nil
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        // Startet das Laden der Bundesländer in einem asynchronen Task
        Task {
            await fetchGermanStates()
        }
        // Fügt den Listener hinzu, der auf Änderungen des Anmeldestatus reagiert
        addAuthStateListener()
    }
    
    func addAuthStateListener() {
        // Entfernt zuerst einen potenziell vorhandenen alten Listener
        removeAuthStateListener()
        // Fügt den neuen Listener hinzu
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            // Prüft, ob ein Nutzer angemeldet ist
            Task { @MainActor in
                if let user = user {
                    print("User is signed in with uid: \(user.uid), isAnonymous: \(user.isAnonymous)")
                    // Setzt den Status auf angemeldet
                    self.isAuthenticated = true
                    self.isAnonymousUser = user.isAnonymous
                    self.email = user.email ?? ""
                    self.confirmPassword = ""
                    self.errorMessage = nil
                    self.successMessage = "Willkommen zurück!"
                    
                    if !user.isAnonymous {
                        await self.checkUserProfileCompletion(isNewUserHint: false)
                    } else {
                        self.showStateSelection = false
                    }
                } else {
                    print("User is signed out.")
                    // Setzt den Status auf nicht angemeldet
                    self.isAuthenticated = false
                    self.isAnonymousUser = false
                    self.email = ""
                    self.confirmPassword = ""
                    self.currentAuthView = .login // Zeigt Login-Screen, wenn ausgeloggt
                    self.showStateSelection = false // Reset state selection flag
                    self.errorMessage = nil
                    self.successMessage = nil
                }
                self.isLoading = false
            }
        }
    }
    
    func removeAuthStateListener() {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Auth State Listener removed.")
        }
    }
    
    func fetchGermanStates() async { // Markiert die Funktion als async
        //        guard Auth.auth().currentUser != nil else {
        //            print("fetchGermanStates skipped: No authenticated user.")
        //            self.germanStates = []
        //            return
        //        }
        // Nur weiter machen, wenn Nutzer angemeldet ist
        self.isLoading = true
        self.errorMessage = nil
        print("Fetching German states from Firestore...") // Debug-Ausgabe
        
        do {
            // Greift auf die 'state_specific_info' Sammlung zu
            let querySnapshot = try await db.collection("state_specific_info")
                .order(by: "stateName", descending: false)
                .getDocuments() // Nutzt die async/await Version
            
            // Prüft, ob Dokumente vorhanden sind
            guard !querySnapshot.documents.isEmpty else {
                print("No state documents found.")
                self.errorMessage = "Keine Bundesländer gefunden."
                self.germanStates = []
                self.isLoading = false // Ladezustand zurücksetzen
                return // Beendet, wenn keine Dokumente da sind
            }
            // Versucht, die Dokumente in [StateSpecificInfo] zu dekodieren
            // compactMap ignoriert Dokumente, die nicht dekodiert werden können
            self.germanStates = querySnapshot.documents.compactMap { document -> StateSpecificInfo? in
                do {
                    return try document.data(as: StateSpecificInfo.self)
                } catch {
                    print("Error decoding state document \(document.documentID): \(error.localizedDescription)")
                    // Optional: Fehler sammeln oder spezifischer loggen
                    return nil // Überspringt dieses Dokument bei Fehler
                }
            }
            print("Successfully fetched \(self.germanStates.count) states.")
        } catch {
            print("Error fetching states: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Abrufen der Bundesländer: \(error.localizedDescription)"
            self.germanStates = []
        }
        // Setzt Ladezustand zurück, egal ob Erfolg oder Fehler
        self.isLoading = false
    }
    
    func signInWithEmail() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            // Wichtig: UI Updates müssen auf dem Main Thread passieren
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = self.mapFirebaseError(error) // Verbesserte Fehlermeldung
                }
            }
        }
    }
    
    func signUpWithEmail() {
        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            return
        }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            Task { @MainActor in
                // Der Task { @MainActor in ... } ist sinnvoll, da dieser
                // Completion Handler von Firebase nicht garantiert auf dem Main Thread läuft.
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = self.mapFirebaseError(error)
                    self.isLoading = false
                    return
                }
                print("Sign up successful, creating initial profile...")
                let success = await self.createInitialUserProfile()
                self.isLoading = false
                if success {
                    self.showStateSelection = true
                } else {
                    self.errorMessage = "Fehler beim Erstellen des Nutzerrofils."
                }
            }
        }
    }
    
    // --- Anonyme Anmeldung ---
    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            print("Signed in anonymously with uid: \(authResult.user.uid)")
            // Der AuthStateListener setzt isAuthenticated und isAnonymousUser.
            // Hier nichts weiter zu tun, außer isLoading zurücksetzen.
            // (Passiert automatisch durch @MainActor am Ende der Funktion)
        } catch let error {
            print("Error signing in anonymously: \(error)")
            self.errorMessage = "Fehler bei der anonymen Anmeldung: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // 1. Google ID Token über GoogleSignIn SDK holen
        guard let rootViewController = UIApplication.shared.keyWindowPresentedController else {
            errorMessage = "Google Sign-In UI konnte nicht präsentiert werden."
            isLoading = false
            return
        }
        
        do {
            // Startet den Google Sign-In Flow
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google ID-Token nicht erhalten."])
            }
            
            // 2. Firebase Credential erstellen
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: gidSignInResult.user.accessToken.tokenString)
            
            // 3. Mit Firebase anmelden (oder Nutzer erstellen/verknüpfen)
            let authResult = try await Auth.auth().signIn(with: credential)
            print("Successfully signed in with Google: \(authResult.user.uid)")
            
            // 4. Profil prüfen/vervollständigen (AuthStateListener macht das meiste davon)
            // Hinweis: Der AuthStateListener wird ausgelöst und setzt isAuthenticated etc.
            // Wir müssen hier nicht viel tun, außer isLoading zurücksetzen.
            
        } catch let error {
            print("Error signing in with Google: \(error)")
            // Spezifische Fehler von Google abfangen? GIDSignInErrorCode
            if (error as NSError).domain == kGIDSignInErrorDomain, (error as NSError).code == GIDSignInError.canceled.rawValue {
                print("Google Sign In cancelled by user.")
                // Setze keine Fehlermeldung, da der Nutzer abgebrochen hat
                self.errorMessage = nil
            } else {
                self.errorMessage = "Fehler bei Google-Anmeldung: \(error.localizedDescription)"
            }
        }
        isLoading = false // Wird am Ende sicher auf dem MainActor gesetzt
    }
    
    // Wird nach erfolgreichem Email/Passwort oder Google Login aufgerufen
    private func checkUserProfileCompletion(isNewUserHint: Bool) async {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        
        // Falls es ein neuer User ist (z.B. von Google Sign-In, das erste Mal) oder
        // ein Email/Passwort-Nutzer (wo wir es nicht sicher wissen), prüfen wir das Profil.
        
        isLoading = true // Ladezustand anzeigen während Profilprüfung
        errorMessage = nil
        print("Checking profile completion for user \(userId)...")
        
        do {
            let documentSnapshot = try await db.collection("user_profiles").document(userId).getDocument()
            
            if documentSnapshot.exists {
                // Profil existiert bereits
                print("Profile exists for user \(userId). Checking for homeStateId.")
                let profile = try documentSnapshot.data(as: UserProfile.self) // Annahme: UserProfile ist Codable
                if let homeStateId = profile.homeStateId, !homeStateId.isEmpty {
                    // Profil existiert und Bundesland ist gesetzt
                    print("homeStateId found: \(homeStateId). Profile complete.")
                    self.showStateSelection = false
                    // isAuthenticated wird bereits vom Listener auf true gesetzt sein.
                } else {
                    // Profil existiert, aber Bundesland fehlt noch
                    print("homeStateId missing or empty. Profile incomplete.")
                    self.showStateSelection = true
                }
            } else {
                // Profil existiert NICHT. Das sollte nach einer Registrierung passieren,
                // oder wenn ein Google-Nutzer zum ersten Mal über diese App kommt.
                print("Profile does NOT exist for user \(userId). Creating initial profile...")
                let success = await self.createInitialUserProfile()
                if success {
                    // Initialprofil erstellt, zeige Bundeslandauswahl
                    self.showStateSelection = true
                } else {
                    // Fehler bei Profilerstellung (Fehlermeldung wurde in createInitialUserProfile gesetzt)
                    // Zeige keine Bundeslandauswahl, da etwas schiefgelaufen ist.
                    self.showStateSelection = false
                }
            }
        } catch {
            print("Error checking/decoding profile for user \(userId): \(error)")
            self.errorMessage = "Fehler beim Laden/Prüfen des Profils: \(error.localizedDescription)"
            // Fallback im Fehlerfall: Zeige dem Nutzer sicherheitshalber die Bundeslandauswahl?
            // Oder informiere ihn nur über den Fehler? Hier zeige ich sie an.
            self.showStateSelection = true
        }
        isLoading = false // Ladezustand am Ende zurücksetzen
    }
    
    // Hilfsfunktion zum Erstellen eines initialen Profils nach Registrierung
    private func createInitialUserProfile() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        let profileData: [String: Any] = [
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "homeStateId": "" // Initial leer
            // displayName kann später hinzugefügt werden
        ]
        
        do {
            try await db.collection("user_profiles").document(user.uid).setData(profileData)
            print("Initial user profile created")
            return true
        } catch {
            print("Error creating initial user profile: \(error)")
            self.errorMessage = "Fehler beim Erstellen des Profils. Bitte versuchen Sie es erneut."
            return false
        }
    }
    
    func saveSelectedState() {
        guard let stateId = selectedStateId else {
            errorMessage = "Bitte wähle ein Bundesland aus."
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Nutzer nicht angemeldet."
            return
        }
        isLoading = true
        errorMessage = nil
        // Der Task hier ist sinnvoll, da der Completion Handler von updateData
        // nicht garantiert auf dem Main Thread läuft.
        
        Task {
            do {
                try await db.collection("user_profiles").document(userId).updateData(["homeStateId": stateId])
                self.isAuthenticated = true
                self.showStateSelection = false
            } catch {
                self.errorMessage = "Fehler beim Speichern des Bundeslandes: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    func forgotPassword() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            // Der Task { @MainActor in ... } ist weiterhin sinnvoll für den Completion Handler
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = self.mapFirebaseError(error)
                } else {
                    // Erfolgsmeldung anzeigen (z.B. über einen anderen @Published String)
                    print("Password reset email sent.")
                    // Erfolgsmeldung für den Nutzer setzen
                    self.successMessage = "Eine E-Mail zum Zurücksetzen des Passworts wurde an \(self.email) gesendet. Bitte prüfe dein Postfach (auch den Spam-Ordner)."
                    // Nicht mehr automatisch zur Login-View wechseln, Nutzer soll Meldung bestätigen.
                    // self.currentAuthView = .login
                }
            }
        }
    }
    
    // --- Abmelden & Konto löschen ---
    func signOut() {
        removeAuthStateListener() // Wichtig: Vor dem SignOut entfernen
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            // AuthStateListener wird den Rest erledigen (isAuthenticated=false setzen),
            // nachdem er wieder hinzugefügt wird.
            addAuthStateListener() // Wichtig: Nach dem SignOut wieder hinzufügen
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            Task { @MainActor in
                self.errorMessage = "Fehler beim Ausloggen: \(signOutError.localizedDescription)"
                addAuthStateListener() // Auch im Fehlerfall wieder hinzufügen
            }
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            Task { @MainActor in errorMessage = "Fehler: Kein Nutzer angemeldet." }
            return
        }
        let userId = user.uid
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // 1. Zusätzliche Nutzerdaten löschen (Profil, Checklisten-Status etc.)
            print("Deleting user data from Firestore for userId: \(userId)")
            try await db.collection("user_profiles").document(userId).delete()
            print("User profile deleted.")
            
            let checklistStateRef = db.collection("checklist_states").document(userId)
            // Sicher prüfen, ob das Dokument existiert, bevor delete aufgerufen wird
            let checklistDoc = try? await checklistStateRef.getDocument()
            if checklistDoc?.exists == true {
                try await checklistStateRef.delete()
                print("User checklist state deleted.")
            } else {
                print("No checklist state found for user \(userId) to delete.")
            }
            
            // 2. Firebase Auth Nutzer löschen
            print("Deleting Firebase Auth user...")
            try await user.delete()
            print("Firebase Auth user deleted successfully.")
            // AuthStateListener wird automatisch auslösen und isAuthenticated auf false setzen.
            
        } catch {
            print("Error deleting user or associated data: \(error)")
            let finalErrorMessage: String
            if let authError = error as NSError?, authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                finalErrorMessage = "Sitzung abgelaufen. Bitte melde dich erneut an, um dein Konto zu löschen."
            } else {
                finalErrorMessage = "Fehler beim Löschen des Kontos: \(error.localizedDescription)"
            }
            Task { @MainActor in self.errorMessage = finalErrorMessage }
        }
        Task { @MainActor in isLoading = false }
    }
    
    // MARK: - Fehlermapping (Korrigiert)
    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError // Umwandlung in NSError für den Zugriff auf 'code'
        
        // Versuche, einen AuthErrorCode direkt aus dem NSError-Code zu initialisieren
        if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            // Switch direkt auf die AuthErrorCode-Instanz
            switch authErrorCode {
            case .invalidEmail:
                return "Das E-Mail-Format ist ungültig."
            case .emailAlreadyInUse:
                return "Diese E-Mail-Adresse wird bereits verwendet."
            case .weakPassword:
                return "Das Passwort ist zu schwach. Es muss mindestens 6 Zeichen lang sein."
            case .wrongPassword:
                return "Das eingegebene Passwort ist falsch."
            case .userNotFound:
                return "Es wurde kein Konto mit dieser E-Mail-Adresse gefunden."
            case .userDisabled:
                return "Dieses Benutzerkonto wurde deaktiviert."
            case .networkError:
                return "Netzwerkfehler. Bitte überprüfe deine Internetverbindung."
            case .requiresRecentLogin:
                return "Diese Aktion erfordert eine kürzliche Anmeldung. Bitte logge dich erneut ein."
            case .tooManyRequests:
                return "Zu viele Anfragen. Bitte versuche es später erneut."
                // Füge hier weitere spezifische 'case' ein, falls benötigt...
                
                // TODO: Bei Update des Firebase SDK prüfen, ob neue AuthErrorCode-Fälle hinzugekommen sind.
            default:
                // Dieser Block fängt alle anderen AuthErrorCodes ab.
                // '@unknown' ist wichtig, damit Xcode warnt, wenn Firebase neue Fehlercodes hinzufügt.
                print("Unhandled Firebase Auth Error Code: \(authErrorCode.rawValue)") // Hilfreich für Debugging
                return "Ein unerwarteter Authentifizierungsfehler ist aufgetreten (Code: \(authErrorCode.rawValue))."
                // Ende des default-Blocks
            }
        }
        // Fallback, wenn der Fehler kein AuthErrorCode ist oder die Konvertierung fehlschlägt
        return nsError.localizedDescription // Gibt die Standard-Fehlerbeschreibung zurück
    }
    // Neue Funktion, um von Anonym zu Registrierung zu wechseln
    func switchToRegistrationFromAnonymous() {
        print("Switching to Registration from Anonymous state...")
        // Zuerst den anonymen Nutzer abmelden
        removeAuthStateListener() // Listener kurz entfernen, um Konflikte zu vermeiden
        do {
            try Auth.auth().signOut()
            print("Anonymous user signed out for registration.")
            self.isAuthenticated = false
            self.isAnonymousUser = false
            self.email = ""
            self.password = ""
            self.confirmPassword = ""
            self.currentAuthView = .registration
            addAuthStateListener()
        } catch let signOutError {
            print("Error signing out anonymous user before registration: \(signOutError)")
            Task { @MainActor in
                self.errorMessage = "Fehler beim Wechsel zur Registrierung: \(signOutError.localizedDescription)"
            }
            addAuthStateListener()
        }
    }
}
