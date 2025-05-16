//
//  TabSelection.swift
//  Expat App
//
//  Created by Dominik Baki on 30.04.25.
//

import Foundation

// Enum zur Definition der Tabs und ihrer Werte (muss Hashable sein für die Auswahl)
enum TabSelection: Equatable, Hashable {
    case home
    case checklists
    case embassy
    case profile
    case settings
}
