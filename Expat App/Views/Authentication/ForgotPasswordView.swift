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
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Gib deine E-Mail-Adresse ein, um einen Link zum Zurücksetzen deines Passworts zu erhalten.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .padding(.horizontal)
                
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
                .background(AppStyles.buttonBackgroundColor)
                .foregroundColor(AppStyles.buttonTextColor)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                Button("Zurück zum Login") {
                    viewModel.currentAuthView = .login
                }
                .foregroundColor(AppStyles.primaryTextColor)
            }
            .padding()
        }
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
            }
        }
        .navigationTitle("Dein Passwort zurücksetzen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Forgot Password View") {
    ForgotPasswordView()
        .environmentObject(AuthenticationViewModel())
}
