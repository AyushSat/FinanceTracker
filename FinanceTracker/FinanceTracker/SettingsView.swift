//
//  SettingsView.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 8/5/23.
//

import SwiftUI
import Charts

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    public var backgroundColorLocal: Color {
        if(colorScheme == .dark){
            return Color(red: 28/255.0, green: 28/255.0, blue: 30/255.0)
            
        }
        return Color(red: 242.0/255.0, green: 242.0/255.0, blue: 247.0/255.0)
    }
    
    public var inputBackgroundColor: Color {
        if(colorScheme == .dark){
            return Color(red: 44/255.0, green: 44/255.0, blue: 47/255.0)
            
        }
        return .white
    }
    
    @AppStorage("categories") var jsonCategories = "[\"Groceries\", \"Rent\", \"Essentials\", \"Dining\", \"Recreation\"]"
    @AppStorage("monthlyLimit") var monthlyLimitAppStorage = 0.0
    @AppStorage("jsonTransactions") var jsonTransactions = "[]"

    @State private var newCategoryName:String = ""
    @State private var spendingLimitInput:String = ""
    
    @State private var monthlyLimitInput:Double = 0.0
    @State private var showLimitAlert = false
    @State private var showCategoryConfirmation = false
    
    private var transactions: [Transaction] {
        
        if let transactionData = jsonTransactions.data(using: .utf8) {
            do{
                let decoder = JSONDecoder()
                let decodedTransactions: [Transaction] = try decoder.decode([Transaction].self, from: transactionData)
                return decodedTransactions
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return []
    }
    
    func deepCopyCategories(_ originalCategories: [Category]) -> [Category] {
        return originalCategories.map { category in
            Category(id: UUID(), name: category.name)
        }
    }
    
    func submitMonthlyLimit(_ s: String){
        if let casted = Double(s) {
            monthlyLimitAppStorage = casted
        } else {
            print("Error, invalid double in string")
        }
        showLimitAlert = true
    }
    
    func submitCategory(_ c: Category){
        var tempCategories = deepCopyCategories(categories)
        tempCategories.append(c)
        let newStringArrOnly: [String] = tempCategories.map{$0.name}
        do{
            let encoder = JSONEncoder()
            let jsonCategoriesData = try encoder.encode(newStringArrOnly)
            if let jsonString = String(data: jsonCategoriesData, encoding: .utf8) {
                jsonCategories = jsonString
            }
            showCategoryConfirmation = true
        }catch {
            print("Error encoding JSON: \(error)")
        }
        
        
        
    }
    
    private var categories: [Category] {
        if let jsonData = jsonCategories.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let decodedCategories = try decoder.decode([String].self, from: jsonData)
                return decodedCategories.map { Category(id: UUID(), name: $0) }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return []
        
    }
    
    func deleteCategory(_ name: String) -> Void {
        print("Deleting category " + name)
        var newArr:[Category] = []
        for category in categories {
            if category.name != name {
                newArr.append(category)
            }
        }
        let newStringArrOnly: [String] = newArr.map{$0.name}
        do{
            let encoder = JSONEncoder()
            let jsonCategoriesData = try encoder.encode(newStringArrOnly)
            if let jsonString = String(data: jsonCategoriesData, encoding: .utf8) {
                jsonCategories = jsonString
            }
            
            //rewrite all transactions with deleted category to "Other"
            var newTransactions:[Transaction] = []
            
            for transaction in transactions{
                if(transaction.cat != name){
                    newTransactions.append(transaction)
                }else{
                    newTransactions.append(Transaction(id: transaction.id, name: transaction.name, date: transaction.date, cat: "Other", cost: transaction.cost))
                }
            }
            
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(newTransactions)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    jsonTransactions = jsonString
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
            
            
        }catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    var body: some View {
            ZStack {
                VStack{
                    
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 18)
                    
                    Group{
                        Group{
                            Text("Set monthly spending limit")
                                .padding(.top, 10.0)
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                            HStack{
                                Text("Spending limit")
                                    .padding(.trailing, 12.0)
                                TextField(monthlyLimitAppStorage > 0 ? toPrettyDouble(monthlyLimitAppStorage) : "Enter limit", text: $spendingLimitInput)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                
                            }.padding(12)
                                .padding(.leading, 5)
                                .background(inputBackgroundColor)
                                .cornerRadius(10)
                            
                            Button(action: {
                                submitMonthlyLimit(spendingLimitInput)
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Set Limit").foregroundColor(.white)
                                        .font(.headline)
                                        .padding(.vertical, 10.0)
                                    
                                    Spacer()
                                }.background(.green)
                                    .cornerRadius(10)
                            }.alert(isPresented: $showLimitAlert, content: {
                                Alert(
                                    title: Text("Monthly limit set"),
                                    message: Text("The new monthly limit is now " + spendingLimitInput + "."),
                                    dismissButton: .default(Text("OK")){
                                        spendingLimitInput = ""
                                    }
                                )
                            })
                        }.padding(.horizontal, 18.0)
                        
                        Group{
                            Text("Add new category")
                                .padding(.top, 10.0)
                                .frame(maxWidth: .infinity,
                                                           alignment: .leading)
                            HStack{
                                Text("Category")
                                    .padding(.trailing, 12.0)
                                TextField("Category title", text: $newCategoryName).multilineTextAlignment(.trailing)
                            }.padding(12)
                                .padding(.leading, 5)
                                .background(inputBackgroundColor)
                                .cornerRadius(10)
                            
                            Button(action: {
                                
                                submitCategory(Category(id: UUID(), name: newCategoryName))
                            }) {
                                
                                HStack {
                                    Spacer()
                                    Text("Add Category").foregroundColor(.white)
                                        .font(.headline)
                                        .padding(.vertical, 10.0)
                                    
                                    Spacer()
                                }.background(.green)
                                    .cornerRadius(10)
                            }.alert(isPresented: $showCategoryConfirmation, content: {
                                Alert(
                                    title: Text("Category Added"),
                                    message: Text("The new category of " + newCategoryName + " was added!"),
                                    dismissButton: .default(Text("OK")){
                                        newCategoryName = ""
                                    }
                                )
                            })
                        }.padding(.horizontal, 18.0)
                    }.onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
                    
                    Text("Current Categories")
                        .frame(maxWidth: .infinity,
                               alignment: .leading).padding(.top, 10)
                        .padding(.horizontal, 18)
                    
                    List {
                        Section(header: Spacer(minLength: 0)){
                            ForEach(categories, id: \.id) { category in
                                HStack{
                                    Text(category.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }.swipeActions(allowsFullSwipe: false) {
                                    
                                    Button(role: .destructive) {
                                        print("HERE")
                                        deleteCategory(category.name)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }.tint(.red)
                                }.listRowBackground(inputBackgroundColor)
                            }
                        }
                    }
                    .background(backgroundColorLocal)
                        .scrollContentBackground(.hidden)

                    
                }
                .padding(.top, 20)
            }
            .background(backgroundColorLocal)
            
        
    }
}

