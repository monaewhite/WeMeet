//
//  SettingsView.swift
//  WeMeet
//
//  Created by Monae White on 11/12/24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var selectedMii: String
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Information Section
                Section(header: Text("Account Information")) {
                    //Text("Name: \(name)")
                    //Text("Email: \(email)") // Replace with actual user email
                    Button("Sign Out") {
                        // Add sign-out functionality
                    }
                        .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                }
                
                // Mii Avatar Selection Section
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Image(selectedMii) // Display current avatar
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        Button("Change Mii Avatar") {
                            // Code to open Mii selection view
                        }
                            .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                }
                
                // Notification Settings
                Section(header: Text("Notifications")) {
                    Toggle("Meeting Reminders", isOn: .constant(true))
                    Toggle("Availability Updates", isOn: .constant(true))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

//#Preview {
//    SettingsView()
//}
