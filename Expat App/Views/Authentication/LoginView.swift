//
//  LoginView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI
import GoogleSignInSwift

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    private let googleButtonViewModel = GoogleSignInButtonViewModel(
        scheme: .dark,
        style: .wide,
        state: .pressed
    )
    
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
                    .cornerRadius(20)
                // .tint(AppStyles.accentColor)
                
                SecureField("Passwort", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                // .tint(AppStyles.accentColor)
                
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
                Text("Andere Anmeldemethode nutzen")
                
                GoogleSignInButton(viewModel: googleButtonViewModel, action: {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                })
                .frame(height: AppStyles.ButtonHeight)
                .disabled(viewModel.isLoading)
                
                Button {
                    Task {
                        await viewModel.signInAnonymously()
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                        Text("Als Gast fortfahren")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppStyles.buttonBackgroundColor)
                    .foregroundColor(AppStyles.buttonTextColor)
                    .clipShape(Capsule())
                }
                .padding(.top, 10)
                .disabled(viewModel.isLoading)
                Spacer()
                HStack {
                    Text("Noch kein Konto?")
                        .foregroundColor(AppStyles.secondaryTextColor)
                    Button("Neu Registrieren") {
                        viewModel.currentAuthView = .registration
                    }
                    .foregroundColor(AppStyles.primaryTextColor)
                }
            }
            .padding()
        }
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
            }
        }
        .navigationTitle("Einloggen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Versteckt den "Zurück"-Button, da Navigation über ViewModel gesteuert wird
    }
}

#Preview("Login View") {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}
