//
//  CalendarMonthViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//

import Foundation
import FirebaseAuth
import Combine

class CalendarMonthViewModel: ObservableObject {
    @Published var availableDays: [Date] = []
    @Published var monthsAhead: Int = 3

    private let api = GoogleCalendarAPI()

    init() {
        loadUserPreferences()
    }
    
    private func loadUserPreferences() {
        monthsAhead = UserDefaults.standard.integer(forKey: "monthsAhead") == 0 ? 3 : UserDefaults.standard.integer(forKey: "monthsAhead")
    }
    
    private func getDynamicDateRange(monthsAhead: Int) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        let futureDate = calendar.date(byAdding: .month, value: monthsAhead, to: currentDate)!
        return (currentDate, futureDate)
    }
    
    func fetchAvailableDays() {
        let dateRange = getDynamicDateRange(monthsAhead: monthsAhead)

        api.fetchFreeBusy(startDate: dateRange.startDate, endDate: dateRange.endDate) { [weak self] result in
            switch result {
            case .success(let busyTimes):
                DispatchQueue.main.async {
                    self?.availableDays = self?.calculateAvailableDays(busyTimes: busyTimes, startDate: dateRange.startDate, endDate: dateRange.endDate) ?? []
                }
            case .failure(let error):
                print("Failed to fetch available days: \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateAvailableDays(busyTimes: [[String: String]], startDate: Date, endDate: Date) -> [Date] {
        let formatter = ISO8601DateFormatter()
        let busyDates = busyTimes.compactMap { range -> (Date, Date)? in
            guard let start = formatter.date(from: range["start"] ?? ""),
                  let end = formatter.date(from: range["end"] ?? "") else {
                return nil
            }
            return (start, end)
        }

        let allDates = stride(from: startDate, to: endDate, by: 60 * 60 * 24).map { $0 }
        return allDates.filter { date in
            !busyDates.contains { $0.0 <= date && date <= $0.1 }
        }
    }
}


