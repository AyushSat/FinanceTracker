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

    @State private var newCategoryName:String = ""
    @State private var spendingLimitInput:String = ""
    @State private var passwordInput:String = ""
    
    @State private var monthlyLimitInput:Double = 0.0
    @State private var showLimitAlert = false
    @State private var showCategoryConfirmation = false
    @State private var showPublishConfirmation = false
    @State private var showPullConfirmation = false
    @State private var pullErrorState = 0
    @State private var publishErrorState = 0
    
    @StateObject private var singleton = FirebaseConnector.singleton
    
    private var transactions: [Transaction] {
        
        return singleton.transactions
    }
    
    private var categories: [Category] {
        return singleton.categories
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
                            Text("Load data from cloud")
                                .padding(.top, 10.0)
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                            HStack{
                                Text("Password")
                                    .padding(.trailing, 12.0)
                                
                                TextField(singleton.getPassword() == "" ? "Enter password" : singleton.getPassword(), text: $passwordInput)
                                    .multilineTextAlignment(.trailing)
                                
                            }.padding(12)
                                .padding(.leading, 5)
                                .background(inputBackgroundColor)
                                .cornerRadius(10)
                            
                            HStack {
                                Button(action: {
                                    Task {
                                        do {
                                            let res = try await singleton.publishData(newPassword: passwordInput)
                                            if res {
                                                showPublishConfirmation = true
                                                publishErrorState = 2
                                            } else {
                                                print("Something went wrong, check logs")
                                                showPublishConfirmation = true
                                                publishErrorState = 1
                                            }
                                        } catch {
                                            publishErrorState = 1
                                        }
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Publish data").foregroundColor(.white)
                                            .font(.headline)
                                            .padding(.vertical, 10.0)
                                        
                                        Spacer()
                                    }.background(.blue)
                                        .cornerRadius(10)
                                }.alert(isPresented: $showPublishConfirmation, content: {
                                    if(publishErrorState == 1){
                                        publishErrorState = 0
                                        return Alert(
                                            title: Text("Creation failed"),
                                            message: Text("An error occured when trying to publish that password to the cloud. Please try again later."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }else if(publishErrorState == 2){
                                        publishErrorState = 0
                                        return Alert(
                                            title: Text("Account created"),
                                            message: Text("An account accessible with the password \(passwordInput) was created, and all existing transaction data has been synced with that password."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }else{
                                        publishErrorState = 0
                                        return Alert(
                                            title: Text("wtf"),
                                            message: Text("wtf."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }
                                })
                                
                                Rectangle().fill(backgroundColorLocal).frame(width: 8, height: 2)
                                
                                Button(action: {
                                    
                                    Task {
                                        do {
                                            let res = try await singleton.pullData(newPassword: passwordInput)
                                            if res {
                                                showPullConfirmation = true
                                                pullErrorState = 2
                                            } else {
                                                showPullConfirmation = true
                                                pullErrorState = 1
                                            }
                                        } catch {
                                            showPullConfirmation = true
                                            pullErrorState = 1
                                            // Handle error if something goes wrong
                                        }
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Pull existing data").foregroundColor(.white)
                                            .font(.headline)
                                            .padding(.vertical, 10.0)
                                        
                                        Spacer()
                                    }.background(.orange)
                                        .cornerRadius(10)
                                }.alert(isPresented: $showPullConfirmation, content: {
                                    if(pullErrorState == 1){
                                        pullErrorState = 0
                                        return Alert(
                                            title: Text("Cloud pull failed"),
                                            message: Text("Most likely, a dataset with that password doesn't exist. Please publish data to that password first."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }else if(pullErrorState == 2){
                                        pullErrorState = 0
                                        return Alert(
                                            title: Text("Pull succeeded"),
                                            message: Text("Data was found linked to password \(passwordInput). All transaction data was synced."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }else{
                                        pullErrorState = 0
                                        return Alert(
                                            title: Text("wtf"),
                                            message: Text("wtf."),
                                            dismissButton: .default(Text("OK")){
                                                passwordInput = ""
                                            }
                                        )
                                    }
                                })
                            }
                        }.padding(.horizontal, 18.0)
                        
                        Group{
                            Text("Set monthly spending limit")
                                .padding(.top, 10.0)
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                            HStack{
                                Text("Spending limit")
                                    .padding(.trailing, 12.0)
                                TextField(singleton.monthlyLimit > 0 ? toPrettyDouble(singleton.monthlyLimit) : "Enter limit", text: $spendingLimitInput)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                
                            }.padding(12)
                                .padding(.leading, 5)
                                .background(inputBackgroundColor)
                                .cornerRadius(10)
                            
                            Button(action: {
                                Task {
                                    await singleton.submitMonthlyLimit(spendingLimitInput)
                                    showLimitAlert = true
                                }
                                
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
                                
                                Task {
                                    await singleton.submitCategory(Category(id: UUID(), name: newCategoryName))
                                    showCategoryConfirmation = true
                                }
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
                                        Task{
                                            await singleton.deleteCategory(category.name)
                                        }
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

