//
//  SplashScreenView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

struct SplashScreenView: View {
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Image("1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 361, height: 361)
                
                Text("Gut vorbereitet auswandern – mit EmigrateIn")
                    .font(Font.custom("SFPro", size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppStyles.primaryTextColor)
            }
            .padding()
        }
    }
}

#Preview {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        SplashScreenView()
    }
}
