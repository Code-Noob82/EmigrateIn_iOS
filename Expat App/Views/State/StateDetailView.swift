//
//  StateDetailView.swift
//  Expat App
//
//  Created by Dominik Baki on 16.05.25.
//

import SwiftUI
import FirebaseFirestore

struct StateDetailView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if authViewModel.isLoadingStateDetails {
                    ProgressView("Lade Bundesland-Details...")
                        .padding()
                } else if let details = authViewModel.selectedStateDetails {
                    // Hier die Details des Bundeslandes anzeigen
                    Text(details.stateName) // stateName kommt aus deinem StateSpecificInfo-Model
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Anzeige der apostilleInfo
                    if let apostilleInfoText = details.apostilleInfo, !apostilleInfoText.isEmpty {
                        SectionView(title: "Apostille Informationen", content: apostilleInfoText)
                    }
                    
                    // Anzeige der apostilleAuthorities
                    if let authorities = details.apostilleAuthorities, !authorities.isEmpty {
                        Text("Zuständige Behörden für Apostillen:")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top)
                            .padding(.bottom, 5)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(authorities, id: \.self) { authority in // Annahme: Authority hat 'name' und ist Identifiable oder name ist unique
                                VStack(alignment: .leading) {
                                    Text(authority.name)
                                        .fontWeight(.semibold)
                                    if let linkString = authority.link, let url = URL(string: linkString) {
                                        Link(destination: url) {
                                            Text(linkString)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .foregroundColor(.blue)
                                        }
                                    } else if let linkString = authority.link, !linkString.isEmpty {
                                        Text("Link: \(linkString)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                    // Füge hier weitere Felder aus deinem StateSpecificInfo-Model hinzu
                } else if let errorMessage = authViewModel.errorMessage, errorMessage.contains("Bundesland-Details") {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Keine Bundesland-Details verfügbar. Bitte wähle ein Bundesland in deinem Profil aus.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Infos für \(authViewModel.selectedStateDetails?.stateName ?? authViewModel.homeStateName ?? "dein Bundesland")")
        .onAppear {
            if authViewModel.selectedStateDetails == nil ||
                authViewModel.selectedStateDetails?.id != authViewModel.userProfile?.homeStateId {
                Task {
                    await authViewModel.fetchSelectedStateDetails()
                }
            }
        }
    }
}

#Preview {
    StateDetailView()
        .environmentObject(AuthenticationViewModel())
}
