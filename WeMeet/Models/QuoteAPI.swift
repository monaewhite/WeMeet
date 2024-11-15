//
//
//  Quote.swift
//  WeMeet
//
//  Created by Monae White.
//

import Foundation

struct Quote: Codable {
    let q: String  // The quote text
    let a: String  // The author

    static func fetchDailyQuote(completion: @escaping (Quote?) -> Void) {
        let urlString = "https://zenquotes.io/api/today"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                completion(quotes.first) // The first quote from the array
            } catch {
                completion(nil)
            }
        }.resume()
    }
}


