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
    // ViewModel wird von außen übergeben (z.B. als @StateObject in der Haupt-App-Struktur)
    @StateObject var viewModel = AuthenticationViewModel()
    
    let gradientColors: [Color] = [
        Color(red: 100/255, green: 180/255, blue: 100/255), // Helleres Grün
        Color(red: 40/255, green: 100/255, blue: 40/255)   // Dunkleres Grün
    ]
    var backgroundGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: gradientColors),
            center: .center,
            startRadius: 50,
            endRadius: 600) // Passe dies ggf. an oder nutze GeometryReader
    }
    
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
                .padding()
                .background(Color.clear)
            }
            // Zeigt die Bundesland-Auswahl als Sheet an, wenn nötig
            .sheet(isPresented: $viewModel.showStateSelection) {
                StateSelectionView()
            }
            // Stellt das ViewModel für die untergeordneten Views bereit
            .environmentObject(viewModel)
            // Zeigt Fehlermeldungen an
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "Unbekannter Fehler")
            })
        }
    }
}

#Preview("Auth Container View") {
    AuthenticationView() // Startet standardmäßig mit Login
}
