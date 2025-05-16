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
            // Hier kommen deine Einstellungsoptionen hin
            Spacer()
            Button("Schließen (Beispiel)") { // Nur falls du einen expliziten Schließen-Button brauchst
                dismiss()
            }
            .padding()
        }
        // Die SettingsView bekommt ihren eigenen Navigationstitel,
        // der vom NavigationStack angezeigt wird.
        .navigationTitle("Einstellungen")
        .navigationBarTitleDisplayMode(.inline) // Oder .large
        // Der NavigationStack stellt automatisch einen "Zurück"-Button bereit.
    }
}

#Preview {
    SettingsView()
}
