//
//  User.swift
//  WeMeet
//
//  Created by Monae White.
//  This code uses addSnapshotListener to listen for changes to the user's Firestore document, initializes new users with a unique document in Firestore, and listens for user changes.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class User: ObservableObject, Identifiable, Codable {
    @Published var name : String = ""
    @Published var email : String = ""
    @Published var uid: String // Tied to Firestore document ID
    @Published var selectedMii : String = "Image 0"
    @Published var grantedPermissions: [String] = []
    
    private let db = Firestore.firestore()
    
    // Initializer
    init(documentID: String, name: String, email: String, selectedMii: String, grantedPermissions: [String] = []) {
        self.uid = documentID
        self.name = name
        self.email = email
        self.selectedMii = selectedMii
        self.grantedPermissions = grantedPermissions
    }
    
    init() {
        self.uid = ""
        startListeningForUserChanges()
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, email, uid, selectedMii, grantedPermissions
    }

    // Required by Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        uid = try container.decode(String.self, forKey: .uid)
        selectedMii = try container.decode(String.self, forKey: .selectedMii)
        grantedPermissions = try container.decode([String].self, forKey: .grantedPermissions)
    }
    
    // Required by Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(uid, forKey: .uid)
        try container.encode(selectedMii, forKey: .selectedMii)
        try container.encode(grantedPermissions, forKey: .grantedPermissions)
    }

    func startListeningForUserChanges() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }

        let userRef = db.collection("Users").document(currentUserUID)
        userRef.addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Error listening for user changes: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self?.name = data?["name"] as? String ?? "Unknown User"
                    self?.email = data?["email"] as? String ?? "No email"
                    self?.selectedMii = data?["selectedMii"] as? String ?? "Image 0"
                    self?.grantedPermissions = data?["grantedPermissions"] as? [String] ?? []
                }
            }
            else {
                print("User document does not exist in Firestore.")
            }
        }
    }
    
    func initializeUserInFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let userRef = db.collection("Users").document(currentUser.uid)
        userRef.setData([
            "name": currentUser.displayName ?? "Unknown User",
            "email": currentUser.email ?? "No Email",
            "selectedMii": "Image 0",
            "grantedPermissions": grantedPermissions
        ], merge: true) { [weak self] error in
            if let error = error {
                print("Failed to initialize user in Firestore: \(error.localizedDescription)")
            }
            else {
                print("User initialized successfully in Firestore.")
                self?.startListeningForUserChanges()
            }
        }
    }
    
    func updateSelectedMii(_ newMii: String) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        
        let userRef = db.collection("Users").document(currentUserUID)
        userRef.updateData(["selectedMii": newMii]) { error in
            if let error = error {
                print("Failed to update selected Mii in Firestore: \(error.localizedDescription)")
            }
            else {
                self.selectedMii = newMii
                print("Successfully updated selected Mii to: \(newMii)")
            }
        }
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.uid == rhs.uid
    }
}
