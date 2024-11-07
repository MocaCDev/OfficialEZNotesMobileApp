//
//  SubscriptionInfoModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/7/24.
//
import SwiftUI

struct SubscriptionInfo {
    var TimeCreated: String?
    var DateCreated: Date?
    var CurrentPeriodStart: Date?
    var CurrentPeriodEnd: Date?
    
    /* MARK: `Lifetime` implies total number of payments made. */
    var Lifetime: Int?
    var ProductName: String?
    var Price: String?
    var Interval: String?
    var PlanID: String?
    var PriceID: String?
    var ProductID: String?
    var Last4: String?
    var PaymentMethodCreatedOn: Date?
    var PaymentType: String? /* MARK: Should always be "card". */
    var CardBrand: String?
    var CardExpMonth: String?
    var CardExpYear: String?
}
