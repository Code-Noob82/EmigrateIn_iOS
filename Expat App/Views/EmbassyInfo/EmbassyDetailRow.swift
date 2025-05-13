//
//  EmbassyDetailRow.swift
//  Expat App
//
//  Created by Dominik Baki on 13.05.25.
//

import SwiftUI

// MARK: - Subview für eine einzelne Zeile mit Botschaftsinformationen
struct EmbassyDetailRow: View {
    let iconName: String
    let label: String
    let value: String?
    var linkType: LinkType? = nil
    var isMultiline = false
    
    enum LinkType {
        case phone, email, web
    }
    
    var body: some View {
        if let val = value, !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: iconName)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .frame(width: 20)
                    
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppStyles.secondaryTextColor.opacity(0.9))
                }
                
                Group {
                    if let type = linkType, let url = generateURL(from: val, type: type) {
                        Link(destination: url) {
                            Text(val)
                                .underline()
                        }
                    } else {
                        Text(val)
                    }
                }
                .font(isMultiline ? .body : .callout)
                .foregroundColor(AppStyles.primaryTextColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 28)
            }
            Divider().background(AppStyles.secondaryTextColor.opacity(0.2))
        }
    }
    // Erzeugt eine URL basierend auf dem Wert und Typ
    private func generateURL(from stringValue: String, type: LinkType) -> URL? {
        let trimmedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        switch type {
        case .phone:
            return URL(string: "tel: \(trimmedValue.filter { !$0.isWhitespace && !$0.isSymbol})")
        case .email:
            return URL(string: "mailto: \(trimmedValue)")
        case .web:
            var urlString = trimmedValue
            if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
                urlString = "https://\(urlString)"
            }
            return URL(string: urlString)
        }
    }
}

#Preview("EmbassyDetailRow Beispiele") {
    VStack(alignment: .leading, spacing: 20) { // Etwas mehr Abstand für die Vorschau
        
        // Beispiel 1: Einfache Zeile mit Wert
        EmbassyDetailRow(
            iconName: "building.columns.fill", // Beispiel-Icon
            label: "Behördenname",
            value: "Auswärtiges Amt - Zentrale"
        )
        
        // Beispiel 2: Telefonnummer als Link
        EmbassyDetailRow(
            iconName: "phone.fill",
            label: "Service-Telefon",
            value: "030 18172000",
            linkType: .phone
        )
        
        // Beispiel 3: E-Mail-Adresse als Link
        EmbassyDetailRow(
            iconName: "envelope.fill",
            label: "Bürgerservice E-Mail",
            value: "buergerservice@auswaertiges-amt.de",
            linkType: .email
        )
        
        // Beispiel 4: Webseite als Link
        EmbassyDetailRow(
            iconName: "globe",
            label: "Offizielle Webseite",
            value: "www.auswaertiges-amt.de",
            linkType: .web
        )
        
        // Beispiel 5: Mehrzeiliger Text
        EmbassyDetailRow(
            iconName: "text.alignleft", // Beispiel-Icon für Text
            label: "Wichtiger Hinweis",
            value: "Bitte beachten Sie, dass aufgrund der aktuellen Lage längere Wartezeiten entstehen können. Informieren Sie sich vorab online.",
            isMultiline: true
        )
        
        // Beispiel 6: Zeile mit optionalem Wert, der nil ist (sollte nicht angezeigt werden)
        EmbassyDetailRow(
            iconName: "printer.fill",
            label: "Faxnummer (optional)",
            value: nil // Dieser Wert ist nil
        )
        
        // Beispiel 7: Zeile mit optionalem Wert, der ein leerer String ist (sollte nicht angezeigt werden)
        EmbassyDetailRow(
            iconName: "questionmark.circle",
            label: "Zusatzinformation (leer)",
            value: "   " // Dieser Wert besteht nur aus Leerzeichen
        )
        
        // Beispiel 8: Lange einzeilige Information
        EmbassyDetailRow(
            iconName: "info.circle",
            label: "Kurzinfo",
            value: "Alle Angaben ohne Gewähr. Stand: Mai 2025."
        )
        
    }
    .padding() // Innenabstand für die VStack
    .background(AppStyles.backgroundGradient.ignoresSafeArea()) // Hintergrund aus AppStyles
}
