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
    
    private let repository: EmbassyRepositoryProtocol
    
    init(repository: EmbassyRepositoryProtocol = EmbassyRepository()) {
        self.repository = repository
    }
    
    func fetchEmbassyInfo(forCountryName countryName: String) async {
        isLoading = true
        errorMessage = nil
        embassy = nil
        
        do {
            let fetchedEmbassy = try await repository.fetchGermanEmbassy(forCountryName: countryName)
            self.embassy = fetchedEmbassy
        } catch let apiError as ApiError {
            self.errorMessage = apiError.errorDescription
            print("EmbassyInfoViewModel: ApiError - \(apiError) (Associated value: \(String(describing: (apiError as NSError).userInfo["Error"])))")
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut später erneut."
            print("EmbassyInfoViewModel: Unexpected error - \(error.localizedDescription)")
        }
        isLoading = false
    }
}
