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
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TextField("E-Mail Adresse", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                ZStack(alignment: .trailing) {
                    if isPasswordVisible {
                        TextField("Passwort", text: $viewModel.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Passwort", text: $viewModel.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 15)
                    }
                }
                
                Button {
                    viewModel.signInWithEmail()
                } label: {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Anmelden")
                            .font(.system(size: 18, weight: .semibold))
                    }
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
                Text("Alternative Anmeldemethode nutzen")
                
                Button {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image("google_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppStyles.buttonBackgroundColor)
                    .foregroundColor(AppStyles.buttonTextColor)
                    .clipShape(Capsule())
                }
                .disabled(viewModel.isLoading)
                
                Button {
                    Task {
                        await viewModel.signInAnonymously()
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                        Text("Als Gast fortfahren")
                            .font(.system(size: 18, weight: .semibold))
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
