//
//  User.swift
//  WeMeet
//
//  Created by Monae White.
//  This code uses addSnapshotListener to listen for changes to the user's Firestore document,  initializes new users with a document in Firestore, and listens for user changes.
//
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class User: ObservableObject {
    @Published var name : String = ""
    @Published var email : String = ""
    @Published var selectedMii : String = "Image 0"
    
    private let db = Firestore.firestore()
    
    init() {
        startListeningForUserChanges()
    }
    
    func startListeningForUserChanges() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let userRef = db.collection("Users").document(currentUser.uid)
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
                }
            }
            else {
                print("User document does not exist in Firestore.")
            }
        }
    }
    
    func initializeUserInFirestore() {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let userRef = db.collection("Users").document(user.uid)
        userRef.setData([
            "name": user.displayName ?? "Unknown User",
            "email": user.email ?? "No Email",
            "selectedMii": "Image 0"
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
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        
        let userRef = db.collection("Users").document(currentUser.uid)
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
