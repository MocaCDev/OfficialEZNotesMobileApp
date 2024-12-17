//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI
import Combine

enum SignUpScreenErrors {
    case None
    case TooShortUsername
    case TooShortPassword
    case InvalidEmail
    case UserExists
    case EmailExists
    case ServerError
    case WrongCode
}

struct SignUpScreen : View, KeyboardReadable {
    @Environment(\.presentationMode) var presentationMode
    
    public var prop: Properties
    
    /* MARK: State/functions regarding errors that can occurr in `SignUpScreen.swift`. */
    @State private var error: SignUpScreenErrors = .None
    
    private func credentialsAreGood() -> Bool { /* MARK: Ensure the credentials entered are all good. */
        return self.error != .TooShortUsername && self.error != .InvalidEmail && self.error != .TooShortPassword
    }
    
    @State private var showPopup: Bool = false
    
    public var startupScreen: StartupScreen
    
    @Binding public var screen: String
    @Binding public var userHasSignedIn: Bool
    @Binding public var serverError: Bool
    @Binding public var supportedStates: Array<String>
    
    @State public var supportedColleges: Array<String> = []
    
    @State public var keyboardActivated: Bool = false
    
    /* MARK: Usernames must by 4 or more characters long. */
    @State private var tooShortUsername: Bool = false
    @State private var makeUsernameFieldRed: Bool = false
    
    @State private var loadingSelectStateAndCollegeSection: Bool = false
    
    /* MARK: A "invalid" email is a email missing "@" or a email missing a domain after "@". */
    let emailDomains = [".com", ".edu", ".net", ".gov", ".org"]
    @State private var invalidEmail: Bool = false
    @State private var makeEmailFieldRed: Bool = false
    
    /* MARK: Password must be 8 characters or more in length. */
    @State private var tooShortPassword: Bool = false
    @State private var makePasswordFieldRed: Bool = false
    
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
    @State public var alreadySignedUp: Bool = false
    
    @State public var imageOpacity: Double = 1
    @FocusState public var passwordFieldInFocus: Bool
    
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
    
    @State public var state: String = ""
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
    
    let stateColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let collegeColumns = [
        GridItem(.flexible())
    ]
    
    func set_image_opacity(focused: Bool)
    {
        imageOpacity = focused ? 0.0 : 1.0;
    }
    
    public func setLoginStatus() -> Void {
        assignUDKey(key: "logged_in", value: true)
        assignUDKey(key: "account_id", value: self.accountID)
        
        assignUDKey(key: "last_signup_section", value: "main")
        
        /* MARK: Ensure that none of the temporary keys in `UserDefaults` carry over after signing up. */
        removeAllSignUpTempKeys()
        
        self.userHasSignedIn = true
    }
    
    @State private var checkInfoAlert: Bool = false
    
    @State private var loadingColleges: Bool = false
    private func get_custom_colleges() {
        self.loadingColleges = true
        
        RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.state))
            .perform(action: get_colleges) { statusCode, resp in
                self.loadingColleges = false
                
                guard
                    resp != nil,
                    resp!.keys.contains("Colleges"),
                    statusCode == 200
                else {
                    self.error = .ServerError//self.error = .ServerError // self.serverError = true
                    return
                }
                
                let respColleges = resp!["Colleges"] as! [String]
                
                for c in respColleges {
                    if !self.colleges.contains(c) { self.colleges.append(c) }
                }
                
                self.colleges.append("Other")
                //self.college = self.colleges[0]
            }
    }
    
    @State private var loadingMajorFields: Bool = false
    @State private var noSuchCollege: Bool = false
    private func get_custom_major_fields(collegeName: String) {
        self.loadingMajorFields = true
        
        RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
            State: self.state,
            College: collegeName
        ))
        .perform(action: get_custom_college_fields_req) { statusCode, resp in
            self.loadingMajorFields = false
            
            //if let resp = resp { print(resp) }
            guard
                resp != nil,
                statusCode == 200
            else {
                guard let resp = resp else {
                    self.error = .ServerError // self.serverError = true
                    return
                }
                
                guard resp.keys.contains("Message") else {
                    self.error = .ServerError // self.serverError = true
                    return
                }
                
                if resp["Message"] as! String == "no_such_college_in_state" {
                    self.noSuchCollege = true
                    return
                }
                
                self.error = .ServerError // self.serverError = true
                return
            }
            
            guard resp!.keys.contains("Fields") else {
                self.error = .ServerError // self.serverError = true
                return
            }
            
            self.majorFields = resp!["Fields"] as! [String]
            self.majorFields.append("Other")
            //self.majorField = self.majorFields[0]
        }
    }
    
    @State private var loadingMajors: Bool = false
    private func get_majors() {
        self.loadingMajors = true
        
        RequestAction<GetMajorsRequestData>(
            parameters: GetMajorsRequestData(
                College: self.college,
                MajorField: self.majorField
            ))
        .perform(action: get_majors_req) { statusCode, resp in
            self.loadingMajors = false
            
            self.loadingCollegeInfoSection = false
            
            guard resp != nil && statusCode == 200 else {
                self.error = .ServerError // self.serverError = true
                return
            }
            
            self.majors = resp!["Majors"] as! [String]
            self.majors.append("Other")
            //self.major = self.majors[0]
        }
    }
    
    @State private var hideAgreementDetails: Bool = false
    
    @FocusState private var usernameTextfieldFocus: Bool
    @FocusState private var emailTextfieldFocus: Bool
    @FocusState private var passwordTextfieldFocus: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if !self.alreadySignedUp {
                VStack {
                    // VStack with TextFields
                    VStack {
                        if self.section != "select_state_and_college" {
                            HStack {
                                /* MARK: While the "loading_code" section is visible, no other content needs to be shown. */
                                if self.section != "loading_code" {
                                    if self.section != "select_plan" {
                                        ZStack {
                                            Button(action: {
                                                switch(self.section) {
                                                case "main":
                                                    self.screen = "home"
                                                    assignUDKey(key: "last_signup_section", value: "main")
                                                    break
                                                case "credentials":
                                                    self.section = "main"
                                                    assignUDKey(key: "last_signup_section", value: "main")
                                                    break
                                                case "select_state_and_college":
                                                    self.section = "credentials"
                                                    assignUDKey(key: "last_signup_section", value: "credentials")
                                                    break
                                                case "code_input":
                                                    RequestAction<DeleteSignupProcessData>(
                                                        parameters: DeleteSignupProcessData(
                                                            AccountID: self.accountID
                                                        )
                                                    )
                                                    .perform(action: delete_signup_process_req) { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            /* MARK: There should never be an error when deleting the process in the backend. */
                                                            if let resp = resp { print(resp) }
                                                            self.error = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        if getUDValue(key: "usecase") == "school" {
                                                            self.section = "select_state_and_college"
                                                            
                                                            /* MARK: When "going back" from the code input section, the app will redirect to the "select major" part of "select_state_and_college".. as that was the last screen shown before the "code_input" one. Since that is the case, we have to remove the "temp_major" key from `UserDefaults` as well as remove any sort of content from `major` and `majors`. */
                                                            removeUDKey(key: "temp_major")
                                                            self.major.removeAll()
                                                            self.majors.removeAll()
                                                            self.get_majors()
                                                        } else {
                                                            self.section = "credentials"
                                                        }
                                                        
                                                        assignUDKey(key: "last_signup_section", value: self.section)
                                                    }
                                                case "select_plan":
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
                                                            self.error = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        self.section = "select_state_and_college"
                                                        assignUDKey(key: "last_signup_section", value: self.section)
                                                        
                                                        /* MARK: Remove all of the temporary information. */
                                                        removeAllSignUpTempKeys()
                                                        
                                                        /* MARK: Ensure that the whole "select_state_and_college" section will restart. */
                                                        self.state.removeAll()
                                                        self.majorField.removeAll()
                                                        self.major.removeAll()
                                                    }
                                                default: break
                                                }
                                            }) {
                                                Image(systemName: "arrow.backward")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                        }
                                        .frame(maxWidth: 20, alignment: .leading)
                                    } else { ZStack { }.frame(maxWidth: 20, alignment: .leading) }
                                    
                                    Text(self.section == "main" || self.section == "credentials"
                                         ? "Sign Up"
                                         : self.section == "code_input"
                                         ? "Input Code"
                                         : "Select Plan"
                                    )//(self.section != "select_plan" ? "Sign Up" : "Plans")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 5)
                                    .foregroundStyle(.white)
                                    .font(
                                        .system(
                                            size: prop.isIpad
                                            ? 90
                                            : prop.isLargerScreen
                                            ? 35
                                            : 25
                                        )
                                    )
                                    .fontWeight(.bold)
                                    
                                    ZStack {
                                        Menu {
                                            if self.error == .ServerError {
                                                Button(action: { print("Report Problem") }) {
                                                    Label("Report Problem", systemImage: "sun.max.trianglebadge.exclamationmark")
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            
                                            if self.section == "code_input" {
                                                Button(action: {
                                                    self.state.removeAll()
                                                    self.college.removeAll()
                                                    self.majorFields.removeAll()
                                                    self.major.removeAll()
                                                    
                                                    /* MARK: Remove the sign up process in the backend. */
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
                                                    
                                                    self.section = "main"
                                                }) {
                                                    Label("Restart Signup", systemImage: "arrow.trianglehead.counterclockwise")
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            
                                            /* MARK: Once the user gets to `code_input` or `select_plan`, they will not be eligible to go to the login screen. */
                                            if self.section != "select_plan" && self.section != "code_input" {
                                                Button(action: { self.screen = "login" }) {
                                                    Label("Go to login", systemImage: "chevron.forward")
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            
                                            Button(action: { print("Get Help") }) {
                                                Label("I need help", systemImage: "questionmark")
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                            //Button(action: { print("Restart") }) { Text("Restart Signup") }
                                            //Button(action: { print("Get help") }) { Text("I need help") }
                                        } label: {
                                            Label("", systemImage: "ellipsis.circle")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            if self.error == .ServerError {
                                Text("There was an internal server error. Please try again.")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(
                                        .system(
                                            size: prop.isIpad || prop.isLargerScreen
                                            ? 15
                                            : 13
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .onAppear { self.section = "main" } /* MARK: If there is a server error, default to the "main" section of the sign up view. */
                            } else {
                                /* TODO: Perhaps restructure the code? I feel like this is bad design. */
                                if self.credentialsAreGood() {
                                    if self.section != "loading_code" {
                                        Text(
                                            self.error == .WrongCode
                                            ? "Wrong code. \(3 - self.wrongCodeAttempts) attempts left. Try again"
                                            : self.error == .UserExists
                                            ? "A user with the username you provided already exists"
                                            : self.error == .EmailExists
                                            ? "A user with the email you provided already exists"
                                            : self.section == "main"
                                            ? "What are you using **EZNotes** for?"
                                            : self.section == "credentials"
                                            ? "Sign up with a unique username, your email and a unique password"
                                            : self.section == "select_state_and_college"
                                            ? "Tell us about your college and your degree :)"
                                            : self.section == "code_input"
                                            ? "A code has been sent to your email. Input the code below"
                                            : "Select a plan that best suits you"
                                        )
                                        .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                        .foregroundStyle(self.error != .None ? Color.EZNotesRed : Color.white)
                                        .font(
                                            .system(
                                                size: prop.isIpad || prop.isLargerScreen
                                                ? 15
                                                : 13
                                            )
                                        )
                                        .multilineTextAlignment(.center)
                                    }
                                } else {
                                    switch self.error {
                                    case .TooShortUsername:
                                        Text("The username provided is too short. It must be 4 or more characters long.")
                                            .frame(maxWidth: prop.size.width - 30, alignment: .center)
                                            .foregroundStyle(Color.EZNotesRed)
                                            .font(
                                                .system(
                                                    size: prop.isIpad || prop.isLargerScreen
                                                    ? 15
                                                    : 13
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                    case .InvalidEmail:
                                        Text("The email provided is missing the domain, or has an invalid domain.")
                                            .frame(maxWidth: prop.size.width - 30, alignment: .center)
                                            .foregroundStyle(Color.EZNotesRed)
                                            .font(
                                                .system(
                                                    size: prop.isIpad || prop.isLargerScreen
                                                    ? 15
                                                    : 13
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                    case .TooShortPassword:
                                        Text("The password provided is too short. It must be 8 or more characters long.")
                                            .frame(maxWidth: prop.size.width - 30, alignment: .center)
                                            .foregroundStyle(Color.EZNotesRed)
                                            .font(
                                                .system(
                                                    size: prop.isIpad || prop.isLargerScreen
                                                    ? 15
                                                    : 13
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                    default: VStack { }.onAppear { self.error = .None }
                                    }
                                }
                            }
                        }
                        
                        if self.wrongCodeAttemptsMet {
                            Text("You have put the wrong code in too many time.")
                                .frame(maxWidth: prop.size.width - 30, alignment: .center)
                                .foregroundStyle(Color.EZNotesRed)
                                .font(
                                    .system(
                                        size: prop.isIpad || prop.isLargerScreen
                                        ? 15
                                        : 13
                                    )
                                )
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            /* TODO: Convert the `if-else if-else` BS to `switch`. */
                            if self.section == "main" {
                                VStack {
                                    Button(action: {
                                        assignUDKey(key: "usecase", value: "school")
                                        self.section = "credentials"
                                        assignUDKey(key: "last_signup_section", value: self.section)
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("School")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 24 : 20))
                                                    .foregroundStyle(.white)
                                                
                                                Text("Tailored to your school needs.")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                            .padding([.top, .bottom])
                                            
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .frame(width: 10, height: 20)
                                                .foregroundStyle(.white)
                                                .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                        )
                                        .cornerRadius(15)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: {
                                        assignUDKey(key: "usecase", value: "work")
                                        self.section = "credentials"
                                        assignUDKey(key: "last_signup_section", value: self.section)
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("Work")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 24 : 20))
                                                    .foregroundStyle(.white)
                                                
                                                Text("Tailored to your everyday needs.")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                            .padding([.top, .bottom])
                                            
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .frame(width: 10, height: 20)
                                                .foregroundStyle(.white)
                                                .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                        )
                                        .cornerRadius(15)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: {
                                        assignUDKey(key: "usecase", value: "general")
                                        self.section = "credentials"
                                        assignUDKey(key: "last_signup_section", value: self.section)
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("General")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 24 : 20))
                                                    .foregroundStyle(.white)
                                                
                                                Text("Tailored to anything you may need help with.")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                            .padding([.top, .bottom])
                                            
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .frame(width: 10, height: 20)
                                                .foregroundStyle(.white)
                                                .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                        )
                                        .cornerRadius(15)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if self.section == "credentials" {
                                if self.loadingSelectStateAndCollegeSection {
                                    VStack {
                                        Text("Hang Tight...")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 18))//.setFontSizeAndWeight(weight: .medium, size: 26)
                                            .fontWeight(.semibold)
                                            .minimumScaleFactor(0.5)
                                        
                                        ProgressView()
                                            .tint(Color.EZNotesBlue)
                                    }
                                    .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .center)
                                } else {
                                    Text("Username")
                                        .frame(
                                            width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 80,
                                            height: 5,
                                            alignment: .leading
                                        )
                                        .padding(.top, 10)
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen ? 18 : 15
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
                                            height: 40
                                        )
                                        .padding([.leading], prop.isLargerScreen ? 15 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(
                                                    isError: !self.makeContentRed
                                                        ? self.userExists || self.makeUsernameFieldRed
                                                        : self.username == ""
                                                )
                                        )
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .padding(prop.isLargerScreen ? 10 : 4)
                                        .tint(Color.EZNotesBlue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .focused($usernameTextfieldFocus)
                                        .onChange(of: usernameTextfieldFocus) {
                                            if !self.usernameTextfieldFocus { assignUDKey(key: "temp_username", value: self.username) }
                                        }
                                    
                                    Text("Email")
                                        .frame(
                                            width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 80,
                                            height: 5,
                                            alignment: .leading
                                        )
                                        .padding(.top, 10)
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen ? 18 : 15
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
                                            height: 40
                                        )
                                        .padding([.leading], prop.isLargerScreen ? 15 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(
                                                    isError: !self.makeContentRed
                                                        ? self.emailExists || self.makeEmailFieldRed
                                                        : self.email == ""
                                                )
                                        )
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .padding(prop.isLargerScreen ? 10 : 4)
                                        .tint(Color.EZNotesBlue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.emailAddress)
                                        .focused($emailTextfieldFocus)
                                        .onChange(of: emailTextfieldFocus) { if !self.emailTextfieldFocus { assignUDKey(key: "temp_email", value: self.email) } }
                                    
                                    Text("Password")
                                        .frame(
                                            width: prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 80,
                                            height: 5,
                                            alignment: .leading
                                        )
                                        .padding(.top, 10)
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen ? 18 : 15
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
                                            height: 40
                                        )
                                        .padding([.leading], prop.isLargerScreen ? 15 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                .borderBottomWLColor(
                                                    isError: !self.makeContentRed
                                                        ? self.makePasswordFieldRed
                                                        : self.password == ""
                                                )
                                        )
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .padding(prop.isLargerScreen ? 10 : 4)
                                        .tint(Color.EZNotesBlue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .focused($passwordFieldInFocus)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .focused($passwordTextfieldFocus)
                                        .onChange(of: passwordTextfieldFocus) { if !self.passwordTextfieldFocus { assignUDKey(key: "temp_password", value: self.password) } }
                                }
                            } else if self.section == "select_state_and_college" {
                                /* TODO: This code is going to need a lot of refactoring. It is very repetitive.. just want it to work for now lol. */
                                HStack {
                                    Button(action: {
                                        if self.collegeIsOther { self.collegeIsOther = false; return }
                                        if self.majorIsOther { self.majorIsOther = false; return }
                                        if self.majorFieldIsOther { self.majorFieldIsOther = false; return }
                                        
                                        if self.state == "" {
                                            /* MARK: Ensure the keys in UserDefaults are deleted to avoid bugs. */
                                            //UserDefaults.standard.removeObject(forKey: "temp_state")
                                            //UserDefaults.standard.removeObject(forKey: "temp_college")
                                            //UserDefaults.standard.removeObject(forKey: "temp_field")
                                            //UserDefaults.standard.removeObject(forKey: "temp_major")
                                            
                                            self.section = "main"
                                            assignUDKey(key: "last_signup_section", value: "main")
                                        }
                                        else {
                                            /* MARK: The below operations will automatically cause the "section" of "select_state_and_college" to go back. */
                                            if self.college == "" {
                                                self.state.removeAll()
                                                
                                                removeUDKey(key: "temp_state")
                                                return
                                            }
                                            if self.majorField == "" {
                                                self.college.removeAll();
                                                
                                                removeUDKey(key: "temp_college")
                                                
                                                /* MARK: Ensure that, when going back, there is content to show. If not, load the content. */
                                                if self.colleges.count == 0 { self.get_custom_colleges() }
                                                return
                                            }
                                            
                                            if self.major == "" {
                                                self.majorField.removeAll()
                                                
                                                removeUDKey(key: "temp_field")
                                                
                                                if self.majorFields.count == 0 { self.get_custom_major_fields(collegeName: self.college) }
                                            }
                                            
                                            self.major.removeAll()
                                            removeUDKey(key: "temp_major")
                                            
                                            if self.majors.count == 0 { self.get_majors() }
                                            //self.majorField.removeAll()
                                            
                                            //removeUDKey(key: "temp_field")
                                            
                                            /* MARK: Ensure that, when going back, there is content to show. If not, load the content. */
                                            //if self.majorFields.count == 0 { self.get_custom_major_fields(collegeName: self.college) }
                                        }
                                    }) {
                                        ZStack {
                                            Image(systemName: "arrow.backward")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }.frame(maxWidth: 20, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    ZStack {
                                        Text(self.state == ""
                                             ? "Select State"
                                             : self.college == ""
                                             ? "Select College"
                                             : self.majorField == ""
                                             ? "Select Field"
                                             : "Select Major")//(self.section != "select_plan" ? "Sign Up" : "Plans")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.bottom, 5)
                                        .foregroundStyle(.white)
                                        .font(
                                            .system(
                                                size: prop.isIpad
                                                ? 90
                                                : prop.isLargerScreen
                                                ? 35
                                                : 25
                                            )
                                        )
                                        .fontWeight(.bold)
                                    }.frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Menu {
                                        Button(action: { print("Get Help") }) {
                                            Label("I need help", systemImage: "questionmark")
                                        }
                                        .foregroundStyle(.white)
                                        .buttonStyle(NoLongPressButtonStyle())
                                    } label: {
                                        Label("", systemImage: "ellipsis.circle")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(.top, prop.isLargerScreen ? -25 : -20)
                                
                                VStack {
                                    /*Text(self.state == ""
                                     ? "Select your state"
                                     : self.college == ""
                                     ? "Select your college"
                                     : self.majorField == ""
                                     ? "Select your field"
                                     : "Select your major"
                                     )
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .heavy, size: 28)
                                     .minimumScaleFactor(0.5)*/
                                    
                                    if self.state != "" && (!self.loadingColleges && !self.loadingMajorFields && !self.loadingMajors) {
                                        Text("*\(self.state)* > *\(self.college)* \(self.majorField != "" ? ">" : "") *\(self.majorField)* \(self.major != "" ? ">" : "") *\(self.major)*")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-ExtraLight", size: 15))//.setFontSizeAndWeight(weight: .medium, size: 16)
                                            .fontWeight(.semibold)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    if self.loadingColleges || self.loadingMajorFields || self.loadingMajors {
                                        VStack {
                                            Text(self.loadingColleges
                                                 ? "Loading Colleges"
                                                 : self.loadingMajorFields
                                                 ? "Loading Fields"
                                                 : "Loading Majors")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 18))
                                            .fontWeight(.bold)
                                            .minimumScaleFactor(0.5)
                                            
                                            ProgressView()
                                                .tint(Color.EZNotesBlue)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    } else {
                                        if !self.collegeIsOther && !self.majorIsOther && !self.majorFieldIsOther {
                                            ScrollView(.vertical, showsIndicators: false) {
                                                VStack {
                                                    LazyVGrid(columns: self.state == "" ? stateColumns : collegeColumns) {
                                                        ForEach(self.state == ""
                                                                ? self.states
                                                                : self.college == ""
                                                                ? self.colleges
                                                                : self.majorField == ""
                                                                ? self.majorFields
                                                                : self.majors, id: \.self) { value in
                                                            Button(action: {
                                                                if self.state == "" {
                                                                    self.state = value
                                                                    assignUDKey(key: "temp_state", value: value)
                                                                    
                                                                    self.colleges.removeAll()
                                                                    self.college.removeAll()
                                                                    self.otherCollege.removeAll()
                                                                    
                                                                    self.majorFields.removeAll()
                                                                    self.majorField.removeAll()
                                                                    self.otherMajorField.removeAll()
                                                                    
                                                                    self.majors.removeAll()
                                                                    self.major.removeAll()
                                                                    self.otherMajor.removeAll()
                                                                    
                                                                    self.get_custom_colleges()
                                                                } else if self.college == "" {
                                                                    if value == "Other" {
                                                                        self.otherCollege.removeAll()
                                                                        self.collegeIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    assignUDKey(key: "temp_college", value: value)
                                                                    
                                                                    self.college = value
                                                                    self.get_custom_major_fields(collegeName: self.college)
                                                                } else if self.majorField == "" {
                                                                    if value == "Other" {
                                                                        self.otherMajorField.removeAll()
                                                                        self.majorFieldIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    assignUDKey(key: "temp_field", value: value)
                                                                    
                                                                    self.majorField = value
                                                                    self.get_majors()
                                                                } else {
                                                                    /* MARK: We can safely assume that, here, we will be assigning the major. */
                                                                    if value == "Other" {
                                                                        self.otherMajor.removeAll()
                                                                        self.majorIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    assignUDKey(key: "temp_major", value: value)
                                                                    
                                                                    self.major = value
                                                                    self.checkInfoAlert = true
                                                                }
                                                            }) {
                                                                HStack {
                                                                    Text(value)
                                                                        .frame(maxWidth: .infinity, alignment: self.state == "" ? .center : .leading)
                                                                        .padding([.leading, .top, .bottom], self.state == "" ? 5 :  10)
                                                                        .foregroundStyle(.white)
                                                                        .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                                        .fontWeight(.bold)
                                                                        .minimumScaleFactor(0.8)
                                                                        .multilineTextAlignment(.leading)
                                                                    
                                                                    if self.state != "" {
                                                                        ZStack {
                                                                            Image(systemName: "chevron.right")
                                                                                .resizable()
                                                                                .frame(width: 10, height: 15)
                                                                        }
                                                                        .frame(maxWidth: 35, alignment: .trailing)
                                                                        .foregroundStyle(.gray)
                                                                        .padding(.trailing, 10)
                                                                    }
                                                                }
                                                                .frame(maxWidth: .infinity)
                                                                .padding(10)
                                                                .background(
                                                                    self.state == ""
                                                                    ? AnyView(
                                                                        RoundedRectangle(cornerRadius: 15)
                                                                            .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                                            .shadow(color: Color.black, radius: 1.5)
                                                                    )
                                                                    : AnyView(Rectangle().fill(Color.EZNotesLightBlack.opacity(0.75)))
                                                                )
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, 20)
                                            }
                                            .alert("Before continuing", isPresented: $checkInfoAlert) {
                                                Button(action: {
                                                    /* MARK: The only way we can get here is if the sate, college, majorField and major variables are not empty. No checks needed. */
                                                    /*UserDefaults.standard.set(self.state, forKey: "temp_state")
                                                    UserDefaults.standard.set(self.college, forKey: "temp_college")
                                                    UserDefaults.standard.set(self.majorField, forKey: "temp_field")
                                                    UserDefaults.standard.set(self.major, forKey: "temp_major")*/
                                                    
                                                    self.section = "loading_code"
                                                    
                                                    //print(self.college, self.majorField, self.major, self.password)
                                                    print(
                                                        getUDValue(key: "temp_username"),
                                                        getUDValue(key: "temp_email"),
                                                        getUDValue(key: "temp_password"),
                                                        getUDValue(key: "temp_college"),
                                                        getUDValue(key: "temp_state"),
                                                        getUDValue(key: "temp_field"),
                                                        getUDValue(key: "temp_major"),
                                                        getUDValue(key: "usecase")
                                                    )
                                                    
                                                    /* TODO: Instead of using states to store credential information, should we go ahead and just use `UserDefaults`? */
                                                    RequestAction<SignUpRequestData>(
                                                        parameters: SignUpRequestData(
                                                            Username: getUDValue(key: "temp_username"),//username,
                                                            Email: getUDValue(key: "temp_email"),//email,
                                                            Password: getUDValue(key: "temp_password"),//password,
                                                            College: getUDValue(key: "temp_college"),//college,
                                                            State: getUDValue(key: "temp_state"),//state,
                                                            Field: getUDValue(key: "temp_field"),//majorField,
                                                            Major: getUDValue(key: "temp_major"),//major,
                                                            IP: getLocalIPAddress(),
                                                            Usecase: getUDValue(key: "usecase")
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
                                                            
                                                            self.error = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        if self.userExists { self.userExists = false }
                                                        if self.makeContentRed { self.makeContentRed = false }
                                                        
                                                        self.accountID = resp!["Message"] as! String
                                                        assignUDKey(key: "temp_account_id", value: self.accountID)
                                                        
                                                        self.section = "code_input"
                                                        
                                                        assignUDKey(key: "last_signup_section", value: "code_input")
                                                    }
                                                }) { Text("Looks Good") }
                                                
                                                Button(action: {
                                                    /* MARK: If `cancel` is tapped, then we will just default back to the beginning of the "select_state_and_college" section. */
                                                    self.major.removeAll()
                                                    self.majorField.removeAll()
                                                    self.college.removeAll()
                                                    self.state.removeAll()
                                                }) { Text("Cancel") }
                                            } message: {
                                                Text("Before continuing, check to make sure the following information is correct:\nState: \(self.state)\nCollege: \(self.college)\nMajor Field: \(self.majorField)\nMajor: \(self.major)\n\nIf all above information is correct, continue. Else, click \"cancel\".")
                                            }
                                        } else {
                                            if self.noSuchCollege {
                                                Text("The college you provided does not reside in \(self.state)")
                                                    .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                                    .foregroundStyle(Color.EZNotesRed)
                                                    .font(
                                                        .system(
                                                            size: prop.isIpad || prop.isLargerScreen
                                                            ? 15
                                                            : 13
                                                        )
                                                    )
                                                    .multilineTextAlignment(.center)
                                            }
                                            
                                            TextField(self.collegeIsOther
                                                      ? "College Name..."
                                                      : self.majorFieldIsOther
                                                        ? "Field Name..."
                                                        : "Major name...",
                                                      text: self.collegeIsOther
                                                        ? $otherCollege
                                                        : self.majorFieldIsOther
                                                            ? $otherMajorField
                                                            : $otherMajor)
                                                .frame(
                                                    width: prop.isIpad
                                                    ? UIDevice.current.orientation.isLandscape
                                                    ? prop.size.width - 800
                                                    : prop.size.width - 450
                                                    : prop.size.width - 100,
                                                    height: prop.isLargerScreen ? 40 : 30
                                                )
                                                .padding([.leading], 15)
                                                .background(
                                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                        .fill(.clear)
                                                        .borderBottomWLColor(
                                                            isError: self.makeContentRed
                                                                ? self.collegeIsOther
                                                                    ? otherCollege == ""
                                                                    : self.majorFieldIsOther
                                                                        ? otherMajorField == ""
                                                                        : otherMajor == ""
                                                                : false
                                                        )
                                                )
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .padding(prop.isLargerScreen ? 10 : 8)
                                                .tint(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .keyboardType(.alphabet)
                                                .focused($otherCollegeFocus)
                                                .onChange(of: self.otherCollegeFocus) {
                                                    if self.otherCollege == "" { self.makeContentRed = true; return }
                                                    
                                                    if !self.otherCollegeFocus {
                                                        /* MARK: We will assume editing is done. */
                                                        self.showCheckCollegeAlert = true
                                                    }
                                                }
                                                .alert(self.collegeIsOther
                                                    ? "Do we have the college right?"
                                                       : self.majorFieldIsOther
                                                       ? "Do we have the major field correct?"
                                                       : "Do we have the Major correct?", isPresented: $showCheckCollegeAlert) {
                                                    Button(action: {
                                                        if self.collegeIsOther {
                                                            /* MARK: First, ensure the state actually has the college being inputted. */
                                                            RequestAction<CheckStateHasCollege>(parameters: CheckStateHasCollege(
                                                                State: self.state, College: self.otherCollege
                                                            ))
                                                            .perform(action: check_college_exists_in_state_req) { statusCode, resp in
                                                                guard resp != nil && statusCode == 200 else {
                                                                    guard let resp = resp else {
                                                                        self.error = .ServerError // self.serverError = true
                                                                        return
                                                                    }
                                                                    
                                                                    guard resp.keys.contains("Message") else {
                                                                        self.error = .ServerError // self.serverError = true
                                                                        return
                                                                    }
                                                                    
                                                                    if resp["Message"] as! String == "no_such_college_in_state" {
                                                                        self.noSuchCollege = true
                                                                        return
                                                                    }
                                                                    self.error = .ServerError // self.serverError = true
                                                                    return
                                                                }
                                                                
                                                                self.get_custom_major_fields(collegeName: self.otherCollege)
                                                                
                                                                /* MARK: First, ensure that there is actually a college with the name given in the state. */
                                                                if !self.noSuchCollege {
                                                                    self.collegeIsOther = false
                                                                    
                                                                    assignUDKey(key: "temp_college", value: self.otherCollege)
                                                                    self.college = self.otherCollege
                                                                    self.otherCollege.removeAll()
                                                                }
                                                                
                                                                return
                                                            }
                                                        }
                                                        
                                                        if self.majorFieldIsOther {
                                                            assignUDKey(key: "temp_filed", value: self.otherMajorField)
                                                            self.majorField = self.otherMajorField
                                                            self.otherMajorField.removeAll()
                                                            self.get_majors()
                                                            self.majorFieldIsOther = false
                                                            
                                                            return
                                                        }
                                                        
                                                        if self.majorIsOther {
                                                            assignUDKey(key: "temp_major", value: self.otherMajor)
                                                            self.major = self.otherMajor
                                                            self.otherMajor.removeAll()
                                                            self.majorIsOther = false
                                                            
                                                            /* MARK: Selecting the major is the last step. Prompt the alert upon submission. */
                                                            self.checkInfoAlert = true
                                                        }
                                                    }) {
                                                        Text("Yes")
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    
                                                    Button("Not correct", role: .cancel) {}.buttonStyle(NoLongPressButtonStyle())
                                                } message: {
                                                    Text(self.collegeIsOther
                                                         ? "Is \(self.otherCollege) the correct college?"
                                                         : self.majorFieldIsOther
                                                            ? "Is \(self.otherMajorField) the correct field?"
                                                            : "Is \(self.otherMajor) the correct major?")
                                                }
                                            
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 40)
                                .padding(.top)
                            } else if self.section == "loading_code" {
                                VStack {
                                    Text("Registering your account...")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: 18))//.setFontSizeAndWeight(weight: .medium, size: 26)
                                        .fontWeight(.semibold)
                                        .minimumScaleFactor(0.5)
                                    
                                    ProgressView()
                                        .tint(Color.EZNotesBlue)
                                }
                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .center)
                            } else if self.section == "code_input" {
                                Text("Code")
                                    .frame(
                                        width: prop.isIpad
                                        ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                        : prop.size.width - 80,
                                        height: 5,
                                        alignment: .leading
                                    )
                                    .padding(.top, 10)
                                    .font(
                                        .system(
                                            size: prop.isLargerScreen ? 18 : 15
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .fontWeight(.medium)
                                
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
                                    height: 40
                                )
                                .padding([.leading], prop.isLargerScreen ? 15 : 5)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                        .borderBottomWLColor(isError: self.error == .WrongCode)
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding(prop.isLargerScreen ? 10 : 4)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.numberPad)
                                .onChange(of: self.userInputedCode) {
                                    /* Codes are 6-digits. */
                                    if self.userInputedCode.count == 6 {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                    
                                    /*if self.userInputedCode.count > 6 {
                                        self.userInputedCode = String(self.userInputedCode.prefix(6))
                                    }*/
                                }
                            } else {
                                Plans(
                                    prop: prop,
                                    email: self.email,
                                    accountID: self.accountID,
                                    isLargerScreen: prop.isLargerScreen,
                                    action: setLoginStatus
                                )
                            }
                        }
                        .padding(.top, prop.isLargerScreen ? 25 : 20)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Keep VStack aligned to the top
                    .ignoresSafeArea(edges: .bottom) // Ignore keyboard safe area
                    
                    //Spacer()
                    
                    if self.section != "main" && self.section != "select_plan" && self.section != "select_state_and_college" && self.section != "loading_code" {
                        VStack {
                            Button(action: {
                                if section == "credentials" {
                                    if self.wrongCodeAttemptsMet { self.wrongCodeAttemptsMet = false }
                                    
                                    /* MARK: Only set `makeContentRed` to true if all of the fields are empty. */
                                    if self.username == "" && self.email == "" && self.password == "" {
                                        self.makeContentRed = true
                                        return
                                    }
                                    
                                    if self.username.count < 4 {
                                        self.error = .TooShortUsername//self.tooShortUsername = true
                                        self.makeUsernameFieldRed = true
                                        return
                                    } else { self.makeUsernameFieldRed = false }
                                    
                                    if !self.email.contains("@") {
                                        self.error = .InvalidEmail//self.invalidEmail = true
                                        self.makeEmailFieldRed = true
                                        return
                                    } else { self.makeEmailFieldRed = false }
                                    
                                    let emailDomain = self.email.split(separator: ".").map { String($0) }
                                    
                                    if !emailDomains.contains(".\(emailDomain[emailDomain.count - 1])") {
                                        self.error = .InvalidEmail//self.invalidEmail = true
                                        self.makeEmailFieldRed = true
                                        return
                                    } else { self.makeEmailFieldRed = false }
                                    
                                    if self.password.count < 8 {
                                        self.error = .TooShortPassword//self.tooShortPassword = true
                                        self.makePasswordFieldRed = true
                                        return
                                    } else { self.makePasswordFieldRed = false }
                                    
                                    /* MARK: Since the focus of the password textfield might not be set to false when the screen switches, we'll go ahead and assign the "temp_password" `UserDefault` key here as well. */
                                    assignUDKey(key: "temp_password", value: self.password)
                                    
                                    self.error = .None /* MARK: Just ensure it is `.None`. */
                                    
                                    if getUDValue(key: "usecase") == "school" {
                                        self.loadingSelectStateAndCollegeSection = true
                                    } else {
                                        self.section = "loading_code" /* MARK: If the usecase is not "school", the app jump straight to the "Input Code" view. Display "Registering Account..." view. */
                                    }
                                    
                                    RequestAction<CheckUsernameRequestData>(parameters: CheckUsernameRequestData(
                                        Username: self.username
                                    ))
                                    .perform(action: check_username_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            self.section = "credentials"
                                            /* MARK: Stay in the "main" section. Just set `userExists` error to true and make content red. */
                                            self.error = .UserExists//self.userExists = true
                                            self.makeContentRed = true
                                            return
                                        }
                                        
                                        if self.error != .None { self.error = .None }
                                        if self.makeContentRed { self.makeContentRed = false }
                                        
                                        RequestAction<CheckEmailRequestData>(parameters: CheckEmailRequestData(
                                            Email: self.email
                                        ))
                                        .perform(action: check_email_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                self.section = "credentials"
                                                /* MARK: Stay in the "main" section. Just set `userExists` error to true and make content red. */
                                                self.error = .EmailExists//self.emailExists = true
                                                self.makeContentRed = true
                                                return
                                            }
                                            
                                            if self.error != .None { self.error = .None }
                                            if self.makeContentRed { self.makeContentRed = false }
                                            
                                            /* MARK: Check what the user is using the app for. If they selected "School" for their use case, proceed onto the state/college/field/major selection view.. else jump straight to the code input view. */
                                            /* TODO: If they select "Work" or "General", perhaps we can have a section where we ask for a bit more information over what the user does to ensure the AI can be tailored a little bit more to what they'll be using the app for. */
                                            if getUDValue(key: "usecase") == "school" {
                                                self.section = "select_state_and_college"
                                                
                                                /* MARK: Set the last section. */
                                                assignUDKey(key: "last_signup_section", value: "select_state_and_college")
                                            } else {
                                                /* MARK: Since the app is not being used for schooling, the college, state, field and major details are not needed. */
                                                /* TODO: Make it to where the server backend is compatible with the fact the mobile app can be used for other purposes besides schooling. */
                                                RequestAction<SignUpRequestData>(
                                                    parameters: SignUpRequestData(
                                                        Username: getUDValue(key: "temp_username"),//username,
                                                        Email: getUDValue(key: "temp_email"),//email,
                                                        Password: getUDValue(key: "temp_password"),//password,
                                                        College: "N/A",//college,
                                                        State: "N/A",//state,
                                                        Field: "N/A",//majorField,
                                                        Major: "N/A",//major,
                                                        IP: getLocalIPAddress(),
                                                        Usecase: getUDValue(key: "usecase")
                                                    )
                                                ).perform(action: complete_signup1_req) { statusCode, resp in
                                                    guard resp != nil && statusCode == 200 else {
                                                        if let resp = resp {
                                                            if resp["ErrorCode"] as! Int == 0x6970 {
                                                                self.section = "credentials"
                                                                self.error = .UserExists//self.userExists = true
                                                                return
                                                            }
                                                            if resp["ErrorCode"] as! Int == 0x7877 {
                                                                self.error = .ServerError
                                                                return
                                                            }
                                                        }
                                                        
                                                        self.error = .ServerError//self.error = .ServerError // self.serverError = true
                                                        return
                                                    }
                                                    
                                                    if self.error != .None { self.error = .None }
                                                    if self.makeContentRed { self.makeContentRed = false }
                                                    
                                                    self.accountID = resp!["Message"] as! String
                                                    assignUDKey(key: "temp_account_id", value: self.accountID)
                                                    
                                                    self.section = "code_input"
                                                    
                                                    assignUDKey(key: "last_signup_section", value: "code_input")
                                                }
                                            }
                                            
                                            /* MARK: Ensure to (temporarily) store username, email and password (just in case they leave the app and come back). */
                                            //assignUDKey(key: "temp_username", value: self.username)
                                            //assignUDKey(key: "temp_email", value: self.email)
                                            //assignUDKey(key: "temp_password", value: self.password)
                                            //UserDefaults.standard.set(self.accountID, forKey: "temp_account_id")
                                        }
                                    }
                                } else {
                                    /* TODO: Is the below if statement needed? */
                                    if self.section == "code_input" {
                                        if self.userInputedCode.isEmpty {
                                            self.error = .WrongCode
                                            return
                                        }
                                        
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
                                                
                                                if let resp = resp { print(resp) }
                                                
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
                                                    assignUDKey(key: "last_signup_section", value: "main")
                                                    
                                                    removeAllSignUpTempKeys()
                                                    self.college.removeAll()
                                                    self.major.removeAll()
                                                    self.majorField.removeAll()
                                                    self.state.removeAll()
                                                    self.accountID.removeAll()
                                                    
                                                    self.colleges.removeAll()
                                                    self.majors.removeAll()
                                                    self.majorFields.removeAll()
                                                    
                                                    /* MARK: Reset code attemp information. */
                                                    self.wrongCodeAttempts = 0
                                                    self.wrongCodeAttemptsMet = true
                                                    self.error = .None//self.wrongCode = false
                                                    return
                                                }
                                                
                                                self.error = .WrongCode//self.wrongCode = true
                                                return
                                            }
                                            
                                            print(self.username)
                                            
                                            assignUDKey(key: "username", value: self.username)
                                            assignUDKey(key: "email", value: self.email)
                                            assignUDKey(key: "major_field", value: self.majorField)
                                            assignUDKey(key: "major_name", value: self.major)
                                            assignUDKey(key: "college_state", value: self.state)
                                            assignUDKey(key: "college_name", value: self.college)
                                            
                                            if self.makeContentRed { self.makeContentRed = false }
                                            if self.error != .None { self.error = .None }
                                            
                                            assignUDKey(key: "last_signup_section", value: "select_plan")
                                            self.section = "select_plan"
                                        }
                                        
                                    }
                                }
                            }) {
                                Text(section == "credentials"
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
                        }
                        .padding(.bottom, self.section == "main"
                                 ? 10
                                 : !prop.isLargerScreen ? 10 : 30
                        )
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    Image(systemName: "exclamationmark.warninglight.fill")
                        .resizable()
                        .frame(width: 45, height: 40)
                        .padding([.top, .bottom], 15)
                        .foregroundStyle(Color.EZNotesRed)
                    
                    Text("Hey There👋")//(self.section != "select_plan" ? "Sign Up" : "Plans")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        .foregroundStyle(.white)
                        .font(
                            .system(
                                size: prop.isIpad
                                ? 90
                                : prop.isLargerScreen
                                ? 35
                                : 25
                            )
                        )
                        .fontWeight(.bold)
                    
                    Text("You have already signed up. Go to the login screen to login.")
                        .frame(maxWidth: prop.size.width - 50, alignment: .center)
                        .foregroundStyle(self.wrongCode || self.userExists || self.emailExists ? Color.EZNotesRed : Color.white)
                        .font(
                            .system(
                                size: prop.isIpad || prop.isLargerScreen
                                ? 15
                                : 13
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Button(action: { self.screen = "login" }) {
                        Text("Go to login")
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
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(self.section == "main" ? .init() : .bottom)
        .background(Color.EZNotesBlack)
        .onAppear {
            /* MARK: If the key "username" exists in `UserDefaults`, then there has been an account created on the device. */
            /* MARK: This will not work if users wipe data from the app. */
            if udKeyExists(key: "username") {
                /*if udKeyExists(key: "plan_selected") {
                    self.alreadySignedUp = true
                    return
                }*/
            }
            
            self.alreadySignedUp = false
            
            guard udKeyExists(key: "last_signup_section") else {
                self.section = "main"
                assignUDKey(key: "main", value: "last_signup_section")
                return
            }
            
            self.section = getUDValue(key: "last_signup_section")//UserDefaults.standard.string(forKey: "last_signup_section")!
            if udKeyExists(key: "temp_username") { self.username = getUDValue(key: "temp_username") }
            if udKeyExists(key: "temp_email") { self.email = getUDValue(key: "temp_email") }
            if udKeyExists(key: "temp_password") { self.password = getUDValue(key: "temp_password") }
            if udKeyExists(key: "temp_account_id") { self.accountID = getUDValue(key: "temp_account_id") }
            
            /* MARK: FOR DEVELOPMENT PURPOSES ONLY. */
            //self.section = "main"
            //self.state = ""
            //self.college = ""
            //self.major = ""
            //self.majorField = ""
            
            /* MARK: If the section is currently `select_state_and_college` or `code_input`, we want to get all of the data over the state, college, major field and major. This data will be needed to finish the sign up process and assign the according `UserDefault` keys. */
            if self.section == "select_state_and_college" || self.section == "code_input" {
                guard udKeyExists(key: "temp_state") else { return }
                
                self.state = getUDValue(key: "temp_state")
                //self.loadingColleges = true
                
                guard udKeyExists(key: "temp_college") else {
                    self.get_custom_colleges()
                    return
                }
                
                self.college = getUDValue(key: "temp_college")
                //self.loadingMajorFields = true
                
                guard udKeyExists(key: "temp_field") else {
                    self.get_custom_major_fields(collegeName: self.college)
                    return
                }
                
                self.majorField = getUDValue(key: "temp_field")
                //self.loadingMajors = true
                
                guard udKeyExists(key: "temp_major") else {
                    self.get_majors()
                    return
                }
                
                self.major = getUDValue(key: "temp_major")
                
                if self.section == "select_state_and_college" {
                    self.checkInfoAlert = true
                }
                
                /*RequestAction<SignUpRequestData>(
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
                        
                        self.error = .ServerError // self.serverError = true
                        return
                    }
                    
                    if self.userExists { self.userExists = false }
                    if self.makeContentRed { self.makeContentRed = false }
                    
                    self.accountID = resp!["Message"] as! String
                    self.section = "code_input"
                    
                    assignUDKey(key: "last_signup_section", value: "code_input")
                }*/
                
                //if UserDefaults.standard.object(forKey: "temp_major") != nil { self.major = UserDefaults.standard.string(forKey: "temp_major")! }*/
            }
        }
    }
}
