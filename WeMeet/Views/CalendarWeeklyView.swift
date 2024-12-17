//
//  CalendarWeeklyView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI

struct CalendarWeeklyView: View {
    @StateObject private var viewModel = CalendarWeeklyViewModel()
    @Binding var selectedDate: Date
    var user: User
    var selectedContacts: [User]

    private func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? Date()
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    private func formatHour(_ hour: Int) -> String {
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        let period = hour < 12 ? "AM" : "PM"
        return "\(hour12) \(period)"
    }
    
    var body: some View {
        VStack {
            // Weekday Selector
            HStack {
                ForEach(0..<7, id: \.self) { offset in
                    let weekday = Calendar.current.date(byAdding: .day, value: offset, to: startOfWeek(for: selectedDate))!
                    Text(weekdayLabel(for: weekday))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(weekday.isSameDay(as: selectedDate) ? Color.black : Color.clear)
                        )
                        .foregroundColor(weekday.isSameDay(as: selectedDate) ? .white : .primary)
                        .onTapGesture {
                            selectedDate = weekday
                        }
                }
            }
            .padding()

            // Selected Date Display
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month().day().year()))
                .font(.headline)
                .padding(.vertical, 5)
                .foregroundColor(.primary)

            // Time Slot Grid
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(spacing: 0) {
                            // Time Label
                            Text(formatHour(hour))
                                .font(.system(size: 14))
                                .frame(width: 60, alignment: .trailing)
                                .padding(.trailing, 8)
                                .foregroundColor(.primary)

                            // Slot Grid
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground))
                                    .frame(height: 30)
                                    .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                // Highlighted Time Slot (Availability)
                                if viewModel.availableHours.contains(hour) {
                                    Rectangle().fill(Color(red: 0, green: 0.6, blue: 0.81).opacity(0.3)).cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)).shadow(radius: 5))
        .padding(.horizontal, 20)
        .onAppear {
            viewModel.fetchAvailableHours(for: selectedDate, user: user, selectedContacts: selectedContacts)
        }
    }
}

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}

#Preview {
    CalendarWeeklyView(selectedDate: .constant(Date()), user: User(documentID: "123", name: "Monae", email: "monaemwhite@gmail.com", selectedMii: "Image 0"), selectedContacts: [])
}
