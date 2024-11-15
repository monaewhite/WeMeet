//
//  CalendarView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedView = "Monthly"  
    @State private var selectedDate = Date()
    // @Binding var selectedMii: String

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                    .padding(.trailing, 8)
                
                Image(systemName: "person.crop.circle.badge.minus")
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0.6, blue: 0.81))
            }
            .padding(.top, 20)
            .padding(.trailing, 16)
            
            // Mii Avatar Image
            Image("Image 0") // Image(selectedMii)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 260, height: 260)
                .padding(.top, -20)
                .padding(.bottom, 20)
            
            // Display Calendar View based on selected toggle
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
    }
}

#Preview {
    CalendarView()
}
