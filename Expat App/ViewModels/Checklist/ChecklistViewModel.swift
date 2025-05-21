//
//  ChecklistViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import Foundation
import FirebaseFirestore // Für Firestore-Typen wie DocumentID etc.
import FirebaseAuth // Um die aktuelle UserID zu bekommen

@MainActor
class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Zustand der Items für den aktuellen Nutzer: [ChecklistItem.id : isCompleted (Bool)]
    @Published var completedItemsState: [String: Bool] = [:]
    @Published private(set) var currentUserId: String?
    @Published var isCurrentuserAnonymous = false
    
    private let categoryId: String // Die Kategorie-ID für diese Checkliste
    private let repository: ContentRepositoryProtocol // Abhängigkeit vom Protokoll
    private var authListener: AuthStateDidChangeListenerHandle?
    
    
    // Dependency Injection: Initialisiert mit categoryId und optionalem Repository
    init(categoryId: String, repository: ContentRepositoryProtocol = ContentRepository()) {
        self.categoryId = categoryId
        self.repository = repository
        self.currentUserId = Auth.auth().currentUser?.uid
        self.isCurrentuserAnonymous = Auth.auth().currentUser?.isAnonymous ?? true // Default true, falls kein Nutzer
        
        // Listener für den Anmeldestatus, um user_checklist_states zu laden/speichern
        addAuthListener()
        
        // Initiales Laden der Checklisten-Items und des Status
        Task {
            await fetchChecklistItems() // Lädt die Items der Kategorie
            if self.currentUserId == nil && !self.isCurrentuserAnonymous { // Lade Status nur für nicht-anonyme User
                await fetchUserChecklistState()
            } else if self.isCurrentuserAnonymous {
                print("Anonymous user, skipping fetching user checklist state.")
                self.completedItemsState = [:] // Stellt sicher, dass der Status für anonyme User leer ist
            }
        }
    }
    
    deinit {
        // Auth-Listener beim Deinitialisieren entfernen, um Speicherlecks zu vermeiden
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Daten laden (Items & Status)
    
    func fetchChecklistItems() async {
        guard !isLoading else {
            return // Verhindert mehrfaches Laden
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Ruft die Items für die gegebene categoryId über das Repository ab
            let fetchedItems = try await repository.fetchChecklistItems(for: self.categoryId)
            self.items = fetchedItems
            print("Successfully fetched \(items.count) checklist items for category \(categoryId).")
        } catch {
            print("Error fetching checklist items: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Laden der Checklisten-Items: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // Lädt den erledigten Status der Items für den angemeldeten Nutzer aus Firestore
    func fetchUserChecklistState() async {
        guard let userId = self.currentUserId else {
            // Wenn kein Nutzer angemeldet ist.
            self.completedItemsState = [:]
            print("No user signed in, not fetching user checklist state from Firestore.")
            return
        }
        
        print("Fetching user checklist state for user: \(userId)")
        
        do {
            let state = try await repository.fetchUserChecklistState(for: userId) // Ruft den Status über das Repository ab
            self.completedItemsState = state.completedItems ?? [:]
            print("Successfully fetched user checklist state: \(completedItemsState.count) completed items.")
        } catch {
            // Behandlt den spezifischen Fehler, wenn das Dokument nicht existiert (Code 404)
            if let nsError = error as NSError?, nsError.code == 404 {
                print("User checklist state document not found for user: \(userId). Initializing empty state.")
                self.completedItemsState = [:] // Initialisiert mit leerem Status
            } else {
                print("Error fetching user checklist state: \(error.localizedDescription)")
                self.errorMessage = "Fehler beim Laden des Checklist-Status: \(error.localizedDescription)"
                self.completedItemsState = [:] // Bei anderen Fehlern auch leeren
            }
        }
    }
    
    // MARK: - Status von Checklist-Items verwalten
    
    func toggleItemCompletion(item: ChecklistItem) async {
        guard let userId = self.currentUserId, !isCurrentuserAnonymous, let itemId = item.id else {
            print("Cannot save item completion: user not signed in, is anonymous, or item ID missing.")
            errorMessage = "Anmeldung erforderlich, um den Status zu speichern."
            return
        }
        
        let isCurrentlyCompleted = completedItemsState[itemId] ?? false
        let newCompletionStatus = !isCurrentlyCompleted
        
        // Aktualisiert den lokalen Zustand sofort für eine reaktive UI
        completedItemsState[itemId] = newCompletionStatus
        
        do {
            // Ruft die spezifische Funktion im Repository auf, um die Änderung in Firestore zu speichern
            try await repository.updateChecklistItemCompletion(userId: userId, itemId: itemId, isCompleted: newCompletionStatus)
            print("Successfully toggled item \(itemId) completion to \(newCompletionStatus) for user \(userId).")
        } catch {
            print("Error toggling item completion: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Speichern des Status: \(error.localizedDescription)"
            // Bei Fehlern den lokalen Zustand zurücksetzen (Rollback)
            completedItemsState[itemId] = isCurrentlyCompleted
        }
    }
    
    // Hilfsfunktion, um zu prüfen, ob ein Item erledigt ist
    func isItemCompleted(_ item: ChecklistItem) -> Bool {
        return completedItemsState[item.id ?? ""] ?? false
    }
    
    // MARK: - Auth State Listener (Reagiert auf An-/Abmeldung des Nutzers)
    private func addAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            Task { @MainActor in
                let newIsAnonymous = user?.isAnonymous ?? true
                if user?.uid != self.currentUserId || newIsAnonymous != self.isCurrentuserAnonymous {
                    self.currentUserId = user?.uid // <-- Zuweisung zu @Published private(set) Property
                    self.isCurrentuserAnonymous = newIsAnonymous // <-- Aktualisiere auch diese Property
                    
                    if user != nil && !self.isCurrentuserAnonymous { // Lade Status nur für NICHT-anonyme User
                        await self.fetchUserChecklistState()
                    } else {
                        self.completedItemsState = [:] // Leert Status bei Abmeldung oder wenn anonym
                        print("User changed or became anonymous. Clearing checklist state.")
                    }
                }
            }
        }
    }
}
