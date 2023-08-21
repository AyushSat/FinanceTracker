//
//  HomeView.swift
//  FinanceTracker
//
//  Created by Ayush Satyavarpu on 7/24/23.
//

import SwiftUI
import Charts



struct Transaction : Identifiable, Codable{
    var id: UUID
    var name = ""
    var date = Date()
    var cat = "Other"
    var cost = 0.0
}

struct Category: Identifiable, Codable {
    let id: UUID
    let name: String
}

struct ChartStruct {
    var id: UUID
    var cat: String
    var amnt: Double
}

struct LineChartStruct {
    var id: UUID
    var monthString: String
    var total: Double
}


struct HomeView: View {
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
    
    private let spaceBetweenRectangles = 5;
    
    private var chartDataForCurrMonth: [ChartStruct] {
        var mainDict: [String: Double] = [:]
        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.month, .year], from: currentDate)
        var currTotal:Double = 0.0
        
        for transaction in transactions {
            let transactionComponents = calendar.dateComponents([.month, .year], from: transaction.date)
            if (currentComponents.month == transactionComponents.month &&
                currentComponents.year == transactionComponents.year){
                if let value = mainDict[transaction.cat] {
                    mainDict[transaction.cat] = value + transaction.cost
                }else{
                    mainDict[transaction.cat] = transaction.cost
                }
                currTotal += transaction.cost
            }
        }
        if(currTotal != totalThisMonth){
            print("Something is wrong: currTotal is \(currTotal) and totalThisMonth is \(totalThisMonth)")
        }
        
        var res: [ChartStruct] = []
        for (categ, cst) in mainDict{
            res.append(ChartStruct(id: UUID(), cat: categ, amnt: cst))
        }
        return res.sorted{
            return $0.amnt > $1.amnt
        }
    }
    
    private var chartDataForAllMonths: [ChartStruct] {
        var mainDict: [String: Double] = [:]
        var currTotal:Double = 0.0
        
        for transaction in transactions {
            if let value = mainDict[transaction.cat] {
                mainDict[transaction.cat] = value + transaction.cost
            }else{
                mainDict[transaction.cat] = transaction.cost
            }
            currTotal += transaction.cost
            
        }
        if(currTotal != totalAllTime){
            print("Something is wrong: currTotal is \(currTotal) and totalThisMonth is \(totalThisMonth)")
        }
        
        var res: [ChartStruct] = []
        for (categ, cst) in mainDict{
            res.append(ChartStruct(id: UUID(), cat: categ, amnt: cst))
        }
        return res.sorted{
            return $0.amnt > $1.amnt
        }
    }
    
    func getBarWidth(_ cat: String) -> CGFloat{
        for cs in chartDataForCurrMonth{
            if cs.cat == cat{
                let width: Double = graphWidth - CGFloat((chartDataForCurrMonth.count - 1) * 3)
                return CGFloat((cs.amnt/totalThisMonth) * width)
            }
        }
        return 30
    }
    
    func getBarWidthTotal(_ cat: String) -> CGFloat{
        for cs in chartDataForAllMonths{
            if cs.cat == cat{
                let width: Double = graphWidth - CGFloat((chartDataForAllMonths.count - 1) * 3)
                return CGFloat((cs.amnt/totalAllTime) * width)
            }
        }
        return 30
    }
    
    func getColor(_ cat: String) -> Color{
        let colorsArr: [Color] = [
            Color(red: 62/255.0, green: 46/255.0, blue: 101/255.0),
            Color(red: 103/255.0, green: 19/255.0, blue: 43/255.0),
            Color(red: 70/255.0, green: 130/255.0, blue: 167/255.0),
            Color(red: 40/255.0, green: 102/255.0, blue: 54/255.0),
            Color(red: 191/255.0, green: 88/255.0, blue: 46/255.0),
            Color(red: 251/255.0, green: 178/255.0, blue: 133/255.0),
            Color(red: 127/255.0, green: 112/255.0, blue: 170/255.0),
            Color(red: 230/255.0, green: 168/255.0, blue: 68/255.0),
            Color(red: 196/255.0, green: 63/255.0, blue: 77/255.0),
            Color(red: 126/255.0, green: 193/255.0, blue: 156/255.0)
        ]
        for index in 0..<categories.count{
            if categories[index].name == cat{
                return colorsArr[index]
            }
        }
        
        return .indigo
    }

    @State private var transactionName = ""
    @State private var transactionDate = Date()
    @State private var transactionCategory = "Groceries"
    @State private var transactionCost:String = ""
    
    @State private var testDouble = 0.0
    
    @State private var newCategoryName:String = ""
    
    @State private var spendingLimitInput:String = ""

    @State private var showConfirmationAlert = false
    
    @StateObject private var singleton = FirebaseConnector.singleton

    
    func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
    }
    
    func convertMonthYearToFormattedDate(_ input: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMMM yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/yy"
        
        if let date = inputFormatter.date(from: input) {
            return outputFormatter.string(from: date)
        }
        
        return nil
    }
    
    private var totalThisMonth: Double {
        let currentDate = Date()
        let calendar = Calendar.current
        
        var totalCost: Double = 0.0
        for transaction in transactions {
            let transactionComponents = calendar.dateComponents([.month, .year], from: transaction.date)
            let currentComponents = calendar.dateComponents([.month, .year], from: currentDate)
            if (currentComponents.month == transactionComponents.month &&
                currentComponents.year == transactionComponents.year){
                totalCost += transaction.cost
            }
        }
        return totalCost
    }
    
    private var totalAllTime: Double {
        var totalCost: Double = 0.0
        for transaction in transactions {
            totalCost += transaction.cost
        }
        return totalCost
    }
    
    private var categories: [Category] {
        return singleton.categories
    }
    
    private var transactions: [Transaction] {
        return singleton.transactions
    }
    
    
    private var formattedTransactionCost: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: Double(transactionCost) ?? 0.0)) ?? ""
    }
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var historyTableData : [MonthTransArrayPair] {
        let sortedTransactions = sortTransactions(transactions)
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
    
    private var lineGraphData: [LineChartStruct] {
        var res :[LineChartStruct] = []
        for i in (0..<historyTableData.count).reversed(){
            let pair : MonthTransArrayPair = historyTableData[i]
            var total: Double = 0.0
            for trans in pair.transactions{
                total += trans.cost
            }
            res.append(LineChartStruct(id: UUID(), monthString: convertMonthYearToFormattedDate(pair.monthStr)!, total: total))
        }
        return res
    }
    
    private var graphWidth: CGFloat {
        return (CGFloat(lineGraphData.count * 50) < screenWidth ? screenWidth : CGFloat(lineGraphData.count * 50)) - 36
    }
    
    var labels: some View{
        var result = Text("")
        for pair in chartDataForAllMonths{
            result = result + Text("●\u{00a0}").foregroundColor(getColor(pair.cat)) + Text(pair.cat + "  ")
        }
        return result
    }
    
    var monthLabels: some View{
        var result = Text("")
        for pair in chartDataForCurrMonth{
            result = result + Text("●\u{00a0}").foregroundColor(getColor(pair.cat)) + Text(pair.cat + "  ")
        }
        return result
    }
    
    var body: some View {
        ScrollView{
            ZStack{
                backgroundColorLocal.ignoresSafeArea()
                ScrollView {
//                    Button(action: {
//
//
//                        monthlyLimitAppStorage = 0
//                        jsonTransactions = "[]"
//                        jsonCategories = "[\"Groceries\", \"Rent\", \"Essentials\", \"Dining\", \"Recreation\"]"
//
//
//                    }) {
//
//                        HStack {
//                            Spacer()
//                            Text("Wipe Data").foregroundColor(.white)
//                                .font(.headline)
//                                .padding(.vertical, 10.0)
//
//                            Spacer()
//                        }.background(.green)
//                            .cornerRadius(10)
//                    }
                    VStack(alignment: .leading){
                        Text("Finance Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 15)
                        .padding(.bottom, 5)
                        
                        HStack {
                            if(singleton.monthlyLimit < 1){
                                Text("You have spent ").font(.title2) + Text("$" + String(totalThisMonth)).font(.title2)                                    .fontWeight(.bold) + Text(" this month.")
                                    .font(.title2)
                            }else {
                                Text("You have ").font(.title2) + Text("$" + String(singleton.monthlyLimit - totalThisMonth)).font(.title2)                                    .fontWeight(.bold) + Text(" left for this month.")
                                    .font(.title2)

                            }
                            
                        }
                            .padding(.bottom, 10)
                        
                        Text("Enter Transaction")
                            .font(.title3)
                        HStack{
                            Text("Transaction")
                                .padding(.trailing, 12.0)
                            TextField("Describe transaction", text: $transactionName).multilineTextAlignment(.trailing)
                        }.padding(12)
                            .padding(.leading, 5)
                            .background(inputBackgroundColor)
                            .cornerRadius(10)
                        
                        DatePicker(selection: $transactionDate, in: ...Date(), displayedComponents: .date)
                        {
                            Text("Transaction Date")
                        }.padding(8)
                            .padding(.leading, 9)
                            .background(inputBackgroundColor)
                            .cornerRadius(10)
                        
                        HStack {
                            Text("Cost")
                                .padding(.trailing, 12.0)
                            Spacer()
                            TextField("Enter cost", text: $transactionCost, onEditingChanged: { _ in
                                transactionCost = formattedTransactionCost
                            }, onCommit: {
                                if let _ = Double(transactionCost) {
                                    transactionCost = formattedTransactionCost
                                } else {
                                    print("Error, invalid double in string")
                                }
                            })
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        }
                        .padding(12)
                        .padding(.leading, 5)
                        .background(inputBackgroundColor)
                        .cornerRadius(10)
                        
                        HStack{
                            Text("Category")
                                .padding(.trailing, 12.0)
                            Spacer()
                            Picker("Transaction Category", selection: $transactionCategory) {
                                ForEach(categories, id: \.id) { category in
                                    Text(category.name).tag(category.name)
                                }
                            }
                        }.padding(.vertical, 12)
                            .padding(.leading, 17)
                            .background(inputBackgroundColor)
                            .cornerRadius(10)
                        
                        
                        Button(action: {
                            
                            
                            if let casted = Double(transactionCost){
                                
                                Task {
                                    await singleton.submitTransaction(Transaction(id: UUID(), name: transactionName, date: transactionDate, cat: transactionCategory, cost: casted))
                                    showConfirmationAlert = true
                                }
                            }else{
                                print("Error, invalid double in string")
                            }
                            
                            
                        }) {
                            
                            HStack {
                                Spacer()
                                Text("Submit").foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.vertical, 10.0)
                                
                                Spacer()
                            }.background(.green)
                                .cornerRadius(10)
                        }.alert(isPresented: $showConfirmationAlert, content: {
                            Alert(
                                title: Text("Submission Confirmation"),
                                message: Text("Your transaction of " + transactionName + " was processed!"),
                                dismissButton: .default(Text("OK")){
                                    transactionName = ""
                                    transactionCost = ""
                                }
                            )
                        })
                        Group{
                            if(lineGraphData.count > 1){
                                Group{
                                    
                                    Text("Monthly spending")
                                        .font(.title3)
                                        .padding(.top, 25)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    
                                    ZStack {
                                        ScrollView(.horizontal){
                                            Chart(lineGraphData, id: \.id) {
                                                LineMark(
                                                    x: .value("Month", $0.monthString),
                                                    y: .value("Total", $0.total)
                                                    
                                                )
                                            }.padding(.top, 10)
                                            .frame(width: graphWidth)
                                        }
                                        
                                        
                                    }.frame(height: 100)
                                }
                            }
                            
                            if(chartDataForCurrMonth.count > 0){
                                Text("This month's breakdown")
                                    .font(.title3)
                                    .padding(.top, 25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing:0){
                                    ForEach(Array(zip(chartDataForCurrMonth.indices, chartDataForCurrMonth)), id: \.0){ index, pair in
                                        
                                        if(index == 0 && index == chartDataForCurrMonth.count - 1){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidth(pair.cat), height: 30).cornerRadius(5)
                                        }else if(index == 0){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidth(pair.cat), height: 30)
                                                .padding(.trailing, 5)
                                                .cornerRadius(5)
                                                .padding(.trailing, -5)
                                            Rectangle().fill(backgroundColorLocal).frame(width: 3)
                                        }else if(index == chartDataForCurrMonth.count - 1){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidth(pair.cat), height: 30)
                                                .padding(.leading, 5)
                                                .cornerRadius(5)
                                                .padding(.leading, -5)
                                        }else{
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidth(pair.cat), height: 30)
                                            Rectangle().fill(backgroundColorLocal).frame(width: 3)
                                        }
                                    }
                                }.frame(width: graphWidth)
                                monthLabels
                            }
                            
                            if(transactions.count > 1){
                                Text("Total category breakdown")
                                    .font(.title3)
                                    .padding(.top, 25)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing:0){
                                    ForEach(Array(zip(chartDataForAllMonths.indices, chartDataForAllMonths)), id: \.0){ index, pair in
                                        if(index == 0 && index == chartDataForAllMonths.count - 1){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidth(pair.cat), height: 30).cornerRadius(5)
                                        }else if(index == 0){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidthTotal(pair.cat), height: 30)
                                                .padding(.trailing, 5)
                                                .cornerRadius(5)
                                                .padding(.trailing, -5)
                                            Rectangle().fill(backgroundColorLocal).frame(width: 3)
                                        }else if(index == chartDataForAllMonths.count - 1){
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidthTotal(pair.cat), height: 30)
                                                .padding(.leading, 5)
                                                .cornerRadius(5)
                                                .padding(.leading, -5)
                                        }else{
                                            Rectangle().fill(getColor(pair.cat)).frame(width: getBarWidthTotal(pair.cat), height: 30)
                                            Rectangle().fill(backgroundColorLocal).frame(width: 3)
                                        }
                                    }
                                }.frame(width: graphWidth)
                                labels.padding(.bottom, 30)
                            }
                            
                        }
                    }
                    
                    
                    
                    
                        
                }
                .padding(.top, 5)
                
                //fix category wiping after submission
                //get page to scroll when keyboard comes up
            }
            .padding(.horizontal, 18.0)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .frame(height: .infinity)
        .background(backgroundColorLocal)
        
            

        
    }
        
}
