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
    @Published var completedItemIDs: Set<String> = []
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
            // Der Listener für den Status wird jetzt im AuthListener oder bei Bedarf aufgerufen
            // und heißt jetzt z.B. listenForCompletedItemIDs
            if let _ = self.currentUserId, !self.isCurrentuserAnonymous {
                await listenForCompletedItemIDs() // GEÄNDERT: Ruft die neue Listener-Funktion auf
            } else {
                self.removeChecklistStateListener()
                self.completedItemIDs = [] // GEÄNDERT: Leert das Set
                self.calculateOverallProgress() // Fortschritt neu berechnen
                print("ChecklistViewModel: Anonymous or signed out user. CompletedItemIDs cleared.")
            }
        }
    }
    
    deinit {
        // Auth-Listener beim Deinitialisieren entfernen, um Speicherlecks zu vermeiden
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        Task { @MainActor [weak self] in
            self?.removeChecklistStateListener()
        }
    }
    
    // MARK: - Daten laden (Kategorie-Details, Items & Status)
    
    func fetchChecklistItemsAndCategoryDetails() async {
        guard !isLoading else {
            return // Verhindert mehrfaches Laden
        }
        
        // Nur neu laden, wenn Items leer sind, um mehrfaches Laden bei View-Appearance zu mildern
        // Dies ist eine optionale Verbesserung, die Hauptursache für mehrfaches .onAppear sollte separat untersucht werden.
        // if !items.isEmpty {
        //     print("ChecklistViewModel: fetchChecklistItemsAndCategoryDetails - Items bereits geladen, überspringe erneutes Laden der Items.")
        //     // Kategorie-Details könnten trotzdem neu geladen werden, falls nötig, oder auch bedingt gemacht werden.
        //     // Fürs Erste lassen wir das Laden der Kategorie-Details hier, da es weniger kritisch ist.
        // }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Kategorie-Details laden (für die Beschreibung)
            if let category = try await repository.fetchChecklistCategory(by: self.categoryId) {
                self.categoryDescription = category.description
                self.categoryTitle = category.title
            } else {
                self.categoryDescription = nil
                self.categoryTitle = nil
                print("ChecklistViewModel: No category found for ID: \(self.categoryId)")
            }
            
            // 2. Checklisten-Items laden
            let fetchedItems = try await repository.fetchChecklistItems(for: self.categoryId)
            self.items = fetchedItems.sorted(by: { $0.order < $1.order })
            self.totalItems = self.items.count
            print("ChecklistViewModel: Successfully fetched \(items.count) items for category \(categoryId). Total items: \(self.totalItems)")
            
            self.calculateOverallProgress()
            
        } catch {
            print("ChecklistViewModel: Error fetching checklist data: \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Laden der Checkliste: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // MARK: - Listener für erledigte Item-IDs (NEUE FUNKTION)
    func listenForCompletedItemIDs() async { // Neuer Name und Logik
        guard let userId = self.currentUserId, !isCurrentuserAnonymous else {
            self.completedItemIDs = []
            self.calculateOverallProgress()
            removeChecklistStateListener()
            print("ChecklistViewModel: Kein User angemeldet oder anonym. Listener nicht gestartet, CompletedItemIDs geleert.")
            return
        }
        
        removeChecklistStateListener() // Alten Listener entfernen, falls vorhanden
        
        print("ChecklistViewModel: Füge Listener für 'completed_items' Subcollection für User \(userId) hinzu (Kategorie: \(self.categoryId)).")
        checklistStateListener = repository.addCompletedItemsSubcollectionListener(for: userId) { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in // Explizit auf MainActor für UI-relevante Updates
                switch result {
                case .success(let fetchedItemIDs):
                    print("ChecklistViewModel: Listener lieferte \(fetchedItemIDs.count) erledigte Item-IDs: \(fetchedItemIDs)")
                    self.completedItemIDs = fetchedItemIDs
                    self.calculateOverallProgress() // Fortschritt aktualisieren, da sich die erledigten Items geändert haben
                case .failure(let error):
                    print("ChecklistViewModel: Fehler vom Subcollection-Listener: \(error.localizedDescription)")
                    self.errorMessage = "Fehler beim Laden des Status: \(error.localizedDescription)"
                    self.completedItemIDs = [] // Bei Fehler leeren
                    self.calculateOverallProgress() // Fortschritt aktualisieren
                }
            }
        }
    }
    
    // Funktion zum Entfernen des Listeners
    private func removeChecklistStateListener() {
        if let listener = checklistStateListener {
            listener.remove()
            checklistStateListener = nil
            print("ChecklistViewModel: Firestore checklist state listener removed.")
        }
    }
    
    // MARK: - Status von Checklist-Items verwalten (ANGEPASST)
    
    func toggleItemCompletion(item: ChecklistItem) async {
        guard let userId = self.currentUserId, !isCurrentuserAnonymous, let itemId = item.id else {
            print("ChecklistViewModel: Cannot save item completion - user not signed in, anonymous, or item ID missing.")
            if item.id == nil {
                print("DEBUG: Item '\(item.text)' hat eine nil ID in toggleItemCompletion.")
            }
            errorMessage = "Anmeldung erforderlich oder Item hat keine ID."
            return
        }
        
        print("DEBUG ChecklistViewModel: toggleItemCompletion - 'itemId' ('\(itemId)'), die ans Repository geht.")
        
        let isCurrentlyCompleted = completedItemIDs.contains(itemId)
        let newCompletionStatus = !isCurrentlyCompleted
        
        // Optimistisches UI-Update
        if newCompletionStatus {
            completedItemIDs.insert(itemId)
        } else {
            completedItemIDs.remove(itemId)
        }
        self.calculateOverallProgress() // Fortschritt nach lokaler Änderung aktualisieren
        
        do {
            // Rufe die neue Repository-Funktion auf
            try await repository.setItemCompletionStatusInSubcollection(userId: userId, itemId: itemId, isCompleted: newCompletionStatus)
            print("ChecklistViewModel: Successfully toggled subcollection item \(itemId) to \(newCompletionStatus) for user \(userId).")
            // Der Listener wird den State von Firestore holen und ggf. korrigieren (obwohl es bei dieser Methode meist konsistent sein sollte)
        } catch {
            print("ChecklistViewModel: Error toggling subcollection item \(itemId) für User \(userId): \(error.localizedDescription)")
            self.errorMessage = "Fehler beim Speichern des Status: \(error.localizedDescription)"
            // Optimistisches Update zurückrollen bei Fehler
            if newCompletionStatus {
                completedItemIDs.remove(itemId)
            } else {
                completedItemIDs.insert(itemId)
            }
            self.calculateOverallProgress() // Fortschritt nach Rollback aktualisieren
        }
    }
    
    // MARK: - Fortschrittsberechnung (ANGEPASST)
    private func calculateOverallProgress() {
        guard totalItems > 0 else {
            totalProgress = 0.0
            self.totalCompletedItems = 0 // Stellt sicher, dass auch dies zurückgesetzt wird
            // print("ChecklistViewModel: Fortschrittsberechnung übersprungen, da totalItems = 0.")
            return
        }
        
        // Zählt, wie viele der Items der aktuellen Kategorie in der Menge der erledigten IDs sind
        let relevantCompletedCount = self.items.filter { checklistItem in
            guard let checklistItemId = checklistItem.id else { return false }
            return self.completedItemIDs.contains(checklistItemId)
        }.count
        
        self.totalCompletedItems = relevantCompletedCount
        totalProgress = Double(relevantCompletedCount) / Double(totalItems)
        print("ChecklistViewModel: Fortschritt berechnet - Erledigt: \(self.totalCompletedItems) / Gesamt: \(self.totalItems) = \(self.totalProgress)")
    }
    
    // Hilfsfunktion, um zu prüfen, ob ein Item erledigt ist (ANGEPASST)
    func isItemCompleted(_ item: ChecklistItem) -> Bool {
        guard let itemId = item.id else {
            // print("WARNUNG isItemCompleted: ChecklistItem '\(item.text)' hat keine ID.")
            return false
        }
        let isCompleted = completedItemIDs.contains(itemId)
        // Die folgende Zeile ist sehr gesprächig, für finales Debugging ggf. entfernen:
        // print("DEBUG isItemCompleted: Item '\(item.text)' (ID: \(itemId)) Status (aus completedItemIDs): \(isCompleted)")
        return isCompleted
    }
    
    
    // MARK: - Auth State Listener (ANGEPASST, um neue Listener-Funktion aufzurufen)
    private func addAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            Task { @MainActor in
                let newUserId = user?.uid
                let newIsAnonymous = user?.isAnonymous ?? true // Default true, falls kein Nutzer mehr da (abgemeldet)
                
                // Reagiere nur, wenn sich die UserID oder der Anonymitätsstatus tatsächlich geändert hat
                if newUserId != self.currentUserId || newIsAnonymous != self.isCurrentuserAnonymous {
                    print("ChecklistViewModel: Auth state changed. New UserID: \(newUserId ?? "nil"), Was: \(self.currentUserId ?? "nil"). New Anonymous: \(newIsAnonymous), Was: \(self.isCurrentuserAnonymous)")
                    
                    self.currentUserId = newUserId
                    self.isCurrentuserAnonymous = newIsAnonymous
                    
                    if newUserId != nil && !newIsAnonymous {
                        // Nutzer ist angemeldet und nicht anonym
                        print("ChecklistViewModel: User angemeldet und nicht anonym. Starte Listener für erledigte Items.")
                        await self.listenForCompletedItemIDs() // NEU: Ruft die korrekte Listener-Funktion auf
                    } else {
                        // Nutzer abgemeldet oder anonym
                        print("ChecklistViewModel: User abgemeldet oder anonym. Entferne Listener und leere Status.")
                        self.removeChecklistStateListener()
                        self.completedItemIDs = [] // GEÄNDERT: Leert das Set
                        self.calculateOverallProgress() // Fortschritt neu berechnen
                    }
                }
            }
        }
    }
}
