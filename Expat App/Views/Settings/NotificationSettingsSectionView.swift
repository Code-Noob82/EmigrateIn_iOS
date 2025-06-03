//
//  NotificationSettingsSectionView.swift
//  Expat App
//
//  Created by Dominik Baki on 03.06.25.
//

import SwiftUI
import FirebaseFirestore

// NEU: Eigene View für den Benachrichtigungs-Einstellungsbereich
struct NotificationSettingsSectionView: View {
    // Zustandvariablen für diesen Bereich
    // Später durch @EnvironmentObject var authViewModel: AuthenticationViewModel ersetzen
    // und die Werte aus authViewModel.userProfile?.settings oder authViewModel.userSettings beziehen
    @State private var generalPushNotificationsEnabled: Bool = true
    @State private var appNewsUpdatesEnabled: Bool = true
    @State private var directMessagesEnabled: Bool = false
    @State private var stateSpecificNewsEnabled: Bool = false
    @State private var groupActivityNotificationsEnabled: Bool = false
    @State private var mentionsNotificationsEnabled: Bool = false
    
    var body: some View {
        settingsCard(title: "Benachrichtigungen") {
            // Übergeordneter Schalter
            SettingsRow {
                Toggle(isOn: $generalPushNotificationsEnabled) {
                    Text("Allgemeine Push-Benachrichtigungen")
                        .foregroundColor(AppStyles.primaryTextColor)
                }
                .tint(Color.accentColor)
                .onChange(of: generalPushNotificationsEnabled) { _, newValue in
                    print("Allgemeine Push-Benachrichtigungen: \(newValue)")
                    // Wenn der Hauptschalter deaktiviert wird, könnten hier auch
                    // die spezifischen Einstellungen im ViewModel aktualisiert werden (z.B. alle auf false setzen)
                }
            }
            // App-spezifische Benachrichtigungen
            SettingsRow {
                Toggle(isOn: $appNewsUpdatesEnabled) {
                    Text("App-Neuigkeiten und Updates")
                        .foregroundColor(generalPushNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                }
                .tint(Color.accentColor)
                .disabled(!generalPushNotificationsEnabled)
                .onChange(of: appNewsUpdatesEnabled) { _, newValue in
                    if generalPushNotificationsEnabled {
                        print("App-Neuigkeiten und Updates: \(newValue)")
                        // Hier später: await authViewModel.updateAppNewsPreference(isEnabled: newValue)
                    }
                }
            }
            SettingsRow {
                Toggle(isOn: $stateSpecificNewsEnabled) {
                    Text("Benachrichtigungen zu meinem Bundesland (comming soon)")
                        .foregroundColor(generalPushNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                }
                .tint(Color.accentColor)
                .disabled(!generalPushNotificationsEnabled)
                .onChange(of: stateSpecificNewsEnabled) { _, newValue in
                    if generalPushNotificationsEnabled {
                        print("Benachrichtigungen zum Bundesland: \(newValue)")
                        // Hier später: await authViewModel.updateStateSpecificNewsPreference(isEnabled: newValue)
                    }
                }
            }
            // Community-Interaktionen
            SettingsRow {
                Toggle(isOn: $directMessagesEnabled) {
                    Text("Neue Direktnachrichten (cooming soon)")
                        .foregroundColor(generalPushNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                }
                .tint(Color.accentColor)
                .disabled(!generalPushNotificationsEnabled)
                .onChange(of: directMessagesEnabled) { _, newValue in
                    if generalPushNotificationsEnabled {
                        print("Neue Direktnachrichten: \(newValue)")
                        // Hier später: await authViewModel.updateDirectMessagesPreference(isEnabled: newValue)
                    }
                }
            }
            SettingsRow {
                Toggle(isOn: $groupActivityNotificationsEnabled) {
                    Text("Aktivitäten in Gruppen/Foren (comming soon)")
                        .foregroundColor(generalPushNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                }
                .tint(Color.accentColor)
                .disabled(!generalPushNotificationsEnabled)
                .onChange(of: groupActivityNotificationsEnabled) { _, newValue in
                    if generalPushNotificationsEnabled {
                        print("Aktivitäten in Gruppen/Foren: \(newValue)")
                        // Hier später: await authViewModel.updateGroupActivityPreference(isEnabled: newValue)
                    }
                }
            }
            SettingsRow { // Letzte Zeile in dieser Sektion
                Toggle(isOn: $mentionsNotificationsEnabled) {
                    Text("Wenn ich erwähnt werde (comming soon)")
                        .foregroundColor(generalPushNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                }
                .tint(Color.accentColor)
                .disabled(!generalPushNotificationsEnabled)
                .onChange(of: mentionsNotificationsEnabled) { _, newValue in
                    if generalPushNotificationsEnabled {
                        print("Benachrichtigungen bei Erwähnungen: \(newValue)")
                        // Hier später: await authViewModel.updateMentionsPreference(isEnabled: newValue)
                    }
                }
            }
        }
    }
    // Hilfsfunktion für Karten-Layout (könnte auch globaler sein, wenn von mehreren Sektionen genutzt)
    // Für diese Demo bleibt sie hier, könnte aber auch in SettingsView verbleiben und an NotificationSettingsSectionView übergeben werden.
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
        .background(AppStyles.cellBackgroundColor.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal) // Abstand der Karte zu den Bildschirmrändern
    }
}

#Preview {
    NotificationSettingsSectionView()
}
