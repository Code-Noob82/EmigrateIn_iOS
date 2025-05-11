//
//  RegistrationView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI
import GoogleSignInSwift

// MARK: - Registration View

struct RegistrationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
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
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }
                .frame(height: 44)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                HStack {
                    Text("Bereits ein Konto?")
                        .foregroundColor(AppStyles.secondaryTextColor)
                    Button("Einloggen") {
                        viewModel.currentAuthView = .login
                    }
                    .foregroundColor(AppStyles.primaryTextColor)
                }
            }
            .padding()
            .background(Color.clear)
        }
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
            }
        }
        .navigationTitle("Neu Registrieren")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Registration View") {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        RegistrationView()
            .environmentObject(AuthenticationViewModel())
    }
}
