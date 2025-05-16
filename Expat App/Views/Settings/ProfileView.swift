//
//  ProfileView.swift
//  Expat App
//
//  Created by Dominik Baki on 30.04.25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Profile View (Neu)

struct ProfileView: View {
    // Zugriff auf das AuthenticationViewModel aus der Umgebung
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var editableDisplayName: String = "" // NEU: Für das TextField
    @State private var isEditingDisplayName = false
    @State private var showingDeleteConfirmation = false // NEU: Steuert den Bearbeitungsmodus
    let globalBackgroundGradient = AppStyles.backgroundGradient
    let headerBackground = AppStyles.backgroundGradient
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Dein Konto")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppStyles.primaryTextColor)
                    Spacer()
                    Button {
                        authViewModel.selectedTab = .settings
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(AppStyles.primaryTextColor)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(headerBackground)
                .overlay(Divider(), alignment: .bottom)
                
                ScrollView {
                    VStack (spacing: 20) {
                        if let displayName = authViewModel.userProfile?.displayName, !displayName.isEmpty {
                            HStack {
                                Text("Nutzerkonto von:")
                                    .font(.callout)
                                    .foregroundColor(AppStyles.secondaryTextColor)
                                Spacer()
                                Text(displayName)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppStyles.primaryTextColor)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.horizontal)
                        }
                        
                        if !authViewModel.isAnonymousUser {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Anzeigename:")
                                        .font(.headline)
                                        .foregroundColor(AppStyles.primaryTextColor)
                                    Spacer()
                                    if !isEditingDisplayName { // "Ändern"-Button nur im Anzeigemodus
                                        Button("Ändern") {
                                            // Beim Starten des Bearbeitungsmodus:
                                            // 1. editableDisplayName mit dem aktuellen Namen vorbelegen
                                            self.editableDisplayName = authViewModel.userProfile?.displayName ?? ""
                                            // 2. In den Bearbeitungsmodus wechseln
                                            self.isEditingDisplayName = true
                                            // 3. Alte Fehlermeldungen für diese Sektion löschen
                                            if authViewModel.errorMessage?.contains("Anzeigename") == true {
                                                authViewModel.errorMessage = nil
                                            }
                                            if authViewModel.successMessage?.contains("Anzeigename") == true {
                                                authViewModel.successMessage = nil
                                            }
                                        }
                                        .font(.callout)
                                    }
                                }
                                
                                if isEditingDisplayName {
                                    // ---- Bearbeitungsmodus ----
                                    TextField("Anzeigename eingeben", text: $editableDisplayName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textContentType(.nickname)
                                        .autocorrectionDisabled(true)
                                    
                                    HStack(spacing: 15) { // Buttons für Speichern und Abbrechen
                                        Button("Speichern") {
                                            Task {
                                                await authViewModel.updateDisplayName(newName: editableDisplayName)
                                                self.isEditingDisplayName = false
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(editableDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                                  editableDisplayName == (authViewModel.userProfile?.displayName ?? "") ||
                                                  authViewModel.isLoading)
                                        
                                        Button("Abbrechen") {
                                            self.isEditingDisplayName = false
                                            // optional: editableDisplayName zurücksetzen, ist aber nicht zwingend nötig,
                                            // da es beim nächsten Klick auf "Ändern" eh neu befüllt wird.
                                            // self.editableDisplayName = authViewModel.userProfile?.displayName ?? ""
                                        }
                                        .buttonStyle(.bordered) // Anderer Stil für Abbrechen
                                    }
                                    .padding(.top, 5)
                                    
                                } else {
                                    // ---- Anzeigemodus ----
                                    // Zeigt den aktuellen Namen oder "Nicht festgelegt"
                                    let currentName = authViewModel.userProfile?.displayName
                                    Text((currentName != nil && !currentName!.isEmpty) ? currentName! : "Nicht festgelegt")
                                        .font(.body)
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                // Erfolgs- oder Fehlermeldungen (relevant für Speichern)
                                // Werden nur angezeigt, wenn eine Meldung da ist (und nicht im Anzeigemodus ohne Aktion)
                                if authViewModel.isLoading && isEditingDisplayName { // Ladeindikator während des Speicherns
                                    ProgressView()
                                        .padding(.top, 5)
                                } else if let successMessage = authViewModel.successMessage, successMessage.contains("Anzeigename") {
                                    Text(successMessage)
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.top, 2)
                                        .onAppear { // Nachricht nach einiger Zeit ausblenden
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                if authViewModel.successMessage?.contains("Anzeigename") == true {
                                                    authViewModel.successMessage = nil
                                                }
                                            }
                                        }
                                } else if let errorMessage = authViewModel.errorMessage, errorMessage.contains("Anzeigename") {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.top, 2)
                                        .onAppear { // Nachricht nach einiger Zeit ausblenden
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                                if authViewModel.errorMessage?.contains("Anzeigename") == true {
                                                    authViewModel.errorMessage = nil
                                                }
                                            }
                                        }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            //.background(AppStyles.secondaryBackgroundColor.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                        }
                        if !authViewModel.email.isEmpty {
                            HStack {
                                Text("E-Mail:")
                                    .font(.callout)
                                    .foregroundColor(AppStyles.secondaryTextColor)
                                Spacer()
                                Text(authViewModel.email)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppStyles.primaryTextColor)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.horizontal)
                        }
                        
                        if let createdAtTimestamp = authViewModel.userProfile?.createdAt {
                            HStack {
                                Text("Konto erstellt am:")
                                    .font(.callout)
                                    .foregroundStyle(AppStyles.secondaryTextColor)
                                Spacer()
                                Text(createdAtTimestamp.dateFormatter())
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppStyles.primaryTextColor)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.horizontal)
                        }
                        
                        if !authViewModel.isAnonymousUser { // Nur für nicht-anonyme Nutzer
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dein Bundesland:")
                                    .font(.headline)
                                    .foregroundColor(AppStyles.primaryTextColor)
                                
                                if let stateName = authViewModel.homeStateName { // Nutzt die Computed Property
                                    Text(stateName)
                                        .font(.body)
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                } else {
                                    Text("Nicht festgelegt")
                                        .font(.body)
                                        .foregroundColor(AppStyles.secondaryTextColor.opacity(0.7))
                                }
                                
                                Button("Bundesland ändern") {
                                    authViewModel.showStateSelection = true // Dieser Wert triggert das Sheet
                                }
                                .font(.callout)
                                .padding(.top, 4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppStyles.secondaryTextColor.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        Button {
                            // Ruft die signOut Funktion direkt im authViewModel auf
                            authViewModel.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Ausloggen")
                            }
                            .foregroundColor(AppStyles.buttonTextColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppStyles.buttonBackgroundColor)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Konto löschen Button
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Konto löschen")
                            }
                            .foregroundColor(AppStyles.destructiveTextColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppStyles.destructiveColor)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(globalBackgroundGradient.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .alert("Konto wirklich löschen?", isPresented: $showingDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {
                }
                Button("Löschen", role: .destructive) {
                    Task {
                        await authViewModel.deleteAccount()
                    }
                }
            } message: {
                Text("Dieser Vorgang kann nicht rückgängig gemacht werden. Alle deine Daten werden dauerhaft gelöscht.")
            }
            .alert("Fehler beim Löschen", isPresented: .constant(authViewModel.errorMessage != nil && authViewModel.errorMessage!.contains("löschen")), actions:{
                Button("OK", role: .cancel) { authViewModel.errorMessage = nil }
            }, message: {
                Text(authViewModel.errorMessage ?? "Ein unbekannter Fehler ist aufgetreten.")
            })
            .onAppear {
                self.editableDisplayName = authViewModel.userProfile?.displayName ?? ""
                if authViewModel.successMessage?.contains("Nutzername") == true {
                    authViewModel.successMessage = nil
                }
                if authViewModel.errorMessage?.contains("Nutzername") == true {
                    authViewModel.errorMessage = nil
                }
            }
            .onChange(of: authViewModel.userProfile?.displayName) { oldName, newName in
                self.editableDisplayName = newName ?? ""
            }
        }
    }
}

#Preview("ProfileView") {
    let previewAuthViewModel = AuthenticationViewModel()
    previewAuthViewModel.email = "test@example.com"
    previewAuthViewModel.isAuthenticated = true
    previewAuthViewModel.isAnonymousUser = false // Wichtig, damit Profil-Details angezeigt werden
    let exampleUserProfile = UserProfile(
        id: "previewUserID", // Beispiel User ID
        displayName: "Max Mustermann",
        email: "test@example.com",
        homeStateId: "BW",
        createdAt: Timestamp(date: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()) // z.B. vor 30 Tagen
    )
    previewAuthViewModel.userProfile = exampleUserProfile
    
    // 4. Erstelle Beispiel-Bundesländer-Daten
    // Mindestens das Bundesland, das in `homeStateId` referenziert wird, sollte hier vorhanden sein.
    // Annahme: Deine StateSpecificInfo Struktur hat `id` und `stateName`.
    let exampleStates = [
        StateSpecificInfo(id: "BW", stateName: "Baden-Württemberg" /*, ...andere Felder falls vorhanden...*/),
        StateSpecificInfo(id: "BY", stateName: "Bayern" /*, ...*/),
        StateSpecificInfo(id: "BE", stateName: "Berlin" /*, ...*/)
    ]
    previewAuthViewModel.germanStates = exampleStates
    previewAuthViewModel.showStateSelection = true
    
    return ProfileView()
        .environmentObject(previewAuthViewModel)
}
