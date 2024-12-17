//
//  GoogleCalendarAPI.swift
//  WeMeet
//
//  Created by Monae White.
//

import Foundation
import FirebaseAuth

class GoogleCalendarAPI {
    private let freeBusyURL = "https://www.googleapis.com/calendar/v3/freeBusy"
    
    func fetchFreeBusy(startDate: Date, endDate: Date, completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        guard let accessToken = getAccessToken() else {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token found. User might need to reauthenticate."])))
            return
        }
        
        makeFreeBusyRequest(accessToken: accessToken, startDate: startDate, endDate: endDate, completion: completion)
    }
    
    private func makeFreeBusyRequest(accessToken: String, startDate: Date, endDate: Date, completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        guard let url = URL(string: freeBusyURL) else {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "timeMin": ISO8601DateFormatter().string(from: startDate),
            "timeMax": ISO8601DateFormatter().string(from: endDate),
            "items": [["id": "primary"]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NSError(domain: "com.wemeet", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body."])))
            return
        }
        
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
    
    private func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "GoogleAccessToken")
    }
}
