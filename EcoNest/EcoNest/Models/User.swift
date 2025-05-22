//
//  User.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Hashable {
    @DocumentID var id: String?
    let username: String
    let email: String
    let favoritePlants: [String]?
    let profileImage: String
    var receiveMessages: Bool
}
