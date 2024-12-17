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
    @State private var navigateToWelcome = false
    @Binding var isSignedIn: Bool
    @Environment(\.dismiss) private var dismiss
    
    private func signOut() {
        DispatchQueue.global(qos: .userInitiated).async {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                DispatchQueue.main.async {
                    isSignedIn = false
                    user.name = ""
                    user.email = ""
                    user.selectedMii = "Image 0"
                    dismiss()
                }
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Account Informations
                Section(header: Text("Account Information")) {
                    Text("Name: \(user.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Email: \(user.email)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Sign Out") {
                        signOut()
                        navigateToWelcome = true
                    }
                    .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                }
                
                // Mii Avatar Selection
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Image(user.selectedMii)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fill)
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
                        Text("1 Month").tag(1)
                        Text("3 Months").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
//                // Notifications
//                Section(header: Text("Notifications")) {
//                    Toggle("Availability Updates", isOn: .constant(true))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tint(Color(red: 0, green: 0.6, blue: 0.81))
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .onChange(of: isSignedIn) {
            navigateToWelcome = true
        }
        .navigationDestination(isPresented: $navigateToWelcome) {
            WelcomeView(isSignedIn: .constant(false))
                .environmentObject(user)
        }
        .navigationDestination(isPresented: $navigateToMiiSelection) {
            MiiSelectionView()
                .environmentObject(user)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Forces a single-column layout on iPad
    }
}

#Preview {
    SettingsView(isSignedIn: .constant(true))
        .environmentObject(User())
}
