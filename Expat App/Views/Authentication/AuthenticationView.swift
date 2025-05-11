//
//  AuthenticationView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - Authentication Container View

// Diese View entscheidet, ob Login oder Registrierung gezeigt wird
struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            NavigationStack {
                VStack {
                    // Zeigt die entsprechende View basierend auf dem ViewModel-Status
                    switch viewModel.currentAuthView {
                    case .login:
                        LoginView()
                    case .registration:
                        RegistrationView()
                    case .forgotPassword:
                        ForgotPasswordView()
                    }
                }
                .navigationTitle(titleForCurrentAuthView())
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            }
            // Zeigt die Bundesland-Auswahl als Sheet an, wenn nötig
            .sheet(isPresented: $viewModel.showStateSelection) {
                StateSelectionView()
            }
            // Zeigt Fehlermeldungen an
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "Unbekannter Fehler")
            })
        }
    }
    
    private func titleForCurrentAuthView() -> String {
        switch viewModel.currentAuthView {
        case .login: return "Anmelden"
        case .registration: return "Registrieren"
        case .forgotPassword: return "Passwort zurücksetzen"
        }
    }
}

#Preview("AuthenticationView - Login") {
    AuthenticationView().environmentObject(AuthenticationViewModel()) // Startet mit Login
}
