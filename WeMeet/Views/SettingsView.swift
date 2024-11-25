//
//  SettingsView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @AppStorage("monthsAhead") private var monthsAhead: Int = 3 
    @EnvironmentObject var user: User
    @State private var navigateToMiiSelection = false
    @State private var navigateToContent = false
    @Binding var isSignedIn: Bool
    @Environment(\.dismiss) private var dismiss

    private func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            user.name = ""
            user.email = ""
            user.selectedMii = "Image 0"
            isSignedIn = false
//            dismiss()
            navigateToContent = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    var body: some View {
        NavigationView {
            if navigateToContent {
                ContentView()
                    .environmentObject(user)
            } else {
                Form {
                    // Account Informations
                    Section(header: Text("Account Information")) {
                        Text("Name: \(user.name)")
                        Text("Email: \(user.email)")
                        Button("Sign Out") {
                            signOut()
                        }
                        .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                    
                    // Mii Avatar Selection
                    Section(header: Text("Profile Picture")) {
                        HStack {
                            Image(user.selectedMii)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            Button("Change Mii") {
                                navigateToMiiSelection = true
                            }
                            .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                        }
                    }
                    
                    // Months Ahead
                    Section(header: Text("Calendar Availablilty For")) {
                        Picker("Show Availability For", selection: $monthsAhead) {
                            Text("3 Months").tag(3)
                            Text("6 Months").tag(6)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Notifications
                    Section(header: Text("Notifications")) {
                        Toggle("Availability Updates", isOn: .constant(true))
                    }
                }
                .navigationTitle("Settings")
            }
        }
        .navigationDestination(isPresented: $navigateToContent) {
            ContentView().environmentObject(user)
        }
        .navigationDestination(isPresented: $navigateToMiiSelection) {
            MiiSelectionView().environmentObject(user)
        }
    }
}


#Preview {
    SettingsView(isSignedIn: .constant(true))
        .environmentObject(User())
}
