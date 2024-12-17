//
//  WelcomeView.swift
//  WeMeet
//
//  Created by Monae White.
// 

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme // Detect the current color scheme
    @StateObject private var viewModel = WelcomeViewModel()
    @EnvironmentObject var user: User
    @Binding var isSignedIn: Bool
    @State private var navigateToCalendar = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                if colorScheme == .light {
                    Image("Mii Channel")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .bottom)
                }
                
                VStack {
                    Spacer()
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
                    
                    Spacer()
                    
                    if isSignedIn {
                        Button(action: { navigateToCalendar = true }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth:.infinity)
                                .background((Color(red: 0, green: 0.6, blue: 0.81)))
                                .cornerRadius(20)
                                .padding(.horizontal)
                                .padding(.bottom, 250)
                        }
                    } else {
                        Button(action: {
                            signInWithGoogle { result in
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
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToCalendar) {
                CalendarView()
            }
            .onAppear {
                viewModel.fetchQuote()
            }
        }
    }
}


#Preview {
    WelcomeView(isSignedIn: .constant(true))
        .environmentObject(User())
}
