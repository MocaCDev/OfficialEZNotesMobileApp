//
//  Plans.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/8/24.
//
import SwiftUI
import StripePayments
import StoreKit

enum PlanErrors {
    case None
    case CardHolderNameEmpty
    case CardNumberEmpty
    case CardExpMonthEmpty
    case CardExpYearEmpty
    case CardCVCEmpty
}

enum CardDetailsPopupType {
    case None
    case PrivacyPolicyPopup
    case TermsAndConditionsPopup
}

public struct Plans: View {
    @EnvironmentObject private var eznotesSubscriptionManager: EZNotesSubscriptionManager
    
    /* MARK: Key variables needed for the struct. */
    var prop: Properties
    var email: String
    var accountID: String
    var isLargerScreen: Bool
    var action: ()->Void /* TODO: Is this needed? */
    
    /* MARK: Plan names; used to determine what plan name to display in the payment information popup. */
    private let planNames: [String: String] = [
        "basic_plan_monthly": "Monthly Basic Plan",
        "basic_plan_annually": "Annual Basic Plan",
        "pro_plan_monthly": "Monthly Pro Plan",
        "pro_plan_annually": "Annual Pro Plan"
    ]
    
    /* MARK: Costs of each plan; used to determine what each plan costs. Described in fine print in the payment popup, and prior to payment popup. */
    private let planCosts: [String: String] = [
        "Monthly Basic Plan": "12",
        "Annual Basic Plan": "126",
        "Monthly Pro Plan": "16",
        "Annual Pro Plan": "170"
    ]
    
    /* MARK: Enumerations over the overall "state" of the view. Below variables help decipher how the view looks. */
    @State private var planError: PlanErrors = .None
    @State private var cardDetailsPopupType: CardDetailsPopupType = .None
    
    /* MARK: Variables over plan selection - data such as whether or not a plan has been selected, what plan was selected etc */
    @State private var isPlanPicked: Bool = false
    @State private var planPicked: String = ""
    @State private var planName: String = "" /* MARK: The name to display at the top of the payment popover. */
    @State private var planPrice: String = ""
    
    /* MARK: Payment information. */
    @State private var cardHolderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvc: String = ""
    
    /* MARK: Variables explicitly adherent to the card details view. `cardDetailsPopup` is used to determine whether or not the card details popup will have a popup show up to present the privacy policy/terms & conditions to the user. */
    @State private var cardDetailsPopup: Bool = false
    @State private var processingPayment: Bool = false
    
    /* MARK: Variables over the "state" of the payment being processed. */
    @State private var paymentGood: Bool = true
    @State private var paymentDone: Bool = false
    
    /* MARK: Function that sends a request to the appropriate API endpoint to create a stripe checkout, enabling the user to "purchase" the subscription they chose. */
    private func payForSubscription(_ paymentMethodId: String, comp: @escaping (String, String?) -> Void) {
        guard let url = URL(string: server)?.appendingPathComponent("/create-stripe-checkout-mobile") else {
            print("Failed")
            return
        }
        
        let body: [String: Any] = [
            "name": self.cardHolderName,
            "email": self.email,
            "paymentID": paymentMethodId,
            "priceID": self.planPicked
        ]
        
        var request = URLRequest(url: url)
        
        request.addValue("yes", forHTTPHeaderField: "Fm")
        request.addValue(self.accountID, forHTTPHeaderField: "Account-Id")
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let _: Void = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                200..<300~=response.statusCode,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                comp("failed", nil)
                return
            }
        
            DispatchQueue.main.async {
                comp("success", resp["customerID"] as? String)
            }
        }).resume()
    }
    
    /* MARK: Convenient function that creates the payment method that will be used in the above function. */
    private func createPaymentMethod(_ comp: @escaping (String, String?) -> Void) {
        let result = STPPaymentMethodCardParams()
        result.number = self.cardNumber
        result.expMonth = NSNumber(value: Int(self.expMonth)!)
        result.expYear = NSNumber(value: Int(self.expYear)!)
        result.cvc = self.cvc
        
        let paymentMethodParams = STPPaymentMethodParams(card: result, billingDetails: nil, metadata: nil)
        
        STPAPIClient.shared.createPaymentMethod(with: paymentMethodParams) { paymentMethod, error in
            if let error = error {
                print("Error creating Payment Method: \(error)")
                
                DispatchQueue.main.async {
                    comp("failed", nil)
                }
                
                return
            }
            
            if paymentMethod != nil {
                self.payForSubscription(paymentMethod!.stripeId, comp: comp)
            }
        }
    }
    
    @State private var planView: String = "basic_plan"
    
    @State private var loadingPlansError: Bool = false
    @State private var plansError: String = ""
    
    public var body: some View {
        VStack {
            /* TODO: Perhaps refactor the way the below hstack is structured. */
            HStack {
                Button(action: {
                    self.planView = "basic_plan"
                    
                    Task {
                        do {
                            try await self.eznotesSubscriptionManager.loadProducts(planIDs: self.eznotesSubscriptionManager.configurePlans(isFor: self.planView))
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    HStack {
                        Text("Basic Plan")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 15))
                            .padding(.bottom, 5) /* MARK: Add padding to the bottom of the text to push the below border down a bit. */
                            .border(width: self.planView == "basic_plan" ? 1 : 0, edges: [.bottom], mgColor: MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ]))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 15)
                }
                
                Button(action: {
                    self.planView = "pro_plan"
                    
                    Task {
                        do {
                            try await self.eznotesSubscriptionManager.loadProducts(planIDs: self.eznotesSubscriptionManager.configurePlans(isFor: self.planView))
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    HStack {
                        Text("Pro Plan")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 15))
                            .padding(.bottom, 5)
                            .border(width: self.planView == "pro_plan" ? 1 : 0, edges: [.bottom], mgColor: MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ]))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                HStack {
                    Text("Pro+ Plan")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 15))
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 15)
            }
            .frame(maxWidth: prop.size.width - 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(Array(self.eznotesSubscriptionManager.planFeatures.keys), id: \.self) { feature in
                        ZStack {
                            if self.eznotesSubscriptionManager.specialFeatures.contains(feature) {
                                MeshGradient(width: 3, height: 3, points: [
                                    .init(0, 0), .init(0.3, 0), .init(1, 0),
                                    .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                                ], colors: [
                                    .indigo, .indigo, Color.EZNotesBlue,
                                    Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                    .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                ])
                                .blur(radius: 10)
                            }
                            
                            HStack {
                                self.eznotesSubscriptionManager.planFeatures[feature]!
                                
                                Text(feature)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))//.font(.system(size: prop.isLargerScreen ? 20 : 16, weight: .medium))
                            }
                            .frame(maxWidth: prop.size.width - 60)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.secondary)
                                    .shadow(color: Color.black, radius: 2.5)
                            )
                            .cornerRadius(10)
                            .padding(2.5)
                        }
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                    }
                    
                    Divider()
                        .background(MeshGradient(width: 3, height: 3, points: [
                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ], colors: [
                            .indigo, .indigo, Color.EZNotesBlue,
                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                        ]))
                        .frame(maxWidth: prop.size.width - 60)
                    
                    if self.eznotesSubscriptionManager.products.isEmpty {
                        if self.loadingPlansError {
                            Text(self.plansError)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 8)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .bold))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                        } else {
                            LoadingView(message: "Loading Details...")
                        }
                    } else {
                        VStack {
                            ForEach(self.eznotesSubscriptionManager.products) { product in
                                Button(action: {
                                    Task {
                                        do {
                                            let success = try await self.eznotesSubscriptionManager.purchase(product)
                                            
                                            /* MARK: If it was not a success, just return. We can assume that the user retreated from buying the selected plan, or some sort of connection/internal error happened forcing them to try again. */
                                            if !success {
                                                return
                                            }
                                            
                                            UserDefaults.standard.set(true, forKey: "plan_selected")
                                            
                                            DispatchQueue.main.async { action() }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Subscribe for \(product.displayPrice)/\(product.displayName.contains("Monthly") ? "month" : "year")")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.black)
                                            .font(.system(size: prop.isLargerScreen ? 16 : 13, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.EZNotesBlue)
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea([.bottom])
        .task {
            Task {
                /* MARK: Perform this when the view appears so that the according buttons show for the "basic_plan" plan view. */
                do {
                    try await self.eznotesSubscriptionManager.loadProducts(planIDs: self.eznotesSubscriptionManager.configurePlans(isFor: self.planView))
                } catch {
                    self.loadingPlansError = true
                    self.plansError = error.localizedDescription
                }
            }
        }
        .popover(isPresented: $isPlanPicked) { /* TODO: Delete. I do not believe it is needed anymore. Keep for now just in case it's needed. */
            GeometryReader { geometry in
                VStack {
                    if self.processingPayment {
                        VStack {
                            Text("Processing...")
                                .foregroundStyle(.white)
                                .font(.system(size: 25))
                            
                            ProgressView()
                                .tint(Color.EZNotesBlue)
                                .controlSize(.regular)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.EZNotesBlack.opacity(0.7))
                    } else {
                        VStack {
                            Text(self.planName)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .leading, .trailing])
                                .padding(.bottom, 5)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 30 : 25, design: .rounded))
                                .fontWeight(.heavy)
                            
                            if self.planError != .None {
                                Text(
                                    self.planError == .CardHolderNameEmpty
                                        ? "Card Holder field was left empty. All fields required to proceed."
                                        : self.planError == .CardNumberEmpty
                                            ? "Card Number field was left empty. All fields required to proceed."
                                            : self.planError == .CardExpMonthEmpty || self.planError == .CardExpYearEmpty
                                                ? "Card Exp Year/Month field was left empty. All fields required to proceed"
                                                : "CVC field was left empty. All fields required to proceed"
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                                .minimumScaleFactor(0.5)
                                .fontWeight(.light)
                                .multilineTextAlignment(.leading)
                            } else {
                                if !self.paymentGood {
                                    Text("An error ocurred while processing your payment. Check over the details and try again. If problems persist, contact us.")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.red)
                                        .font(.system(size: 12))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            Divider()
                                .frame(maxWidth: prop.size.width - 40)
                            
                            VStack {
                                Text("Card Details")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 22))
                                    .fontWeight(.medium)
                                
                                TextField("Card Holder Name", text: $cardHolderName)
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: prop.isLargerScreen ? 40 : 30
                                    )
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom], 5)
                                    .padding(.horizontal, 25)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                            .borderBottomWLColor(isError: self.planError != .CardHolderNameEmpty)
                                    )
                                    .tint(Color.EZNotesBlue)
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal, 10)
                                    .keyboardType(.alphabet)
                                    .overlay(
                                        HStack {
                                            Image(systemName: "person.crop.circle")
                                                .foregroundColor(.gray)
                                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                        }
                                    )
                                
                                TextField("Card Number", text: $cardNumber)
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: prop.isLargerScreen ? 40 : 30
                                    )
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom], 5)
                                    .padding(.horizontal, 25)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                            .borderBottomWLColor(isError: self.planError != .CardNumberEmpty)
                                    )
                                    .tint(Color.EZNotesBlue)
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal, 10)
                                    .overlay(
                                        HStack {
                                            Image(systemName: "creditcard")
                                                .foregroundColor(.gray)
                                                .frame(
                                                    minWidth: 0, maxWidth: .infinity,
                                                    minHeight: 0, maxHeight: .infinity,
                                                    alignment: .leading
                                                )
                                                .padding(.leading, 15)
                                        }
                                    )
                                    .textContentType(.creditCardNumber)
                                    .onChange(of: self.cardNumber) {
                                        if self.cardNumber.count >= 16 {
                                            self.cardNumber = String(self.cardNumber.prefix(16))
                                        }
                                    }
                                
                                HStack {
                                    HStack {
                                        VStack {
                                            TextField("02", text: $expMonth)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: prop.isLargerScreen ? 40 : 30,
                                                    alignment: .leading
                                                )
                                                .padding(.leading, 5)
                                                .padding([.top], 5)
                                                .background(
                                                    Rectangle()
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .borderBottomWLColor(isError: self.planError != .CardExpYearEmpty)
                                                )
                                                .tint(Color.EZNotesBlue)
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .padding(.horizontal, 10)
                                                .keyboardType(.numberPad)
                                                .onChange(of: self.expMonth) {
                                                    if self.expMonth.count >= 2 {
                                                        self.expMonth = String(self.expMonth.prefix(2))
                                                    }
                                                }
                                            
                                            Text("Month")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(.white)
                                                .padding(.leading, 15)
                                                .font(.system(size: 12))
                                                .fontWeight(.thin)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        VStack {
                                            TextField("27", text: $expYear)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: prop.isLargerScreen ? 40 : 30,
                                                    alignment: .trailing
                                                )
                                                .padding(.leading, 5)
                                                .padding([.top], 5)
                                                .background(
                                                    Rectangle()
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .borderBottomWLColor(isError: self.planError != .CardExpYearEmpty)
                                                )
                                                .tint(Color.EZNotesBlue)
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .padding(.horizontal, 10)
                                                .keyboardType(.numberPad)
                                                .onChange(of: self.expYear) {
                                                    if self.expYear.count >= 2 {
                                                        self.expYear = String(self.expYear.prefix(2))
                                                    }
                                                }
                                            
                                            Text("Year")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(.white)
                                                .padding(.leading, 15)
                                                .font(.system(size: 12))
                                                .fontWeight(.thin)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        TextField("CVC", text: $cvc)
                                            .frame(
                                                maxWidth: .infinity,
                                                maxHeight: prop.isLargerScreen ? 40 : 30,
                                                alignment: .leading
                                            )
                                            .padding(.leading, 15)
                                            .padding([.top], prop.isLargerScreen ? 5 : 0)
                                            .padding(.horizontal, 25)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                    .borderBottomWLColor(isError: self.planError != .CardCVCEmpty)
                                            )
                                            .tint(Color.EZNotesBlue)
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .font(.system(size: 18))
                                            .fontWeight(.medium)
                                            .autocapitalization(.words)
                                            .disableAutocorrection(true)
                                            .padding(.horizontal, 10)
                                            .keyboardType(.numberPad)
                                            .overlay(
                                                HStack {
                                                    Image(systemName: "key")
                                                        .foregroundColor(.gray)
                                                        .frame(
                                                            minWidth: 0, maxWidth: .infinity,
                                                            minHeight: 0, maxHeight: .infinity,
                                                            alignment: .leading
                                                        )
                                                        .padding(.leading, 15)
                                                }
                                            )
                                            .onChange(of: self.cvc) {
                                                if self.cvc.count == 3 {
                                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                }
                                                /*if self.cvc.count >= 3 {
                                                 self.cvc = String(self.cvc.prefix(3))
                                                 }*/
                                            }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.bottom, prop.isLargerScreen ? 18 : 14)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("By clicking \"Submit Payment\" you are **purchasing a recurring subscription**. Upon clicking \"Submit Payment\", you agree to the payment of **$\(self.planPrice)/\(self.planPicked.contains("monthly") ? "month" : "year")**.\n\nAll purchases are handled securely by Stripe. Stripe is our partner for processing payments for subscriptions. If you have any questions, do not hesitate to contact us.\n\nBy clicking \"Submit Payment\" below, you agree to EZNotes Terms and Conditions and confirm you have read and understood our Privacy and Policy.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Button(action: {
                                        self.cardDetailsPopupType = .PrivacyPolicyPopup
                                        self.cardDetailsPopup.toggle()
                                    }) {
                                        Text("Privacy & Policy")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.light)
                                            .underline()
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .background(.white)
                                        .frame(height: 15)
                                    
                                    Button(action: {
                                        self.cardDetailsPopupType = .TermsAndConditionsPopup
                                        self.cardDetailsPopup.toggle()
                                    }) {
                                        Text("Terms and Conditions")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.light)
                                            .underline()
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, maxHeight: 26, alignment: .leading)
                                .padding(.top, prop.isLargerScreen ? 0 : -5)
                                
                                Button(action: {
                                    if self.cardHolderName == "" { self.planError = .CardHolderNameEmpty; return }
                                    if self.cardNumber == "" { self.planError = .CardNumberEmpty; return }
                                    if self.expYear == "" { self.planError = .CardExpYearEmpty; return }
                                    if self.expMonth == "" { self.planError = .CardExpMonthEmpty; return }
                                    if self.cvc == "" { self.planError = .CardCVCEmpty; return }
                                    
                                    /* MARK: If all above if statements pass, ensure the state `error` is `.None`. */
                                    if self.planError != .None { self.planError = .None }
                                    
                                    self.processingPayment = true
                                    
                                    self.createPaymentMethod() { status, customerId in
                                        if status != "success" {
                                            self.processingPayment = false
                                            self.paymentGood = false
                                            return
                                        }
                                        
                                        self.processingPayment = false
                                        self.paymentGood = true
                                        self.isPlanPicked = false
                                        self.paymentDone = true
                                        
                                        UserDefaults.standard.set(true, forKey: "plan_selected")
                                        
                                        /* Continue to account. */
                                        //UserDefaults.standard.set(self.username, forKey: "username")
                                        //UserDefaults.standard.set(self.email, forKey: "email")
                                        //UserDefaults.standard.set(customerId!, forKey: "client_id")
                                        
                                        DispatchQueue.main.async { action() }
                                    }
                                }) {
                                    Text("Submit Payment")
                                        .frame(
                                            width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 90,
                                            height: 10
                                        )
                                        .padding([.top, .bottom])
                                        .font(.system(size: 25, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.leading, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                )
                            }
                            .frame(maxWidth: prop.size.width - 80, alignment: .top)
                            .padding(.top, 20)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                        }
                        .frame(maxWidth: prop.size.width - 80, maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        
                        //Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesBlack)
                .popover(isPresented: $cardDetailsPopup) {
                    switch(self.cardDetailsPopupType) {
                    case .PrivacyPolicyPopup:
                        WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                            .navigationBarTitle("Privacy Policy", displayMode: .inline)
                    default:
                        WebView(url: URL(string: "https://www.eznotes.space/terms_and_conditions")!)
                            .navigationBarTitle("Terms & Conditions", displayMode: .inline)
                    }
                }
                .onAppear(perform: {
                    /* MARK: This is so stupid, but it is needed to be able to correctly display the title. */
                    self.planName = self.planNames[self.planPicked]!
                    
                    self.planPrice = self.planCosts[self.planName]!
                })
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}
