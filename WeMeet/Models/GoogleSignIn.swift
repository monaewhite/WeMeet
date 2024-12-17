//
//  GoogleSignIn.swift
//  WeMeet
//
//  Created by Monae White.
//  This code implements the Google Sign In process, initializes new users with a document in Firestore, and listens for user changes.
//  
//  https://firebase.google.com/docs/auth/ios/google-signin

import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

typealias SignInCompletion = (Result<Void, Error>) -> Void

func configureFirebaseApp() {
    FirebaseApp.configure()
}

func signInWithGoogle(completion: @escaping SignInCompletion) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found."])))
        return
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController(), hint: nil, additionalScopes: ["https://www.googleapis.com/auth/calendar.readonly"]) { result, error in
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
        print("Access Token: \(accessToken)")
        
        saveAccessToken(accessToken)

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                let user = User()
                if let isNewUser = result.additionalUserInfo?.isNewUser, isNewUser {
                    print("New user detected. Initializing Firestore document.")
                    user.initializeUserInFirestore()
                } else {
                    print("Existing user detected. Fetching data.")
                }
                user.startListeningForUserChanges()
                completion(.success(()))
            }
        }
    }
}

private func saveAccessToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "GoogleAccessToken")
    print("Access token saved.")
}

func getAccessToken() -> String? {
    return UserDefaults.standard.string(forKey: "GoogleAccessToken")
}


private func getRootViewController() -> UIViewController {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        fatalError("Unable to get root view controller.")
    }
    return rootViewController
}

