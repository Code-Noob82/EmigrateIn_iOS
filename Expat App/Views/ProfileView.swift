//
//  ProfileView.swift
//  Expat App
//
//  Created by Dominik Baki on 30.04.25.
//

import SwiftUI

// MARK: - Profile View (Neu)

struct ProfileView: View {
    // Zugriff auf das AuthenticationViewModel aus der Umgebung
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack { // Optional: Fügt eine Navigationsleiste hinzu
            VStack {
                Spacer()

                Text("Profil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                // Hier könnten später Nutzerinfos angezeigt werden
                if !authViewModel.email.isEmpty { // Sicherer Zugriff
                    Text("Angemeldet als: \(authViewModel.email)")
                         .font(.callout)
                         .foregroundColor(.gray)
                         .padding(.bottom, 40)
                }
                
                Button {
                    // Ruft die signOut Funktion direkt im authViewModel auf
                    authViewModel.signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Ausloggen")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            // .navigationTitle("Profil") // Optionaler Titel für die Navigationsleiste
            // .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
}
