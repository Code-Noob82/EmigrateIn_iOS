//
//  AppTabView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - AppTabView (Hauptansicht nach Login)
struct AppTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Zugriff auf das ViewModel
    @State private var selectedTab: TabSelection = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Start", systemImage: "house.fill", value: .home) {
                // .environmentObject(InfoHubViewModel())
            }
            Tab("Checklisten", systemImage: "checklist.checked", value: .checklists) {
                // .environmentObject(ChecklistViewModel())
            }
            Tab("Botschaft", systemImage: "building.columns.fill", value: .embassy) {
                // .environmentObject(EmbassyInfoViewModel())
            }
            Tab("Profil", systemImage: "person.crop.circle.fill", value: .profile) {
                ProfileView()
            }
        }
    }
}

#Preview("AppTabView") {
    AppTabView()
        .environmentObject(AuthenticationViewModel())
}
