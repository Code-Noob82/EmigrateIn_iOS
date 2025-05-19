//
//  SettingsView.swift
//  Expat App
//
//  Created by Dominik Baki on 16.05.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss // Um ggf. programmatisch zurückzukehren
    
    var body: some View {
        VStack {
            Text("Einstellungen")
                .font(.largeTitle)
                .padding()
            // Hier kommen später weitere Einstellungsoptionen hin
            Spacer()
            Button("Schließen") {
                dismiss()
            }
            .padding()
        }
        .navigationTitle("Einstellungen")
        .navigationBarTitleDisplayMode(.inline) // Oder .large
    }
}

#Preview {
    SettingsView()
}
