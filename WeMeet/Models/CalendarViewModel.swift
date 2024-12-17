//
//  CalendarViewModel.swift
//  WeMeet
//
//  Created by Monae White.
//  This code fetches availability data for the user and their contacts and coordinates updates between different calendar views, ensuring consistency and shared logic across the app's calendar feature.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var selectedContacts: [User] = [] // Tracks contacts selected for comparison
    
    func displayUserAndContacts(user: User, geometry: GeometryProxy) -> some View {
        Group {
            if selectedContacts.isEmpty {
                Image(user.selectedMii)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.3)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            } else if selectedContacts.count == 1 {
                HStack(spacing: geometry.size.width * 0.05) {
                    Image(user.selectedMii)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    Image(selectedContacts[0].selectedMii)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.2)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            } else if selectedContacts.count == 2 {
                HStack(spacing: geometry.size.width * 0.05) {
                    Image(selectedContacts[0].selectedMii)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.2)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    Image(user.selectedMii)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.3)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    Image(selectedContacts[1].selectedMii)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.2)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
        }
    }
}
