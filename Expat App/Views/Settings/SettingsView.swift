//
//  SettingsView.swift
//  Expat App
//
//  Created by Dominik Baki on 16.05.25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Zustandvariablen
    @State private var pushNotificationsEnabled: Bool = true
    @State private var selectedTheme: AppTheme = .system
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    private var appDisplayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "EmigrateIn" // Fallback
    }
    private var currentYear: String {
        let year = Calendar.current.component(.year, from: Date())
        return String(year)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) { // Haupt-VStack, der Header, ScrollView und Footer enthält
                // MARK: - Custom Header
                HStack {
                    Text("Einstellungen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppStyles.primaryTextColor)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(AppStyles.backgroundGradient)
                .overlay(Divider(), alignment: .bottom)
                
                // MARK: - ScrollView für Inhalte
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Benachrichtigungen Karte
                        settingsCard(title: "Benachrichtigungen") {
                            SettingsRow {
                                Toggle(isOn: $pushNotificationsEnabled) {
                                    Text("Push-Benachrichtigungen")
                                        .foregroundColor(AppStyles.primaryTextColor)
                                }
                                .tint(Color.accentColor)
                                .onChange(of: pushNotificationsEnabled) { _, newValue in
                                    print("Push-Benachrichtigungen: \(newValue)")
                                }
                            }
                        }
                        
                        // MARK: - Darstellung Karte
                        settingsCard(title: "Darstellung") {
                            SettingsRow {
                                Menu {
                                    ForEach(AppTheme.allCases) { theme in
                                        Button {
                                            selectedTheme = theme
                                        } label: {
                                            Label(theme.rawValue, systemImage: theme.icon)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("Theme")
                                            .foregroundColor(AppStyles.primaryTextColor)
                                        Spacer()
                                        Text(selectedTheme.rawValue)
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundColor(AppStyles.secondaryTextColor)
                                    }
                                }
                                .onChange(of: selectedTheme) { _, newTheme in
                                    print("Theme geändert zu: \(newTheme.rawValue)")
                                }
                            }
                        }
                        
                        // MARK: - Rechtliches Karte
                        settingsCard(title: "Rechtliches") {
                            SettingsRow {
                                navigationButton(title: "Datenschutzerklärung", systemImage: "doc.text.fill", action: openPrivacyPolicy)
                            }
                            SettingsRow {
                                navigationButton(title: "Nutzungsbedingungen", systemImage: "doc.text.fill", action: openTermsOfService)
                            }
                        }
                        
                        // MARK: - Hilfe & Support Karte
                        settingsCard(title: "Hilfe & Support") {
                            SettingsRow {
                                navigationButton(title: "FAQ", systemImage: "questionmark.circle.fill", action: openFAQ)
                            }
                            SettingsRow {
                                navigationButton(title: "Kontakt zum Support", systemImage: "message.fill", action: openSupportContact)
                            }
                            SettingsRow {
                                navigationButton(title: "Feedback geben", systemImage: "bubble.left.and.bubble.right.fill", action: openFeedbackForm)
                            }
                        }
                        
                        // MARK: - Über die App Karte
                        settingsCard(title: "Über die App") {
                            SettingsRow {
                                HStack {
                                    Text("App Version")
                                        .foregroundColor(AppStyles.primaryTextColor)
                                    Spacer()
                                    Text("\(appVersion) (\(buildNumber))")
                                        .foregroundColor(AppStyles.secondaryTextColor)
                                }
                            }
                        }
                        
                        Spacer(minLength: 20) // Sorgt für etwas Platz am Ende des Scroll-Inhalts
                        
                    }
                    .padding(.vertical)
                } // Ende ScrollView
                
                // MARK: - Fixierter Footer
                VStack(spacing: 0) {
                    Divider() // Trennlinie über dem Footer
                    Text("© \(currentYear) \(appDisplayName). Alle Rechte vorbehalten.")
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10) // Vertikales Padding im Footer
                        .padding(.horizontal) // Horizontales Padding im Footer
                        .background(AppStyles.backgroundGradient.edgesIgnoringSafeArea(.bottom)) // Hintergrund für den Footer
                }
            } // Ende Haupt-VStack
            .background(AppStyles.backgroundGradient.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(colorScheme(for: selectedTheme))
        }
    }

    // MARK: - Hilfsfunktion für Karten-Layout (unverändert)
    @ViewBuilder
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 5)
            
            content()
        }
        .background(AppStyles.backgroundGradient)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Hilfsfunktion für Navigations-Buttons in Karten (unverändert)
    @ViewBuilder
    private func navigationButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundColor(AppStyles.primaryTextColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppStyles.secondaryTextColor.opacity(0.7))
            }
        }
    }
    
    // MARK: - Aktionen (unverändert)
    func openPrivacyPolicy() { print("Datenschutzerklärung öffnen...") }
    func openTermsOfService() { print("Nutzungsbedingungen öffnen...") }
    func openFAQ() { print("FAQ öffnen...") }
    func openSupportContact() { print("Support kontaktieren...") }
    func openFeedbackForm() { print("Feedback-Formular öffnen...") }
    
    private func colorScheme(for theme: AppTheme) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

#Preview {
    SettingsView()
}
