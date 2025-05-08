//
//  Expat_AppApp.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI
import Firebase // Firebase Core importieren
import GoogleSignIn

@main
struct EmigrateInApp: App {
    // ViewModel für Authentifizierung und Nutzerdaten (als StateObject für den App-Lebenszyklus)
    @StateObject var authViewModel = AuthenticationViewModel()
    
    // Speichert, ob der Nutzer das Onboarding bereits abgeschlossen hat.
    // @AppStorage speichert diesen Wert persistent auf dem Gerät (in UserDefaults).
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // State für die Anzeige des Splash Screens
    @State private var showingSplashScreen = true
    
    let backgroundGradient = AppStyles.backgroundGradient
    
    // Initialisierer der App-Struktur
    init() {
        // Konfiguriert Firebase beim Start der App.
        FirebaseApp.configure()
        print("Firebase configured!") // Debug-Ausgabe
    }
    
    var body: some Scene {
        WindowGroup {
            // --- Haupt-View-Logik ---
            ZStack {
                AppStyles.backgroundGradient.ignoresSafeArea()
                
                // Zeigt die passende Ansicht basierend auf dem Zustand
                if showingSplashScreen {
                    SplashScreenView()
                        .onAppear {
                            // Zeige den Splash Screen für eine kurze Zeit (z.B. 2 Sekunden)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showingSplashScreen = false
                                }
                            }
                        }
                } else if !hasCompletedOnboarding {
                    // Zeige das Onboarding, wenn es noch nicht abgeschlossen wurde
                    OnboardingContainerView {
                        // Diese Aktion wird ausgeführt, wenn der "Los geht's!" Button gedrückt wird
                        withAnimation {
                            hasCompletedOnboarding = true // Markiert Onboarding als abgeschlossen
                        }
                    }
                    // Übergib das ViewModel, falls das Onboarding es benötigen sollte (aktuell nicht der Fall)
                    // .environmentObject(authViewModel)
                } else {
                    // Nach Splash & Onboarding: Zeige die ContentView, die den Auth-Status prüft
                    ContentView()
                        .environmentObject(authViewModel) // Übergibt das ViewModel an ContentView und dessen Kinder
                }
            }
            .onOpenURL { incomingURL in
                // Diese Funktion wird aufgerufen, wenn die App über ein URL Scheme geöffnet wird.
                print("App wurde mit URL geöffnet: \(incomingURL)") // Debug-Ausgabe
                // Leite die URL an das Google Sign-In SDK weiter, damit es den Login abschließen kann.
                GIDSignIn.sharedInstance.handle(incomingURL)
            }
        }
    }
}
