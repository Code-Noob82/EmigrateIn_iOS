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
    @State private var isPasswordVisible: Bool = false // NEU: Für Passwort-Sichtbarkeit
    @State private var isConfirmPasswordVisible: Bool = false // NEU: Für Bestätigungspasswort-Sichtbarkeit
    
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        TextField("E-Mail Adresse", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("Passwort festlegen", text: $viewModel.password)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(20)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Passwort festlegen", text: $viewModel.password)
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
                        ZStack(alignment: .trailing) {
                            if isConfirmPasswordVisible {
                                TextField("Passwort bestätigen", text: $viewModel.confirmPassword)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(20)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Passwort bestätigen", text: $viewModel.confirmPassword)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 15)
                            }
                        }
                        Button {
                            viewModel.signUpWithEmail()
                        } label: {
                            HStack {
                                Image(systemName: "person.fill.checkmark")
                                Text("Registrieren")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppStyles.buttonBackgroundColor)
                        .foregroundColor(AppStyles.buttonTextColor)
                        .clipShape(Capsule())
                        .disabled(viewModel.isLoading)
                        
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
                            .frame(height: AppStyles.buttonHeight) // Wenn AppStyles.buttonHeight existiert
                            .background(AppStyles.buttonBackgroundColor)
                            .foregroundColor(AppStyles.buttonTextColor)
                            .clipShape(Capsule())
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                }
                Divider().padding(.vertical, 10)
                // Fixierter Footer
                HStack {
                    Text("Bereits ein Konto?")
                        .font(.subheadline)
                        .foregroundColor(AppStyles.secondaryTextColor)
                    Button("Einloggen") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.currentAuthView = .login
                        }
                    }
                    .buttonStyle(TextLinkButtonStyle(textColor: AppStyles.primaryTextColor))
                }
                .padding() // Padding für den Footer selbst
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .overlay { // Zeigt Ladeindikator
            if viewModel.isLoading {
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
            }
        }
    }
}

#Preview("Registration View") {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        RegistrationView()
            .environmentObject(AuthenticationViewModel())
    }
}
