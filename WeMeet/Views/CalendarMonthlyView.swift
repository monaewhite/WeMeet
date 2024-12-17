//
//  CalendarMonthlyView.swift
//  WeMeet
//
//  Created by Monae White.
//  

import SwiftUI
import UIKit

struct CalendarMonthlyView: View {
    @StateObject private var viewModel = CalendarMonthlyViewModel()
    @Binding var selectedDate: Date
    var user: User
    var selectedContacts: [User]
    
    private var daysInMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: selectedDate)
        return range?.count ?? 0
    }
    
    private var startDayOffset: Int {
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate))!
        return Calendar.current.component(.weekday, from: firstDayOfMonth) - 1 // -1 to make Sunday = 0, Monday = 1, etc.
    }
    
    private func currentMonthYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func makeDate(day: Int) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return Calendar.current.date(from: DateComponents(year: components.year, month: components.month, day: day)) ?? Date()
    }

    var body: some View {
        VStack {
            HStack {
                Text(currentMonthYearString())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()

            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            
            // Generate rows for the days of the month
            let totalCells = daysInMonth + startDayOffset
            let rows = (totalCells / 7) + (totalCells % 7 == 0 ? 0 : 1)
            
            VStack {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \.self) { column in
                            let dayIndex = row * 7 + column
                            if dayIndex >= startDayOffset && dayIndex < daysInMonth + startDayOffset {
                                let day = dayIndex - startDayOffset + 1

                                Text("\(day)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 30).fill(Color(UIColor.systemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(viewModel.availableDays.contains(makeDate(day: day)) ? Color(red: 0, green: 0.6, blue: 0.81) : Color.clear, lineWidth: 2))
                            }
                            else if dayIndex < startDayOffset { // Previous month's days
                                let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                                let daysInPreviousMonth = Calendar.current.range(of: .day, in: .month, for: previousMonthDate)!.count
                                let day = daysInPreviousMonth - (startDayOffset - dayIndex) + 1
                                Text("\(day)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 30).fill(Color(UIColor.systemBackground)))
                            }
                            else { // Next month's days
                                let day = dayIndex - (daysInMonth + startDayOffset) + 1
                                Text("\(day)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 30).fill(Color(UIColor.systemBackground)))
                            }
                        }
                    }
                }
            }
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width < -50 { // Swipe left for next month
                            nextMonth()
                        }
                        else if gesture.translation.width > 50 { // Swipe right for previous month
                            previousMonth()
                        }
                    }
            )
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)).shadow(radius: 5))
        .padding(.horizontal, 20)
        .onAppear {
            viewModel.fetchAvailableDays(user: user, selectedContacts: selectedContacts)
        }
    }
}

#Preview {
    CalendarMonthlyView(selectedDate: .constant(Date()), user: User(documentID: "123", name: "Monae", email: "monaemwhite@gmail.com", selectedMii: "Image 0"), selectedContacts: [])
}
