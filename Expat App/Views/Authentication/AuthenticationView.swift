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
                        // Übergang für LoginView beim Erscheinen/Verschwinden
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading), // Login kommt von links (wenn von Register/Forgot zurück)
                                removal: .move(edge: .trailing))) // Login geht nach rechts (wenn zu Register/Forgot)
                    case .registration:
                        RegistrationView()
                        // Übergang für RegistrationView beim Erscheinen/Verschwinden
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing), // Register kommt von rechts (wenn von Login)
                                removal: .move(edge: .leading))) // Register geht nach links (wenn zurück zu Login)
                    case .forgotPassword:
                        ForgotPasswordView()
                        // Übergang für ForgotPasswordView beim Erscheinen/Verschwinden
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing), // Forgot kommt von rechts
                                removal: .move(edge: .leading))) // Forgot geht nach links
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentAuthView)
                .navigationTitle(titleForCurrentAuthView())
                .navigationBarTitleDisplayMode(.inline)
                .background(AppStyles.backgroundGradient)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
            }
            // Zeigt die Bundesland-Auswahl als Sheet an, wenn nötig
            .sheet(isPresented: $viewModel.showStateSelection) {
                StateSelectionView()
            }
            // Zeigt Fehlermeldungen an
            .alert("Fehler", isPresented: .constant(viewModel.inlineMessage != nil), actions: {
                Button("OK", role: .cancel) { viewModel.inlineMessage = nil }
            }, message: {
                Text(viewModel.inlineMessage ?? "Unbekannter Fehler")
            })
        }
    }
    
    private func titleForCurrentAuthView() -> String {
        switch viewModel.currentAuthView {
        case .login: return "Anmelden"
        case .registration: return "Neu Registrieren"
        case .forgotPassword: return "Passwort zurücksetzen"
        }
    }
}

#Preview("AuthenticationView - Login") {
    AuthenticationView().environmentObject(AuthenticationViewModel()) // Startet mit Login
}
