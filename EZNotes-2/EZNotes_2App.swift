//
//  EZNotes_2App.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//

import SwiftUI
import StoreKit
import Foundation

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

public func getLocalIPAddress() -> String? {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    var localAddress: String?
    
    // Retrieve the current interfaces
    guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
    
    // Iterate through each interface
    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ptr.pointee
        
        // Check for IPv4 or IPv6
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            // Convert interface address to a human-readable string
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(
                interface.ifa_addr,
                socklen_t(interface.ifa_addr.pointee.sa_len),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )
            
            let address = String(cString: hostname)
            
            // Filter out loopback and link-local addresses
            if address != "127.0.0.1" && address != "::1" && !address.contains("%") {
                localAddress = address
                break
            }
        }
    }
    freeifaddrs(ifaddr)
    
    return localAddress
}

@main
struct EZNotes_2App: App {
    @StateObject private var eznotesSubscriptionManager: EZNotesSubscriptionManager = EZNotesSubscriptionManager()
    @StateObject private var categoryData: CategoryData = CategoryData()
    @StateObject private var accountInfo: AccountDetails = AccountDetails()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var settings: SettingsConfigManager = SettingsConfigManager()
    @StateObject public var messageModel: MessagesModel = MessagesModel()
    @StateObject private var model: FrameHandler = FrameHandler()
    
    /* MARK: Needed for `CategoryInternalsView.swift`, as there is the ability to create a set via images. */
    @StateObject public var images_to_upload: ImagesUploads = ImagesUploads()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                images_to_upload: self.images_to_upload,
                model: model
            )
                .environmentObject(self.eznotesSubscriptionManager)
                .environmentObject(self.categoryData)
                .environmentObject(self.accountInfo)
                .environmentObject(self.networkMonitor)
                .environmentObject(self.settings)
                .environmentObject(self.messageModel)
                //.environmentObject(self.images_to_upload)
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
