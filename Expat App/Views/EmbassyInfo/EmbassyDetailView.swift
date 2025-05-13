//
//  EmbassyDetailView.swift
//  Expat App
//
//  Created by Dominik Baki on 13.05.25.
//

import SwiftUI

// MARK: - Subview für die Anzeige der Botschaftsdetails in einer ScrollView
struct EmbassyDetailView: View {
    let embassy: Embassy
    let backgroundGradient = AppStyles.backgroundGradient
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(embassy.type ?? "Deutsche Auslandsvertretung")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                    
                    EmbassyDetailRow(iconName: "mappin.and.ellipse", label: "Land & Stadt", value: "\(embassy.countryName ?? "-"), \(embassy.city ?? "-")")
                    EmbassyDetailRow(iconName: "location.fill", label: "Adresse", value: embassy.address, isMultiline: true)
                    EmbassyDetailRow(iconName: "phone.fill", label: "Telefon", value: embassy.phone, linkType: .phone)
                    EmbassyDetailRow(iconName: "envelope.fill", label: "E-Mail", value: embassy.email, linkType: .email)
                    EmbassyDetailRow(iconName: "globe", label: "Webseite", value: embassy.url, linkType: .web)
                    EmbassyDetailRow(iconName: "clock.fill", label: "Öffnungszeiten", value: embassy.openingHours, isMultiline: true)
                    EmbassyDetailRow(iconName: "info.circle.fill", label: "Hinweis", value: embassy.remark, isMultiline: true)
                }
                .padding()
            }
            .background(AppStyles.primaryTextColor.opacity(0.05))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

#Preview {
    let sampleEmbassy = Embassy(
        id: "preview123",
        type: "Botschaft der Bundesrepublik Deutschland",
        countryName: "Vorschau-Land",
        city: "Musterstadt",
        address: "Teststraße 123, 12345 Musterstadt",
        phone: "+49 123 4567890",
        email: "muster.botschaft@example.com",
        url: "https://www.example-botschaft.de",
        openingHours: "Mo-Fr: 09:00 - 12:00 Uhr\nNachmittags nach Vereinbarung.",
        remark: "Dies ist ein Beispielhinweis für die Vorschau. Bitte beachten Sie die aktuellen Informationen auf der Webseite."
    )
    EmbassyDetailView(embassy: sampleEmbassy)
}
