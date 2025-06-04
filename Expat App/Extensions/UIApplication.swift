//
//  await UIApplication.swift
//  Expat App
//
//  Created by Dominik Baki on 07.05.25.
//

import Foundation
import UIKit

// MARK: - Hilfsextension für Root View Controller (für Google Sign In)
extension UIApplication {
    var keyWindowPresentedController: UIViewController? {
        let windowScene = self.connectedScenes
        // Filtere nach aktiven Scenes im Vordergrund
            .filter { $0.activationState == .foregroundActive }
        // Nimm die erste Scene, die eine UIWindowScene ist
            .first { $0 is UIWindowScene } as? UIWindowScene
                 
        // Finde das Fenster in dieser Scene, das das Key Window ist
        let keyWindow = windowScene?.windows.first(where: { $0.isKeyWindow })
                 
        // Gehe von RootViewController zum obersten präsentierten Controller
        var topController = keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
