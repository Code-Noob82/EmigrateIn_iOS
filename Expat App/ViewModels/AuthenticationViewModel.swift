//
//  AuthenticationViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    
    func fetchGermanStates() async { // Markiert die Funktion als async
        guard Auth.auth().currentUser != nil else {
            print("fetchGermanStates skipped: No authenticated user.")
            self.germanStates = []
            return
        }
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
                    // Optional: Fehler sammeln oder spezifischer loggen
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
                await self.checkUserProfileCompletion()
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
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            Task { @MainActor in
                // Der Task { @MainActor in ... } ist sinnvoll, da dieser
                // Completion Handler von Firebase nicht garantiert auf dem Main Thread läuft.
                self.isLoading = false // Setzt isLoading hier zurück
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                let success = await self.createInitialUserProfile()
                if success {
                    self.showStateSelection = true
                } else {
                    self.errorMessage = "Fehler beim Erstellen des Nutzerrofils."
                }
            }
        }
    }
    
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
    private func checkUserProfileCompletion() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil
        do {
            let documentSnapshot = try await db.collection("user_profiles").document(userId).getDocument()
            
            if !documentSnapshot.exists {
                let profile = try documentSnapshot.data(as: UserProfile.self)
                if profile.homeStateId != nil && !profile.homeStateId!.isEmpty {
                    self.isAuthenticated = true
                    self.showStateSelection = false
                } else {
                    self.showStateSelection = true
                }
            } else {
                print("User profile does not exist after login/google sign-in")
                let success = await self.createInitialUserProfile()
                if success {
                    self.errorMessage = "Fehler beim Erstellen des Nutzerprofils"
                }
            }
        } catch {
            print("Error checking/decoding profile: \(error)")
            self.errorMessage = "Fehler beim Laden des Profils: \(error.localizedDescription)"
            self.showStateSelection = true
        }
        self.isLoading = false
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
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            // Der Task { @MainActor in ... } ist weiterhin sinnvoll für den Completion Handler
            Task { @MainActor in
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
    
    func signOut() {
        // Entfernt den Listener *vor* dem Ausloggen, um unnötige UI-Updates zu vermeiden
        removeAuthStateListener()
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            // Der Auth State Listener wird den Rest erledigen, wenn er wieder hinzugefügt wird.
            // Fügt den Listener wieder hinzu, falls der Nutzer sich erneut anmeldet
            addAuthStateListener()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            Task { @MainActor in
                self.errorMessage = "Fehler beim Ausloggen: \(signOutError.localizedDescription)"
                // Fügt den Listener sicherheitshalber wieder hinzu
                addAuthStateListener()
            }
        }
    }
    
    // NEUE Funktion zum Löschen des Kontos
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Fehler: Kein Nutzer angemeldet."
            return
        }
        let userId = user.uid
        isLoading = true
        errorMessage = nil
        
        do {
            try await db.collection("user_profiles").document(userId).delete()
            print("User profile deleted from Firestore.")
            
            let checklistStateRef = db.collection("checklist_states").document(userId)
            if (try? await checklistStateRef.getDocument())?.exists == true {
                try await checklistStateRef.delete()
                print("User checklist state deleted from Firestore.")
            } else {
                print("No ckecklist state found for user to delete.")
            }
            
            try await user.delete()
            print("Firebase Auth user deleted successfully.")
        } catch {
            print("Error deleting user: \(error)")
            if let authError = error as NSError?, authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                errorMessage = "Sitzung abgelaufen. Bitte melde dich erneut an, um dein Konto zu löschen."
            } else {
                errorMessage = "Fehler beim Löschen des Kontos: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
