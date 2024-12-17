//
//  ContactsView.swift
//  WeMeet
//
//  Created by Monae White.
//  

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @EnvironmentObject var user: User
    @State private var showAddContactView = false

    var body: some View {
        NavigationView {
            VStack {
                contactList // Refactored List for compiler errors
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddContactView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
            .tint(Color(red: 0, green: 0.6, blue: 0.81))
            .sheet(isPresented: $showAddContactView) {
                AddContactView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.fetchContacts()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Forces a single-column layout on iPad
    }

    private var contactList: some View {
        List {
            ForEach(viewModel.contacts) { contact in
                ContactRow(contact: contact, isSelected: viewModel.selectedContacts.contains { $0.uid == contact.uid }) {
                    viewModel.toggleContactSelection(contact)
                }
            }
            .onDelete(perform: viewModel.deleteContact)
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ContactRow: View {
    let contact: User
    let isSelected: Bool
    let onToggleSelection: () -> Void

    var body: some View {
        HStack {
            Image(contact.selectedMii)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color(red: 0, green: 0.6, blue: 0.81) : .gray)
            }
        }
    }
}

#Preview {
    ContactsView()
        .environmentObject(User())
}

