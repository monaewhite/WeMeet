//
//  ContentView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @StateObject private var user = User()
    
    var body: some View {
        NavigationStack {
            WelcomeView(isSignedIn: $isSignedIn)
                .environmentObject(user)
        }
        .onAppear {
            checkUserSignInStatus()
        }
    }
    
    private func checkUserSignInStatus() {
        guard let currentUser = Auth.auth().currentUser else {
            isSignedIn = false
            return
        }

        isSignedIn = true

        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(currentUser.uid)

        userRef.getDocument { [weak user] document, error in
            if let document = document, document.exists {
                print("User already exists in Firestore")
                user?.startListeningForUserChanges()
            } else {
                user?.initializeUserInFirestore()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(User())
}
