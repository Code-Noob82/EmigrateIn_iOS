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
    let placeholderCountryName = "Land auswählen..."
    
    @Published var embassy: Embassy?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // NEUE Published Properties für die Länderauswahl
    @Published var allCountryNames: [String] = []
    @Published var selectedCountryName: String // Wird jetzt im init gesetzt
    @Published var isLoadingCountries = false // Für das Laden der Länderliste
    @Published var countryListErrorMessage: String? // Für Fehler beim Laden der Länderliste
    
    // NEUE Published Properties für die Liste aller Vertretungen
    @Published var allRepresentationsForCountry: [Embassy] = []
    @Published var isLoadingAllRepresentations = false
    @Published var allRepresentationsErrorMessage: String?
    
    @Published var displayContent: DisplayContent = .none
    
    private let repository: EmbassyRepositoryProtocol
    
    init(repository: EmbassyRepositoryProtocol = EmbassyRepository()) {
        self.repository = repository
        self.selectedCountryName = placeholderCountryName
    }
    // NEUE Funktion zum Laden aller Ländernamen
    func loadAllCountryNames() async {
        isLoadingCountries = true
        countryListErrorMessage = nil
        
        do {
            let names = try await repository.fetchAllCountryNames()
            self.allCountryNames = names
            
            print("EmbassyInfoViewModel: Direkt nach Zuweisung hat self.allCountryNames \(self.allCountryNames.count) Einträge.")
            print("EmbassyInfoViewModel: Die ersten 10 Länder in self.allCountryNames: \(self.allCountryNames.prefix(10))")
            if self.allCountryNames.count > 10 { // Nur ausgeben, wenn mehr als 10 vorhanden sind
                print("EmbassyInfoViewModel: Die letzten 10 Länder in self.allCountryNames: \(self.allCountryNames.suffix(10))")
            }
            
            if names.isEmpty {
                self.countryListErrorMessage = "Keine Länder von der API geladen."
                self.selectedCountryName = placeholderCountryName
            }
        } catch let apiError as ApiError {
            self.countryListErrorMessage = "Fehler beim Laden der Länderliste: \(apiError.errorDescription ?? "Unbekannter Fehler")"
            self.allCountryNames = [] // Leert die Liste bei Fehler
            self.selectedCountryName = placeholderCountryName // Setzt auf Platzhalter zurück
            print("EmbassyInfoViewModel: ApiError loading country names: \(apiError.localizedDescription)")
        } catch {
            self.countryListErrorMessage = "Ein unerwarteter Fehler ist beim Laden der Länderliste aufgetreten."
            self.allCountryNames = []
            self.selectedCountryName = placeholderCountryName
            print("EmbassyInfoViewModel: Unexpected error loading country names: \(error.localizedDescription)")
        }
        isLoadingCountries = false
    }
    
    func fetchMainEmbassyForSelectedCountry() async {
        guard selectedCountryName != placeholderCountryName && !selectedCountryName.isEmpty else {
            self.errorMessage = "Bitte wähle ein Land aus der Liste aus."
            self.embassy = nil
            self.allRepresentationsForCountry = []
            self.displayContent = .none
            return
        }
        isLoading = true
        errorMessage = nil
        embassy = nil
        allRepresentationsForCountry = []
        allRepresentationsErrorMessage = nil
        
        do {
            let fetchedEmbassy = try await repository.fetchGermanEmbassy(forCountryName: selectedCountryName)
            self.embassy = fetchedEmbassy
            self.displayContent = .singleEmbassy
            if fetchedEmbassy == nil && self.errorMessage == nil {
                self.errorMessage = "Keine Haupt-Botschaft für '\(selectedCountryName)' gefunden."
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
        guard selectedCountryName != placeholderCountryName && !selectedCountryName.isEmpty else {
            self.allRepresentationsErrorMessage = "Bitte wähle ein Land aus der Liste aus."
            self.embassy = nil
            self.allRepresentationsForCountry = []
            self.displayContent = .none
            return
        }
        
        isLoadingAllRepresentations = true
        allRepresentationsErrorMessage = nil
        allRepresentationsForCountry = []
        embassy = nil
        errorMessage = nil
        
        do {
            let representations = try await repository.fetchAllRepresentationsInCountry(countryName: selectedCountryName)
            self.allRepresentationsForCountry = representations
            self.displayContent = .allRepresentationsInCountry // Modus setzen
            if representations.isEmpty && self.allRepresentationsErrorMessage == nil {
                // Diese Meldung kann auch direkt in der View basierend auf der leeren Liste angezeigt werden.
                self.allRepresentationsErrorMessage = "Keine Vertretungen für '\(selectedCountryName)' gefunden."
            }
        } catch let apiError as ApiError {
            self.allRepresentationsErrorMessage = "Fehler beim Laden aller Vertretungen: \(apiError.errorDescription ?? "Unbekannter Fehler")"
            self.displayContent = .none
            print("EmbassyInfoViewModel: Fetch all representations failed: \(apiError.localizedDescription)")
        } catch {
            self.allRepresentationsErrorMessage = "Ein unerwarteter Fehler ist beim Laden aller Vertretungen aufgetreten."
            self.displayContent = .none
            print("EmassyInfoViewModel: Fetch all representations failed: \(error.localizedDescription)")
        }
        isLoadingAllRepresentations = false
    }
}
