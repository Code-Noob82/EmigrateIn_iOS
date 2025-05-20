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
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 25) {
                    
                    // Hauptüberschrift
                    Text("Wähle dein Bundesland")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .multilineTextAlignment(.center)
                    
                    // Ausführlicher Hinweistext
                    Text("Diese Angabe hilft uns, dir spezifische Informationen für Behörden, Apostillen und mehr in deinem Bundesland anzuzeigen. \nDu kannst deine Auswahl jederzeit in deinem Profil ändern.")
                        .font(.callout)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Picker zur Auswahl des Bundeslandes
                    Picker("Bundesland", selection: $viewModel.selectedStateId) {
                        Text("Bitte auswählen").tag(nil as String?) // Platzhalter
                            .foregroundColor(AppStyles.primaryTextColor)
                        
                        ForEach(viewModel.germanStates) { state in
                            // Zeigt den Namen an, speichert aber die ID (z.B. "BW")
                            Text(state.stateName).tag(state.id as String?)
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.inline)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                           // .fill(Color.black.opacity(0.3))
                            .stroke(AppStyles.primaryTextColor.opacity(0.5), lineWidth: 1)
                    )
                    .tint(AppStyles.primaryTextColor)
                    
                    Spacer()
                    
                    Button("Speichern & Weiter") {
                        Task {
                            viewModel.saveSelectedState()
                            // Das Sheet wird automatisch geschlossen, wenn viewModel.isAuthenticated auf true wechselt
                            // und die App-Logik dies steuert. Kein dismiss() hier, um den authViewModel Flow nicht zu stören.
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(viewModel.selectedStateId == nil ||
                              viewModel.isLoading) // Deaktivieren, wenn nichts ausgewählt oder am Laden
                    // Zusätzliche visuelle Deaktivierung, falls der Button-Stil nicht greift
                    .opacity(viewModel.selectedStateId == nil ||
                             viewModel.isLoading ? 0.6 : 1.0)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(AppStyles.destructiveColor)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(AppStyles.backgroundGradient)
                .cornerRadius(15)
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
                .navigationTitle("Profil vervollständigen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppStyles.backgroundGradient, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
                .overlay { // Zeigt Ladeindikator
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppStyles.primaryTextColor)
                    }
                }
                // Schließen-Button in der Toolbar
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .foregroundColor(AppStyles.primaryTextColor)
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
