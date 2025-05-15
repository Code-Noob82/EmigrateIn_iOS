//
//  ContentView.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI

// MARK: - ContentView (Verwaltet Auth vs. Haupt-App)

// Diese View entscheidet, ob der Login/Registrierungs-Screen oder die Haupt-App (Tabs) angezeigt wird.
struct ContentView: View {
    // Zugriff auf das zentrale AuthenticationViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            // Prüft den Authentifizierungsstatus aus dem ViewModel
            if authViewModel.isAuthenticated {
                // Wenn angemeldet, zeige die Haupt-TabView
                AppTabView()
            } else {
                // Wenn nicht angemeldet, zeige die AuthenticationView
                AuthenticationView()
            }
            // Wichtig: Das EnvironmentObject wird von EmigrateInApp hierher weitergereicht.
        }
        .sheet(isPresented: $authViewModel.showStateSelection) {
            StateSelectionView()
                .environmentObject(authViewModel)
        }
    }
}
