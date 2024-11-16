//
//  Plans.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/8/24.
//
import SwiftUI
import StripePayments

public struct Plans: View {
    var prop: Properties
    var email: String
    var accountID: String
    var borderBottomColor: LinearGradient
    var borderBottomColorError: LinearGradient
    var isLargerScreen: Bool
    var action: () -> Void
    
    private let planNames: [String: String] = [
        "basic_plan_monthly": "Monthly Basic Plan",
        "basic_plan_annually": "Annual Basic Plan",
        "pro_plan_monthly": "Monthly Pro Plan",
        "pro_plan_annually": "Annual Pro Plan"
    ]
    
    private let planCosts: [String: String] = [
        "Monthly Basic Plan": "12",
        "Annual Basic Plan": "126",
        "Monthly Pro Plan": "16",
        "Annual Pro Plan": "170"
    ]
    
    @State private var isPlanPicked: Bool = false
    @State private var planPicked: String = ""
    @State private var planName: String = "" /* MARK: The name to display at the top of the payment popover. */
    @State private var planPrice: String = ""
    @State private var cardHolderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvc: String = ""
    @State private var lastCardNumberLength: Int = 0
    @State private var cardNumberIndex: Int = 0
    @State private var showPrivacyPolicy: Bool = false
    @State private var processingPayment: Bool = false
    @State private var paymentGood: Bool = true
    @State private var paymentDone: Bool = false
    
    /* MARK: This is a state of this structure because there is no point of making using it as a binding. */
    @Binding public var makeContentRed: Bool
    
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
    
    public var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack {
                        VStack {
                            VStack {
                                Text("Basic Plan")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.black)
                                    .padding([.top, .bottom])
                                    .font(.system(size: 24))
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        
                        VStack {
                            VStack {
                                Text("Description")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                /*Text("The Basic Plan includes all of the fundamental features that a user will need to automate the note taking process.")*/
                                Text("The Basic Plan equips you with all the fundamentals that the app comes with.\nIt enables you to uploads roughly 100 images of notes at once and backup roughly 450K notes. You also get access to EZNotes Chatbot which can be your personal tutor through your note taking and studying adventures.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding([.bottom, .leading], 10)
                                    .font(.system(size: 12))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.leading)
                            
                            VStack {
                                Text("Uploads:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• 1gb Upload Limit\n\t◦ 100 Image Upload Limit\n• 5gb Backup Limit\n\t◦ Roughly 450K notes can be backed up")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading])
                            
                            VStack {
                                Text("AI Access:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• EZNotes LLM\n\t◦ Powers the automated note-curation\n• EZNotes Chatbot\n\t◦ Your personal tutor")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading])
                            
                            VStack {
                                Text("Built-in Features:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• Essay Helper\n• Note Curation")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading, .bottom])
                        }
                        .padding()
                        
                        VStack {
                            Button(action: {
                                self.planPicked = "basic_plan_monthly"
                                self.isPlanPicked = true
                            }) {
                                HStack {
                                    VStack {
                                        Text("Select Monthly")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 20 : 16, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.semibold)
                                        
                                        Text("From $12/month ($144/year)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ZStack {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(8)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Divider()
                                .background(.gray)
                            
                            Button(action: {
                                self.planPicked = "basic_plan_annually"
                                self.isPlanPicked = true
                            }) {
                                HStack {
                                    VStack {
                                        Text("Select Yearly")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 20 : 16, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.semibold)
                                        
                                        Text("From $126/year ($10.50/month)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ZStack {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(8)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                        .background(Color.black.opacity(0.30))
                        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    }
                    .frame(maxWidth: prop.size.width - 40)
                    .cornerRadius(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesBlack)
                            .shadow(color: .black, radius: 2.5)
                    )
                    .padding(.bottom, 15)
                }
                .frame(maxWidth: prop.size.width - 30)
                
                VStack {
                    VStack {
                        VStack {
                            Text("Pro Plan")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .padding([.top, .bottom])
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                 Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                 Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                            ])
                        )
                        
                        VStack {
                            VStack {
                                Text("Description")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("The Pro Plan equips you with everything from the Basic Plan and more.\nWith the Pro Plan, you get 2x the limit on the uploads and backups enabling you to upload 200+ images of notes at once and enabling you to store roughly 1M curated sets of notes. Further, the Pro Plan equips you with a model of EZNotes AI that is capable of adapting to your handwriting and curating a essay in your handwriting.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding([.bottom, .leading], 10)
                                    .font(.system(size: 14))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.leading)
                            
                            VStack {
                                Text("Uploads:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• 2gb Upload Limit\n\t◦ 200-250 Image Upload Limit\n• 10gb Backup Limit\n\t◦ Roughly 1M notes can be backed up")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading])
                            
                            VStack {
                                Text("AI Access:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• EZNotes LLM\n\t◦ Powers the automated note-curation\n• EZNotes Chatbot\n\t◦ Your personal tutor")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading])
                            
                            VStack {
                                Text("Built-in Features:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("• Essay Helper\n• Handwritten Note Curation\n• Integrated Note-taking Styles\n• Note Curation")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .padding(.top, 5)
                                    .padding(.leading, 10)
                                    .font(.system(size: 15))
                                    .minimumScaleFactor(0.5)
                            }
                            .padding([.top, .leading, .bottom])
                        }
                        .padding()
                        
                        VStack {
                            Button(action: {
                                self.planPicked = "pro_plan_monthly"
                                self.isPlanPicked = true
                            }) {
                                HStack {
                                    VStack {
                                        Text("Select Monthly")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 20 : 16, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.semibold)
                                        
                                        Text("From $16/month ($192/year)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ZStack {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(8)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Divider()
                                .background(.gray)
                            
                            Button(action: {
                                self.planPicked = "pro_plan_annually"
                                self.isPlanPicked = true
                            }) {
                                HStack {
                                    VStack {
                                        Text("Select Yearly")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 20 : 16, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.semibold)
                                        
                                        Text("From $170/year ($14/month)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    ZStack {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(8)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                        .padding(8)
                        .background(Color.black.opacity(0.30))
                        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    }
                    .frame(maxWidth: prop.size.width - 40)
                    .cornerRadius(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesBlack)
                            .shadow(color: .black, radius: 2.5)
                    )
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: prop.size.width - 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popover(isPresented: $isPlanPicked) {
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
                                .font(.system(size: self.isLargerScreen ? 30 : 25, design: .rounded))
                                .fontWeight(.heavy)
                            
                            if !self.paymentGood {
                                Text("An error ocurred while processing your payment. Check over the details and try again. If problems persist, contact us.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.red)
                                    .font(.system(size: 12))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.light)
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
                                        maxHeight: self.isLargerScreen ? 40 : 30
                                    )
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom], 5)
                                    .padding(.horizontal, 25)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                            .border(
                                                width: 1,
                                                edges: [.bottom],
                                                lcolor: !self.makeContentRed
                                                ? self.borderBottomColor
                                                : self.cardHolderName == "" ? self.borderBottomColorError : self.borderBottomColor
                                            )
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
                                        maxHeight: self.isLargerScreen ? 40 : 30
                                    )
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom], 5)
                                    .padding(.horizontal, 25)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                            .border(
                                                width: 1,
                                                edges: [.bottom],
                                                lcolor: !self.makeContentRed
                                                ? self.borderBottomColor
                                                : self.cardNumber == "" ? self.borderBottomColorError : self.borderBottomColor
                                            )
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
                                                    maxHeight: self.isLargerScreen ? 40 : 30,
                                                    alignment: .leading
                                                )
                                                .padding(.leading, 5)
                                                .padding([.top], 5)
                                                .background(
                                                    Rectangle()
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .border(
                                                            width: 1,
                                                            edges: [.bottom],
                                                            lcolor: !self.makeContentRed
                                                            ? self.borderBottomColor
                                                            : self.expMonth == "" ? self.borderBottomColorError : self.borderBottomColor
                                                        )
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
                                                    maxHeight: self.isLargerScreen ? 40 : 30,
                                                    alignment: .trailing
                                                )
                                                .padding(.leading, 5)
                                                .padding([.top], 5)
                                                .background(
                                                    Rectangle()
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .border(
                                                            width: 1,
                                                            edges: [.bottom],
                                                            lcolor: !self.makeContentRed
                                                            ? self.borderBottomColor
                                                            : self.expYear == "" ? self.borderBottomColorError : self.borderBottomColor
                                                        )
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
                                                maxHeight: self.isLargerScreen ? 40 : 30,
                                                alignment: .leading
                                            )
                                            .padding(.leading, 15)
                                            .padding([.top], self.isLargerScreen ? 5 : 0)
                                            .padding(.horizontal, 25)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                    .border(
                                                        width: 1,
                                                        edges: [.bottom],
                                                        lcolor: !self.makeContentRed
                                                        ? self.borderBottomColor
                                                        : self.cvc == "" ? self.borderBottomColorError : self.borderBottomColor
                                                    )
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
                                    .padding(.bottom, self.isLargerScreen ? 18 : 14)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("By clicking \"Submit Payment\" you are **purchasing a recurring subscription**. Upon clicking \"Submit Payment\", you agree to the payment of **$\(self.planPrice)/\(self.planPicked.contains("monthly") ? "month" : "year")**.\n\nAll purchases are handled securely by Stripe. Stripe is our partner for processing payments for subscriptions. If you have any questions, do not hesitate to contact us.\n\nBy clicking \"Submit Payment\" below, you agree to EZNotes Terms and Conditions and confirm you have read and understood our Privacy and Policy.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: self.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Button(action: { self.showPrivacyPolicy.toggle() }) {
                                        Text("Privacy & Policy")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: self.isLargerScreen ? 13 : 11))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.light)
                                            .underline()
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .background(.white)
                                        .frame(height: 15)
                                    
                                    Button(action: { self.showPrivacyPolicy.toggle() }) {
                                        Text("Terms and Conditions")
                                            .foregroundStyle(.blue)
                                            .font(.system(size: self.isLargerScreen ? 13 : 11))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.light)
                                            .underline()
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, maxHeight: 26, alignment: .leading)
                                .padding(.top, self.isLargerScreen ? 0 : -5)
                                
                                if !self.isLargerScreen {
                                    Button(action: {
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
                            }
                            .frame(maxWidth: prop.size.width - 80, alignment: .top)
                            .padding(.top, 20)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                        }
                        .frame(maxWidth: prop.size.width - 80, maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        
                        //Spacer()
                        
                        if self.isLargerScreen {
                            VStack {
                                Button(action: {
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
                                        
                                        //if action != nil {
                                            DispatchQueue.main.async { action() }
                                        //}
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
                                .padding(.bottom, 20)
                                
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesBlack)
                .popover(isPresented: $showPrivacyPolicy) {
                    WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                        .navigationBarTitle("Privacy Policy", displayMode: .inline)
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
