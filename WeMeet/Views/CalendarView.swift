//
//  CalendarView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var user: User
    @State private var selectedView = "Monthly"
    @State private var selectedDate = Date()
    @State private var navigateToSettings = false
    @State private var navigateToContactsList = false
    @State private var addedContacts: [Contact] = [] // Tracks contacts added for comparison
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: { navigateToContactsList = true}) {
                    Image(systemName: "person.2.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                }
                Button(action: { navigateToSettings = true}) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                }
            }
            .padding(.top, 20)
            .padding(.trailing, 16)
            
            // Mii Avatar Image
            Image(user.selectedMii)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 260, height: 260)
                .padding(.top, -20)
                .padding(.bottom, 20)
            
            // Calendar View based on selected toggle
            VStack {
                if selectedView == "Monthly" {
                    CalendarMonthView(selectedDate: $selectedDate)

                }
//                else if selectedView == "Weekly" {
//                    CalendarWeeklyView(selectedDate: $selectedDate)
//                }
//                else if selectedView == "Daily" {
//                    CalendarDailyView(selectedDate: $selectedDate)
//                }
            }
                        
            // Toggle for Monthly, Weekly, and Daily Views
            HStack {
                ForEach(["Monthly", "Weekly", "Daily"], id: \.self) { view in
                    Button(action: {
                        selectedView = view
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
            .padding(.bottom, 20)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            user.startListeningForUserChanges()
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(isSignedIn: .constant(true))
                .environmentObject(user)
        }
//        .navigationDestination(isPresented: $navigateToContactsList) {
//            ContactsListView(addedContacts: $addedContacts)
//                .environmentObject(user)
//        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(User())
}
