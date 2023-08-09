//
//  ContentView.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 7/16/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
           TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                    }.tag(0)
                HistoryView()
                   .tabItem{
                       Image(systemName: "table")
                   }.tag(1)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                    }.tag(2)
               
           }.tint(.green)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
