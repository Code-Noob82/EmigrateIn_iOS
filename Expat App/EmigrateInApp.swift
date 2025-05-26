//
//  Expat_AppApp.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct EmigrateInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    
    // Speichert, ob der Nutzer das Onboarding bereits abgeschlossen hat.
    // @AppStorage speichert diesen Wert persistent auf dem Gerät (in UserDefaults).
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // State für die Anzeige des Splash Screens
    @State private var showingSplashScreen = true
    
    let backgroundGradient = AppStyles.backgroundGradient
    
    let splashScreenFullText: String = "EmigrateIn - Dein Zuhause im Ausland startet hier!"
    
    // Initialisierer der App-Struktur
    init() {
        print("App init() aufgerufen.") // Debug-Ausgabe
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
                            let logoAnimationTotalDuration = 0.5 + 1.5
                            let textAnimationDuration = 1.0 + (Double(splashScreenFullText.count) * 0.05)
                            let totalSplashScreenAnimationTime = max(logoAnimationTotalDuration, textAnimationDuration)
                            let finalDelayBeforeTransition = totalSplashScreenAnimationTime + 0.5
                            
                            print("Logo Animation Dauer: \(logoAnimationTotalDuration)s")
                            print("Text Animation Dauer: \(textAnimationDuration)s")
                            print("Gesamt Splash Screen Animationsdauer: \(totalSplashScreenAnimationTime)s")
                            print("Endgültige Verzögerung vor Übergang: \(finalDelayBeforeTransition)s")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + finalDelayBeforeTransition) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showingSplashScreen = false
                                }
                            }
                        }
                } else if !hasCompletedOnboarding {
                    // Zeige das Onboarding, wenn es noch nicht abgeschlossen wurde
                    OnboardingContainerView {
                        // Diese Aktion wird ausgeführt, wenn der "Los geht's!" Button gedrückt wird
                        withAnimation(.easeOut(duration: 0.7)) {
                            hasCompletedOnboarding = true // Markiert Onboarding als abgeschlossen
                        }
                    }
                    .transition(.move(edge: .trailing))
                } else {
                    // Nach Splash & Onboarding: Zeige die ContentView, die den Auth-Status prüft
                    ContentView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .opacity)
                        )
                        .environmentObject(authViewModel) // Übergibt das ViewModel an ContentView und dessen Kinder
                }
            }
            .onOpenURL { incomingURL in
                // Diese Funktion wird aufgerufen, wenn die App über ein URL Scheme geöffnet wird.
                print("App wurde mit URL geöffnet: \(incomingURL)") // Debug-Ausgabe
                // Leite die URL an das Google Sign-In SDK weiter, damit es den Login abschließen kann.
                GIDSignIn.sharedInstance.handle(incomingURL)
            }
            .animation(.default, value: showingSplashScreen)
            .animation(.default, value: hasCompletedOnboarding)
        }
    }
}
