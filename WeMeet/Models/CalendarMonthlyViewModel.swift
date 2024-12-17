//
//  CalendarMonthlyViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//  This code fetches user data and calculates shared availability for the specified month based on stored free/busy data. 
//

import Foundation
import FirebaseAuth
import Combine

class CalendarMonthlyViewModel: ObservableObject {
    @Published var availableDays: Set<Date> = []
    @Published var monthsAhead: Int = UserDefaults.standard.integer(forKey: "monthsAhead") == 1 ? 3 : UserDefaults.standard.integer(forKey: "monthsAhead")

    private let api = GoogleCalendarAPI()
    
    init() {
        loadUserPreferences()
    }
    
    private func loadUserPreferences() {
        monthsAhead = UserDefaults.standard.integer(forKey: "monthsAhead") == 1 ? 3 : UserDefaults.standard.integer(forKey: "monthsAhead")
    }
    
    private func getDynamicDateRange(monthsAhead: Int) -> (startDate: Date, endDate: Date) {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.timeZone = TimeZone(abbreviation: "UTC") 
        
        // Start of the current month
        components.day = 1
        let startOfMonth = calendar.date(from: components)!
        
        let futureDate = calendar.date(byAdding: .month, value: monthsAhead, to: startOfMonth)!
        
        print("Normalized Start of Month (UTC): \(startOfMonth)")
        print("Normalized Future Date (UTC): \(futureDate)")
        
        return (startOfMonth, futureDate)
    }
    
    func fetchAvailableDays(user: User, selectedContacts: [User]) {
        let dateRange = getDynamicDateRange(monthsAhead: monthsAhead)
        
        if selectedContacts.isEmpty {
            api.fetchFreeBusy(startDate: dateRange.startDate, endDate: dateRange.endDate) { [weak self] result in
                switch result {
                case .success(let busyTimes):
                    print("Busy Times: \(busyTimes)")
                    self?.updateAvailableDays(busyTimes: busyTimes, startDate: dateRange.startDate, endDate: dateRange.endDate)
                case .failure(let error):
                    print("Failed to fetch available days: \(error.localizedDescription)")
                }
            }
        } else {
            // Fetch mutual availability between user and selected contacts
            var mutuallyBusyTimes: [[String: String]] = []
            let group = DispatchGroup()
            
            var allBusyTimes: [[[String: String]]] = []
                
            // Fetch busy times for the user
            group.enter()
            api.fetchFreeBusy(startDate: dateRange.startDate, endDate: dateRange.endDate/*, userID: user.uid*/) { result in
                switch result {
                case .success(let busyTimes):
                    allBusyTimes.append(busyTimes)
                default:
                    print("Failed to fetch user's busy times.")
                }
                group.leave()
            }
                
            // Fetch busy times for each selected contact
            for contact in selectedContacts {
                group.enter()
                api.fetchFreeBusy(startDate: dateRange.startDate, endDate: dateRange.endDate/*, userID: contact.uid*/) { result in
                    switch result {
                    case .success(let contactBusyTimes):
                        allBusyTimes.append(contactBusyTimes)
                    case .failure(let error):
                        print("Failed to fetch busy times for \(contact.name): \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }
                
            group.notify(queue: .main) { [weak self] in
                mutuallyBusyTimes = self?.intersectAllBusyTimes(allBusyTimes: allBusyTimes) ?? []
                self?.updateAvailableDays(busyTimes: mutuallyBusyTimes, startDate: dateRange.startDate, endDate: dateRange.endDate)
            }
        }
    }

    private func intersectAllBusyTimes(allBusyTimes: [[[String: String]]]) -> [[String: String]] {
        guard !allBusyTimes.isEmpty else { return [] }

        // Start with the first user's busy times
        var mutuallyBusyTimes = allBusyTimes[0]

        for busyTimes in allBusyTimes.dropFirst() {
            mutuallyBusyTimes = mutuallyBusyTimes.filter { busy1 in
                busyTimes.contains { busy2 in
                    busy1["start"] == busy2["start"] && busy1["end"] == busy2["end"]
                }
            }
        }
        return mutuallyBusyTimes
    }

    private func updateAvailableDays(busyTimes: [[String: String]], startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let allDates = stride(from: startDate, to: endDate, by: 60 * 60 * 24).map { calendar.startOfDay(for: $0) }
                
        var availableDaysSet = Set<Date>()
        allDates.forEach { date in
            let availableHours = Calendar.calculateAvailableHours(for: date, busyIntervals: busyTimes)
                .filter { hour in hour >= 9 && hour < 17 } // Filter to 9 AM (9) to 5 PM (17)
            
            if !availableHours.isEmpty {
                availableDaysSet.insert(date)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.availableDays = availableDaysSet
        }
    }
}
