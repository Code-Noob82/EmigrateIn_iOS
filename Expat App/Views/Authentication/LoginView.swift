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
            Text("Anmelden")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppStyles.primaryTextColor)
            
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
            .background(AppStyles.buttonBackgroundColor)
            .foregroundColor(AppStyles.buttonTextColor)
            .clipShape(Capsule())
            .disabled(viewModel.isLoading) // Deaktivieren während Laden
            
             Button("Passwort vergessen?") {
                 viewModel.currentAuthView = .forgotPassword
             }
             .font(.footnote)
             .foregroundColor(AppStyles.primaryTextColor)
             .padding(.top, 5)
            
            Divider().padding(.vertical, 10)
            
            Button("Mit Google anmelden") {
                 viewModel.signInWithGoogle()
            }
            // TODO: Google Sign-In Button Styling hinzufügen
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray5))
            .foregroundColor(Color.primary)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)

            Spacer()

            HStack {
                Text("Noch kein Konto?")
                    .foregroundColor(AppStyles.secondaryTextColor)
                Button("Registrieren") {
                    viewModel.currentAuthView = .registration
                }
            }
        }
        .padding()
        .background(Color.clear)
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Anmelden")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Versteckt den "Zurück"-Button, da Navigation über ViewModel gesteuert wird
    }
}

#Preview("Login View") {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
