//
//  StateSelectionView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - State Selection View

struct StateSelectionView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss // Zum Schließen des Sheets

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Wählt Euer Bundesland")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Diese Angabe hilft uns, euch relevante Informationen (z.B. für Behörden) anzuzeigen.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)

                // Picker zur Auswahl des Bundeslandes
                Picker("Bundesland", selection: $viewModel.selectedStateId) {
                    Text("Bitte auswählen").tag(nil as String?) // Platzhalter
                    ForEach(viewModel.germanStates) { state in
                        // Zeigt den Namen an, speichert aber die ID (z.B. "BW")
                        Text(state.stateName).tag(state.id as String?)
                    }
                }
                .pickerStyle(.wheel)

                Spacer()

                Button("Speichern & Weiter") {
                    viewModel.saveSelectedState()
                    // Das Sheet wird geschlossen, wenn isAuthenticated true wird
                    // oder man könnte hier auch dismiss() aufrufen,
                    // falls das Speichern asynchron ist und man nicht warten will.
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.selectedStateId == nil ||
                          viewModel.isLoading) // Deaktivieren, wenn nichts ausgewählt oder am Laden
            }
            .padding()
            .navigationTitle("Profil vervollständigen")
            .navigationBarTitleDisplayMode(.inline)
            .overlay { // Zeigt Ladeindikator
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            // Optional: Füge einen Schließen-Button hinzu, falls nötig
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Abbrechen") {
                         dismiss()
                     }
                 }
             }
        }
    }
}

#Preview("State Selection View") {
    StateSelectionView()
        .environmentObject(AuthenticationViewModel())
}
