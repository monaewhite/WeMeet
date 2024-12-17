//
//  AddContactView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddContactView: View {
    @ObservedObject var viewModel: ContactsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var selectedUser: User?
    @State private var errorMessage: String?

    // Searches Firestore for desired User to add as a contact
    private func searchUser() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You are not logged in."
            return
        }

        errorMessage = nil
        selectedUser = nil

        let db = Firestore.firestore()
        db.collection("Users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to search: \(error.localizedDescription)"
                    }
                    return
                }

                guard let document = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No user found with this email."
                    }
                    return
                }

                let data = document.data()
                guard
                    let uid = document.documentID as String?,
                    uid != currentUser.uid, // Prevents self-addition
                    let name = data["name"] as? String,
                    let email = data["email"] as? String,
                    let selectedMii = data["selectedMii"] as? String
                else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid user data or you cannot add yourself."
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.selectedUser = User(documentID: uid, name: name, email: email, selectedMii: selectedMii)
                }
            }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Search by Email:")
                        .font(.headline)

                    HStack {
                        TextField("Enter email address", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Button("Search") {
                            searchUser()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0, green: 0.6, blue: 0.81))
                        .disabled(email.isEmpty)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)

                // Display Found User
                if let selectedUser = selectedUser {
                    VStack(spacing: 10) {
                        Text("User Found:")
                            .font(.headline)

                        HStack {
                            Image(selectedUser.selectedMii)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(selectedUser.name)
                                    .font(.headline)
                                Text(selectedUser.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }

                        Button("Add Contact") {
                            viewModel.addContact(contactUID: selectedUser.uid) { error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.errorMessage = "Failed to add contact: \(error.localizedDescription)"
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.dismiss()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Add Contact", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Forces a single-column layout on iPad
    }
}

#Preview {
    AddContactView(viewModel: ContactsViewModel())
        .environmentObject(User())
}

