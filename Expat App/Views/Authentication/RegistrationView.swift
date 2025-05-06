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
            Text("Registrieren")
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
            
            SecureField("Passwort bestätigen", text: $viewModel.confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button("Registrieren") {
                viewModel.signUpWithEmail()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppStyles.buttonBackgroundColor)
            .foregroundColor(AppStyles.buttonTextColor)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)

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
                Text("Bereits ein Konto?")
                    .foregroundColor(AppStyles.secondaryTextColor)
                Button("Anmelden") {
                    viewModel.currentAuthView = .login
                }
                .foregroundColor(AppStyles.primaryTextColor)
            }
        }
        .padding()
        .background(Color.clear)
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Registrieren")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Registration View") {
    RegistrationView()
        .environmentObject(AuthenticationViewModel())
}
