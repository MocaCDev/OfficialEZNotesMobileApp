//
//  EZNotes_2App.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//

import SwiftUI
import StoreKit

/* TODO: Should the below code go into `EZNotesSubscriptionManager`? */
public func monitorTransactions() async {
    // Continuously listen for transaction updates
    for await verificationResult in StoreKit.Transaction.updates {
        // Verify the transaction
        switch verificationResult {
        case .verified(let transaction):
            // Handle the successful transaction
            await handleTransaction(transaction)
        case .unverified(let transaction, let error):
            // Handle unverified transaction (e.g., signature mismatch)
            print("Transaction unverified: \(transaction.id), error: \(error)")
        }
    }
}

// Function to process verified transactions
public func handleTransaction(_ transaction: StoreKit.Transaction) async {
    // Unlock the purchased content or deliver entitlement
    print("Transaction successful for product ID: \(transaction.productID)")

    // Mark the transaction as finished
    await transaction.finish()
}

@main
struct EZNotes_2App: App {
    @StateObject private var eznotesSubscriptionManager: EZNotesSubscriptionManager = EZNotesSubscriptionManager()
    @StateObject private var categoryData: CategoryData = CategoryData()
    @StateObject private var accountInfo: AccountDetails = AccountDetails()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var settings: SettingsConfigManager = SettingsConfigManager()
    @StateObject public var messageModel: MessagesModel = MessagesModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.eznotesSubscriptionManager)
                .environmentObject(self.categoryData)
                .environmentObject(self.accountInfo)
                .environmentObject(self.networkMonitor)
                .environmentObject(self.settings)
                .environmentObject(self.messageModel)
                .onAppear {
                    Task {
                        self.categoryData.getData()
                        self.networkMonitor.startMonitoring()
                        self.settings.loadSettings()
                        
                        await monitorTransactions()
                    }
                }
                .task {
                    Task {
                        await self.eznotesSubscriptionManager.obtainCurrentSubscription()
                    }
                }
        }
    }
}
