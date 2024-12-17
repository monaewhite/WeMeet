//
//  ContactsViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//  This code fetches contact data from Firestore, manages the addition and removal of contacts, and allows toggling of selected contacts for shared calendar availability.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class ContactsViewModel: ObservableObject {
    @Published var contacts: [User] = []
    @Published var selectedContacts: [User] = [] // Contacts selected for CalendarView
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    
    func addContact(contactUID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("Users").document(currentUserUID)
        userRef.updateData([
            "grantedPermissions": FieldValue.arrayUnion([contactUID])
        ]) { error in
            completion(error)
        }
    }
    
    func fetchContacts() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: User is not authenticated.")
            DispatchQueue.main.async {
                self.errorMessage = "You must be logged in to view contacts."
            }
            return
        }

        let userRef = db.collection("Users").document(currentUser.uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch your contacts."
                }
                return
            }

            guard let data = document?.data(),
                  let grantedPermissions = data["grantedPermissions"] as? [String] else {
                print("No granted permissions found or invalid data format.")
                DispatchQueue.main.async {
                    self.contacts = [] // Ensure the contacts list is cleared
                }
                return
            }

            // Filter out empty or invalid IDs
            let validPermissions = grantedPermissions.filter { !$0.isEmpty }
            self.fetchUsers(from: validPermissions)
        }
    }

    private func fetchUsers(from uids: [String]) {
        guard !uids.isEmpty else {
            DispatchQueue.main.async {
                self.contacts = [] // No users to fetch
            }
            return
        }

        db.collection("Users")
            .whereField(FieldPath.documentID(), in: uids)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to fetch contacts."
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "No contacts found."
                    }
                    return
                }

                let users = documents.compactMap { document -> User? in
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let email = data["email"] as? String,
                          let selectedMii = data["selectedMii"] as? String else {
                        return nil
                    }
                    return User(documentID: document.documentID, name: name, email: email, selectedMii: selectedMii)
                }

                DispatchQueue.main.async {
                    self?.contacts = users
                }
            }
    }

    func toggleContactSelection(_ contact: User) {
        if selectedContacts.contains(where: { $0.uid == contact.uid }) {
            selectedContacts.removeAll { $0.uid == contact.uid }
        } else if selectedContacts.count < 2 {
            selectedContacts.append(contact)
        }
    }

    func deleteContact(at offsets: IndexSet) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            errorMessage = "No user is logged in."
            return
        }

        offsets.forEach { index in
            let contact = contacts[index]

            db.collection("Users").document(currentUserUID).updateData([
                "grantedPermissions": FieldValue.arrayRemove([contact.uid])
            ]) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to delete contact: \(error.localizedDescription)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.contacts.remove(at: index)
                    }
                }
            }
        }
    }
}
