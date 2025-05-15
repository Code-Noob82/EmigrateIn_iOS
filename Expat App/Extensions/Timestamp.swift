//
//  Timestamp.swift
//  Expat App
//
//  Created by Dominik Baki on 15.05.25.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    func dateFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self.dateValue())
    }
}
