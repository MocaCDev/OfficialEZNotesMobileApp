//
//  EZNotesSubscriptionManager.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/28/24.
//
import SwiftUI
import Foundation
import StoreKit

class EZNotesSubscriptionManager: ObservableObject {
    
    /* MARK: Users subscriptions. */
    @Published private(set) var userSubscriptionIDs = Set<String>()
    @Published private(set) var userSubscriptionID: String? = nil
    @Published private(set) var subscriptionName: String = "N/A"
    @Published private(set) var userProducts = Set<Product>()
    @Published private(set) var subscriptionStatus: Product.SubscriptionInfo.Status? = nil
    
    /* MARK: Information over the plan details (monthly/yearly) depending on the `planView` in `Plans` view. */
    @Published private(set) var products: Array<Product> = []
    
    /* MARK: Plan IDs. */
    private let plans: [String: Array<String>] = [
        "basic_plan": [
            "eznotes.basic.plan.monthly",
            "eznotes.basic.plan.annually"
        ],
        "pro_plan": [
            "eznotes.pro.plan.monthly",
            "eznotes.pro.plan.annually"
        ]
    ]
    
    /* MARK: Features for each plan. */
    private let basic_plan_features: [String: AnyView] = [
        "1gb Upload Limit": AnyView(Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
            .resizable()
            .frame(width: 20, height: 25)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "100 Image Upload Limit": AnyView(Image(systemName: "photo.artframe")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "5gb Backup Limit": AnyView(Image(systemName: "clock")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "~450K Backup Limit on Notes": AnyView(Image(systemName: "list.bullet.clipboard")
            .resizable()
            .frame(width: 20, height: 25)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "EZNotes LLM": AnyView(Image(systemName: "sparkles")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "EZNotes ChatBot": AnyView(Image(systemName: "sparkles")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20))
    ]
    
    private let pro_plan_features: [String: AnyView] = [
        "2gb Upload Limit": AnyView(Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
            .resizable()
            .frame(width: 20, height: 25)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "200-250 Image Upload Limit": AnyView(Image(systemName: "photo.artframe")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "10gb Backup Limit": AnyView(Image(systemName: "clock")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "~10M Backup Limit on Notes": AnyView(Image(systemName: "list.bullet.clipboard")
            .resizable()
            .frame(width: 20, height: 25)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "EZNotes LLM": AnyView(Image(systemName: "sparkles")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "EZNotes ChatBot": AnyView(Image(systemName: "sparkles")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "Essay Helper": AnyView(Image(systemName: "note")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "Handwritten Note Curation": AnyView(Image(systemName: "pencil.and.scribble")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20)),
        "Integrated Note-taking Styles": AnyView(Image(systemName: "pencil.and.scribble")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .padding(.trailing, 20))
    ]
    
    /* MARK: Special features; will let the `Plans` view whether to color the card differently or not. */
    public let specialFeatures: Array<String> = [
        "Essay Helper", "Handwritten Note Curation",
        "Integrated Note-taking Styles"
    ]
    
    /* MARK: All of the features for the selected plan in the `Plans` view. */
    @Published public var planFeatures: [String: AnyView] = [:]
    
    private var updates: Task<Void, Never>? = nil
    init() {
        //self.updates = self.observeTransactionUpdates()
    }
    
    //deinit { updates?.cancel() }
    
    /* MARK: Methods for getting details about the users subscription. */
    public func getSubscriptionName() -> String? {
        /*if self.userSubscriptionIDs.isEmpty { return nil }
        
        /* MARK: Return `Optional`, as the return type of the function is an optional. */
        if self.userSubscriptionIDs.first!.contains("basic") { return Optional("Basic Plan") }
        else { return Optional("Pro Plan") }*/
        guard
            let subscriptionDetails = self.userProducts.first
        else {
            return nil
        }
        
        if subscriptionDetails.displayName.contains("Basic") { return Optional("Basic Plan") }
        else { return Optional("Pro Plan") }
    }
    
    public func getSubscriptionPrice() -> String? {
        guard
            let subscriptionDetails = self.userProducts.first
        else {
            return nil
        }
        
        return Optional(subscriptionDetails.displayPrice)
    }
    
    public func configurePlans(isFor: String) -> Array<String> {
        switch(isFor) {
        case "basic_plan":
            self.planFeatures = self.basic_plan_features
            return self.plans[isFor]!
        case "pro_plan":
            self.planFeatures = self.pro_plan_features
            return self.plans[isFor]!
        default:
            self.planFeatures = self.basic_plan_features
            return self.plans[isFor]!
        }
    }
    
    public func loadProducts(planIDs: Array<String>) async throws {
        let p = try await Product.products(for: planIDs)
        
        /* MARK: Ensure the `Published` variable is updated on the main thread. */
        await MainActor.run {
            self.products = p
        }
    }
    
    /* MARK: Returns `true` upon purchase being successful; else returns `false`. */
    public func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
            await self.obtainCurrentSubscription()
            return true
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            print(error)
            return true
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
        
        return false
    }
    
    public func obtainSubscriptionID() -> String? { return self.userSubscriptionID }
    
    public func doesSubscriptionAutoRenew() -> String? {
        do {
            guard
                let json: [String: Any] = try JSONSerialization.jsonObject(with: self.subscriptionStatus!.renewalInfo.payloadData, options: []) as? [String : Any],
                json.keys.contains("autoRenewStatus")
            else {
                return nil
            }
            
            return json["autoRenewStatus"]! as! Int == 1 ? Optional("Yes") : Optional("No")
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func obtainBillingDueDate() -> String? {
        
        if self.subscriptionStatus != nil {
            do {
                let json: [String: Any] = try JSONSerialization.jsonObject(with: self.subscriptionStatus!.renewalInfo.payloadData, options: []) as! [String : Any]
                
                print(json)
                
                print(Date(timeIntervalSince1970: TimeInterval((json["renewalDate"]! as! Int) / 1000)).formatted(date: .long, time: .omitted))//(json["renewalDate"]! as! Date).formatted(date: .numeric, time: .omitted))
                
                return Optional(Date(timeIntervalSince1970: TimeInterval((json["renewalDate"]! as! Int) / 1000)).formatted(date: .long, time: .omitted))
            } catch {
                print(error)
            }
        }
        
        /*do {
            // Iterate through entitlements and verify each transaction
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    // Check if this is the subscription we're interested in
                    /*if transaction.productID == "com.example.app.subscription" {
                        billingDueDate = transaction.expirationDate
                        return // Stop once we find the relevant subscription
                    }*/
                    if transaction.productID.contains("eznotes") {
                        let json: [String: Any] = try JSONSerialization.jsonObject(with: await transaction.subscriptionStatus!.renewalInfo.payloadData, options: []) as! [String : Any]
                        
                        //print(json)
                        
                        print(Date(timeIntervalSince1970: TimeInterval((json["renewalDate"]! as! Int) / 1000)).formatted(date: .long, time: .omitted))//(json["renewalDate"]! as! Date).formatted(date: .numeric, time: .omitted))
                        
                        return Optional(Date(timeIntervalSince1970: TimeInterval((json["renewalDate"]! as! Int) / 1000)).formatted(date: .long, time: .omitted))
                    }
                case .unverified(_, let error):
                    print("Unverified transaction: \(error.localizedDescription)")
                    break
                    //return nil
                }
            }
        } catch {
            print("Failed to fetch billing due date: \(error.localizedDescription)")
        }*/
        
        return nil
    }
    
    public func obtainCurrentSubscriptionID() -> String? { return self.userSubscriptionID }
    
    public func obtainCurrentSubscription() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Check if this is the subscription we're interested in
                /*if transaction.productID == "com.example.app.subscription" {
                    billingDueDate = transaction.expirationDate
                    return // Stop once we find the relevant subscription
                }*/
                let status = await transaction.subscriptionStatus
                
                await MainActor.run { self.subscriptionStatus = status }
                
                if transaction.productID.contains("eznotes") {
                    let _ = await MainActor.run { self.userSubscriptionID = transaction.productID }
                }
            case .unverified(_, let error):
                print("Unverified transaction: \(error.localizedDescription)")
            }
            
            //guard case .verified(let transaction) = result else { continue }
        }
        
        do {
            if self.userSubscriptionID != nil {
                let productDetails = try await Product.products(for: [self.userSubscriptionID!])
                
                await MainActor.run {
                    self.userProducts = Set<Product>(productDetails)
                }
            }
        } catch {
            print(error)
        }
    }
    
    public func getSubscriptionDetails() -> Set<Product> {
        return self.userProducts
    }
    
    /* MARK: "Listen" for payment updates on subscription. Needed just in case a subscription is deactivated, renewed etc from outside the app. */
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.obtainCurrentSubscription()
            }
        }
    }
}
