//
//  AddContactView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI

struct AddContactView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedMii: String = "defaultMii" // Default Mii image
    @State private var errorMessage: String?
    @ObservedObject var viewModel: ContactsViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let miis = (0..<25).map { "Image \($0)" }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input fields for Name and Email
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                // Mii Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a Mii:")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(miis, id: \.self) { mii in
                                Image(mii)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedMii == mii ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedMii = mii
                                    }
                            }
                        }
                    }
                }

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                // Add Contact Button
                Button(action: addContact) {
                    Text("Add Contact")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || email.isEmpty)
            }
            .padding()
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    private func addContact() {
        guard !name.isEmpty, !email.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        // Create a new contact
        let newContact = Contact(
            id: nil,
            name: name,
            email: email,
            selectedMii: selectedMii,
            refreshToken: nil
        )

        viewModel.addContact(contact: newContact)

        dismiss()
    }
}

#Preview {
    AddContactView(viewModel: ContactsViewModel())
}
