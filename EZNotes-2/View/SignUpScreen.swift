//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI
import Combine

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
    
    /* MARK: Usernames must by 4 or more characters long. */
    @State private var tooShortUsername: Bool = false
    @State private var makeUsernameFieldRed: Bool = false
    
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
    
    @State private var isLargerScreen: Bool = false
    
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
    
    public func setLoginStatus() -> Void {
        UserDefaults.standard.set(
            true,
            forKey: "logged_in"
        )
        UserDefaults.standard.set(
            self.accountID,
            forKey: "account_id"
        )
        UserDefaults.standard.set("main", forKey: "last_signup_section")
        
        /* MARK: Ensure that none of the temporary keys in `UserDefaults` carry over after signing up. */
        UserDefaults.standard.removeObject(forKey: "temp_college")
        UserDefaults.standard.removeObject(forKey: "temp_field")
        UserDefaults.standard.removeObject(forKey: "temp_major")
        UserDefaults.standard.removeObject(forKey: "temp_state")
        UserDefaults.standard.removeObject(forKey: "temp_username")
        UserDefaults.standard.removeObject(forKey: "temp_email")
        UserDefaults.standard.removeObject(forKey: "temp_password")
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
                    self.serverError = true
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
                    self.serverError = true
                    return
                }
                
                guard resp.keys.contains("Message") else {
                    self.serverError = true
                    return
                }
                
                if resp["Message"] as! String == "no_such_college_in_state" {
                    self.noSuchCollege = true
                    return
                }
                
                self.serverError = true
                return
            }
            
            guard resp!.keys.contains("Fields") else {
                self.serverError = true
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
                self.serverError = true
                return
            }
            
            self.majors = resp!["Majors"] as! [String]
            self.majors.append("Other")
            //self.major = self.majors[0]
        }
    }
    
    /* MARK: Needed to keep responsive sizes consistent with the devices geometry. */
    /* MARK: For example, when the keyboard is active the geometry of the view (in height) shrinks to accomdate the keyboard. */
    @State private var lastHeight: CGFloat = 0.0
    @State private var hideAgreementDetails: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            if !self.alreadySignedUp {
                VStack {
                    // VStack with TextFields
                    VStack {
                        if self.section != "select_state_and_college" {
                            HStack {
                                if self.section != "loading_code" {
                                    ZStack {
                                        Button(action: {
                                            switch(self.section) {
                                            case "main":
                                                self.screen = "home"
                                                UserDefaults.standard.set("main", forKey: "last_signup_section")
                                                break
                                            case "select_state_and_college":
                                                self.section = "main"
                                                UserDefaults.standard.set(self.section, forKey: "last_signup_section")
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
                                                        self.serverError = true
                                                        return
                                                    }
                                                    
                                                    self.section = "select_state_and_college"
                                                    UserDefaults.standard.set(self.section, forKey: "last_signup_section")
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
                                                        self.serverError = true
                                                        return
                                                    }
                                                    
                                                    self.section = "select_state_and_college"
                                                    UserDefaults.standard.set(self.section, forKey: "last_signup_section")
                                                    
                                                    /* MARK: Remove all of the temporary information. */
                                                    UserDefaults.standard.removeObject(forKey: "temp_college")
                                                    UserDefaults.standard.removeObject(forKey: "temp_field")
                                                    UserDefaults.standard.removeObject(forKey: "temp_major")
                                                    UserDefaults.standard.removeObject(forKey: "temp_state")
                                                    UserDefaults.standard.removeObject(forKey: "temp_username")
                                                    UserDefaults.standard.removeObject(forKey: "temp_email")
                                                    UserDefaults.standard.removeObject(forKey: "temp_password")
                                                    
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
                                    
                                    Text(self.section == "main"
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
                                            : self.isLargerScreen
                                            ? 35
                                            : 25
                                        )
                                    )
                                    .fontWeight(.bold)
                                    
                                    ZStack {
                                        Menu {
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
                            
                            /* TODO: Perhaps restructure the code? I feel like this is bad design. */
                            if !self.tooShortUsername && !self.invalidEmail && !self.tooShortPassword {
                                if self.section != "loading_code" {
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
                                    .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                    .foregroundStyle(self.wrongCode || self.userExists || self.emailExists ? Color.EZNotesRed : Color.white)
                                    .font(
                                        .system(
                                            size: prop.isIpad || self.isLargerScreen
                                            ? 15
                                            : 13
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                }
                            } else {
                                if self.tooShortUsername {
                                    Text("The username provided is too short. It must be 4 or more characters long.")
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
                                } else if self.invalidEmail {
                                    Text("The email provided is missing the domain, or has an invalid domain.")
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
                                } else {
                                    Text("The password provided is too short. It must be 8 or more characters long.")
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
                            }
                        }
                        
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
                                                ? self.userExists || self.makeUsernameFieldRed ? self.borderBottomColorError : self.borderBottomColor
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
                                                ? self.userExists || self.makeEmailFieldRed ? self.borderBottomColorError : self.borderBottomColor
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
                                                ? self.makePasswordFieldRed ? self.borderBottomColorError : self.borderBottomColor
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
                                            UserDefaults.standard.set("main", forKey: "last_signup_section")
                                        }
                                        else {
                                            /* MARK: The below operations will automatically cause the "section" of "select_state_and_college" to go back. */
                                            if self.college == "" {
                                                self.state.removeAll()
                                                
                                                UserDefaults.standard.removeObject(forKey: "temp_state")
                                                return
                                            }
                                            if self.majorField == "" {
                                                self.college.removeAll();
                                                
                                                UserDefaults.standard.removeObject(forKey: "temp_college")
                                                
                                                /* MARK: Ensure that, when going back, there is content to show. If not, load the content. */
                                                if self.colleges.count == 0 { self.get_custom_colleges() }
                                                return
                                            }
                                            
                                            self.majorField.removeAll()
                                            
                                            UserDefaults.standard.removeObject(forKey: "temp_field")
                                            
                                            /* MARK: Ensure that, when going back, there is content to show. If not, load the content. */
                                            if self.majorFields.count == 0 { self.get_custom_major_fields(collegeName: self.college) }
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
                                                : self.isLargerScreen
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
                                .padding(.top, self.isLargerScreen ? -25 : -20)
                                
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
                                                                    UserDefaults.standard.set(value, forKey: "temp_state")
                                                                    
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
                                                                    
                                                                    self.get_custom_colleges()
                                                                } else if self.college == "" {
                                                                    if value == "Other" {
                                                                        self.collegeIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    UserDefaults.standard.set(value, forKey: "temp_college")
                                                                    
                                                                    self.college = value
                                                                    self.get_custom_major_fields(collegeName: self.college)
                                                                } else if self.majorField == "" {
                                                                    if value == "Other" {
                                                                        self.majorFieldIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    UserDefaults.standard.set(value, forKey: "temp_field")
                                                                    print("HI")
                                                                    
                                                                    self.majorField = value
                                                                    self.get_majors()
                                                                } else {
                                                                    /* MARK: We can safely assume that, here, we will be assigning the major. */
                                                                    if value == "Other" {
                                                                        self.majorIsOther = true
                                                                        return
                                                                    }
                                                                    
                                                                    UserDefaults.standard.set(value, forKey: "temp_major")
                                                                    
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
                                                            
                                                            self.serverError = true
                                                            return
                                                        }
                                                        
                                                        if self.userExists { self.userExists = false }
                                                        if self.makeContentRed { self.makeContentRed = false }
                                                        
                                                        self.accountID = resp!["Message"] as! String
                                                        UserDefaults.standard.set(self.accountID, forKey: "temp_account_id")
                                                        
                                                        self.section = "code_input"
                                                        
                                                        UserDefaults.standard.set("code_input", forKey: "last_signup_section")
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
                                                            size: prop.isIpad || self.isLargerScreen
                                                            ? 15
                                                            : 13
                                                        )
                                                    )
                                                    .multilineTextAlignment(.center)
                                            }
                                            
                                            TextField(self.collegeIsOther ? "College Name..." : "Field Name...", text: self.collegeIsOther ? $otherCollege : $otherMajorField)
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
                                                .alert(self.collegeIsOther ? "Do we have the college right?" : "Do we have the Major Field correct?", isPresented: $showCheckCollegeAlert) {
                                                    Button(action: {
                                                        if self.collegeIsOther {
                                                            /* MARK: First, ensure the state actually has the college being inputted. */
                                                            RequestAction<CheckStateHasCollege>(parameters: CheckStateHasCollege(
                                                                State: self.state, College: self.otherCollege
                                                            ))
                                                            .perform(action: check_college_exists_in_state_req) { statusCode, resp in
                                                                guard resp != nil && statusCode == 200 else {
                                                                    guard let resp = resp else {
                                                                        self.serverError = true
                                                                        return
                                                                    }
                                                                    
                                                                    guard resp.keys.contains("Message") else {
                                                                        self.serverError = true
                                                                        return
                                                                    }
                                                                    
                                                                    if resp["Message"] as! String == "no_such_college_in_state" {
                                                                        self.noSuchCollege = true
                                                                        return
                                                                    }
                                                                    self.serverError = true
                                                                    return
                                                                }
                                                                
                                                                self.get_custom_major_fields(collegeName: self.otherCollege)
                                                                
                                                                /* MARK: First, ensure that there is actually a college with the name given in the state. */
                                                                if !self.noSuchCollege {
                                                                    self.collegeIsOther = false
                                                                    
                                                                    UserDefaults.standard.set(self.otherCollege, forKey: "temp_college")
                                                                    self.college = self.otherCollege
                                                                    self.otherCollege.removeAll()
                                                                }
                                                                
                                                                return
                                                            }
                                                        }
                                                        
                                                        if self.majorFieldIsOther {
                                                            UserDefaults.standard.set(self.otherMajorField, forKey: "temp_field")
                                                            self.majorField = self.otherMajorField
                                                            self.otherMajorField.removeAll()
                                                            self.get_majors()
                                                            self.majorFieldIsOther = false
                                                            
                                                            return
                                                        }
                                                    }) {
                                                        Text("Yes")
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    
                                                    Button("Not correct", role: .cancel) {}.buttonStyle(NoLongPressButtonStyle())
                                                } message: {
                                                    Text(self.collegeIsOther ? "Is \(self.otherCollege) the correct college?" : "Is \(self.otherMajorField) the correct field?")
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
                                    borderBottomColor: self.borderBottomColor,
                                    borderBottomColorError: self.borderBottomColorError,
                                    isLargerScreen: self.isLargerScreen,
                                    action: setLoginStatus,
                                    makeContentRed: $makeContentRed
                                )
                            }
                        }
                        .padding(.top, self.isLargerScreen ? 25 : 20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top) // Keep VStack aligned to the top
                    .ignoresSafeArea(edges: .bottom) // Ignore keyboard safe area
                    .onChange(of: prop.size.height) {
                        if prop.size.height < self.lastHeight { self.isLargerScreen = prop.size.height / 2.5 > 200 }
                        else { self.isLargerScreen = prop.size.height / 2.5 > 300 }
                        
                        self.lastHeight = prop.size.height
                    }
                    
                    Spacer()
                    
                    if self.section != "select_plan" && self.section != "select_state_and_college" && self.section != "loading_code" {
                        VStack {
                            Button(action: {
                                if section == "main" {
                                    if self.wrongCodeAttemptsMet { self.wrongCodeAttemptsMet = false }
                                    
                                    if self.username == "" || self.email == "" || self.password == "" {
                                        self.makeContentRed = true
                                        return
                                    }
                                    
                                    if self.username.count < 4 {
                                        self.tooShortUsername = true
                                        self.makeUsernameFieldRed = true
                                        return
                                    } else {
                                        /* MARK: Ensure both above variables are false. */
                                        self.tooShortUsername = false
                                        self.makeUsernameFieldRed = false
                                    }
                                    
                                    if self.password.count < 8 {
                                        self.tooShortPassword = true
                                        self.makePasswordFieldRed = true
                                        return
                                    } else {
                                        /* MARK: Ensure both above variables are false. */
                                        self.tooShortPassword = false
                                        self.makePasswordFieldRed = false
                                    }
                                    
                                    if !self.email.contains("@") {
                                        self.invalidEmail = true
                                        self.makeEmailFieldRed = true
                                        return
                                    } else {
                                        self.invalidEmail = false
                                        self.makeEmailFieldRed = false
                                    }
                                    
                                    let emailDomain = self.email.split(separator: ".").map { String($0) }
                                    
                                    if !emailDomains.contains(".\(emailDomain[emailDomain.count - 1])") {
                                        self.invalidEmail = true
                                        self.makeEmailFieldRed = true
                                        return
                                    } else {
                                        self.invalidEmail = false
                                        self.makeEmailFieldRed = false
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
                                            //UserDefaults.standard.set(self.accountID, forKey: "temp_account_id")
                                        }
                                    }
                                } else {
                                    /* TODO: Is the below if statement needed? */
                                    if self.section == "code_input" {
                                        print("\(accountID)!")
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
                                                    UserDefaults.standard.set("main", forKey: "last_signup_section")
                                                    
                                                    UserDefaults.standard.removeObject(forKey: "temp_college")
                                                    UserDefaults.standard.removeObject(forKey: "temp_field")
                                                    UserDefaults.standard.removeObject(forKey: "temp_major")
                                                    UserDefaults.standard.removeObject(forKey: "temp_state")
                                                    UserDefaults.standard.removeObject(forKey: "temp_username")
                                                    UserDefaults.standard.removeObject(forKey: "temp_email")
                                                    UserDefaults.standard.removeObject(forKey: "temp_password")
                                                    
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
                                            
                                            if self.makeContentRed { self.makeContentRed = false }
                                            if self.wrongCode { self.wrongCode = false }
                                            
                                            UserDefaults.standard.set("select_plan", forKey: "last_signup_section")
                                            self.section = "select_plan"
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
                        }
                        .padding(.bottom, self.section == "main" ? 0 : 30)
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
                                : self.isLargerScreen
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
                                size: prop.isIpad || self.isLargerScreen
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
            self.isLargerScreen = prop.size.height / 2.5 > 300
            self.lastHeight = prop.size.height
            
            /* MARK: If the key "username" exists in `UserDefaults`, then there has been an account created on the device. */
            /* MARK: This will not work if users wipe data from the app. */
            if UserDefaults.standard.object(forKey: "username") != nil {
                if UserDefaults.standard.object(forKey: "plan_selected") != nil {
                    self.alreadySignedUp = true
                    return
                }
            }
            
            self.alreadySignedUp = false
            
            guard UserDefaults.standard.object(forKey: "last_signup_section") != nil else {
                self.section = "main"
                UserDefaults.standard.set("main", forKey: "last_signup_section")
                return
            }
            
            self.section = UserDefaults.standard.string(forKey: "last_signup_section")!
            if UserDefaults.standard.object(forKey: "temp_username") != nil { self.username = UserDefaults.standard.string(forKey: "temp_username")! }
            if UserDefaults.standard.object(forKey: "temp_email") != nil { self.email = UserDefaults.standard.string(forKey: "temp_email")! }
            if UserDefaults.standard.object(forKey: "temp_password") != nil { self.password = UserDefaults.standard.string(forKey: "temp_password")! }
            if UserDefaults.standard.object(forKey: "temp_account_id") != nil { self.accountID = UserDefaults.standard.string(forKey: "temp_account_id")! }
            
            /* MARK: FOR DEVELOPMENT PURPOSES ONLY. */
            //self.section = "main"
            //self.state = ""
            //self.college = ""
            //self.major = ""
            //self.majorField = ""
            
            if self.section == "select_state_and_college" {
                guard UserDefaults.standard.object(forKey: "temp_state") != nil else { return }
                
                self.state = UserDefaults.standard.string(forKey: "temp_state")!
                //self.loadingColleges = true
                
                guard UserDefaults.standard.object(forKey: "temp_college") != nil else {
                    self.get_custom_colleges()
                    return
                }
                
                self.college = UserDefaults.standard.string(forKey: "temp_college")!
                //self.loadingMajorFields = true
                
                guard UserDefaults.standard.object(forKey: "temp_field") != nil else {
                    self.get_custom_major_fields(collegeName: self.college)
                    return
                }
                
                self.majorField = UserDefaults.standard.string(forKey: "temp_field")!
                //self.loadingMajors = true
                
                guard UserDefaults.standard.object(forKey: "temp_major") != nil else {
                    self.get_majors()
                    return
                }
                self.major = UserDefaults.standard.string(forKey: "temp_major")!
                
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
                        
                        self.serverError = true
                        return
                    }
                    
                    if self.userExists { self.userExists = false }
                    if self.makeContentRed { self.makeContentRed = false }
                    
                    self.accountID = resp!["Message"] as! String
                    self.section = "code_input"
                    
                    UserDefaults.standard.set("code_input", forKey: "last_signup_section")
                }
                
                //if UserDefaults.standard.object(forKey: "temp_major") != nil { self.major = UserDefaults.standard.string(forKey: "temp_major")! }*/
            }
        }
    }
}

#Preview {
    ContentView()
}
