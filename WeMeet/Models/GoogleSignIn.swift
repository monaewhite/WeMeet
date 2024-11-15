//
//  GoogleSignIn.swift
//  WeMeet
//
//  Created by Monae White.
//  https://firebase.google.com/docs/auth/ios/google-signin

import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import UIKit

// Define a typealias for the completion handler to make the code cleaner
typealias SignInCompletion = (Result<Void, Error>) -> Void

// Configure Google Sign-In
func configureFirebaseApp() {
    FirebaseApp.configure()
}

// Handle the URL from Google Sign-In in AppDelegate
//func handleOpenURL(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//    return GIDSignIn.sharedInstance.handle(url)
//}

// Main function to handle Google Sign-In and Firebase Authentication
func signInWithGoogle(completion: @escaping SignInCompletion) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found."])))
        return
    }
    
    // Create Google Sign-In configuration object
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    // Start the sign-in process
    GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve authentication tokens."])))
            return
        }
        
        let accessToken = user.accessToken.tokenString
        
        // Firebase credential with the Google ID token and access token
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in with Firebase using the credential
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                completion(.success(()))
            }
        }
    }
}

private func getRootViewController() -> UIViewController {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        fatalError("Unable to get root view controller.")
    }
    return rootViewController
}

func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
    let firebaseAuth = Auth.auth()
    do {
        try firebaseAuth.signOut()
        completion(.success(()))
    } catch let signOutError as NSError {
        completion(.failure(signOutError))
    }
}
