//
//  DataHandler.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 8/19/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import CryptoKit

func sha256Hash(_ input: String) -> String {
    if let inputData = input.data(using: .utf8) {
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    } else {
        return ""
    }
}

struct FirestoreData: Codable {
    let transactionsJSON: String
    let categoriesJSON: String
    let monthlyLimit: Double // Assuming the data type is Double, adjust as needed
}

func deepCopyCategories(_ originalCategories: [Category]) -> [Category] {
    return originalCategories.map { category in
        Category(id: UUID(), name: category.name)
    }
}

class FirebaseConnector: ObservableObject{
    @AppStorage("password") public var password: String = ""

    public static let singleton: FirebaseConnector = FirebaseConnector()
    
    private init(){
    }
    
    @Published private var transactionsJSON: String = "[]"
    @Published private var jsonCategories: String = "[\"Groceries\", \"Rent\", \"Essentials\", \"Dining\", \"Recreation\"]"
    @Published public var monthlyLimit = 0.0
    
    public var transactions: [Transaction] {
        if let transactionData = transactionsJSON.data(using: .utf8) {
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
    
    public var categories: [Category] {
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
    
    public func submitTransaction(_ t: Transaction) async -> Bool{
        if let jsonData = transactionsJSON.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                var decodedTransactions = try decoder.decode([Transaction].self, from: jsonData)
                decodedTransactions.append(t)
                do {
                    let encoder = JSONEncoder()
                    let jsonData = try encoder.encode(decodedTransactions)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        transactionsJSON = jsonString // Update the state on the main thread
                        return try await publishData(newPassword: password)
                    }
                } catch {
                    print("Error encoding JSON: \(error)")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return false
    }
    
    public func deleteTransaction(id: UUID) async{
        print("Deleting transaction with id: " + id.uuidString)
        var newArr:[Transaction] = []
        for transaction in transactions {
            if transaction.id != id {
                newArr.append(transaction)
            }
        }
        assert(newArr.count == transactions.count - 1)
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(newArr)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                transactionsJSON = jsonString
                let _ = try await publishData(newPassword: password)
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    public func submitCategory(_ c: Category) async {
        var tempCategories = deepCopyCategories(categories)
        tempCategories.append(c)
        let newStringArrOnly: [String] = tempCategories.map{$0.name}
        do{
            let encoder = JSONEncoder()
            let jsonCategoriesData = try encoder.encode(newStringArrOnly)
            if let jsonString = String(data: jsonCategoriesData, encoding: .utf8) {
                jsonCategories = jsonString
                let _ = try await publishData(newPassword: password)
            }
        }catch {
            print("Error encoding JSON: \(error)")
        }
        
    }
    
    public func deleteCategory(_ name: String) async -> Void {
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
                    transactionsJSON = jsonString
                    let _ = try await publishData(newPassword: password)
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
            
            
        }catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    public func submitMonthlyLimit(_ s: String) async{
        if let casted = Double(s) {
            monthlyLimit = casted
            do {
                let _ = try await publishData(newPassword: password)
            } catch {
                print("Error publishing\(error)")
            }
        } else {
            print("Error, invalid double in string")
        }
    }
    
    public func publishData(newPassword: String) async throws -> Bool{
        password = newPassword
        if password == ""{
            return true
        }
        let db = Firestore.firestore()
        let coll = db.collection("allData")
        do {
            print(transactionsJSON)
            try await coll.document(sha256Hash(password)).setData([
                "transactionsJSON": transactionsJSON,
                "categoriesJSON": jsonCategories,
                "monthlyLimit": monthlyLimit
            ])
            return true
        } catch {
            print("Error:\(error)")
            throw error
        }
        //clear any existing document with sha(password)
        //publish all current transactions to firebase under document sha(password)
    }
    
    public func pullData(newPassword: String) async throws-> Bool{
        let oldPw = password
        password = newPassword
        let db = Firestore.firestore()
        let testCol = db.collection("allData").document(sha256Hash(newPassword))
        do {
            let document = try await testCol.getDocument()
            
            if document.exists {
                guard let data = document.data(),
                        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                    print("Error decoding JSON data")
                    password = oldPw
                    return false
                }
                
                let decoder = JSONDecoder()
                let firestoreData = try decoder.decode(FirestoreData.self, from: jsonData)
                
                transactionsJSON = firestoreData.transactionsJSON
                jsonCategories = firestoreData.categoriesJSON
                monthlyLimit = firestoreData.monthlyLimit
                return true
            } else {
                password = oldPw
                print("Password not found or document data is missing")
                return false
            }
        } catch {
            print("Error: \(error)")
            password = oldPw
            throw error
        }
    }
    
    public func getPassword() -> String{
        return password
    }
}
