//
//  SectionView.swift
//  Expat App
//
//  Created by Dominik Baki on 20.05.25.
//

import SwiftUI
import MarkdownUI

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppStyles.primaryTextColor)
                .padding(.bottom, 2)
            
            Markdown(content)
                .markdownTheme(.basic)
                .font(.body)
                .foregroundColor(AppStyles.secondaryTextColor)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SectionView(title: "Beispieltitel", content: "Beispieltext")
}
