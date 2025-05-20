//
//  SectionView.swift
//  Expat App
//
//  Created by Dominik Baki on 20.05.25.
//

import SwiftUI

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .padding(.bottom, 2)
            Text(content)
                .font(.body)
        }
    }
}

#Preview {
    SectionView(title: "Beispieltitel", content: "Beispieltext")
}
