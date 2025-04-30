//
//  LoginView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Anmelden").font(.largeTitle).fontWeight(.bold)
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

            Button("Anmelden") {
                viewModel.signInWithEmail()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading) // Deaktivieren während Laden

            // NavigationLink für "Passwort vergessen?"
            // NavigationLink("Passwort vergessen?", destination: ForgotPasswordView()) // Einfachere Variante
            // Oder über ViewModel-Status steuern:
             Button("Passwort vergessen?") {
                 viewModel.currentAuthView = .forgotPassword
             }
             .font(.footnote)


            Divider()

            Button("Mit Google anmelden") {
                 viewModel.signInWithGoogle()
            }
            // TODO: Google Sign-In Button Styling hinzufügen
            .padding()
            .disabled(viewModel.isLoading)

            Spacer()

            HStack {
                Text("Noch kein Konto?")
                Button("Registrieren") {
                    viewModel.currentAuthView = .registration
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

#Preview("Login View") {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
