//
//  MiiSelectionView.swift
//  WeMeet
//
//  Created by Monae White.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MiiSelectionView: View {
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presentationMode
    private let miis = (0..<25).map { "Image \($0)" }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5), spacing: 10) {
                ForEach(miis, id: \.self) { mii in
                    Button ( action: {
                        user.updateSelectedMii(mii)
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Image(mii)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(5)
                            .overlay(
                                Circle().stroke(user.selectedMii == mii ? Color(red: 0, green: 0.6, blue: 0.81) : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Select Mii")
    }
}

#Preview {
    MiiSelectionView()
        .environmentObject(User())
}
