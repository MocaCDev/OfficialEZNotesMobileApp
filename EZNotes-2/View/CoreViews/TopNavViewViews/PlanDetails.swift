//
//  PlanDetails.swift
//  EZNotes-2
//
//  Created by Aidan White on 1/10/25.
//
import SwiftUI

struct PlanDetails: View {
    @EnvironmentObject private var eznotesSubscriptionManager: EZNotesSubscriptionManager
    var prop: Properties
    
    @Binding public var accountPopupSection: String
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                .background(
                    Image("DefaultThemeBg3")
                        .resizable()
                        .scaledToFill()
                )
                .padding(.top, 70)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)
            
            VStack {
                HStack {
                    Button(action: { self.accountPopupSection = "main" }) {
                        ZStack {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 20, alignment: .leading)
                        .padding(.top, 15)
                        .padding(.leading, 25)
                    }
                    
                    VStack {
                        Text(self.eznotesSubscriptionManager.getSubscriptionName() != nil ? self.eznotesSubscriptionManager.getSubscriptionName()! : "Plan Details")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding([.top], 25)
                            .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                        
                        /* MARK: Do we really want to display the subscriptions price under the subscriptions name? */
                        Text(self.eznotesSubscriptionManager.getSubscriptionPrice() != nil ?
                             self.eznotesSubscriptionManager.getSubscriptionPrice()! : "")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .setFontSizeAndWeight(weight: .bold, size: 14)
                    }
                    .frame(maxWidth: .infinity)
                    
                    /* MARK: "spacing" to ensure above Text stays in the middle. */
                    ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(.top, prop.isLargerScreen ? 55 : prop.isMediumScreen ? 45 : 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                if self.eznotesSubscriptionManager.userSubscriptionID == nil {
                    ErrorMessage(
                        prop: self.prop,
                        placement: .center,
                        message: "No Active Subscriptions"
                    )
                } else {
                    Text("Details")
                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                        .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 26 : 20))
                        .foregroundStyle(.white)
                    
                    VStack {
                        HStack {
                            Text("Auto Renews:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                                .foregroundStyle(.white)
                            
                            Text(self.eznotesSubscriptionManager.doesSubscriptionAutoRenew() != nil ?
                                 self.eznotesSubscriptionManager.doesSubscriptionAutoRenew()! : "N/A")
                            .frame(alignment: .trailing)
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .background(.white)
                        
                        HStack {
                            Text("Renewal Date:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                                .foregroundStyle(.white)
                            
                            Text(self.eznotesSubscriptionManager.obtainBillingDueDate() != nil ?
                                self.eznotesSubscriptionManager.obtainBillingDueDate()! : "N/A")
                            .frame(alignment: .trailing)
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .background(.white)
                        
                        HStack {
                            Text("Renewal Price:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                                .foregroundStyle(.white)
                            
                            Text(self.eznotesSubscriptionManager.getSubscriptionPrice() != nil ?
                                 self.eznotesSubscriptionManager.getSubscriptionPrice()! : "N/A")
                            .frame(alignment: .trailing)
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .background(.white)
                        
                        HStack {
                            Text("Subscription Name:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                                .foregroundStyle(.white)
                            
                            Text(self.eznotesSubscriptionManager.userProducts.first!.displayName)
                            .frame(alignment: .trailing)
                            .font(Font.custom("Poppins-Light", size: 14))
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(8)
                    .padding()
                    .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                    .cornerRadius(15)
                    
                    Text("Actions")
                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                        .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 24 : 18))
                        .foregroundStyle(.white)
                        .padding(.top, 20)
                    
                    VStack {
                        Button(action: {
                            guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Text("Manage Subscription")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding([.top, .bottom], 8)
                                    .foregroundStyle(.black)
                                    .setFontSizeAndWeight(weight: .bold, size: 18)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.white)
                            )
                            .cornerRadius(15)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            .padding(.top, prop.isLargerScreen ? 150 : prop.isMediumScreen ? 140 : 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
