//
//  CalendarMonthView.swift
//  WeMeet
//
//  Created by Monae White.
//  

import SwiftUI

struct CalendarMonthView: View {
    @StateObject private var viewModel = CalendarMonthViewModel()
    @Binding var selectedDate: Date
    
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
            }
            .padding()

            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.semibold)
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
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(viewModel.availableDays.contains(makeDate(day: day)) ? Color(red: 0, green: 0.6, blue: 0.81) : Color.clear, lineWidth: 3))
                            }
                            else if dayIndex < startDayOffset { // Previous month's days
                                let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                                let daysInPreviousMonth = Calendar.current.range(of: .day, in: .month, for: previousMonthDate)!.count
                                let day = daysInPreviousMonth - (startDayOffset - dayIndex) + 1
                                Text("\(day)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                            }
                            else { // Next month's days
                                let day = dayIndex - (daysInMonth + startDayOffset) + 1
                                Text("\(day)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
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
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
        .padding(.horizontal, 20)
        .onAppear {
            viewModel.fetchAvailableDays()
        }
    }
}
#Preview {
    CalendarMonthView(selectedDate: .constant(Date()))
}
