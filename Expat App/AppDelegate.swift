//
//  AppDelegate.swift
//  Expat App
//
//  Created by Dominik Baki on 15.05.25.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("AppDelegate: Firebase wurde in didFinishLaunchingWithOptions konfiguriert.")
        
        self.runIsolatedFirestoreTest()
        
        return true
    }
    
    // Definiere die Testfunktion hier (oder als static func)
    func runIsolatedFirestoreTest() {
        let db = Firestore.firestore()
        let testDocRef = db.collection("debug_map_tests").document("doc1")

        print("ISOLIERTER TEST: Lese debug_map_tests/doc1...")

        // Test mit getDocument()
        testDocRef.getDocument { (document, error) in
            if let error = error {
                print("ISOLIERTER TEST (getDocument) - FEHLER: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let rawData = document.data()
                print("ISOLIERTER TEST (getDocument) - Rohdaten des Dokuments: \(rawData ?? [:])")
                
                if let simpleMapDataField = rawData?["simpleMapData"] {
                    print("ISOLIERTER TEST (getDocument) - Feld 'simpleMapData' gefunden. Typ: \(type(of: simpleMapDataField))")
                    if let mapValue = simpleMapDataField as? [String: Bool] {
                        print("ISOLIERTER TEST (getDocument) - simpleMapData erfolgreich als [String: Bool] gelesen: \(mapValue)")
                    } else if let mapValueAny = simpleMapDataField as? [String: Any] {
                        print("ISOLIERTER TEST (getDocument) - simpleMapData als [String: Any] gelesen: \(mapValueAny)")
                        // Versuch einer manuellen Konvertierung, falls es als [String: Any] ankommt
                        var tempMap: [String: Bool] = [:]
                        var conversionError = false
                        for (key, value) in mapValueAny {
                            if let boolVal = value as? Bool {
                                tempMap[key] = boolVal
                            } else if let intVal = value as? Int, (intVal == 0 || intVal == 1) {
                                tempMap[key] = (intVal == 1)
                            } else {
                                print("ISOLIERTER TEST (getDocument) - MANUELLE KONVERTIERUNG WARNUNG: Wert für Key '\(key)' ist weder Bool noch Int(0/1): \(value)")
                                conversionError = true
                            }
                        }
                        if !conversionError {
                             print("ISOLIERTER TEST (getDocument) - simpleMapData MANUELL KONVERTIERT: \(tempMap)")
                        } else {
                             print("ISOLIERTER TEST (getDocument) - MANUELLE KONVERTIERUNG FEHLGESCHLAGEN")
                        }
                    } else {
                        print("ISOLIERTER TEST (getDocument) - Feld 'simpleMapData' konnte nicht als Dictionary konvertiert werden.")
                    }
                } else {
                     print("ISOLIERTER TEST (getDocument) - Feld 'simpleMapData' nicht in Rohdaten gefunden.")
                }
            } else {
                print("ISOLIERTER TEST (getDocument) - Dokument nicht gefunden oder existiert nicht.")
            }
        }

        // Optional: Test mit Listener (kannst du erstmal auskommentiert lassen, getDocument ist wichtiger)
        /*
        testDocRef.addSnapshotListener { (documentSnapshot, error) in
            // ... (ähnliche Logik)
        }
        */
    }
}
