//
//  GoogleCalendarAPI.swift
//  WeMeet
//
//  Created by Monae White.
//
//  Step 1: Fetch the user's and contact's calendar IDs.
//  Step 2: Query the /freebusy endpoint for availability.
//  Step 3: Parse the busy intervals and compute free slots.
//  Step 4: Display the mutual availability on your calendar UI.

import Foundation
import FirebaseAuth

class GoogleCalendarAPI {
    private let freeBusyURL = "https://www.googleapis.com/calendar/v3/freeBusy"
    
    func fetchFreeBusy(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<[[String: String]], Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."])))
            return
        }

        currentUser.getIDToken { idToken, error in
            guard let idToken = idToken, error == nil else {
                completion(.failure(error ?? NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch ID token."])))
                return
            }

            let dateFormatter = ISO8601DateFormatter()
            let requestBody: [String: Any] = [
                "timeMin": dateFormatter.string(from: startDate),
                "timeMax": dateFormatter.string(from: endDate),
                "items": [["id": "primary"]]
            ]

            self.makeRequest(idToken: idToken, requestBody: requestBody, completion: completion)
        }
    }

    private func makeRequest(
        idToken: String,
        requestBody: [String: Any],
        completion: @escaping (Result<[[String: String]], Error>) -> Void
    ) {
        guard let url = URL(string: freeBusyURL) else {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body."])))
            return
        }

        // Network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let calendars = json["calendars"] as? [String: Any],
                   let primaryCalendar = calendars["primary"] as? [String: Any],
                   let busyTimes = primaryCalendar["busy"] as? [[String: String]] {
                    completion(.success(busyTimes))
                } else {
                    completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed response data."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
