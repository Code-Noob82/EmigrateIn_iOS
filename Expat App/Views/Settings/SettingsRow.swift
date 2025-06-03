//
//  SettingsRow.swift
//  Expat App
//
//  Created by Dominik Baki on 03.06.25.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(.vertical, 10) // Vertikales Padding für den Inhalt der Zeile
            Divider()
        }
        .padding(.horizontal) // Horizontales Padding für den Inhalt der Zeile, relativ zur Karte
    }
}

//#Preview {
//    SettingsRow()
//}
