//
//  RepresentationRowView.swift
//  Expat App
//
//  Created by Dominik Baki on 13.05.25.
//

import SwiftUI

// NEUE Subview für die Darstellung einer einzelnen Vertretung in der Liste
struct RepresentationRowView: View {
    let representation: Embassy // Wir verwenden weiterhin das Embassy-Modell

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(representation.type ?? "Unbekannter Typ")
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
            Text("Stadt: \(representation.city ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(AppStyles.secondaryTextColor)
            if let phone = representation.phone, !phone.isEmpty {
                Text("Tel: \(phone)")
                    .font(.caption)
                    .foregroundColor(AppStyles.secondaryTextColor)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview("RepresentationRowView Beispiele") {
    // Erstelle Beispiel-Embassy-Objekte für die Vorschau
    let beispielVertretung1 = Embassy(
        id: "rep001",
        type: "Generalkonsulat der Bundesrepublik Deutschland",
        countryName: "Vorschauland", // Wird in dieser Row nicht direkt angezeigt
        city: "Metropolis",
        address: "Konsulstraße 1, 12345 Metropolis", // Wird nicht direkt angezeigt
        phone: "+49 123 987654",
        email: "info@metropolis.example.de", // Wird nicht direkt angezeigt
        url: "http://metropolis.example.de", // Wird nicht direkt angezeigt
        openingHours: "Mo-Fr: 09:00-13:00 Uhr", // Wird nicht direkt angezeigt
        remark: "Terminvereinbarung erforderlich." // Wird nicht direkt angezeigt
    )

    let beispielVertretung2 = Embassy(
        id: "rep002",
        type: "Honorarkonsulin der Bundesrepublik Deutschland",
        countryName: "Vorschauland",
        city: "Kleinstadt",
        address: "Dorfplatz 5",
        phone: nil, // Beispiel ohne Telefonnummer
        email: "hk.kleinstadt@example.de",
        url: nil,
        openingHours: "Di, Do: 10:00-12:00 Uhr",
        remark: "Nur nach telefonischer Absprache."
    )
    
    let beispielVertretung3 = Embassy(
        id: "rep003",
        type: "Kulturinstitut (Goethe-Zentrum)", // Ein anderer Typ von Vertretung
        countryName: "Vorschauland",
        city: "Kulturstadt",
        address: "Kunstweg 10",
        phone: "+49 123 112233",
        email: "info@kulturstadt-goethe.de",
        url: "http://kulturstadt-goethe.de",
        openingHours: "Mo-Sa: 10:00-18:00 Uhr",
        remark: "Freier Eintritt zu Ausstellungen."
    )

    // Zeige die Beispiele in einer VStack auf dem App-Hintergrund an
    VStack(alignment: .leading, spacing: 10) {
        RepresentationRowView(representation: beispielVertretung1)
        Divider().background(AppStyles.secondaryTextColor.opacity(0.3)) // Trennlinie
        RepresentationRowView(representation: beispielVertretung2) // Beispiel ohne Telefon
        Divider().background(AppStyles.secondaryTextColor.opacity(0.3))
        RepresentationRowView(representation: beispielVertretung3)
    }
    .padding() // Etwas Innenabstand für die VStack
    .background(AppStyles.backgroundGradient.ignoresSafeArea()) // Hintergrund für besseren Kontrast
}
