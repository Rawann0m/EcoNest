//
//  Community.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import Foundation
import FirebaseFirestore

struct Community: Identifiable, Hashable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let members: [String]
}
