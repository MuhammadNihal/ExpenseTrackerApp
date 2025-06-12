//
//  ExpenseView.swift
//  ExpenseTrackerApp
//
//  Created by Admin on 6/12/25.
//

import SwiftUI
import SwiftData

struct ExpenseView: View {
    @Query(sort: [SortDescriptor(\Expense.date, order: .reverse)], animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    
    @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var orignalGroupedExpenses: [GroupedExpenses] = []
    
    @State private var addExpense: Bool = false
    @State private var searchText: String = ""
    @Binding var currentTab: String
    
    var body: some View {
        NavigationStack {
            List {
                expenseListView
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
            .navigationTitle("Expenses")
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .onChange(of: searchText, initial: true) { oldValue, newValue in
            if !newValue.isEmpty {
                filterExpenses(newValue)
            } else {
                groupedExpenses = orignalGroupedExpenses
            }
        }
        .onChange(of: allExpenses, initial: false) { oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab.lowercased() == "categories" {
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addExpense) {
            AddExpenseView()
                .interactiveDismissDisabled()
        }
    }
    
    func reloadData(_ expense: Expense, _ group: GroupedExpenses) {
        var group = group
        withAnimation {
            group.expenses.removeAll(where: { $0.id == expense.id })
            if group.expenses.isEmpty {
                groupedExpenses.removeAll(where: { $0.id == group.id })
            }
        }
    }
    
    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = orignalGroupedExpenses.compactMap { group -> GroupedExpenses? in
                let expenses = group.expenses.filter({$0.title.lowercased().contains(query)})
                if expenses.isEmpty {
                    return nil
                }
                return .init(date: group.date, expenses: expenses)
            }
            
            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }
    
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
                
                return dateComponents
            }
            
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current
                let date1 = calendar.date(from: $0.key) ?? .init()
                let date2 = calendar.date(from: $1.key) ?? .init()
                
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
                orignalGroupedExpenses = groupedExpenses
            }
        }
    }
}

extension ExpenseView {
    var expenseListView: some View {
        ForEach(groupedExpenses, id: \.groupTitle) { group in
            Section(header: Text(group.groupTitle)) {
                ForEach(group.expenses, id: \.id) { expense in
                    ExpenseCardView(expense: expense)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                context.delete(expense)
                                reloadData(expense, group)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
