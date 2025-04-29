//
//  AuthenticationViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import FirebaseAuth
import FirebaseFirestore

// MARK: - AuthenticationViewModel
// Dieses ViewModel steuert den gesamten Auth-Fluss
// Es interagiert mit Firebase Auth und Firestore (über Services)

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
    // Wichtig in komplexeren Szenarien, um Memory Leaks zu vermeiden ("Best Practice")
    deinit {
        removeAuthStateListener()
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
                    print("User is signed in with uid: \(user.uid)")
                    // Setzt den Status auf angemeldet
                    self.isAuthenticated = true
                    // Optional: Hier könnte man prüfen, ob das Profil vollständig ist
                    // oder direkt zur Hauptansicht navigieren.
                    // Fürs Erste setze ich nur isAuthenticated.
                    // Die Logik, ob StateSelection gezeigt wird, passiert nach explizitem Login/SignUp.
                } else {
                    print("User is signed out.")
                    // Setzt den Status auf nicht angemeldet
                    self.isAuthenticated = false
                    self.currentAuthView = .login // Zeigt Login-Screen, wenn ausgeloggt
                    self.showStateSelection = false // Reset state selection flag
                }
            }
        }
    }
    
    func removeAuthStateListener() {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Auth State Listener removed.")
        }
    }
    
    @MainActor // Stellt sicher, dass UI-Updates auf dem Main Thread erfolgen
    func fetchGermanStates() async { // Markiert die Funktion als async
        // Setzt Ladezustand und löscht alte Fehler
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
                self.isLoading = false // Ladezustand zurücksetzen
                return // Beendet, wenn keine Dokumente da sind
            }
            // Versucht, die Dokumente in [StateSpecificInfo] zu dekodieren
            // compactMap ignoriert Dokumente, die nicht dekodiert werden können
            self.germanStates = querySnapshot.documents.compactMap { document -> StateSpecificInfo? in
                do {
                    // data(as:) nutzt die Codable-Konformität des Models
                    return try document.data(as: StateSpecificInfo.self)
                } catch {
                    print("Error decoding state document \(document.documentID): \(error.localizedDescription)")
                    // Optional: Sammle Fehler oder logge sie spezifischer
                    return nil // Überspringt dieses Dokument bei Fehler
                }
            }
            print("Successfully fetched \(self.germanStates.count) states.")
        } catch {
            print("Error fetching states: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Abrufen der Bundesländer: \(error.localizedDescription)"
        }
        // Setzt Ladezustand zurück, egal ob Erfolg oder Fehler
        self.isLoading = false
    }
    
    @MainActor // Stellt sicher, dass UI-Updates auf dem Main Thread erfolgen
    func signInWithEmail() {
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            // Wichtig: UI Updates müssen auf dem Main Thread passieren
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                // Erfolgreich angemeldet
                // Prüft, ob das Nutzerprofil (insb. homeStateId) existiert/vollständig ist
                self.checkUserProfileCompletion()
            }
        }
    }
    
    @MainActor
    func signUpWithEmail() {
        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            return
        }
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                // Erfolgreich registriert
                // Erstellt Basis-Profil und zeigt Bundesland-Auswahl
                self.createInitialUserProfile { success in
                    if success {
                        self.showStateSelection = true
                    } else {
                        // Fehler beim Profil erstellen (sollte nicht passieren, aber sicherheitshalber)
                        self.errorMessage = "Fehler beim Erstellen des Nutzerprofils."
                    }
                }
            }
        }
    }
    
    @MainActor
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        // TODO: Firebase Google Sign-In Logik (via AuthService)
        // Erfordert zusätzliche Konfiguration (GoogleService-Info.plist, URL Schemes etc.)
        // Hier nur Platzhalter
        print("Google Sign-In muss implementiert werden.")
        // Beispielhafter Ablauf nach erfolgreichem Google Login:
        // self.checkUserProfileCompletion()
        Task { @MainActor in // Stelle sicher, dass UI-Updates auf dem Main Thread sind
            self.isLoading = false
        }
    }
    
    // Hilfsfunktion zum Prüfen des Profils nach Login/Google-Sign-In
    @MainActor
    private func checkUserProfileCompletion() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        // TODO: Logik zum Laden des UserProfile aus Firestore (via UserService)
        // Beispiel:
        db.collection("user_profiles").document(userId).getDocument { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            Task { @MainActor in // Stelle sicher, dass UI-Updates auf dem Main Thread sind
                self.isLoading = false // Setze isLoading hier zurück
                
                if let document = documentSnapshot, document.exists {
                    // Profil existiert, versuche zu decodieren
                    do {
                        let profile = try document.data(as: UserProfile.self)
                        if profile.homeStateId != nil && !profile.homeStateId!.isEmpty {
                            // Bundesland ist vorhanden
                            self.isAuthenticated = true // Setze finalen Auth-Status
                            self.showStateSelection = false
                        } else {
                            // Bundesland fehlt, zeige Auswahl
                            self.showStateSelection = true
                        }
                    } catch {
                        // Fehler beim Decodieren oder Profil unvollständig
                        print("Error decoding profile or profile incomplete: \(error)")
                        self.showStateSelection = true // Zeige Auswahl zur Sicherheit
                    }
                } else if error != nil {
                    // Fehler beim Laden des Profils
                    self.errorMessage = "Fehler beim Laden des Profils: \(error!.localizedDescription)"
                    // Evtl. trotzdem zur State Selection? Oder Fehler anzeigen?
                    self.showStateSelection = true
                } else {
                    // Profil existiert nicht (sollte nach Google Sign-In/Login nicht passieren, aber sicherheitshalber)
                    print("User profile does not exist after login/google sign-in.")
                    // Erstellt Basis-Profil und zeigt Bundesland-Auswahl
                    self.createInitialUserProfile { success in
                        if success {
                            self.showStateSelection = true
                        } else {
                            self.errorMessage = "Fehler beim Erstellen des Nutzerprofils."
                        }
                    }
                }
            }
        }
    }
    
    // Hilfsfunktion zum Erstellen eines initialen Profils nach Registrierung
    @MainActor
    private func createInitialUserProfile(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let profileData: [String: Any] = [
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "homeStateId": "" // Initial leer
            // displayName kann später hinzugefügt werden
        ]
        
        db.collection("user_profiles").document(user.uid).setData(profileData) { [weak self] error in
            Task { @MainActor in // Stellt sicher, dass UI-Updates auf dem Main Thread sind
                guard let self = self else { return }
                if let error = error {
                    print("Error creating initial user profile: \(error)")
                    self.errorMessage = "Fehler beim Speichern des Profils."
                    completion(false)
                } else {
                    print("Initial user profile created.")
                    completion(true)
                }
            }
        }
    }
    
    @MainActor
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
        // UserProfile in Firestore aktualisieren
        db.collection("user_profiles").document(userId).updateData(["homeStateId": stateId]) { [weak self] error in
            guard let self = self else { return }
            Task { @MainActor in // Stellt sicher, dass UI-Updates auf dem Main Thread sind
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = "Fehler beim Speichern des Bundeslandes: \(error.localizedDescription)"
                } else {
                    // Erfolgreich gespeichert
                    self.isAuthenticated = true // Nutzer ist jetzt vollständig authentifiziert/angemeldet
                    self.showStateSelection = false // Sheet schließen
                }
            }
        }
    }
    
    @MainActor
    func forgotPassword() {
        isLoading = true
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            Task { @MainActor in // Stellt sicher, dass UI-Updates auf dem Main Thread sind
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // Erfolgsmeldung anzeigen (z.B. über einen anderen @Published String)
                    print("Password reset email sent.")
                    // Wechselt zurück zum Login-Screen, damit Nutzer sich nach Reset anmelden kann
                    self.currentAuthView = .login
                    // Optional: Zeigt eine Bestätigungsnachricht an
                }
            }
        }
    }
    
    @MainActor
    func signOut() {
        // Entfernt den Listener *vor* dem Ausloggen, um unnötige UI-Updates zu vermeiden
        removeAuthStateListener()
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            // Der Auth State Listener (falls noch aktiv) würde isAuthenticated auf false setzen.
            // Setzt es hier zur Sicherheit auch direkt.
            // Die UI wird durch den Listener aktualisiert, wenn er wieder hinzugefügt wird.
            // self.isAuthenticated = false // Nicht unbedingt hier nötig
            // self.currentAuthView = .login // Wird durch Listener gesetzt
            // Fügt den Listener wieder hinzu, falls der Nutzer sich erneut anmeldet
            addAuthStateListener()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            Task { @MainActor in // Stellt sicher, dass UI-Updates auf dem Main Thread sind
                self.errorMessage = "Fehler beim Ausloggen: \(signOutError.localizedDescription)"
                // Fügt den Listener sicherheitshalber wieder hinzu
                addAuthStateListener()
            }
        }
    }
}
