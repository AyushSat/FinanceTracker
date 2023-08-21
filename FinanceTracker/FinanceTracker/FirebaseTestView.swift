//
//  FirebaseTestView.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 8/18/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


struct FirebaseTestView: View {
    @State private var dataDescription: String = "Loading..." // Default initial value

    func fetchData() async {
        let db = Firestore.firestore()
        let testCol = db.collection("allData").document("eRVJUCgAHuCZlSRt9Bet")
        do {
            let document = try await testCol.getDocument()
            if document.exists {
                let newDataDescription = document.data().map(String.init(describing:)) ?? "nil"
                self.dataDescription = newDataDescription
            } else {
                self.dataDescription = "nothing"
            }
        } catch {
            self.dataDescription = "error: \(error)"
        }
    }

    var body: some View {
        VStack {
            Text(dataDescription)
                .task {
                    await fetchData()
                }
        }
    }
}

