//
//  ProfileView.swift
//  Expat App
//
//  Created by Dominik Baki on 30.04.25.
//

import SwiftUI

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
                
                VStack (spacing: 30) {
                    Spacer()
                    
                    Text("Nutzerkonto")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .padding(.bottom)
                    
                    // Hier könnten später Nutzerinfos angezeigt werden
                    if !authViewModel.email.isEmpty { // Sicherer Zugriff
                        Text("Angemeldet als: \(authViewModel.email)")
                            .font(.callout)
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding(.bottom, 20)
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
    return ProfileView()
        .environmentObject(previewAuthViewModel)
}
