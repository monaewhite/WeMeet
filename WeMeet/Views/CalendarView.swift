//
//  CalendarView.swift
//  WeMeet
//
//  Created by Monae White.
//  

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedView = "Monthly"
    @State private var selectedDate = Date()
    @State private var navigateToSettings = false
    @State private var navigateToContacts = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { navigateToContacts = true }) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: geometry.size.width * 0.08))
                            .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                    Button(action: { navigateToSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: geometry.size.width * 0.08))
                            .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    }
                }
                .padding(.top, geometry.size.width * 0.02)
                .padding(.trailing, geometry.size.width * 0.02)
                
                // Mii Images
                VStack {
                    viewModel.displayUserAndContacts(user: user, geometry: geometry)
                }
                .frame(height: geometry.size.height * 0.3)

                Spacer()

                // Calendar Views
                ZStack {
                    if selectedView == "Monthly" {
                        CalendarMonthlyView(selectedDate: $selectedDate, user: user, selectedContacts: viewModel.selectedContacts)
                            .frame(height: geometry.size.height * 0.5)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                    if selectedView == "Weekly" {
                        CalendarWeeklyView(selectedDate: $selectedDate, user: user, selectedContacts: viewModel.selectedContacts)
                            .frame(height: geometry.size.height * 0.5)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .frame(width: geometry.size.width)

                Spacer()

                // View Toggle Buttons
                HStack {
                    ForEach(["Monthly", "Weekly"], id: \.self) { view in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedView = view
                            }
                        }) {
                            Text(view)
                                .font(.headline)
                                .foregroundColor(selectedView == view ? .white : Color(red: 0, green: 0.6, blue: 0.81))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedView == view ? Color(red: 0, green: 0.6, blue: 0.81) : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: geometry.size.width)
            }
            .background(
                Image("Mii Channel 2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            user.startListeningForUserChanges()
        }
        .navigationDestination(isPresented: $navigateToContacts) {
            ContactsView()
                .environmentObject(user)
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(isSignedIn: .constant(true))
                .environmentObject(user)
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(User())
}
