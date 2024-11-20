//
//  WelcomeViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import Combine

class WelcomeViewModel: ObservableObject {
    @Published var quoteText: String = "Loading..."
    @Published var author: String = ""

    init() {
        fetchQuote()
    }

    func fetchQuote() {
        Quote.fetchDailyQuote { [weak self] quote in
            DispatchQueue.main.async {
                if let quote = quote {
                    self?.quoteText = "\"\(quote.q)\""
                    self?.author = "- \(quote.a)"
                } else {
                    self?.quoteText = "Failed to load quote"
                    self?.author = ""
                }
            }
        }
    }
}

