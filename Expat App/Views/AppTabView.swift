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
    
    let backgroundGradient = AppStyles.backgroundGradient
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.stackedLayoutAppearance.normal.badgePositionAdjustment.horizontal = 5
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 16.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            TabView(selection: $authViewModel.selectedTab) {
                Tab("Start", systemImage: "house.fill", value: .home) {
                    InfoCategoryListView().environmentObject(authViewModel)
                }
                Tab("Checklisten", systemImage: "checklist.checked", value: .checklists) {
                    Text("Checklisten Inhalt")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppStyles.backgroundGradient)
                    // ChecklistView()
                }
                Tab("Botschaft", systemImage: "building.columns.fill", value: .embassy) {
                    EmbassyInfoView()
                }
                Tab("Profil", systemImage: "person.crop.circle.fill", value: .profile) {
                    ProfileView().environmentObject(authViewModel)
                }
                Tab("Einstellungen", systemImage: "gearshape.fill", value: .settings) {
                    SettingsView().environmentObject(authViewModel)
                }
            }
            .toolbarColorScheme(.light, for: .tabBar)
        }
    }
}

#Preview("AppTabView") {
    AppTabView()
        .environmentObject(AuthenticationViewModel())
}
