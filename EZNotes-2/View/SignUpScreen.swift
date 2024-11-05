//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI
import Combine
import WebKit
import StripePayments

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct SignUpScreen : View, KeyboardReadable {
    @Environment(\.presentationMode) var presentationMode
    
    public var prop: Properties
    
    @State private var showPopup: Bool = false
    
    public var startupScreen: StartupScreen
    
    @Binding public var screen: String
    @Binding public var userHasSignedIn: Bool
    @Binding public var serverError: Bool
    @Binding public var supportedStates: Array<String>
    @State public var supportedColleges: Array<String> = []
    
    @State public var keyboardActivated: Bool = false
    
    @State public var planID: String = ""
    @State public var collegesPickerOpacity: Double  = 0.0
    @State public var accountID: String = ""
    @State public var userInputedCode: String = ""
    @State public var wrongCode: Bool = false
    @State public var wrongCodeAttempts: Int = 0
    @State public var wrongCodeAttemptsMet: Bool = false
    @State public var userExists: Bool = false
    @State public var emailExists: Bool = false
    @State public var username: String = ""
    @State public var email: String = ""
    @State public var password: String = ""
    @State public var college: String = ""
    @State public var major: String = ""
    @State public var section: String = "main"
    @State public var makeContentRed: Bool = false
    
    @State public var imageOpacity: Double = 1
    @FocusState public var passwordFieldInFocus: Bool
    
    @State private var isLargerScreen: Bool = false
    
    @State private var isPlanPicked: Bool = false
    @State private var planPicked: String = ""
    @State private var planName: String = "" /* MARK: The name to display at the top of the payment popover. */
    @State private var cardHolderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvv: String = ""
    @State private var lastCardNumberLength: Int = 0
    @State private var cardNumberIndex: Int = 0
    @State private var showPrivacyPolicy: Bool = false
    @State private var processingPayment: Bool = false
    @State private var paymentGood: Bool = true
    @State private var paymentDone: Bool = false
    
    private let planNames: [String: String] = [
        "basic_plan_monthly": "Monthly Basic Plan",
        "basic_plan_annually": "Annual Basic Plan",
        "pro_monthly_plan": "Monthly Pro Plan",
        "pro_annual_plan": "Annual Pro Plan"
    ]
    
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
        "Wisconsin", "Wyoming"
    ]
    
    @State public var state: String = "Ohio"
    @State private var loadingCollegeInfoSection: Bool = false
    @State private var colleges: Array<String> = []
    @State private var majorFields: Array<String> = []
    @State private var majorField: String = ""
    @State private var majorFieldIsOther: Bool = false
    @State private var majorIsOther: Bool = false
    @State private var collegeIsOther: Bool = false
    @State private var otherCollege: String = ""
    @State private var otherMajorField: String = ""
    @State private var otherMajor: String = ""
    @FocusState private var otherMajorFieldFocus: Bool
    @FocusState private var otherCollegeFocus: Bool
    @State private var showCheckCollegeAlert: Bool = false
    @State private var showCheckMajorFieldAlert: Bool = false
    @State private var majors: Array<String> = []
    
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
        result.cvc = self.cvv
        
        let paymentMethodParams = STPPaymentMethodParams(card: result, billingDetails: nil, metadata: nil)
        
        STPAPIClient.shared.createPaymentMethod(with: paymentMethodParams) { paymentMethod, error in
            if let error = error {
                print("Error creating Payment Method: \(error)")
                return
            }
            
            if paymentMethod != nil {
                self.payForSubscription(paymentMethod!.stripeId, comp: comp)
            }
        }
    }
    
    var borderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesBlue, Color.EZNotesOrange]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    var borderBottomColorError: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesRed, Color.EZNotesRed]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func set_image_opacity(focused: Bool)
    {
        imageOpacity = focused ? 0.0 : 1.0;
    }
    
    private func setLoginStatus() -> Void {
        UserDefaults.standard.set(
            true,
            forKey: "logged_in"
        )
        UserDefaults.standard.set(
            self.accountID,
            forKey: "account_id"
        )
        self.userHasSignedIn = true
    }
    
    /* MARK: Needed to keep responsive sizes consistent with the devices geometry. */
    /* MARK: For example, when the keyboard is active the geometry of the view (in height) shrinks to accomdate the keyboard. */
    @State private var lastHeight: CGFloat = 0.0
    @State private var hideAgreementDetails: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // VStack with TextFields
                VStack {
                    Text(self.section != "select_plan" ? "Sign Up" : "Plans")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        .foregroundStyle(.white)
                        .font(
                            .system(
                                size: prop.isIpad
                                    ? 90
                                    : self.isLargerScreen
                                        ? 35
                                        : 25
                            )
                        )
                        .fontWeight(.bold)
                    
                    Text(
                        self.wrongCode
                            ? "Wrong code. \(3 - self.wrongCodeAttempts) attempts left. Try again"
                            : self.userExists
                                    ? "A user with the username you provided already exists"
                                    : self.emailExists
                                        ? "A user with the email you provided already exists"
                                        : self.section == "main"
                                            ? "Sign up with a unique username, your email and a unique password"
                                            : self.section == "select_state_and_college"
                                                ? "Tell us about your college and your degree :)"
                                                : self.section == "code_input"
                                                    ? "A code has been sent to your email. Input the code below"
                                                    : "Select a plan that best suits you"
                    )
                    .frame(maxWidth: prop.size.width - 30, alignment: .center)
                    .foregroundStyle(self.wrongCode || self.userExists || self.emailExists ? Color.EZNotesRed : Color.white)
                    .font(
                        .system(
                            size: prop.isIpad || self.isLargerScreen
                                ? 15
                                : 13
                        )
                    )
                    .multilineTextAlignment(.center)
                    
                    if self.wrongCodeAttemptsMet {
                        Text("You have put the wrong code in too many time.")
                            .frame(maxWidth: prop.size.width - 30, alignment: .center)
                            .foregroundStyle(Color.EZNotesRed)
                            .font(
                                .system(
                                    size: prop.isIpad || self.isLargerScreen
                                        ? 15
                                        : 13
                                )
                            )
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack {
                        if self.section == "main" {
                            Text("Username")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 10)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 20
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField("Username...", text: $username)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding(self.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                            
                            Text("Email")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 20
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField("Email...", text: $email)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.email == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding(self.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                            
                            Text("Password")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 20
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            SecureField("Password...", text: $password)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                            ? self.borderBottomColor
                                            : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding(self.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .focused($passwordFieldInFocus)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else if self.section == "select_state_and_college" {
                            HStack {
                                Text("State")
                                /*.frame(
                                 width: prop.isIpad
                                 ? prop.size.width - 450
                                 : prop.size.width - 100,
                                 height: 5,
                                 alignment: .leading
                                 )*/
                                    .frame(alignment: .leading)
                                    .padding(.top, 25)
                                    .font(.system(size: self.isLargerScreen ? 20 : 15))
                                    .foregroundStyle(.white)
                                    .fontWeight(.medium)
                                
                                Picker("States", selection: $state) {
                                    ForEach(states, id: \.self) { state in
                                        Text(state)
                                            .id(UUID())
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 25)
                                .padding(.leading, 15)
                                .tint(Color.EZNotesBlue)
                                //.padding(.trailing, 15)
                                .onChange(of: self.state) {
                                    if self.colleges.count > 0 {
                                        self.colleges.removeAll()
                                        self.college = ""
                                    }
                                    if self.majorFields.count > 0 {
                                        self.majorFields.removeAll()
                                        self.majorField = ""
                                    }
                                    if self.majors.count > 0 {
                                        self.majors.removeAll()
                                        self.major = ""
                                    }
                                    RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.state))
                                        .perform(action: get_colleges) { statusCode, resp in
                                            guard
                                                resp != nil,
                                                resp!.keys.contains("Colleges"),
                                                statusCode == 200
                                            else {
                                                self.serverError = true
                                                return
                                            }
                                            
                                            let respColleges = resp!["Colleges"] as! [String]
                                            
                                            for c in respColleges {
                                                if !self.colleges.contains(c) { self.colleges.append(c) }
                                            }
                                            
                                            self.colleges.append("Other")
                                            self.college = self.colleges[0]
                                        }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 100)
                            
                            if self.college != "" {
                                HStack {
                                    Text("College")
                                    /*.frame(
                                     width: prop.isIpad
                                     ? prop.size.width - 450
                                     : prop.size.width - 100,
                                     height: 5,
                                     alignment: .leading
                                     )*/
                                        .frame(alignment: .leading)
                                        .font(.system(size: self.isLargerScreen ? 20 : 15))
                                        .foregroundStyle(.white)
                                        .fontWeight(.medium)
                                    
                                    Picker("College", selection: $college) {
                                        ForEach(colleges, id: \.self) { c in
                                            Text(c)
                                                .id(UUID())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.leading, 15)
                                    .tint(Color.EZNotesBlue)
                                    .minimumScaleFactor(0.5)
                                    //.padding(.trailing, 15)
                                    .onChange(of: self.college) {
                                        if self.college == "Other" { self.collegeIsOther = true }
                                        else {
                                            if self.collegeIsOther { self.collegeIsOther = false }
                                            //if self.majorFields.count == 0 {
                                            RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                College: self.college
                                            ))
                                            .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                if let resp = resp { print(resp) }
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Fields") else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                self.majorFields = resp!["Fields"] as! [String]
                                                self.majorFields.append("Other")
                                                self.majorField = self.majorFields[0]
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 100)
                                .padding()
                                .padding(.bottom, self.college.count >= 22 ? 10 : 0)
                            }
                            
                            if self.collegeIsOther {
                                TextField("Other...", text: $otherCollege)
                                    .frame(
                                        width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                            : prop.size.width - 100,
                                        height: self.isLargerScreen ? 40 : 30
                                    )
                                    .padding([.leading], 15)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .border(
                                                width: 1,
                                                edges: [.bottom],
                                                lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                            )
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding(self.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .focused($otherCollegeFocus)
                                    .onChange(of: self.otherCollegeFocus) {
                                        if !self.otherCollegeFocus {
                                            /* MARK: We will assume editing is done. */
                                            self.showCheckCollegeAlert = true
                                        }
                                    }
                                    .alert("Do we have the college right?", isPresented: $showCheckCollegeAlert) {
                                        Button(action: {
                                            RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                College: self.otherCollege
                                            ))
                                            .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Fields") else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                self.majorFields = resp!["Fields"] as! [String]
                                                self.majorFields.append("Other")
                                                self.majorField = self.majorFields[0]
                                                
                                                self.otherCollegeFocus = false
                                                self.colleges.remove(at: self.colleges.count - 1)
                                                self.colleges.append(self.otherCollege)
                                                self.colleges.append("Other")
                                                self.college = self.otherCollege
                                            }
                                        }) {
                                            Text("Yes")
                                        }
                                        
                                        Button("Not correct", role: .cancel) {}
                                    } message: {
                                        Text("Is \(self.otherMajorField) the correct college?")
                                    }
                            }
                            
                            if self.majorField != "" {
                                HStack {
                                    Text("Field")
                                        .frame(alignment: .leading)
                                        .font(.system(size: self.isLargerScreen ? 20 : 15))
                                        .foregroundStyle(.white)
                                        .fontWeight(.medium)
                                    
                                    Picker("Fields", selection: $majorField) {
                                        ForEach(majorFields, id: \.self) { f in
                                            Text(f)
                                                .id(UUID())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tint(Color.EZNotesBlue)
                                    .padding(.leading, 15)
                                    .onChange(of: self.majorField) {
                                        if self.majorField == "Other" { self.majorFieldIsOther = true }
                                        else {
                                            if self.majorFieldIsOther { self.majorFieldIsOther = false }
                                            //if self.majors.count == 0 {
                                                RequestAction<GetMajorsRequestData>(
                                                    parameters: GetMajorsRequestData(
                                                        College: self.college,
                                                        MajorField: self.majorField
                                                    ))
                                                    .perform(action: get_majors_req) { statusCode, resp in
                                                        self.loadingCollegeInfoSection = false
                                                        
                                                        guard resp != nil && statusCode == 200 else {
                                                            self.serverError = true
                                                            return
                                                        }
                                                        
                                                        self.majors = resp!["Majors"] as! [String]
                                                        self.majors.append("Other")
                                                        self.major = self.majors[0]
                                                    }
                                            //}
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 100)
                            }
                            
                            if self.majorFieldIsOther {
                                TextField("Other...", text: $otherMajorField)
                                    .frame(
                                        width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                        : prop.size.width - 100,
                                        height: self.isLargerScreen ? 40 : 30
                                    )
                                    .padding([.leading], 15)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .border(
                                                width: 1,
                                                edges: [.bottom],
                                                lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                            )
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding(self.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .focused($otherMajorFieldFocus)
                                    .onChange(of: self.otherMajorFieldFocus) {
                                        if !self.otherMajorFieldFocus {
                                            /* MARK: We will assume editing is done. */
                                            self.showCheckMajorFieldAlert = true
                                        }
                                    }
                                    .alert("Do we have the field of major right?", isPresented: $showCheckMajorFieldAlert) {
                                        Button(action: {
                                            RequestAction<GetCustomMajorsRequestData>(parameters: GetCustomMajorsRequestData(
                                                CMajorField: self.otherMajorField
                                            ))
                                            .perform(action: get_custom_majors_req) { statusCode, resp in
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Majors") else {
                                                    self.serverError = true
                                                    return
                                                }
                                                
                                                self.majors = resp!["Majors"] as! [String]
                                                self.majors.append("Other")
                                                self.major = self.majors[0]
                                                
                                                self.otherMajorFieldFocus = false
                                                self.majorFields.remove(at: self.majorFields.count - 1)
                                                self.majorFields.append(self.otherMajorField)
                                                self.majorFields.append("Other")
                                                self.majorField = self.otherMajorField
                                            }
                                        }) {
                                            Text("Yes")
                                        }
                                        
                                        Button("Not correct", role: .cancel) {}
                                    } message: {
                                        Text("Is \(self.otherMajorField) the correct field?")
                                    }
                            }
                            
                            if self.majors.count > 0 {
                                HStack {
                                    Text("Major")
                                        .frame(alignment: .leading)
                                        .font(.system(size: self.isLargerScreen ? 20 : 15))
                                        .foregroundStyle(.white)
                                        .fontWeight(.medium)
                                    
                                    Picker("Majors", selection: $major) {
                                        ForEach(majors, id: \.self) { m in
                                            Text(m)
                                                .id(UUID())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.top, 5)
                                    .tint(Color.EZNotesBlue)
                                    .padding(.leading, 15)
                                    .onChange(of: self.major) {
                                        if self.major == "Other" { self.majorIsOther = true }
                                        else {
                                            if self.majorIsOther { self.majorIsOther = false }
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 100)
                            }
                            
                            if self.majorIsOther {
                                TextField("Other...", text: $otherMajor)
                                    .frame(
                                        width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                        : prop.size.width - 100,
                                        height: self.isLargerScreen ? 40 : 30
                                    )
                                    .padding([.leading], 15)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .border(
                                                width: 1,
                                                edges: [.bottom],
                                                lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                            )
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding(self.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                            }
                        } else if self.section == "loading_code" {
                            VStack {
                                Text("Registering your account...")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: 22))//.setFontSizeAndWeight(weight: .medium, size: 26)
                                    .minimumScaleFactor(0.5)
                                ProgressView()
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .center)
                        } else if self.section == "code_input" {
                            Text("Code")
                                .frame(
                                    width: prop.isIpad
                                        ? prop.size.width - 450
                                        : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                            
                            TextField(
                                "Code...",
                                text: $userInputedCode,
                                onEditingChanged: set_image_opacity
                            )
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: self.isLargerScreen ? 40 : 30
                            )
                            .padding([.leading], 15)
                            .background(
                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                    .border(
                                        width: 1,
                                        edges: [.bottom],
                                        lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                    )
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .padding()
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.numberPad)
                            .onChange(of: self.userInputedCode) {
                                /* Codes are 6-digits. */
                                if self.userInputedCode.count > 6 { self.userInputedCode = String(self.userInputedCode.prefix(6)) }
                            }
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
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
                                        
                                        HStack {
                                            VStack {
                                                Button(action: {
                                                    self.planPicked = "basic_plan_monthly"
                                                    self.isPlanPicked = true
                                                }) {
                                                    Text("Select Monthly")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $10.50/month")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            VStack {
                                                Button(action: {
                                                    self.planPicked = "basic_plan_annually"
                                                    self.isPlanPicked = true
                                                }) {
                                                    Text("Select Annually")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $120/year")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                        .padding(.bottom)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .cornerRadius(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)
                                            .shadow(color: .black, radius: 2.5)
                                    )
                                    .padding(.bottom, 15)
                                    
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
                                                
                                                /*Text("The Pro Plan is **coming soon**. The plan builds on top of the Basic Plan giving 2x upload and backup limits; further, the Pro Plan gives users access to a multitude of helpful features that allows for a more feasible experience when studying/doing homework. See the features to the right.")*/
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
                                        
                                        HStack {
                                            VStack {
                                                Button(action: {
                                                    self.planPicked = "pro_plan_monthly"
                                                    self.isPlanPicked = true
                                                }) {
                                                    Text("Select Monthly")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $16/month")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            VStack {
                                                Button(action: {
                                                    self.planPicked = "pro_plan_annually"
                                                    self.isPlanPicked = true
                                                }) {
                                                    Text("Select Annually")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .foregroundStyle(.white)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $160/year")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                        .padding(.bottom)
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
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
                                                                    : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
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
                                                                    : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
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
                                                                                : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
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
                                                                                : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
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
                                                            TextField("CVV", text: $cvv)
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
                                                                            : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
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
                                                                .onChange(of: self.cvv) {
                                                                    if self.cvv.count >= 3 {
                                                                        self.cvv = String(self.cvv.prefix(3))
                                                                    }
                                                                }
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                        .padding(.bottom, self.isLargerScreen ? 18 : 14)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    Text("All purchases are handled securely by Stripe. Stripe is our partner for processing payments for subscriptions. If you have any questions, do not hesitate to contact us.\n\nBy clicking \"Submit Payment\" below, you agree to EZNotes Terms and Conditions and confirm you have read and understood our Privacy and Policy.")
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .padding(.top)
                                                        .padding(.bottom, 2)
                                                        .foregroundStyle(.secondary)
                                                        .font(.system(size: self.isLargerScreen ? 13 : 11))
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.light)
                                                    
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
                                                                
                                                                /* Continue to account. */
                                                                UserDefaults.standard.set(self.username, forKey: "username")
                                                                UserDefaults.standard.set(self.email, forKey: "email")
                                                                UserDefaults.standard.set(customerId!, forKey: "client_id")
                                                                self.setLoginStatus()
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
                                                            
                                                            /* Continue to account. */
                                                            UserDefaults.standard.set(self.username, forKey: "username")
                                                            UserDefaults.standard.set(self.email, forKey: "email")
                                                            UserDefaults.standard.set(customerId!, forKey: "client_id")
                                                            self.setLoginStatus()
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
                                    })
                                }
                            }
                        }
                    }
                    .padding(.top, self.isLargerScreen ? 25 : 20)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top) // Keep VStack aligned to the top
                .ignoresSafeArea(.keyboard, edges: .bottom) // Ignore keyboard safe area
                .onChange(of: prop.size.height) {
                    if prop.size.height < self.lastHeight { self.isLargerScreen = prop.size.height / 2.5 > 200 }
                    else { self.isLargerScreen = prop.size.height / 2.5 > 300 }
                    
                    self.lastHeight = prop.size.height
                }
                
                Spacer() // To push the TextFields to the top
                
                if self.section != "select_plan" {
                    VStack {
                        Button(action: {
                            if section == "main" {
                                if self.username == "" || self.email == "" || self.password == "" {
                                    self.makeContentRed = true
                                    return
                                }
                                
                                RequestAction<CheckUsernameRequestData>(parameters: CheckUsernameRequestData(
                                    Username: self.username
                                ))
                                .perform(action: check_username_req) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        /* MARK: Stay in the "main" section. Just set `userExists` error to true and make content red. */
                                        self.userExists = true
                                        self.makeContentRed = true
                                        return
                                    }
                                    
                                    if self.userExists { self.userExists = false }
                                    if self.makeContentRed { self.makeContentRed = false }
                                    
                                    RequestAction<CheckEmailRequestData>(parameters: CheckEmailRequestData(
                                        Email: self.email
                                    ))
                                    .perform(action: check_email_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            /* MARK: Stay in the "main" section. Just set `userExists` error to true and make content red. */
                                            self.emailExists = true
                                            self.makeContentRed = true
                                            return
                                        }
                                        
                                        if self.emailExists { self.emailExists = false }
                                        if self.makeContentRed { self.makeContentRed = false }
                                        
                                        /* MARK: If this request is good (status returned is 200), proceed with the sign up process. */
                                        self.section = "select_state_and_college"
                                        
                                        /* MARK: Set the last section. */
                                        UserDefaults.standard.set("select_state_and_college", forKey: "last_signup_section")
                                        
                                        /* MARK: Ensure to (temporarily) store username, email and password (just in case they leave the app and come back). */
                                        UserDefaults.standard.set(self.username, forKey: "temp_username")
                                        UserDefaults.standard.set(self.email, forKey: "temp_email")
                                        UserDefaults.standard.set(self.password, forKey: "temp_password")
                                    }
                                }
                            } else {
                                if self.section == "select_state_and_college" {
                                    if self.state == "" || self.college == "" || self.major == "" {
                                        self.makeContentRed = true
                                        return
                                    }
                                    
                                    self.section = "loading_code"
                                    
                                    RequestAction<SignUpRequestData>(
                                        parameters: SignUpRequestData(
                                            Username: username,
                                            Email: email,
                                            Password: password,
                                            College: college,
                                            State: state,
                                            Field: majorField,
                                            Major: major
                                        )
                                    ).perform(action: complete_signup1_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            if let resp = resp {
                                                if resp["ErrorCode"] as! Int == 0x6970 {
                                                    self.section = "main"
                                                    self.userExists = true
                                                    return
                                                }
                                            }
                                            
                                            self.section = "main"
                                            self.serverError = true
                                            return
                                        }
                                        
                                        if self.userExists { self.userExists = false }
                                        if self.makeContentRed { self.makeContentRed = false }
                                        
                                        self.accountID = resp!["Message"] as! String
                                        self.section = "code_input"
                                        
                                        UserDefaults.standard.set("code_input", forKey: "last_signup_section")
                                        UserDefaults.standard.set(self.state, forKey: "temp_state")
                                        UserDefaults.standard.set(self.college, forKey: "temp_college")
                                        UserDefaults.standard.set(self.majorField, forKey: "temp_field")
                                        UserDefaults.standard.set(self.major, forKey: "temp_major")
                                        
                                        /*if r.Bad != nil {
                                            if r.Bad!.ErrorCode == 0x6970 {
                                                self.section = "main"
                                                self.userExists = true
                                                return
                                            }
                                            
                                            self.serverError = true
                                            return
                                        }
                                        else {
                                            if self.userExists { self.userExists = false }
                                            
                                            self.accountID = r.Good!.Message
                                            self.section = "code_input"
                                            UserDefaults.standard.set("code_input", forKey: "last_signup_section")
                                        }*/
                                    }
                                } else {
                                    if self.section == "code_input" {
                                        RequestAction<SignUp2RequestData>(
                                            parameters: SignUp2RequestData(
                                                AccountID: accountID,
                                                UserInputtedCode: userInputedCode
                                            )
                                        ).perform(action: complete_signup2_req) { statusCode, resp in
                                            if resp != nil {
                                                print(resp!)
                                            }
                                            
                                            guard resp != nil && statusCode == 200 else {
                                                self.wrongCodeAttempts += 1
                                                
                                                if self.wrongCodeAttempts >= 3 {
                                                    /* MARK: Delete the signup process in the backend. */
                                                    RequestAction<DeleteSignupProcessData>(
                                                        parameters: DeleteSignupProcessData(
                                                            AccountID: self.accountID
                                                        )
                                                    )
                                                    .perform(action: delete_signup_process_req) { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            /* MARK: There should never be an error when deleting the process in the backend. */
                                                            if let resp = resp { print(resp) }
                                                            return
                                                        }
                                                    }
                                                    
                                                    /* MARK: Go back to the "main" section. Reset the "last_signup_section" key. */
                                                    self.section = "main"
                                                    UserDefaults.standard.set("main", forKey: "last_signup_section")
                                                    
                                                    /* MARK: Reset code attemp information. */
                                                    self.wrongCodeAttempts = 0
                                                    self.wrongCodeAttemptsMet = true
                                                    self.wrongCode = false
                                                    return
                                                }
                                                
                                                self.wrongCode = true
                                                return
                                            }
                                            
                                            UserDefaults.standard.set(self.username, forKey: "username")
                                            UserDefaults.standard.set(self.email, forKey: "email")
                                            UserDefaults.standard.set(self.majorField, forKey: "major_field")
                                            UserDefaults.standard.set(self.major, forKey: "major_name")
                                            UserDefaults.standard.set(self.state, forKey: "college_state")
                                            UserDefaults.standard.set(self.college, forKey: "college_name")
                                            UserDefaults.standard.set("select_plan", forKey: "last_signup_section")
                                            
                                            if self.makeContentRed { self.makeContentRed = false }
                                            if self.wrongCode { self.wrongCode = false }
                                            self.section = "select_plan"
                                            
                                            /*if r.Bad != nil {
                                                self.wrongCode = true
                                                return
                                            }
                                            else {
                                                UserDefaults.standard.set(self.username, forKey: "username")
                                                UserDefaults.standard.set(self.email, forKey: "email")
                                                UserDefaults.standard.set("select_plan", forKey: "last_signup_section")
                                                self.section = "select_plan"
                                            }*/
                                        }
                                        /* TODO: Add screen for the code to be put in.
                                         * TODO: After the screen is implemented, this else statement will take the code and send it to the server.*/
                                    } else {
                                        UserDefaults.standard.set(self.planID, forKey: "plan_id")
                                        
                                        /* TODO: The code in `setLoginStatus` is not needed. */
                                        setLoginStatus()
                                    }
                                }
                            }
                        }) {
                            Text(section == "main"
                                 ? "Continue"
                                 : section == "select_state_and_college"
                                 ? "Submit"
                                 : "Complete")
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
                        
                        if !(self.section == "code_input") {
                            Button(action: {
                                if self.section == "main" { self.screen = "home" }
                                else { self.section = "main" }
                            }) {
                                Text("Go Back")
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
                                    .foregroundStyle(.white)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesLightBlack)
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .onAppear {
            self.isLargerScreen = prop.size.height / 2.5 > 300
            self.lastHeight = prop.size.height
            
            guard UserDefaults.standard.object(forKey: "last_signup_section") != nil else {
                UserDefaults.standard.set("main", forKey: "last_signup_section")
                return
            }
            
            self.section = UserDefaults.standard.string(forKey: "last_signup_section")!
            if UserDefaults.standard.object(forKey: "temp_username") != nil { self.username = UserDefaults.standard.string(forKey: "temp_username")! }
            if UserDefaults.standard.object(forKey: "temp_email") != nil { self.email = UserDefaults.standard.string(forKey: "temp_email")! }
            if UserDefaults.standard.object(forKey: "temp_password") != nil { self.password = UserDefaults.standard.string(forKey: "temp_password")! }
            
            if self.section == "select_state_and_college" {
                if UserDefaults.standard.object(forKey: "temp_state") != nil {
                    self.state = UserDefaults.standard.string(forKey: "temp_state")!
                    
                    RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.state))
                        .perform(action: get_colleges) { statusCode, resp in
                            guard
                                resp != nil,
                                resp!.keys.contains("Colleges"),
                                statusCode == 200
                            else {
                                self.serverError = true
                                return
                            }
                            
                            let respColleges = resp!["Colleges"] as! [String]
                            
                            for c in respColleges {
                                if !self.colleges.contains(c) { self.colleges.append(c) }
                            }
                            
                            if !self.colleges.contains("Other") { self.colleges.append("Other") }
                            self.college = self.colleges[0]
                        }
                }
                if UserDefaults.standard.object(forKey: "temp_college") != nil {
                    self.college = UserDefaults.standard.string(forKey: "temp_college")!
                    
                    RequestAction<ReqPlaceholder>(parameters: ReqPlaceholder())
                        .perform(action: get_major_fields_req) { statusCode, resp in
                            self.loadingCollegeInfoSection = false
                            
                            guard resp != nil && statusCode == 200 else {
                                self.serverError = true
                                return
                            }
                            
                            let respMajorFields = resp!["Categories"] as! [String]
                            
                            for mf in respMajorFields {
                                if !self.majorFields.contains(mf) { self.majorFields.append(mf) }
                            }
                            
                            //if !self.majorFields.contains("Other") { self.majorFields.append("Other") }
                            self.majorField = self.majorFields[0]
                        }
                }
                if UserDefaults.standard.object(forKey: "temp_field") != nil {
                    self.majorField = UserDefaults.standard.string(forKey: "temp_field")!
                    
                    RequestAction<GetMajorsRequestData>(
                        parameters: GetMajorsRequestData(
                            College: self.college,
                            MajorField: self.majorField
                        ))
                        .perform(action: get_majors_req) { statusCode, resp in
                            self.loadingCollegeInfoSection = false
                            
                            guard resp != nil && statusCode == 200 else {
                                self.serverError = true
                                return
                            }
                            
                            self.majors = resp!["Majors"] as! [String]
                            
                            self.majors.append("Other")
                            
                            self.major = self.majors[0]
                        }
                }
                if UserDefaults.standard.object(forKey: "temp_major") != nil { self.major = UserDefaults.standard.string(forKey: "temp_major")! }
            }
        }
        /*VStack {
            Spacer()
            VStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.EZNotesOrange,
                            Color.EZNotesOrange,
                            prop.isIpad && (prop.isLandscape && !keyboardActivated)
                                ? Color.EZNotesBlue
                                : Color.EZNotesOrange,
                            prop.isIpad && (prop.isLandscape && !keyboardActivated)
                                ? Color.EZNotesBlue
                                : Color.EZNotesOrange,
                            //Color.EZNotesOrange,
                            //Color.EZNotesOrange
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                )
                .padding([.top], prop.isIpad && UIDevice.current.orientation.isLandscape ? -80 : 0)
                .frame(
                    width: prop.isIpad
                        ? 320
                        : 350,
                    height: prop.isIpad
                        ? 200
                        : 230
                )
                .mask(
                    Text("Sign Up")
                        .frame(alignment: .top)
                        .padding(
                            [.top],
                            prop.isIpad
                                ? -90
                                : prop.size.height / 2.5 > 300
                                    ? -115
                                    : imageOpacity == 0 || passwordFieldInFocus ? -100 : -120)
                        .padding([.bottom], -80)
                        .shadow(color: .white, radius: 2.5)
                        .font(
                            .system(
                                size: prop.isIpad
                                    ? 90
                                    : prop.size.width / 2.5 > 300
                                        ? 55
                                        : 45
                            )
                        )
                        .multilineTextAlignment(.center)
                        //.opacity(opacity2)
                )
                
                Text(
                    self.wrongCode
                        ? "Wrong code. Try again"
                        : self.section == "main"
                            ? "Sign up with a unique username, your email and a unique password"
                        : self.section == "select_state_and_college"
                                ? "Tell us about your college and your degree :)"
                                : "A code has been sent to your email. Input the code below"
                )
                .fontWeight(.bold)
                .padding([.top], prop.isIpad
                         ? UIDevice.current.orientation.isLandscape ? -140 : -80
                         : prop.size.width / 2.5 > 300
                            ? -170
                            : -180
                )
                .padding()
                .font(
                    .system(
                        size: prop.isIpad || prop.size.width / 2.5 > 300
                            ? 20
                            : 18
                    )
                )
                .multilineTextAlignment(.center)
                .frame(
                    maxWidth: prop.isIpad
                        ? prop.size.width - 480
                        : 350,
                    maxHeight: 50,
                    alignment: .top
                )
                .foregroundStyle(wrongCode ? Color.red : Color.white)
                    
            }
            .padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                            ? -330
                            : -180
                    : -120)
            .frame(
                width: prop.isIpad
                        ? 400
                        : nil,
                height: prop.isIpad
                        ? 850
                        : prop.size.height / 2.5 > 300
                            ? 750
                            : (prop.size.height / 2.5) + 200
            )
            
            VStack {
                VStack {
                    if section == "main" {
                        Text("Username")
                            .frame(
                                width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding(.top, 10)
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Username",
                            text: $username,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                        
                        Text("Email")
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Email",
                            text: $email,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.email == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        
                        Text("Password")
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        SecureField(
                            "Password",
                            text: $password
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))//(Color.EZNotesLightBlack.opacity(0.6))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .focused($passwordFieldInFocus)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    } else if section == "select_state_and_college"
                    {
                        Text("State")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding([.top], 10)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "College name...",
                            text: $state,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.state == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Text("College Being Attended")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "College name...",
                            text: $college,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.college == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Text("Major")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Major...",
                            text: $major,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        //Spacer()
                    } else
                    {
                        Text("Code")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding([.top], 40)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                        
                        TextField(
                            "Code",
                            text: $userInputedCode,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                            ? prop.size.width - 450
                            : prop.size.width - 100,
                            height: 45
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.wrongCode
                                        ? self.borderBottomColor
                                        : self.borderBottomColorError
                                )
                        )
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.EZNotesBlue)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    
                    Button(action: {
                        if section == "main" {
                            if self.username == "" || self.email == "" || self.password == "" {
                                self.makeContentRed = true
                                return
                            }
                            
                            if self.makeContentRed { self.makeContentRed = false }
                            
                            section = "select_state_and_college"
                        } else {
                            if self.section == "select_state_and_college" {
                                if self.state == "" || self.college == "" || self.major == "" {
                                    self.makeContentRed = true
                                    return
                                }
                                RequestAction<SignUpRequestData>(
                                    parameters: SignUpRequestData(
                                        Username: username,
                                        Email: email,
                                        Password: password,
                                        College: college,
                                        State: state
                                    )
                                ).perform(action: complete_signup1_req) { r in
                                    if r.Bad != nil {
                                        print(r.Bad!)
                                        return
                                    }
                                    else {
                                        self.accountID = r.Good!.Message
                                        self.section = "code_input"
                                    }
                                }
                            }
                            else {
                                if self.section == "code_input" {
                                    RequestAction<SignUp2RequestData>(
                                        parameters: SignUp2RequestData(
                                            AccountID: accountID,
                                            UserInputtedCode: userInputedCode
                                        )
                                    ).perform(action: complete_signup2_req) {r in
                                        if r.Bad != nil {
                                            self.wrongCode = true
                                            return
                                        }
                                        else {
                                            UserDefaults.standard.set(username, forKey: "username")
                                            UserDefaults.standard.set(email, forKey: "email")
                                            
                                            self.showPopup = true
                                        }
                                    }
                                    /* TODO: Add screen for the code to be put in.
                                     * TODO: After the screen is implemented, this else statement will take the code and send it to the server.*/
                                }
                            }
                        }
                    }) {
                        Text(section == "main"
                             ? "Continue"
                             : section == "select_state_and_college"
                                 ? "Submit"
                                 : "Complete")
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
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                    )
                    
                    /*startupScreen.createButton(
                        prop: prop,
                        text: "Go Back",
                        backgroundColor: Color.EZNotesBlue,
                        primaryGlow: false,
                        action: {
                            if section == "main" {
                                self.screen = "home"
                            } else if section == "select_state_and_college" {
                                section = "main"
                            } else {
                                section = "select_state_and_college"
                            }
                        }
                    )
                    .padding([.top], 5)*/
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(20)
                .padding(
                    [.top],
                        prop.isIpad
                            ? UIDevice.current.orientation.isLandscape && keyboardActivated
                                ? -450
                                : UIDevice.current.orientation.isLandscape ? -400 : -350
                            : prop.size.height / 2.5 > 300
                                ? -420
                                : -200
                )
                /*TextField("Username", text: $username)
                 .foregroundStyle(Color.white)
                 .padding([.top], -150)*/
                
                //Spacer()
            }
        }
        .alert("Enable FaceID?", isPresented: $showPopup) {
            Button("Enable") {
                UserDefaults.standard.set("enabled", forKey: "faceID_enabled")
                setLoginStatus()
            } //action: { self.allowFaceID = true }) { }
            Button("Disable", role: .cancel) {
                UserDefaults.standard.set("disabled", forKey: "faceID_enabled")
                setLoginStatus()
            }
        } message: {
            Text("Enabling FaceID will further secure your data")
        }*/
    }
}

struct SignUpScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
