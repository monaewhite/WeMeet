//
//  ContactViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class Contact: ObservableObject {
    @Published var contacts: [Contact] = [] // Stores fetched contacts
    @Published var errorMessage: String?
    @Published var isLoading = false // Tracks loading state

    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func addContact(contact: Contact) {
        guard let userId = userId else { return }
        
        let contactData: [String: Any] = [
            "name": contact.name,
            "email": contact.email,
            "selectedMii": contact.selectedMii,
            "refreshToken": contact.refreshToken ?? "" // Store empty string if nil
        ]
        
        db.collection("Users")
            .document(userId)
            .collection("Contacts")
            .addDocument(data: contactData) { error in
                if let error = error {
                    print("Error adding contact: \(error.localizedDescription)")
                } else {
                    print("Contact added successfully!")
                }
            }
    }
    
    func fetchContacts() {
        guard let userId = userId else {
            errorMessage = "User not logged in"
            return
        }

        isLoading = true
        let contactsRef = db.collection("Users").document(currentUser.uid).collection("Contacts")

        contactsRef.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.errorMessage = "Failed to fetch contacts: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No contacts found"
                    self.isLoading = false
                    return
                }
                
                self.contacts = documents.compactMap { try? $0.data(as: Contact.self) }
                self.isLoading = false
            }
        }
    }

    func deleteContact(at offsets: IndexSet) {
        guard let userId = userId else { return }

        offsets.forEach { index in
            let contact = contacts[index]
            if let contactID = contact.id {
                let contactRef = db.collection("Users").document(userId).collection("Contacts").document(contactID)

                contactRef.delete { error in
                    if let error = error {
                        print("Failed to delete contact: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.contacts.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}
