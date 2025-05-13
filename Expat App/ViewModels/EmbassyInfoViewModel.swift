//
//  EmbassyInfoViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation
import SwiftUI

@MainActor
class EmbassyInfoViewModel: ObservableObject {
    @Published var embassy: Embassy?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // NEUE Published Properties für die Länderauswahl
    @Published var allCountryNames: [String] = []
    @Published var selectedCountryName: String = "" // Hält das aktuell ausgewählte Land
    @Published var isLoadingCountries = false // Für das Laden der Länderliste
    @Published var countryListErrorMessage: String? // Für Fehler beim Laden der Länderliste
    
    // NEUE Published Properties für die Liste aller Vertretungen
    @Published var allRepresentationsForCountry: [Embassy] = []
    @Published var isLoadingAllRepresentations: Bool = false
    @Published var allRepresentationsErrorMessage: String?
    
    @Published var displayContent: DisplayContent = .none
    
    private let repository: EmbassyRepositoryProtocol
    
    init(repository: EmbassyRepositoryProtocol = EmbassyRepository()) {
        self.repository = repository
    }
    // NEUE Funktion zum Laden aller Ländernamen
    func loadAllCountryNames() async {
        isLoadingCountries = true
        countryListErrorMessage = nil
        allCountryNames = [] // Leere die Liste vor dem Neuladen
        
        do {
            let names = try await repository.fetchAllCountryNames()
            self.allCountryNames = names
            
            // Wählt das erste Land in der Liste als Standard aus, falls die Liste nicht leer ist.
            // Alternativ könntest du einen Platzhalter wie "Bitte Land auswählen" hinzufügen
            // und selectedCountryName initial auf diesen Platzhalter setzen.
            if let firstName = names.first {
                self.selectedCountryName = firstName
            } else {
                // Falls keine Länder geladen wurden, selectedCountryName leer lassen oder auf Platzhalter setzen.
                self.selectedCountryName = ""
                self.countryListErrorMessage = "Keine Länder von der API geladen." // Informative Meldung
            }
        } catch let apiError as ApiError {
            self.countryListErrorMessage = "Fehler beim Laden der Länderliste: \(apiError.errorDescription ?? "Unbekannter Fehler")"
            print("EmbassyInfoViewModel: ApiError loading country names - \(apiError)")
        } catch {
            self.countryListErrorMessage = "Ein unerwarteter Fehler ist beim Laden der Länderliste aufgetreten."
            print("EmbassyInfoViewModel: Unexpected error loading country names - \(error.localizedDescription)")
        }
        isLoadingCountries = false
    }
    
    func fetchMainEmbassyForSelectedCountry() async {
        guard !selectedCountryName.isEmpty else {
            self.errorMessage = "Bitte wähle ein Land aus der Liste aus."
            self.embassy = nil; self.allRepresentationsForCountry = []; self.displayContent = .none
            return
        }
        isLoading = true
        errorMessage = nil
        embassy = nil
        
        do {
            let fetchedEmbassy = try await repository.fetchGermanEmbassy(forCountryName: selectedCountryName)
            self.embassy = fetchedEmbassy
            self.displayContent = .singleEmbassy
            
            if fetchedEmbassy == nil {
                self.errorMessage = "Keine Haupt-Botschaft fur '\(selectedCountryName)' gefunden."
            }
        } catch let apiError as ApiError {
            self.errorMessage = apiError.errorDescription
            self.displayContent = .none
            print("EmbassyInfoViewModel: ApiError fetching embassy for '\(selectedCountryName)' - \(apiError)")
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            self.displayContent = .none
            print("EmbassyInfoViewModel: Unexpected error fetching embassy for '\(selectedCountryName)' - \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // NEUE Funktion zum Abrufen aller Vertretungen für das ausgewählte Land
    func fetchAllRepresentationsForSelectedCountry() async {
        guard !selectedCountryName.isEmpty else {
            self.allRepresentationsErrorMessage = "Bitte wählen ein Land aus der Liste aus."
            self.embassy = nil; self.allRepresentationsForCountry = []; self.displayContent = .none
            return
        }
        
        isLoadingAllRepresentations = true
        allRepresentationsErrorMessage = nil
        allRepresentationsForCountry = []
        embassy = nil // Andere Ergebnisliste leeren
        
        do {
            let representations = try await repository.fetchAllRepresentationsInCountry(countryName: selectedCountryName)
            self.allRepresentationsForCountry = representations
            self.displayContent = .allRepresentationsInCountry // Modus setzen
            if representations.isEmpty {
                // Diese Meldung kann auch direkt in der View basierend auf der leeren Liste angezeigt werden.
                self.allRepresentationsErrorMessage = "Keine Vertretungen für '\(selectedCountryName)' gefunden."
            }
        } catch let apiError as ApiError {
            self.allRepresentationsErrorMessage = "Fehler beim Laden aller Vertretungen: \(apiError.errorDescription ?? "Unbekannter Fehler")"
            self.displayContent = .none
            // ... (Logging) ...
        } catch {
            self.allRepresentationsErrorMessage = "Ein unerwarteter Fehler ist beim Laden aller Vertretungen aufgetreten."
            self.displayContent = .none
            // ... (Logging) ...
        }
        isLoadingAllRepresentations = false
    }
}
