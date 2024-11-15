//
//  CalendarMonthView.swift
//  WeMeet
//
//  Created by Monae White on 11/12/24.
//  Add a function that adds .overlay() in blue to the user's free days

import SwiftUI

struct CalendarMonthView: View {
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

    var body: some View {
        VStack {
            HStack {
                Text(currentMonthYearString())
                    .font(.title2)
                    .fontWeight(.bold)
//                Spacer()
//                Button(action: previousMonth) {
//                    Image(systemName: "chevron.left")
//                }
//                Button(action: nextMonth) {
//                    Image(systemName: "chevron.right")
//                }
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
    }
}
#Preview {
    CalendarMonthView(selectedDate: .constant(Date()))
}
