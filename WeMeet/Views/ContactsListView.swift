//
//  ContactsListView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

//struct ContactsListView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var user: User
//    @State private var contacts: [Contact] = []
//    @State private var errorMessage: String?
//    @State private var isLoading = true
//    @State private var showAddContactView = false
//    @State private var showInviteLink = false // For inviting contacts to authenticate
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if isLoading {
//                    ProgressView()
//                } else {
//                    List {
//                        // Show the contacts below the user's profile
//                        Section(header: Text("Contacts")) {
//                            HStack {
//                                Image(user.selectedMii)
//                                    .resizable()
//                                    .frame(width: 50, height: 50)
//                                    .clipShape(Circle())
//                                VStack(alignment: .leading) {
//                                    Text(user.name.isEmpty ? "Unknown User" : user.name)
//                                        .font(.headline)
//                                    Text(user.email.isEmpty ? "No Email" : user.email)
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            ForEach(contacts) { contact in
//                                HStack {
//                                    Image(contact.mii)
//                                        .resizable()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                    VStack(alignment: .leading) {
//                                        Text(contact.name)
//                                            .font(.headline)
//                                        Text(contact.email)
//                                            .font(.subheadline)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                            }
//                            .onDelete(perform: deleteContact) // Swipe to delete
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Contacts")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showAddContactView = true
//                    }) {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.title)
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddContactView) {
////                AddContactView()
//            }
//            .onAppear {
//                fetchContacts()
//            }
//        }
//    }
//
//    private func fetchContacts() {
//        guard let currentUser = Auth.auth().currentUser else {
//            errorMessage = "User not logged in"
//            return
//        }
//
//        let db = Firestore.firestore()
//        let contactsRef = db.collection("Users").document(currentUser.uid).collection("Contacts")
//
//        contactsRef.getDocuments { snapshot, error in
//            if let error = error {
//                self.errorMessage = "Failed to fetch contacts: \(error.localizedDescription)"
//                self.isLoading = false
//                return
//            }
//
//            guard let documents = snapshot?.documents else {
//                self.errorMessage = "No contacts found"
//                self.isLoading = false
//                return
//            }
//
//            self.contacts = documents.compactMap { try? $0.data(as: Contact.self) }
//            self.isLoading = false
//        }
//    }
//
//    private func deleteContact(at offsets: IndexSet) {
//        guard let currentUser = Auth.auth().currentUser else { return }
//
//        let db = Firestore.firestore()
//        offsets.forEach { index in
//            let contact = contacts[index]
//            if let contactID = contact.id {
//                let contactRef = db.collection("Users").document(currentUser.uid).collection("Contacts").document(contactID)
//
//                contactRef.delete { error in
//                    if let error = error {
//                        print("Failed to delete contact: \(error.localizedDescription)")
//                    } else {
//                        self.contacts.remove(at: index)
//                    }
//                }
//            }
//        }
//    }
//}
