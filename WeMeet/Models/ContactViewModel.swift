//
//  ContactViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//

import Foundation
import FirebaseFirestore

struct Contact: Identifiable, Codable, Equatable {
    @DocumentID var id: String? // Firestore document ID
    var name: String
    var email: String
    var mii: String
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
}
