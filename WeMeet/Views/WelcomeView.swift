//
//  WelcomeView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @EnvironmentObject var user: User
    @Binding var isSignedIn: Bool
    @State private var navigateToCalendar = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Image("Mii Channel")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                
                VStack {
                    Text("WeMeet")
                        .font(.custom("Impact", size: 64, relativeTo: .largeTitle))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.bottom, 100)
                    
                    Text(viewModel.quoteText)
                        .font(.title2)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 16)
                        .padding()
                    
                    Text(viewModel.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 60)
                    
                    if isSignedIn {
                        Button(action: { navigateToCalendar = true}) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background((Color(red: 0, green: 0.6, blue: 0.81)))
                                .cornerRadius(20)
                                .padding(.horizontal)
                                .padding(.bottom, 250)
                        }
                    }
                    else {
                        Button(action: { signInWithGoogle { result in
                            switch result {
                            case .success:
                                isSignedIn = true
                                navigateToCalendar = true
                                errorMessage = nil
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title2)
                                Text("Sign in with Google")
                                    .font(.headline)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background((Color(red: 0, green: 0.6, blue: 0.81)))
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.bottom, 250)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToCalendar) {
                    CalendarView()
                        .environmentObject(user)
                }
                .onAppear {
                    viewModel.fetchQuote()
                    if isSignedIn {
                        user.startListeningForUserChanges()
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeView(isSignedIn: .constant(true))
        .environmentObject(User())
}
