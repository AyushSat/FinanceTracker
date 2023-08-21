//
//  HistoryView.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 8/5/23.
//

import SwiftUI

func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter.string(from: date)
}

func toPrettyDouble(_ cost: Double) -> String {
    let scaledCost:Int = Int(cost * 100)
    let realCost:Double = Double(scaledCost) / 100.0
    let res = "$" + String(realCost)
    if let i = res.firstIndex(of: ".") {
        let index: Int = res.distance(from: res.startIndex, to: i)
        if index == res.count - 1 {
            return res + "00"
        }else if index == res.count - 2 {
            return res + "0"
        }else{
            return res
        }
    }else{
        return res + ".00"
    }
}

func toPrettyMonthString(_ date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: date)
}

func mergeTransArray(_ arr1: [Transaction], _ arr2: [Transaction]) -> [Transaction]{
    var res :[Transaction] = []
    var ptr1 = 0
    var ptr2 = 0
    while(ptr1 < arr1.count && ptr2 < arr2.count){
        if(arr1[ptr1].date > arr2[ptr2].date){
            res.append(arr1[ptr1])
            ptr1 += 1
        }else{
            res.append(arr2[ptr2])
            ptr2 += 1
        }
    }
    res.append(contentsOf: arr1[ptr1...])
    res.append(contentsOf: arr2[ptr2...])
    return res
}

func sortTransactions(_ arr: [Transaction]) -> [Transaction]{
    guard arr.count > 1 else {
        return arr
    }
    
    let middle = arr.count/2
    let left = sortTransactions(Array(arr[..<middle]))
    let right = sortTransactions(Array(arr[middle...]))
    return mergeTransArray(left, right)
    
}

struct MonthTransArrayPair: Identifiable{
    var id: UUID
    var monthStr: String
    var transactions: [Transaction]
}

struct HistoryView: View {
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

    @State private var showAlert = false
    @State private var selectedTransaction: Transaction? = nil
    @StateObject private var singleton = FirebaseConnector.singleton

    private var transactions: [Transaction] {
        return singleton.transactions
    }
    
    private var columnWidths: [CGFloat] {
        var widths: [CGFloat] = []
        
        let nameWidth = transactions
            .map { $0.name.width(withConstrainedHeight: 100, font: .systemFont(ofSize: 17)) }
            .max() ?? 100
        widths.append(nameWidth)
        
        let costWidth = transactions
            .map { (toPrettyDouble($0.cost)).width(withConstrainedHeight: 100, font: .systemFont(ofSize: 17)) }
            .max() ?? 100
        widths.append(costWidth)
        
        return widths
    }
    
    
    private var historyTableData : [MonthTransArrayPair] {
        var sortedTransactions = sortTransactions(transactions)
        var res: [MonthTransArrayPair] = []

        for transaction in sortedTransactions {
            var alrInRes: Bool = false
            for i in 0..<res.count{
                if res[i].monthStr == toPrettyMonthString(transaction.date){
                    res[i].transactions.append(transaction)
                    alrInRes = true
                }
            }
            if !alrInRes{
                res.append(MonthTransArrayPair(id: UUID(), monthStr: toPrettyMonthString(transaction.date), transactions: [transaction]))
            }
        }
        return res
        
    }
    
    var body: some View {
        
        VStack {
            Text("Transactions")
                .font(.largeTitle)
                .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 18)
            if historyTableData.count>0 {
                List {
                    ForEach(historyTableData, id: \.id) { pair in
                        Section(header:
                                    Text(pair.monthStr)
                            .foregroundColor(.green)
                        ){
                            ForEach(pair.transactions, id: \.id) { transaction in
                                HStack{
                                    Text(transaction.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Spacer()
                                    Text(toPrettyDouble(transaction.cost))
                                        .frame(width: columnWidths[1], alignment: .trailing)
                                }.swipeActions(allowsFullSwipe: false) {

                                        Button(role: .destructive) {
                                            
                                            Task{
                                                await singleton.deleteTransaction(id: transaction.id)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }.tint(.red)
                                }.contentShape(Rectangle())
                                .onTapGesture{
                                    selectedTransaction = transaction
                                    showAlert = true
                                }
                                .listRowBackground(inputBackgroundColor)
                                
                            }
                        }
                    }
                }
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Transaction Information"),
                          message:
                            Text("This transaction, dated \(formatDate(_:(selectedTransaction?.date ?? Date()))), falls under the category of \(selectedTransaction?.cat ?? ""), named \(selectedTransaction?.name ?? ""), and costs \(toPrettyDouble(selectedTransaction?.cost ?? 0)).")
                    
                    )
                }
                .background(backgroundColorLocal)
            .scrollContentBackground(.hidden)
            }
            else {
                Spacer()
            }
            

            
        }.padding(.top, 20)
            .frame(height: .infinity)
            .background(backgroundColorLocal)
            
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.width)
    }
}
