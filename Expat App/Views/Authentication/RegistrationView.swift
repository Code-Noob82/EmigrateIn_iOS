//
//  RegistrationView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - Registration View

struct RegistrationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Registrieren").font(.largeTitle).fontWeight(.bold)
            TextField("E-Mail", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Passwort", text: $viewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Passwort bestätigen", text: $viewModel.confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button("Registrieren") {
                viewModel.signUpWithEmail()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)

             Divider()

            Button("Mit Google anmelden") {
                 viewModel.signInWithGoogle()
            }
            // TODO: Google Sign-In Button Styling hinzufügen
            .padding()
            .disabled(viewModel.isLoading)

            Spacer()

            HStack {
                Text("Bereits ein Konto?")
                Button("Anmelden") {
                    viewModel.currentAuthView = .login
                }
            }
        }
        .padding()
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview("Registration View") {
    RegistrationView()
        .environmentObject(AuthenticationViewModel())
}
