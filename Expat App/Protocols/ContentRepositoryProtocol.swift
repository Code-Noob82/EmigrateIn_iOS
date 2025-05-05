//
//  ContentRepositoryProtocol.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import FirebaseFirestore

protocol ContentRepositoryProtocol {
    func fetchInfoCategories() async throws -> [InfoCategory]
    func fetchInfoContent(for categoryId: String) async throws -> [InfoContent]
}
