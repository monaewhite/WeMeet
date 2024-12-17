//
//  CalendarWeeklyViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//  This code calculates time slots for each day in the week and checks for overlapping availability with selected contacts. 
//

import SwiftUI
import Foundation
import Combine
import FirebaseAuth

class CalendarWeeklyViewModel: ObservableObject {
    @Published var availableHours: [Int] = []
    private var api = GoogleCalendarAPI()

    func daysOfWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Placeholder for the first three letters in the name
        return formatter.string(from: date)
    }

    func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func fullDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a" // "h" for 12-hour clock, "a" for AM/PM
        guard let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) else { return "\(hour):00" }
        return formatter.string(from: date)
    }
    
    func fetchAvailableHours(for date: Date, user: User, selectedContacts: [User]) {
        let calendar = Calendar.current
        guard let startOfDay = calendar.startOfDay(for: date) as Date?,
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return
        }
        
        var allBusyIntervals: [[[String: String]]] = []
        let group = DispatchGroup()

        // Fetch current user's busy intervals
        group.enter()
        api.fetchFreeBusy(startDate: startOfDay, endDate: endOfDay) { result in
            switch result {
            case .success(let busyIntervals):
                allBusyIntervals.append(busyIntervals)
            case .failure(let error):
                print("Failed to fetch user's busy hours: \(error.localizedDescription)")
            }
            group.leave()
        }

        // Fetch busy intervals for selected contacts
        for contact in selectedContacts {
            group.enter()
            api.fetchFreeBusy(startDate: startOfDay, endDate: endOfDay /*, userID: contact.uid */) { result in
                switch result {
                case .success(let contactBusyIntervals):
                    allBusyIntervals.append(contactBusyIntervals)
                case .failure(let error):
                    print("Failed to fetch busy hours for \(contact.name): \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Calculate mutual availability once all requests are done
        group.notify(queue: .main) { [weak self] in
            if allBusyIntervals.isEmpty {
                self?.availableHours = []
                return
            }

            // Calculate mutual busy intervals
            let mutualBusyIntervals = self?.intersectBusyIntervals(allBusyIntervals) ?? []
            self?.availableHours = Calendar.calculateAvailableHours(for: startOfDay, busyIntervals: mutualBusyIntervals)
        }
    }

    private func intersectBusyIntervals(_ allBusyIntervals: [[[String: String]]]) -> [[String: String]] {
        guard !allBusyIntervals.isEmpty else { return [] }

        var mutualIntervals = allBusyIntervals[0]

        for intervals in allBusyIntervals.dropFirst() {
            mutualIntervals = mutualIntervals.filter { interval1 in
                intervals.contains { interval2 in
                    interval1["start"] == interval2["start"] && interval1["end"] == interval2["end"]
                }
            }
        }

        return mutualIntervals
    }
//    func fetchAvailableHours(for date: Date) {
//        let calendar = Calendar.current
//        guard let startOfDay = calendar.startOfDay(for: date) as Date?,
//              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
//            return
//        }
//        
//        api.fetchFreeBusy(startDate: startOfDay, endDate: endOfDay) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let busyIntervals):
//                    self?.availableHours = self?.calculateAvailableHours(busyIntervals: busyIntervals, startOfDay: startOfDay) ?? []
//                case .failure(let error):
//                    print("Failed to fetch available hours: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
 
}

extension Calendar {
    static func calculateAvailableHours(for date: Date, busyIntervals: [[String: String]]) -> [Int] {
        let formatter = ISO8601DateFormatter()
        let parsedIntervals = busyIntervals.compactMap { range -> (Date, Date)? in
            guard let start = formatter.date(from: range["start"] ?? ""),
                  let end = formatter.date(from: range["end"] ?? "") else { return nil }
            return (start, end)
        }

        let hoursInDay = Array(0..<24)
        let calendar = Calendar.current

        return hoursInDay.filter { hour in
            let hourStart = calendar.date(byAdding: .hour, value: hour, to: date)!
            let hourEnd = calendar.date(byAdding: .hour, value: hour + 1, to: date)!

            return !parsedIntervals.contains { interval in
                (interval.0 <= hourStart && hourStart < interval.1) ||
                (interval.0 < hourEnd && hourEnd <= interval.1)
            }
        }
    }
}
