//
//  Category.swift
//  ExpenseTrackerApp
//
//  Created by Admin on 6/12/25.
//

import SwiftUI
import SwiftData

@Model
class Category {
    var categoryName: String
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.category)
    var expenses: [Expense]?
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
