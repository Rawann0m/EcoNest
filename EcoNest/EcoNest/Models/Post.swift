//
//  Posts.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import Foundation
import FirebaseFirestore

struct Posts: Identifiable, Hashable {
    @DocumentID var id: String?
    let userId: String
    let content: [String]
    let timestamp: Timestamp
}
