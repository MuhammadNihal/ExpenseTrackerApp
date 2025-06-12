//
//  ContentView.swift
//  ExpenseTrackerApp
//
//  Created by Admin on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab: String = "Expenses"
    var body: some View {
        TabView(selection: $currentTab) {
            ExpenseView(currentTab: $currentTab)
                .tag("Expenses")
                .tabItem { Image(systemName: "creditcard.fill")
                    Text("Expenses")
                }
            
            CategoryView()
                .tag("Categories")
                .tabItem { Image(systemName: "list.clipboard.fill")
                    Text("Categories")
                }
        }
    }
}

#Preview {
    ContentView()
}
