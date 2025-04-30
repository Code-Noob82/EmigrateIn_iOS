//
//  ForgotPasswordView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Passwort zurücksetzen").font(.largeTitle).fontWeight(.bold)
            Text("Gib deine E-Mail-Adresse ein, um einen Link zum Zurücksetzen deines Passworts zu erhalten.")
                .font(.callout)
                .multilineTextAlignment(.center)

            TextField("E-Mail", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button("Link senden") {
                viewModel.forgotPassword()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)

            Spacer()

            Button("Zurück zum Login") {
                viewModel.currentAuthView = .login
            }
        }
        .padding()
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
            }
        }
        // Optional: Füge einen Navigationstitel hinzu
        // .navigationTitle("Passwort vergessen")
        // .navigationBarBackButtonHidden(true) // Versteckt ggf. den Zurück-Button der NavigationStack
    }
}

#Preview("Forgot Password View") {
    ForgotPasswordView()
        .environmentObject(AuthenticationViewModel()) // Füge hier das EnvironmentObject hinzu
}
