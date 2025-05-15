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
    @State private var showingDeleteConfirmation = false
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                ScrollView {
                    VStack (spacing: 30) {
                        Spacer(minLength: 20)
                        
                        Text("Nutzerkonto")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppStyles.primaryTextColor)
                            .padding(.bottom)
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
            .navigationTitle("Dein Konto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            .alert("Konto wirklich löschen?", isPresented: $showingDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) { }
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
