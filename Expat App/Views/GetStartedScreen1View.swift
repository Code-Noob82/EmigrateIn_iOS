//
//  OnboardingScreen1View.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI

// Represents the initial "Get Started" screen based on the provided image.
struct GetStartedScreenView: View {
    
    // Action to perform when the button is tapped.
    // This should be provided by the parent view to navigate further.
    var getStartedButtonAction: () -> Void = {} // Default empty action
    
    var body: some View {
        // ZStack allows layering views on top of each other (background image + content)
        ZStack {
            // --- Main Content VStack ---
            // This VStack now holds only the foreground content (Text, Card, Button)
            VStack {
                // --- App Name Overlay ---
                Spacer().frame(height: 7) // Adjust height as needed
                
                Text("EmigrateIn")
                    .font(
                        Font.custom("Inter", size: 60)
                            .weight(.semibold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Spacer() // Pushes the bottom card upwards
                
                // --- Bottom Card ---
                VStack(spacing: 30) { // Content inside the white card
                    Text("Bereit, Grenzen zu überschreiten?")
                        .font(
                            Font.custom("Inter", size: 34)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0, green: 0.48, blue: 0.55))
                    
                        .frame(width: 325.33954, alignment: .top)
                    
                    // --- Get Started Button ---
                    Button {
                        getStartedButtonAction()
                    } label: {
                        Text("Eure Auswanderung beginnt hier!")
                            .fontWeight(.semibold)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.1, green: 0.5, blue: 0.5)) // Teal-like color
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical, 30)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(
                    .rect(
                        topLeadingRadius: 25,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 25
                    )
                )
            } // End of Main Content VStack
            
        } // End of ZStack
        // --- Apply Background Image to the ZStack ---
        .background(
            Image("Get Started Bild2") // Replace with your image asset name
                .resizable() // Make image resizable
                .scaledToFill() // Scale to fill, potentially cropping
                .ignoresSafeArea() // Extend into safe areas
            // The 'alignment' parameter controls which part of the image is kept visible
            // when .scaledToFill crops the image.
            , alignment: .centerLastTextBaseline // <<< ÄNDERE DIESEN WERT!
            // Mögliche Werte: .top, .bottom, .leading, .trailing,
            // .topLeading, .topTrailing, .bottomLeading, .bottomTrailing, .center (Standard)
        )
    }
}

// --- Preview Provider ---
#Preview {
    GetStartedScreenView(getStartedButtonAction: {
        print("Get Started button tapped!")
    })
    // You might need to provide a placeholder image for the preview
    // .environment(\.imageProvider, YourPlaceholderImageProvider())
    
}
