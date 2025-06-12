//
//  ExpenseTrackerAppApp.swift
//  ExpenseTrackerApp
//
//  Created by Admin on 6/12/25.
//

import SwiftUI

@main
struct ExpenseTrackerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Expense.self, Category.self])
    }
}
