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
    
    @Published var categoryDescription: String? = nil
    @Published var categoryTitle: String? = nil
    
    // Zustand der Items für den aktuellen Nutzer: [ChecklistItem.id : isCompleted (Bool)]
    @Published var completedItemsState: [String: Bool] = [:]
    @Published private(set) var currentUserId: String?
    @Published var isCurrentuserAnonymous = false
    
    // MARK: - NEU: Fortschritts-Eigenschaften
    @Published var totalProgress: Double = 0.0 // Gesamtfortschritt (0.0 - 1.0)
    @Published var totalCompletedItems: Int = 0
    @Published var totalItems: Int = 0
    
    private let categoryId: String // Die Kategorie-ID für diese Checkliste
    private let repository: ContentRepositoryProtocol // Abhängigkeit vom Protokoll
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // NEU: Firestore Snapshot Listener Handle
    private var checklistStateListener: ListenerRegistration?
    
    
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
            await fetchChecklistItemsAndCategoryDetails() // Lädt die Items der Kategorie
            if let _ = self.currentUserId, !self.isCurrentuserAnonymous {
                await fetchUserChecklistState() // Startet den Firestore Listener für diesen Nutzer
            } else {
                // Wenn anonym oder nicht angemeldet, sorge dafür, dass der Listener entfernt ist
                // und der Status leer ist.
                self.removeChecklistStateListener() // Wichtig: Listener explizit entfernen
                self.completedItemsState = [:]
                print("Anonymous or signed out user. Checklist state will not be fetched from Firestore.")
            }
        }
    }
    
    deinit {
        // Auth-Listener beim Deinitialisieren entfernen, um Speicherlecks zu vermeiden
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.removeChecklistStateListener()
        }
    }
    
    // MARK: - Daten laden (Kategorie-Details, Items & Status)
    
    func fetchChecklistItemsAndCategoryDetails() async { // <<< NEU: Umbenannt für Klarheit
        guard !isLoading else {
            return // Verhindert mehrfaches Laden
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Kategorie-Details laden (für die Beschreibung)
            if let category = try await repository.fetchChecklistCategory(by: self.categoryId) {
                self.categoryDescription = category.description
                self.categoryTitle = category.title
                print("DEBUG: Loaded category description: \(self.categoryDescription ?? "nil")")
                print("DEBUG: Loaded category title: \(self.categoryTitle ?? "nil")")
            } else {
                self.categoryDescription = nil
                self.categoryTitle = nil
                print("No category found for ID: \(self.categoryId)")
            }
            
            // 2. Checklisten-Items laden
            let fetchedItems = try await repository.fetchChecklistItems(for: self.categoryId)
            self.items = fetchedItems.sorted(by: { $0.order < $1.order })
            print("Successfully fetched \(items.count) checklist items for category \(categoryId).")
            
            self.totalItems = self.items.count
            
        } catch {
            print("Error fetching checklist data or state: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Laden der Checkliste: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // Diese Funktion wird jetzt primär vom Listener getriggert oder wenn ein User-Wechsel sie explizit aufruft.
    func fetchUserChecklistState() async {
        guard let userId = self.currentUserId else {
            // Wenn kein Nutzer angemeldet ist.
            self.completedItemsState = [:]
            self.calculateOverallProgress()
            removeChecklistStateListener()
            print("No user signed in, clearing checklist state.")
            return
        }
        removeChecklistStateListener()
        
        print("Adding Firestore snapshot listener for user checklist state: \(userId) in category \(categoryId)") // Log-Anpassung
        
        checklistStateListener = repository.addChecklistStateSnapshotListener(for: userId, categoryId: categoryId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let state):
                // Hier ist die Korrektur: Optional Chain auf 'state' selbst
                                let allCompletedItems = state?.completedItems ?? [:] // Wenn state nil ist, nimm ein leeres Dictionary
                                
                                // Nun kannst du filter auf allCompletedItems anwenden, da es nicht optional ist
                                let relevantCompletedItems = allCompletedItems.filter { (itemId, _) in
                                    self.items.contains(where: { $0.id == itemId })
                }
                
                self.completedItemsState = relevantCompletedItems
                self.totalCompletedItems = self.completedItemsState.filter { $0.value }.count // NEU: Anzahl der erledigten Items aus dem State
                self.calculateOverallProgress() // NEU: Fortschritt nach Status-Update berechnen
                                
                print("Successfully updated completedItemsState from Firestore snapshot. Items: \(self.completedItemsState.count) (Completed: \(self.totalCompletedItems))")
                
            case .failure(let error):
                print("Error fetching user checklist state from snapshot: \(error.localizedDescription)")
                self.errorMessage = "Fehler beim Laden des Status: \(error.localizedDescription)"
                self.completedItemsState = [:]
                self.totalCompletedItems = 0 // Bei Fehler zurücksetzen
                self.calculateOverallProgress() // Fortschritt aktualisieren
            }
        }
    }
    
    // Funktion zum Entfernen des Listeners
    private func removeChecklistStateListener() {
        if let listener = checklistStateListener {
            listener.remove()
            checklistStateListener = nil
            print("Firestore checklist state listener removed.")
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
    
    // MARK: - Fortschrittsberechnung
       
       // Berechnung des Gesamtfortschritts
       private func calculateOverallProgress() {
           guard totalItems > 0 else {
               totalProgress = 0.0
               return
           }
           // totalCompletedItems wird bereits im Listener aktualisiert
           totalProgress = Double(totalCompletedItems) / Double(totalItems)
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
                        self.removeChecklistStateListener()
                        self.completedItemsState = [:] // Leert Status bei Abmeldung oder wenn anonym
                        print("User changed or became anonymous. Clearing checklist state.")
                    }
                }
            }
        }
    }
}
