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
    
    // @Published var errorMessage: String? = nil // ERSETZT durch activeError für kritische Fehler
    @Published var inlineMessage: String? = nil // Für Fehlermeldungen
    
    @Published var isLoading = false // Für Ladeindikatoren
    
    @Published var currentAuthView: AuthViewType = .login // Startet initial mit Login
    @Published var showStateSelection = false // Steuert Anzeige der Bundesland-Auswahl
    @Published var isAuthenticated = false // Ist der Nutzer angemeldet?
    
    @Published var isAnonymousUser = false
    @Published var successMessage: String? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var selectedStateDetails: StateSpecificInfo? = nil // NEU: Für die geladenen Details des Bundeslandes
    @Published var isLoadingStateDetails: Bool = false // NEU: Ladezustand für diese spezifische Aktion
    
    @Published var selectedTab: TabSelection = .home
    
    // NEU: Für die Re-Authentifizierungs-UI (z.B. Alert mit Passwortfeld)
    @Published var showPasswordReauthPrompt = false
    @Published var reauthPasswordInput = "" // Gebunden an das Passwortfeld im Alert/Sheet
    
    // NEU: Ein zentraler State für anzuzeigende Fehler
    @Published var activeError: AppError? = nil
    
    // Eine homeStateName Computed Property
    var homeStateName: String? {
        guard let currentProfile = self.userProfile,
              let homeStateId = currentProfile.homeStateId,
              !homeStateId.isEmpty else {
            return nil
        }
        return germanStates.first(where: { $0.id == homeStateId })?.stateName
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
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
                self.activeError = nil
                if let user = user {
                    print("User is signed in with uid: \(user.uid), isAnonymous: \(user.isAnonymous)")
                    // Setzt den Status auf angemeldet
                    self.isAuthenticated = true
                    self.isAnonymousUser = user.isAnonymous
                    self.email = user.email ?? ""
                    self.confirmPassword = ""
                    self.inlineMessage = nil
                    self.successMessage = nil
                    
                    if !user.isAnonymous {
                        await self.fetchGermanStates()
                        await self.checkUserProfileCompletion(isNewUserHint: false)
                        if self.userProfile?.homeStateId != nil {
                            await self.fetchSelectedStateDetails()
                        }
                    } else {
                        self.germanStates = []
                        self.showStateSelection = false
                    }
                } else {
                    print("User is signed out.")
                    // Setzt den Status auf nicht angemeldet
                    self.isAuthenticated = false
                    self.isAnonymousUser = false
                    self.email = ""
                    self.confirmPassword = ""
                    self.userProfile = nil
                    self.currentAuthView = .login // Zeigt Login-Screen, wenn ausgeloggt
                    self.showStateSelection = false // Reset state selection flag
                    self.germanStates = []
                    self.inlineMessage = nil
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
        guard Auth.auth().currentUser != nil else {
            print("fetchGermanStates: Überspringen, da kein User angemeldet ist.")
            self.germanStates = []
            return
        }
        self.isLoading = true
        self.inlineMessage = nil
        print("Fetching German states from Firestore...") // Debug-Ausgabe
        
        do {
            // Greift auf die 'state_specific_info' Sammlung zu
            let querySnapshot = try await db.collection("state_specific_info")
                .order(by: "stateName", descending: false)
                .getDocuments() // Nutzt die async/await Version
            
            // Prüft, ob Dokumente vorhanden sind
            guard !querySnapshot.documents.isEmpty else {
                print("No state documents found.")
                self.activeError = .generalError(message: "Keine Bundesländer gefunden.")
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
                    self.activeError = .fetchStatesFailed(originalError: error)
                    return nil // Überspringt dieses Dokument bei Fehler
                }
            }
            print("Successfully fetched \(self.germanStates.count) states.")
        } catch {
            print("Error fetching states: \(error.localizedDescription)")
            self.activeError = .fetchStatesFailed(originalError: error)
            self.germanStates = []
        }
        // Setzt Ladezustand zurück, egal ob Erfolg oder Fehler
        self.isLoading = false
    }
    
    func signInWithEmail() {
        isLoading = true
        inlineMessage = nil
        successMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            // Wichtig: UI Updates müssen auf dem Main Thread passieren
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.activeError = .generalLoginFailed(originalError: error)
                }
            }
        }
    }
    
    func signUpWithEmail() {
        guard password == confirmPassword else {
            self.activeError = .generalError(message:"Passwörter stimmen nicht überein.")
            return
        }
        isLoading = true
        activeError = nil
        successMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.activeError = .generalSignUpFailed(originalError: error)
                    self.isLoading = false
                    return
                }
                print("Sign up successful, creating initial profile...")
                let success = await self.createInitialUserProfile()
                self.isLoading = false
                if success {
                    self.showStateSelection = true
                } else {
                    self.inlineMessage = "Fehler beim Erstellen des Nutzerrofils."
                }
            }
        }
    }
    
    // --- Anonyme Anmeldung ---
    func signInAnonymously() async {
        isLoading = true
        activeError = nil
        successMessage = nil
        
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            print("Signed in anonymously with uid: \(authResult.user.uid)")
            // Der AuthStateListener setzt isAuthenticated und isAnonymousUser.
            // Hier nichts weiter zu tun, außer isLoading zurücksetzen.
            // (Passiert automatisch durch @MainActor am Ende der Funktion)
        } catch let error {
            print("Error signing in anonymously: \(error)")
            self.activeError = .anonymousSignInFailed(originalError: error)
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        activeError = nil
        successMessage = nil
        
        // 1. Google ID Token über GoogleSignIn SDK holen
        guard let rootViewController = UIApplication.shared.keyWindowPresentedController else {
            self.activeError = .generalError(message: "Google Sign-In UI konnte nicht präsentiert werden.")
            isLoading = false
            return
        }
        
        do {
            // Startet den Google Sign-In Flow
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                throw AppError.googleSignInFailed(originalError: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google ID-Token nicht erhalten."]))
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
            let nsError = error as NSError
            if nsError.domain == kGIDSignInErrorDomain && nsError.code == GIDSignInError.canceled.rawValue {
                print("Google Sign In cancelled by user.")
                // Setze keine Fehlermeldung, da der Nutzer abgebrochen hat
                self.inlineMessage = nil
            } else {
                self.activeError = .googleSignInFailed(originalError: error, isCancelled: false)
            }
        }
        isLoading = false // Wird am Ende sicher auf dem MainActor gesetzt
    }
    
    // Wird nach erfolgreichem Email/Passwort oder Google Login aufgerufen
    private func checkUserProfileCompletion(isNewUserHint: Bool) async {
        guard let user = Auth.auth().currentUser else {
            self.userProfile = nil
            return
        }
        let userId = user.uid
        
        // Falls es ein neuer User ist (z.B. von Google Sign-In, das erste Mal) oder
        // ein Email/Passwort-Nutzer (wo wir es nicht sicher wissen), prüfen wir das Profil.
        
        isLoading = true // Ladezustand anzeigen während Profilprüfung
        inlineMessage = nil
        print("Checking profile completion for user \(userId)...")
        
        do {
            let documentSnapshot = try await db.collection("user_profiles").document(userId).getDocument()
            if documentSnapshot.exists {
                // Profil existiert bereits
                print("Profile exists for user \(userId). Checking for homeStateId.")
                let profile = try documentSnapshot.data(as: UserProfile.self) // Annahme: UserProfile ist Codable
                print("DEBUG checkUserProfileCompletion: Successfully decoded profile: \(profile)") // Debug-Log hinzugefügt
                self.userProfile = profile
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
                self.userProfile = nil
                let success = await self.createInitialUserProfile()
                if success {
                    print("DEBUG checkUserProfileCompletion: Initial profile created. Setting showStateSelection = true.") // Debug-Log hinzugefügt
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
            self.userProfile = nil
            self.activeError = .fetchProfileFailed(originalError: error)
            // Fallback
            self.showStateSelection = true
        }
        isLoading = false // Ladezustand am Ende zurücksetzen
        print("DEBUG checkUserProfileCompletion: Exiting. Final self.userProfile?.homeStateId = \(self.userProfile?.homeStateId ?? "nil")") // Debug-Log hinzugefügt
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
            self.activeError = .createInitialProfileFailed(originalError: error)
            return false
        }
    }
    
    func saveSelectedState() {
        guard let stateId = selectedStateId else {
            self.activeError = .generalError(message: "Bitte wähle ein Bundesland aus.")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            self.activeError = .generalError(message: "Nutzer nicht angemeldet.")
            return
        }
        isLoading = true
        inlineMessage = nil
        // Der Task hier ist sinnvoll, da der Completion Handler von updateData
        // nicht garantiert auf dem Main Thread läuft.
        Task {
            do {
                try await db.collection("user_profiles").document(userId).updateData(["homeStateId": stateId])
                print("Bundesland erfolgreich in Firestore gespeichert.")
                await self.checkUserProfileCompletion(isNewUserHint: false)
                await self.fetchSelectedStateDetails()
                self.isAuthenticated = true
                self.showStateSelection = false
                print("Lokales User-Profil nach Speichern aktualisiert: homeStateId sollte jetzt \(self.userProfile?.homeStateId ?? "nil"), Name: \(self.homeStateName ?? "unbekannt") sein")
            } catch {
                self.activeError = .stateSelectionSaveFailed(originalError: error)
                self.showStateSelection = true
            }
            self.isLoading = false
        }
    }
    
    func forgotPassword() {
        isLoading = true
        activeError = nil
        successMessage = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            // Der Task { @MainActor in ... } ist weiterhin sinnvoll für den Completion Handler
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.activeError = .passwordResetFailed(originalError: error)
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
                self.inlineMessage = "Fehler beim Ausloggen: \(signOutError.localizedDescription)"
                addAuthStateListener() // Auch im Fehlerfall wieder hinzufügen
            }
        }
    }
    
    // MARK: - Account Löschen
    
    // Iniziert den Account-Löschen Prozess, durch Anstoßen der re-authentication
    
    func initiateAccountDeletion() {
        guard Auth.auth().currentUser != nil else {
            self.activeError = .generalError(message: "Kein Nutzer angemeldet für Kontolöschung.")
            return
        }
        // Setzt den E-Mail-Wert für die Re-Authentifizierung, falls nicht schon geschehen
        if let currentUserEmail = Auth.auth().currentUser?.email, self.email.isEmpty {
            self.email = currentUserEmail
        }
        self.reauthPasswordInput = "" // Passwortfeld leeren
        self.showPasswordReauthPrompt = true // Löst die UI zur Passworteingabe aus
        self.activeError = nil
        self.successMessage = nil
    }
    
    // Confirms and executes account deletion after successful re-authentication.
    // This function should be called after the user has provided their password via the UI.
    func confirmAndDeleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            self.activeError = .accountDeletionFailed(originalError: NSError(domain: "AppAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kein Nutzer angemeldet für Löschbestätigung."]))
            return
        }
        guard let userEmailForReauth = user.email, !userEmailForReauth.isEmpty else {
            self.activeError = .accountDeletionFailed(originalError: NSError(domain: "AppAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "E-Mail des Benutzers nicht verfügbar für Re-Authentifizierung."]))
            return
        }
        
        // Das Passwort kommt jetzt von `reauthPasswordInput`
        let passwordToReauth = self.reauthPasswordInput
        
        guard !passwordToReauth.isEmpty else {
            self.activeError = .accountDeletionFailed(originalError: NSError(domain: "AppAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Passwort für die Bestätigung erforderlich."]))
            return
        }
        
        isLoading = true
        activeError = nil
        successMessage = nil
        
        let userId = user.uid
        
        do {
            // Schritt 1: Re-Authentifizierung
            print("Attempting to re-authenticate user \(userEmailForReauth)...")
            let credential = EmailAuthProvider.credential(withEmail: userEmailForReauth, password: passwordToReauth)
            try await user.reauthenticate(with: credential)
            print("User re-authenticated successfully.")
            
            // Schritt 2: Zusätzliche Nutzerdaten löschen (Profil, Checklisten-Status etc.)
            // Dies geschieht NACH erfolgreicher Re-Authentifizierung.
            print("Deleting user data from Firestore for userId: \(userId)")
            
            // Profil löschen
            let userProfileRef = db.collection("user_profiles").document(userId)
            try await userProfileRef.delete()
            print("User profile deleted from Firestore.")
            
            // Checklisten-Status löschen
            let checklistStateRef = db.collection("checklist_states").document(userId)
            // Optional: Prüfen, ob das Dokument existiert, bevor `delete` aufgerufen wird,
            // um Fehler zu vermeiden, falls es nicht existiert. `delete()` auf ein nicht
            // existierendes Dokument wirft jedoch keinen Fehler.
            try await checklistStateRef.delete()
            print("User checklist state deleted from Firestore.")
            
            // Schritt 3: Firebase Auth Nutzer löschen
            print("Deleting Firebase Auth user...")
            
            let userChecklistStatesRef = db.collection("user_checklist_states").document(userId)
            try await userChecklistStatesRef.delete()
            print("User document from user_checklist_states deleted from Firestore.")
            
            try await user.delete()
            print("Firebase Auth user deleted successfully.")
            // AuthStateListener wird automatisch auslösen und UI-Status aktualisieren.
            // `reauthPasswordInput` hier leeren.
            Task { @MainActor in
                self.reauthPasswordInput = ""
                self.successMessage = "Dein Konto wurde erfolgreich gelöscht."
            }
            
        } catch {
            print("Error during account deletion process: \(error)")
            let finalErrorMessage: String
            if let authError = error as NSError? {
                switch AuthErrorCode(rawValue: authError.code) {
                case .requiresRecentLogin:
                    // Sollte durch Re-Auth abgefangen sein, aber als Fallback
                    finalErrorMessage = "Sitzung abgelaufen. Bitte versuche den Vorgang erneut."
                case .wrongPassword:
                    finalErrorMessage = "Das eingegebene Passwort ist falsch. Bitte versuche es erneut."
                case .userMismatch:
                    finalErrorMessage = "Die Anmeldeinformationen stimmen nicht mit dem angemeldeten Benutzer überein."
                    // Fügen Sie hier weitere spezifische AuthErrorCode-Fälle hinzu, falls nötig
                default:
                    finalErrorMessage = "Fehler beim Löschen des Kontos: \(error.localizedDescription)"
                }
            } else {
                finalErrorMessage = "Fehler beim Löschen des Kontos: \(error.localizedDescription)"
            }
            Task { @MainActor in
                self.inlineMessage = finalErrorMessage
                self.reauthPasswordInput = "" // Passwort bei Fehler ebenfalls leeren
            }
        }
        isLoading = false
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
                print("Unhandled Firebase Auth Error Code: \(authErrorCode.rawValue)") // Hilfreich für Debugging
                return "Ein unerwarteter Authentifizierungsfehler ist aufgetreten (Code: \(authErrorCode.rawValue))."
                // Ende des default-Blocks
            }
        }
        // Fallback, wenn der Fehler kein AuthErrorCode ist oder die Konvertierung fehlschlägt
        return nsError.localizedDescription // Gibt die Standard-Fehlerbeschreibung zurück
    }
    // Neue Funktion, um von Anonym zur Registrierung zu wechseln
    func switchToRegistrationFromAnonymous() {
        print("Switching to Registration from Anonymous...")
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
                self.inlineMessage = "Fehler beim Wechsel zur Registrierung: \(signOutError.localizedDescription)"
            }
            addAuthStateListener()
        }
    }
    // Neue Funktion, um den displayName nach der Registrierung speichern zu können.
    func updateDisplayName(newName: String) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.inlineMessage = "Nutzer nicht angemeldet, um den Namen zu ändern."
            print("DEBUG: updateDisplayName: Error - user not signed in.")
            return
        }
        
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNewName.isEmpty else {
            self.inlineMessage = "Anzeigename darf nicht leer sein."
            print("DEBUG: updateDisplayName: Error - New name is empty")
            return
        }
        
        guard trimmedNewName != (self.userProfile?.displayName ?? "") else {
            print("DEBUG: updateDisplayName: Name ist unverändert, kein Update nötig")
            self.successMessage = "Anzeigename ist bereits aktuell."
            return
        }
        
        isLoading = true
        inlineMessage = nil
        successMessage = nil
        print("DEBUG: updateDisplayName: Attempting to update displayName to: '\(trimmedNewName)' for userId: '\(userId)'")
        
        do {
            try await db.collection("user_profiles").document(userId).updateData(["displayName": trimmedNewName])
            print("DEBUG: updateDisplayName: DisplayName erfolgreich in Firestore auf '\(trimmedNewName)' aktualisiert.")
            
            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = trimmedNewName
                try await changeRequest.commitChanges()
                print("DEBUG: updateDisplayName: DisplayName erfolgreich im Firebase Auth User-Objekt aktualisiert.")
            }
            
            await self.checkUserProfileCompletion(isNewUserHint: false)
            print("DEBUG: updateDisplayName: Lokales UserProfile nach Update neu geladen. Neuer Name im Profil: '\(self.userProfile?.displayName ?? "nicht gesetzt")'")
            self.successMessage = "Anzeigename erfolgreich aktualisiert."
        } catch {
            print("DEBUG: updateDisplayName: Fehler beim Aktualisieren des DisplayName: \(error)")
            self.inlineMessage = "Fehler beim Ändern des Anzeigenamens:: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // NEUE FUNKTION: Lädt die Details für eine gegebene stateId
    func fetchSelectedStateDetails() async {
        guard let homeStateId = userProfile?.homeStateId, !homeStateId.isEmpty else {
            print("DEBUG: fetchSelectedStateDetails: No homeStateId in userProfile, or userProfile is nil. Clearing details.")
            self.selectedStateDetails = nil // Stellt sicher, dass alte Details gelöscht werden
            return
        }
        
        print("DEBUG: fetchSelectedStateDetails: Attempting to fetch details for stateId '\(homeStateId)'.")
        self.isLoadingStateDetails = true
        self.inlineMessage = nil
        
        do {
            let documentSnapshot = try await db.collection("state_specific_info").document(homeStateId).getDocument()
            
            if documentSnapshot.exists {
                let details = try documentSnapshot.data(as: StateSpecificInfo.self)
                self.selectedStateDetails = details
                print("DEBUG: fetchSelectedStateDetails: Successfully fetched and decoded details: \(details)")
            } else {
                print("DEBUG: fetchSelectedStateDetails: Document for stateId '\(homeStateId)' does not exist.")
                self.selectedStateDetails = nil
                self.inlineMessage = "Details für das ausgewählte Bundesland konnten nicht gefunden werden."
            }
        } catch {
            print("DEBUG: fetchSelectedStateDetails: Error fetching state details for '\(homeStateId)': \(error)")
            self.selectedStateDetails = nil
            self.inlineMessage = "Fehler beim Laden der Bundesland-Details: \(error.localizedDescription)"
        }
        self.isLoadingStateDetails = false
    }
    
}
