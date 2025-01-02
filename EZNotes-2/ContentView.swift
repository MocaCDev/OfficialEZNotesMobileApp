//
//  ContentView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//

import SwiftUI
import Combine
import UIKit
import LocalAuthentication
import Stripe

//import PhotosUI
//import UIKit

/*class AppDelegate: NSObject, UIApplicationDelegate {
    
}*/

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

enum LoginErrors {
    case None
    case EmptyUsername
    case InvalidUserError
    case EmptyPassword
    case InvalidPasswordError
    case ServerError /* MARK: An error that ocurrs in the server that is not directly linked to the username/email or password being incorrect. */
}

struct ContentView: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    
    //@State private var faceIDAuthenticated: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State public var reAuthReqFromLogin: Bool = false
    //@StateObject public var accountInfo: AccountDetails = AccountDetails()
    
    /*init() {
        StripeAPI.defaultPublishableKey = "pk_test_51OdoXSDNLx34I7Pu22ELrZac5NUd5lrs8EXqK96SFOUJM6wZqOe8HQxyH0f3CR8emsCAVwQiqStwTWyGhCj1wRtM00T1fR9V2D"
    }*/
    
    /*public func authenticate(initializing: Bool) {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "FaceID is recommended to secure you data"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    self.faceIDAuthenticated = true
                    
                    if initializing { UserDefaults.standard.set(true, forKey: "faceID_initialized") }
                } else {
                    if initializing {
                        UserDefaults.standard.set("disabled", forKey: "faceID_enabled")
                    } else {
                        self.goBackToLogin = true
                        //self.userHasSignedIn = false
                        UserDefaults.standard.set(false, forKey: "logged_in")
                        //UserDefaults.standard.removeObject(forKey: "logged_in")
                        UserDefaults.standard.removeObject(forKey: "requires_faceID")
                    }
                }
            }
        } else {
            // no biometrics
        }
    }*/
    
    @State public var userHasSignedIn: Bool = UserDefaults.standard.bool(forKey: "logged_in")
    @State public var userNotFound: Bool = false
    @State private var goBackToLogin: Bool = false
    @StateObject private var model: FrameHandler = FrameHandler()
    
    //@StateObject public var categoryData: CategoryData = CategoryData()
    
    //@State private var messages: Array<MessageDetails> = []
    
    /* MARK: `UUID` will be the chat ID. */
    //@State private var temporaryStoredChats: [String: [UUID: Array<MessageDetails>]] = getTemporaryStoredChats()
    
    //private let rotationChangePublisher = NotificationCenter.default
        //.publisher(for: UIDevice.orientationDidChangeNotification)
    
    @State private var topBanner: TopBanner = .None
    //@State private var needsNoWifiBanner: Bool = false
    
    /* `section` can be: "upload", "review_upload", "home" or "chat". */
    @State private var section: String = "upload"
    @State private var selectedTab: Int = 1
    @State private var lastSection: String = "upload"
    
    //@ObservedObject public var images_to_upload: ImagesUploads
    @StateObject public var images_to_upload: ImagesUploads = ImagesUploads()
    //@ObservedObject public var model: FrameHandler
    
    @State private var loadingCameraView: Bool = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0
    
    @State private var homeView: Bool = true
    
    @State private var localUpload: Bool = false
    @State private var createOneCategory: Bool = false
    @State private var errorType: String = "" /* TODO: Change this. */
    
    /* MARK: States for the "startup screen" which prompts the login prompt for the user. */
    @State private var loginUsername: String = ""
    @State private var loginPassword: String = ""
    @FocusState public var loginPasswordFieldInFocus: Bool
    @FocusState public var loginUsernameFieldInFocus: Bool
    @State public var loginError: LoginErrors = .None
    
    /* MARK: States for signing up. */
    @State private var signupUsername: String = ""
    @FocusState private var signupUsernameFieldInFocus: Bool
    @State private var signupEmail: String = ""
    @FocusState private var signupEmailFieldInFocus: Bool
    @State private var signupPassword: String = ""
    @FocusState private var signupPasswordFieldInFocus: Bool
    @State private var signupConfirmCode: String = ""
    @FocusState private var signupConfirmCodeFieldInFocus: Bool
    
    @State private var signupUsernameError: Bool = false
    @State private var signupEmailError: Bool = false
    @State private var signupPasswordError: Bool = false
    
    @State private var isLoggingIn: Bool = true
    @State private var signupSection: String = "usecase"
    
    @State private var signupError: SignUpScreenErrors = .None
    @State private var loadingColleges: Bool = false
    @State private var loadingMajorFields: Bool = false
    @State private var loadingMajors: Bool = false
    @State private var colleges: Array<String> = []
    @State private var collegeIsOther: Bool = false
    @State private var majorFields: Array<String> = []
    @State private var majorFieldIsOther: Bool = false
    @State private var majors: Array<String> = []
    @State private var majorIsOther: Bool = false
    @State private var userExists: Bool = false
    
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
    let stateColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /* MARK: Makes assigning `signuperror` and `signupSection` easier. */
    private func setSignupErrorAndSection(error: SignUpScreenErrors = .None, section: String) -> Void {
        self.signupError = error
        self.signupSection = section
    }
    
    @State private var loggingIn: Bool = false
    
    var body: some View {
        if !userHasSignedIn {
            ResponsiveView(eventTypeToIgnore: .keyboard, edgesToIgnore: [.bottom]) { prop in
                VStack {
                    HStack {
                        if !self.isLoggingIn { ZStack { }.frame(maxWidth: 20, alignment: .leading) }
                        else { Spacer() }
                        
                        ZStack {
                            Image("JustLogo")
                                .logoImageModifier(prop: prop)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        if !self.isLoggingIn {
                            ZStack {
                                Menu {
                                    if self.signupError == .ServerError || self.signupError == .ErrorOccurred || self.signupError == .ForceRestart {
                                        Button(action: { print("Report Problem") }) {
                                            Label("Report Problem", systemImage: "sun.max.trianglebadge.exclamationmark")
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    if self.signupSection != "usecase" && self.signupSection != "select_plan" { /* MARK: Although restarting the sign up process via this menu on the "Credentials" view is useless, it doesn't hurt to have it as a feature. */
                                        Button(action: {
                                            self.colleges.removeAll()
                                            self.majorFields.removeAll()
                                            self.majors.removeAll()
                                            
                                            /*removeUDKey(key: "username")
                                            removeUDKey(key: "email")
                                            removeUDKey(key: "password")
                                            removeUDKey(key: "account_id")
                                            removeUDKey(key: "state")
                                            removeUDKey(key: "college")
                                            removeUDKey(key: "major_field")
                                            removeUDKey(key: "major")*/
                                            
                                            /* MARK: Remove the sign up process in the backend. */
                                            RequestAction<DeleteSignupProcessData>(
                                                parameters: DeleteSignupProcessData(
                                                    AccountID: getUDValue(key: "account_id") /* MARK: If the current section is "code_input", an account ID has been generated for the client. */
                                                )
                                            )
                                            .perform(action: delete_signup_process_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    /* MARK: There should never be an error when deleting the process in the backend. */
                                                    if let resp = resp { print(resp) }
                                                    return
                                                }
                                            }
                                            
                                            /* MARK: Ensure all keys in `UserDefaults` that have been assigned throughout the signup process get removed. */
                                            udRemoveAllAccountInfoKeys()
                                            
                                            self.signupSection = "usecase"
                                        }) {
                                            Label("Restart Signup", systemImage: "arrow.trianglehead.counterclockwise")
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    /* MARK: Once the user gets to `code_input` or `select_plan`, they will not be eligible to go to the login screen. */
                                    if self.signupSection != "select_plan" && self.signupSection != "code_input" {
                                        Button(action: { self.isLoggingIn = true }) {
                                            Label("Back to Login", systemImage: "chevron.forward")
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
                                    Label("", systemImage: "ellipsis")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .rotationEffect(Angle(degrees: 90))
                                        .padding()
                                }
                            }
                            .frame(maxWidth: 20, alignment: .trailing)
                        } else { Spacer() }
                    }
                    //.frame(maxHeight: prop.isLargerScreen ? 150 : 120)
                    
                    if self.isLoggingIn {
                        VStack {
                            Text("Welcome Back!")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 26 : 24))
                                .lineSpacing(1.5)
                                .foregroundStyle(.white)
                                //.padding(.top, prop.isLargerScreen ? 16 : 4)
                                .padding(.bottom, prop.isLargerScreen ? 40 : 28)
                            
                            if self.loginError == .ServerError {
                                Text("Something went wrong. Try again.")
                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                    .lineLimit(1...2)
                                    .font(
                                        .system(
                                            size: prop.isLargerScreen ? 18 : 15
                                        )
                                    )
                                    .foregroundStyle(Color.EZNotesRed)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 6)
                            }
                            
                            TextField("", text: $loginUsername)
                                .frame(width: prop.size.width - 70)
                                .padding(.vertical, 6.5)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .borderBottomWLColor(isError: self.loginError == .InvalidUserError || self.loginError == .EmptyUsername, width: 0.5)
                                )
                                .overlay(
                                    HStack {
                                        if self.loginUsername.isEmpty && !self.loginUsernameFieldInFocus {
                                            Text("Username or Email")
                                                .font(
                                                    .system(
                                                        size: prop.isLargerScreen ? 18 : 15,
                                                        weight: .medium
                                                    )
                                                )
                                                .foregroundStyle(Color(.systemGray2))
                                                .padding(.leading, 5)
                                                .onTapGesture { self.loginUsernameFieldInFocus = true }
                                            Spacer()
                                        } else {
                                            if self.loginUsername.isEmpty {
                                                Text("Username or Email")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .medium
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 5)
                                                    .onTapGesture { self.loginUsernameFieldInFocus = true }
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                            //.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(Font.custom("Poppins-SemiBold", size: 18))
                                .focused($loginUsernameFieldInFocus)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                                .onChange(of: self.loginUsername) {
                                    if self.loginError == .EmptyUsername && !self.loginUsername.isEmpty { self.loginError = .None }
                                }
                            
                            if self.loginError == .InvalidUserError || self.loginError == .EmptyUsername {
                                Text(self.loginError == .InvalidUserError
                                     ? "The username/email provided doesn't exist. Try again"
                                     : "Fill in the above field")
                                .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                .lineLimit(1...2)
                                .font(
                                    .system(
                                        size: prop.isLargerScreen ? 18 : 15
                                    )
                                )
                                .foregroundStyle(Color.EZNotesRed)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 6)
                            }
                            
                            SecureField("", text: $loginPassword)
                                .frame(
                                    maxWidth: prop.size.width - 70
                                )
                                .padding(.vertical, 6.5)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                        .borderBottomWLColor(isError: self.loginError == .InvalidPasswordError || self.loginError == .EmptyPassword, width: 0.5)
                                )
                                .overlay(
                                    HStack {
                                        if self.loginPassword.isEmpty && !self.loginPasswordFieldInFocus {
                                            Text("Password")
                                                .font(
                                                    .system(
                                                        size: prop.isLargerScreen ? 18 : 15,
                                                        weight: .medium
                                                    )
                                                )
                                                .foregroundStyle(Color(.systemGray2))
                                                .padding(.leading, 5)
                                                .onTapGesture { self.loginPasswordFieldInFocus = true }
                                            Spacer()
                                        } else {
                                            if self.loginPassword.isEmpty {
                                                Text("Password")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .medium
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 5)
                                                    .onTapGesture { self.loginPasswordFieldInFocus = true }
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                            //.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(Font.custom("Poppins-SemiBold", size: 18))
                                .focused($loginPasswordFieldInFocus)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.vertical, self.loginError != .InvalidPasswordError && self.loginError != .EmptyPassword ? 16 : 0)
                                .padding(.top, self.loginError == .InvalidPasswordError || self.loginError == .EmptyPassword ? 12 : 0)
                                .onChange(of: self.loginPassword) {
                                    if self.loginError == .EmptyPassword && !self.loginPassword.isEmpty { self.loginError = .None }
                                }
                            
                            if self.loginError == .InvalidPasswordError || self.loginError == .EmptyPassword {
                                Text(self.loginError == .InvalidPasswordError
                                     ? "Incorrect password. Try again"
                                     : "Fill in the above field")
                                .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                .lineLimit(1...2)
                                .font(
                                    .system(
                                        size: prop.isLargerScreen ? 18 : 15
                                    )
                                )
                                .foregroundStyle(Color.EZNotesRed)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 6)
                            }
                            
                            Button(action: {
                                self.loginError = .None /* MARK: Ensure the `loginError` value is `.None` to ensure no errors show. */
                                
                                if self.loginUsername.isEmpty { self.loginError = .EmptyUsername; return }
                                if self.loginPassword.isEmpty { self.loginError = .EmptyPassword; return }
                                
                                self.loggingIn = true
                                
                                RequestAction<LoginRequestData>(parameters: LoginRequestData(
                                    Username: self.loginUsername, Password: self.loginPassword
                                )).perform(action: complete_login_req) { statusCode, resp in
                                    self.loggingIn = false
                                    
                                    guard resp != nil && statusCode == 200 else {
                                        guard
                                            let resp = resp,
                                            resp.keys.contains("ErrorCode"),
                                            let errorCode = resp["ErrorCode"] as? Int
                                        else {
                                            self.loginError = .ServerError
                                            return
                                        }
                                        
                                        switch(errorCode) {
                                        case 0x53: /* MARK: "invalid_user"; AKA, user does not exist. */
                                            self.loginError = .InvalidUserError
                                            break
                                        case 0x54: /* MARK: "invalid_password". */
                                            self.loginError = .InvalidPasswordError
                                            break
                                        default:
                                            self.loginError = .ServerError
                                            break
                                        }
                                        
                                        return
                                    }
                                    
                                    /* MARK: If we are here, the response was good; ensure that all the required data exists in the response. */
                                    guard
                                        let resp = resp,
                                        resp.keys.contains("Username"),
                                        resp.keys.contains("AccountID"),
                                        resp.keys.contains("Email"),
                                        resp.keys.contains("Usecase")
                                    else {
                                        self.loginError = .ServerError /* MARK: Error in the response; not particularly related to invalid username/email or password. Prompt user to try again. */
                                        return
                                    }
                                    
                                    /* MARK: Depending on the usecase, check for the according data in the response. */
                                    switch(resp["Usecase"]! as! String) {
                                    case "school":
                                        guard
                                            resp.keys.contains("Major"),
                                            resp.keys.contains("Field"),
                                            resp.keys.contains("State"),
                                            resp.keys.contains("College")
                                        else {
                                            self.loginError = .ServerError
                                            return
                                        }
                                        
                                        assignUDKey(key: "major", value: resp["Major"]! as! String)
                                        assignUDKey(key: "major_field", value: resp["Field"]! as! String)
                                        assignUDKey(key: "state", value: resp["State"]! as! String)
                                        assignUDKey(key: "college", value: resp["College"]! as! String)
                                        break
                                    default: break
                                    }
                                    
                                    self.loginError = .None /* MARK: Ensure the `loginError` value is `.None` so no errors show. */
                                    
                                    assignUDKey(key: "username", value: resp["Username"]! as! String)
                                    self.accountInfo.setUsername(username: getUDValue(key: "username"))
                                    
                                    assignUDKey(key: "email", value: resp["Email"]! as! String)
                                    self.accountInfo.setEmail(email: getUDValue(key: "email"))
                                    
                                    assignUDKey(key: "account_id", value: resp["AccountID"]! as! String)
                                    self.accountInfo.setAccountID(accountID: getUDValue(key: "account_id"))
                                    
                                    /* MARK: Log user in. */
                                    assignUDKey(key: "logged_in", value: true)
                                    self.userHasSignedIn = true
                                    // self.setLoginStatus()
                                }
                            }) {
                                if !self.loggingIn {
                                    Text("Login")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                        .foregroundStyle(.black)
                                } else {
                                    LoadingView(tint: Color.EZNotesBlack)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(10)
                            .background(Color.EZNotesBlue)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom)
                            
                            Button(action: { }) {
                                Text("Having trouble signing in?")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundStyle(.gray)
                            }
                            
                            HStack {
                                if !udKeyExists(key: "usecase") { /* MARK: If this key exists, that means the user has started the sign up process. */
                                    Text("Don't have an account?")
                                        .frame(alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundStyle(.white)
                                }
                                
                                Button(action: {
                                    self.isLoggingIn = false
                                    
                                    self.signupSection = "hang_tight_screen" /* MARK: Show this screen by default while the app attempts to figure out where the user left off in the sign up process, if possible. */
                                    
                                    /* TODO: Depending on the last "state" of the sign up section, configure the view accordingly here. */
                                    if udKeyExists(key: "usecase") {
                                        /* MARK: Check to see if all of the credentials needed to create an account exists. */
                                        if !udKeyExists(key: "username") { self.signupSection = "credentials"; return }
                                        if !udKeyExists(key: "email") { self.signupSection = "credentials"; return }
                                        if !udKeyExists(key: "password") { self.signupSection = "credentials"; return }
                                        
                                        /* MARK: If all of the above keys exist, assign them just in case the user goes back to the "Credentials" view. */
                                        self.signupUsername = getUDValue(key: "username")
                                        self.signupEmail = getUDValue(key: "email")
                                        self.signupPassword = getUDValue(key: "password")
                                        
                                        /* MARK: Check the usecase. Depending, we will check what happens next. */
                                        if getUDValue(key: "usecase") == "school" {
                                            if !udKeyExists(key: "state") { self.signupSection = "select_state"; return }
                                            if !udKeyExists(key: "college") {
                                                /* MARK: Regenerate the array of colleges to be displayed. */
                                                RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(
                                                    State: getUDValue(key: "state")
                                                )).perform(action: get_colleges) { statusCode, resp in
                                                    self.loadingColleges = false
                                                    
                                                    guard
                                                        let resp = resp,
                                                        resp.keys.contains("Colleges"),
                                                        statusCode == 200
                                                    else {
                                                        self.signupError = .ServerError//self.error = .ServerError // self.serverError = true
                                                        return
                                                    }
                                                    
                                                    if let colleges = resp["Colleges"]! as? [String] {
                                                        for c in colleges {
                                                            if !self.colleges.contains(c) { self.colleges.append(c) }
                                                        }
                                                        
                                                        self.colleges.append("Other")
                                                        self.signupSection = "select_college"
                                                        return
                                                    }
                                                    
                                                    self.signupSection = "usecase"
                                                    self.signupError = .ServerError
                                                    return
                                                }
                                                
                                                return
                                            }
                                            if !udKeyExists(key: "major_field") {
                                                /* MARK: Regenerate all of the major fields to be displayed. */
                                                RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                    State: getUDValue(key: "state"),
                                                    College: getUDValue(key: "college")
                                                )).perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                    
                                                    //if let resp = resp { print(resp) }
                                                    guard
                                                        let resp = resp,
                                                        resp.keys.contains("Fields"),
                                                        statusCode == 200
                                                    else {
                                                        /*guard let resp = resp else {
                                                            self.signupSection = "usecase"
                                                            
                                                            self.signupError = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        guard resp.keys.contains("Message") else {
                                                            self.signupSection = "usecase"
                                                            
                                                            self.signupError = .ServerError // self.serverError = true
                                                            return
                                                        }*/
                                                        self.signupSection = "usecase"
                                                        
                                                        self.signupError = .ServerError // self.serverError = true
                                                        return
                                                        /*if resp["Message"] as! String == "no_such_college_in_state" {
                                                         self.signupError = .NoSuchCollege
                                                         return
                                                         }*/
                                                        
                                                        //self.signupError = .ServerError // self.serverError = true
                                                        //return
                                                    }
                                                    
                                                    if let fields = resp["Fields"]! as? [String] {
                                                        self.majorFields = fields
                                                        self.majorFields.append("Other")
                                                        
                                                        self.signupSection = "select_major_field"
                                                        return
                                                    }
                                                    
                                                    self.signupSection = "usecase"
                                                    self.signupError = .ServerError
                                                    return
                                                }
                                                
                                                return
                                            }
                                            if !udKeyExists(key: "major") {
                                                /* MARK: Regenerate all majors to be displayed. */
                                                RequestAction<GetMajorsRequestData>(
                                                    parameters: GetMajorsRequestData(
                                                        College: getUDValue(key: "college"),
                                                        MajorField: getUDValue(key: "major_field")
                                                    ))
                                                .perform(action: get_majors_req) { statusCode, resp in
                                                    
                                                    guard
                                                        let resp = resp,
                                                        resp.keys.contains("Majors"),
                                                        statusCode == 200
                                                    else {
                                                        self.signupSection = "usecase"
                                                        self.signupError = .ServerError
                                                        return
                                                    }
                                                    
                                                    if let majors = resp["Majors"]! as? [String] {
                                                        self.majors = majors
                                                        self.majors.append("Other")
                                                        self.signupSection = "select_major"
                                                        return
                                                    }
                                                    
                                                    self.signupSection = "usecase"
                                                    self.signupError = .ServerError
                                                    return
                                                }
                                                
                                                return
                                            }
                                        }
                                        
                                        if !udKeyExists(key: "account_id") {
                                            /* TODO: Resend email with code. Present the "Registering Account..." view. */
                                            RequestAction<SignUpRequestData>(
                                                parameters: SignUpRequestData(
                                                    Username: getUDValue(key: "username"),//username,
                                                    Email: getUDValue(key: "email"),//email,
                                                    Password: getUDValue(key: "password"),//password,
                                                    College: udKeyExists(key: "college") ? getUDValue(key: "college") : "N/A",//college,
                                                    State: udKeyExists(key: "state") ? getUDValue(key: "state") : "N/A",//state,
                                                    Field: udKeyExists(key: "major_field") ? getUDValue(key: "major_field") : "N/A",//majorField,
                                                    Major: udKeyExists(key: "major") ? getUDValue(key: "major") : "N/A",//major,
                                                    IP: getLocalIPAddress(),
                                                    Usecase: getUDValue(key: "usecase")
                                                )
                                            ).perform(action: complete_signup1_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    if let resp = resp {
                                                        if resp["ErrorCode"] as! Int == 0x6970 {
                                                            self.signupSection = "credentials"
                                                            self.userExists = true
                                                            return
                                                        }
                                                    }
                                                    
                                                    self.signupError = .ServerError // self.serverError = true
                                                    return
                                                }
                                                
                                                if self.userExists { self.userExists = false }
                                                //if self.makeContentRed { self.makeContentRed = false }
                                                
                                                assignUDKey(key: "account_id", value: resp!["Message"] as! String)
                                                
                                                self.signupSection = "code_input"
                                            }
                                            return
                                        } else {
                                            if udKeyExists(key: "selecting_plan") { self.signupSection = "select_plan"; return }
                                            self.signupSection = "code_input"
                                        }
                                    } else {
                                        self.signupSection = "usecase"
                                    }
                                }) {
                                    Text(!udKeyExists(key: "usecase") ? "Sign Up" : "Continue Sign-Up Process")
                                        .frame(alignment: .leading)
                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .underline()
                                }
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 3.5, height: 6.5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            
                            Spacer()
                        }
                        .onAppear {
                            /* MARK: If the key `selecting_plan` exists in `UserDefaults`, force the user back to the screen where they have to select a plan. */
                            if udKeyExists(key: "selecting_plan") {
                                self.isLoggingIn = false
                                self.signupSection = "select_plan"
                            }
                        }
                    } else {
                        if self.signupSection != "hang_tight_screen" {
                            Text(self.signupSection == "usecase"
                                 ? "Select Usage"
                                 : self.signupSection == "credentials"
                                 ? "Enter Your Credentials"
                                 : self.signupSection == "select_state"
                                 ? "Select State"
                                 : self.signupSection == "select_college"
                                 ? "Select College"
                                 : self.signupSection == "select_major_field"
                                 ? "Select Field of Study"
                                 : self.signupSection == "select_major"
                                 ? "Select Major"
                                 : self.signupSection == "code_input"
                                 ? "Enter Code"
                                 : self.signupSection == "select_plan"
                                 ? "Select Plan"
                                 : "Select Usage" /* MARK: Default. */)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 26 : 24))
                            .lineSpacing(1.5)
                            .foregroundStyle(.white)
                            .padding(.top, prop.isLargerScreen ? 16 : 0)
                            .padding(.bottom, self.signupSection != "select_state" &&
                                     self.signupSection != "select_college" &&
                                     self.signupSection != "select_major_field" &&
                                     self.signupSection != "select_major" &&
                                     (
                                        self.signupError != .ServerError &&
                                        self.signupError != .ErrorOccurred &&
                                        self.signupError != .ForceRestart
                                     )
                                     ?
                                        prop.isLargerScreen
                                            ? 32
                                            : 20
                                     : 0)
                        }
                        
                        if self.signupError == .ServerError || self.signupError == .ErrorOccurred || self.signupError == .ForceRestart {
                            Text(self.signupError == .ServerError
                                 ? "Something went wrong. Try again"
                                 : self.signupError == .ErrorOccurred
                                    ? "An error occurred. If the problem persists, contact us"
                                    : "Oh No! We lost track of your data in the midst of signing up. Try again. If the problem persists, contact us")
                                .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                .foregroundStyle(Color.EZNotesRed)
                                .font(
                                    .system(
                                        size: 13
                                    )
                                )
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        } else {
                            if self.signupSection == "code_input" {
                                Text("A code has been sent to \((getUDValue(key: "email")) as String)")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .center)
                                    .padding(.bottom, 5)
                                    .foregroundStyle(.white)
                                    .font(
                                        .system(
                                            size: 13
                                        )
                                    )
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                            }
                        }
                            
                        
                        switch(self.signupSection) {
                        case "usecase":
                            VStack {
                                Button(action: {
                                    assignUDKey(key: "usecase", value: "school")
                                    self.signupSection = "credentials"
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
                                    .padding(.all, prop.isLargerScreen ? 16 : 12)
                                    .padding(.horizontal, !prop.isLargerScreen ? 8 : 0) /* MARK: "Extend" the width of the "card" on smaller screens since the overall padding around the content is smaller. */
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack)
                                    )
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Button(action: {
                                    assignUDKey(key: "usecase", value: "work")
                                    self.signupSection = "credentials"
                                }) {
                                    HStack {
                                        VStack {
                                            Text("Work")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 24 : 20))
                                                .foregroundStyle(.white)
                                            
                                            Text("Tailored to your work needs.")
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
                                    .padding(.all, prop.isLargerScreen ? 16 : 12)//.padding()
                                    .padding(.horizontal, !prop.isLargerScreen ? 8 : 0) /* MARK: "Extend" the width of the "card" on smaller screens since the overall padding around the content is smaller. */
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack)
                                    )
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Button(action: {
                                    assignUDKey(key: "usecase", value: "general")
                                    self.signupSection = "credentials"
                                }) {
                                    HStack {
                                        VStack {
                                            Text("General")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 24 : 20))
                                                .foregroundStyle(.white)
                                            
                                            Text("Tailord to your everyday needs.")
                                                .lineLimit(1...2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                .foregroundStyle(.white)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                        .padding([.top, .bottom])
                                        
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .frame(width: 10, height: 20)
                                            .foregroundStyle(.white)
                                            .padding(.trailing, 10)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .padding(prop.isLargerScreen ? 16 : 12)//.padding()
                                    .padding(.horizontal, !prop.isLargerScreen ? 8 : 0) /* MARK: "Extend" the width of the "card" on smaller screens since the overall padding around the content is smaller. */
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack)
                                    )
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "credentials":
                            VStack {
                                TextField("", text: $signupUsername)
                                    .frame(width: prop.size.width - 70)
                                    .padding(.vertical, 6.5)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .borderBottomWLColor(isError: self.signupError == .TooShortUsername || self.signupError == .UserExists, width: 0.5)
                                    )
                                    .overlay(
                                        HStack {
                                            if self.signupUsername.isEmpty && !self.signupUsernameFieldInFocus {
                                                Text(self.signupUsername.isEmpty ? "Username..." : "")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .bold
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 10)
                                                    .onTapGesture { self.signupUsernameFieldInFocus = true }
                                                Spacer()
                                            } else {
                                                if self.signupUsername.isEmpty {
                                                    Text(self.signupUsername.isEmpty ? "Username..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 15,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupUsernameFieldInFocus = true }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    //.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .focused($signupUsernameFieldInFocus)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                
                                if self.signupError == .TooShortUsername || self.signupError == .UserExists {
                                    Text(self.signupError == .TooShortUsername
                                         ? "Username is too short. Must be 4 characters or longer"
                                         : "Username already exists")
                                    .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                    .padding(.bottom, 5)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(
                                        .system(
                                            size: 13
                                        )
                                    )
                                    .fontWeight(.medium)
                                }
                                
                                TextField("", text: $signupEmail)
                                    .frame(width: prop.size.width - 70)
                                    .padding(.vertical, 6.5)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .borderBottomWLColor(isError: self.signupError == .InvalidEmail || self.signupError == .EmailExists, width: 0.5)
                                    )
                                    .overlay(
                                        HStack {
                                            if self.signupEmail.isEmpty && !self.signupEmailFieldInFocus {
                                                Text(self.signupEmail.isEmpty ? "Email..." : "")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .bold
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 10)
                                                    .onTapGesture { self.signupEmailFieldInFocus = true }
                                                Spacer()
                                            } else {
                                                if self.signupEmail.isEmpty {
                                                    Text(self.signupEmail.isEmpty ? "Email..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 15,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupEmailFieldInFocus = true }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .focused($signupEmailFieldInFocus)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .padding(.vertical, (self.signupError != .InvalidEmail && self.signupError != .EmailExists) && (self.signupError != .TooShortUsername && self.signupError != .UserExists) ? 16 : 0)
                                    .padding(.bottom, self.signupError == .TooShortUsername || self.signupError == .UserExists ? 16 : 0)
                                
                                if self.signupError == .InvalidEmail || self.signupError == .EmailExists {
                                    Text(self.signupError == .InvalidEmail
                                         ? "Invalid email"
                                         : "Email is already in use")
                                    .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                    .padding(.bottom, 5)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(
                                        .system(
                                            size: 13
                                        )
                                    )
                                    .fontWeight(.medium)
                                }
                                
                                SecureField("", text: $signupPassword)
                                    .frame(width: prop.size.width - 70)
                                    .padding(.vertical, 6.5)
                                    .background(
                                        Rectangle()//RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .borderBottomWLColor(isError: self.signupError == .TooShortPassword, width: 0.5)
                                    )
                                    .overlay(
                                        HStack {
                                            if self.signupPassword.isEmpty && !self.signupPasswordFieldInFocus {
                                                Text("Password...")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .bold
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 10)
                                                    .onTapGesture { self.signupPasswordFieldInFocus = true }
                                                Spacer()
                                            } else {
                                                if self.signupPassword.isEmpty {
                                                    Text("Password...")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 15,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupPasswordFieldInFocus = true }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                    .tint(Color.EZNotesBlue)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .focused($signupPasswordFieldInFocus)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.alphabet)
                                    .padding(.bottom)
                                
                                if self.signupError == .TooShortPassword {
                                    Text("Password is too short. It must be 8 characters or longer")
                                        .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                        .padding(.bottom, 5)
                                        .foregroundStyle(Color.EZNotesRed)
                                        .font(
                                            .system(
                                                size: 13
                                            )
                                        )
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_state":
                            VStack {
                                LazyVGridScrollViewForArray(
                                    config: LazyVGridScrollViewConfiguration(
                                        lazyVGridColumns: self.stateColumns
                                    ),
                                    data: self.states
                                ) { value in
                                    Button(action: {
                                        assignUDKey(key: "state", value: value)
                                        
                                        self.signupSection = "hang_tight_screen"
                                        
                                        /* MARK: Before going onto the next step of the signup process (selecting a college), we need to generate a list of colleges for the user to choose from. */
                                        RequestAction<GetCollegesRequestData>(
                                            parameters: GetCollegesRequestData(
                                                State: value
                                            )
                                        ).perform(action: get_colleges) { statusCode, resp in
                                            guard
                                                let resp = resp,
                                                resp.keys.contains("Colleges"),
                                                statusCode == 200
                                            else {
                                                if let resp = resp { print(resp) }
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            if let colleges = resp["Colleges"]! as? [String] {
                                                self.colleges = colleges
                                                
                                                self.signupSection = "select_college" /* MARK: The next view to show after selecting the state is the "Select College" view. */
                                                return
                                            }
                                            
                                            self.signupError = .ServerError
                                            return
                                        }
                                    }) {
                                        HStack {
                                            Text(value)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding([.leading, .top, .bottom], 5)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                .fontWeight(.bold)
                                                .minimumScaleFactor(0.8)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(prop.isLargerScreen ? 10 : 8) /* MARK: Make the "cards" slightly smaller for smaller screens. */
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                    .shadow(color: Color.black, radius: 1.5)
                                        )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 8)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_college":
                            VStack {
                                LazyVGridScrollViewForArray(
                                    data: self.colleges
                                ) { value in
                                    Button(action: {
                                        assignUDKey(key: "college", value: value)
                                        
                                        self.signupSection = "hang_tight_screen"
                                        
                                        /* MARK: Get major fields for the college that the user has selected. */
                                        RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                            State: getUDValue(key: "state"), /* MARK: If we are in this view, "state" should exist in `UserDefaults`. */
                                            College: value
                                        ))
                                        .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                            guard
                                                let resp = resp,
                                                resp.keys.contains("Fields"),
                                                statusCode == 200
                                            else {
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            if let majorFields = resp["Fields"]! as? [String] {
                                                self.majorFields = majorFields
                                                
                                                self.signupSection = "select_major_field"
                                                return
                                            }
                                            
                                            self.signupError = .ServerError
                                            return
                                        }
                                    }) {
                                        HStack {
                                            Text(value)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding([.leading, .top, .bottom], 5)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                .fontWeight(.bold)
                                                .minimumScaleFactor(0.6)
                                                .multilineTextAlignment(.leading)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)
                                            }
                                            .frame(maxWidth: 20, alignment: .trailing)
                                            .foregroundStyle(.gray)
                                            .padding(.trailing, 10)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(prop.isLargerScreen ? 10 : 8) /* MARK: Make the "cards" slightly smaller for smaller screens. */
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                    .shadow(color: Color.black, radius: 1.5)
                                        )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 8)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_major_field":
                            VStack {
                                LazyVGridScrollViewForArray(
                                    data: self.majorFields
                                ) { value in
                                    Button(action: {
                                        assignUDKey(key: "major_field", value: value)
                                        
                                        self.signupSection = "hang_tight_screen"
                                        
                                        /* MARK: Generate majors for the major field selected. */
                                        RequestAction<GetMajorsRequestData>(parameters: GetMajorsRequestData(
                                            College: getUDValue(key: "college"),
                                            MajorField: value
                                        )).perform(action: get_majors_req) { statusCode, resp in
                                            guard
                                                let resp = resp,
                                                let majors = resp["Majors"] as? [String],
                                                statusCode == 200
                                            else {
                                                self.signupSection = "select_major_field"
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            self.majors = majors
                                            self.majors.append("Other")
                                            
                                            self.signupSection = "select_major"
                                            return
                                        }
                                    }) {
                                        HStack {
                                            Text(value)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding([.leading, .top, .bottom], 5)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                .fontWeight(.bold)
                                                .minimumScaleFactor(0.6)
                                                .multilineTextAlignment(.leading)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)
                                            }
                                            .frame(maxWidth: 20, alignment: .trailing)
                                            .foregroundStyle(.gray)
                                            .padding(.trailing, 10)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(prop.isLargerScreen ? 10 : 8) /* MARK: Make the "cards" slightly smaller for smaller screens. */
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                    .shadow(color: Color.black, radius: 1.5)
                                        )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 8)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_major":
                            VStack {
                                LazyVGridScrollViewForArray(data: self.majors) { value in
                                    Button(action: {
                                        assignUDKey(key: "major", value: value)
                                        
                                        self.signupSection = "hang_tight_screen"
                                        
                                        RequestAction<SignUpRequestData>(parameters: SignUpRequestData(
                                            Username: self.signupUsername,
                                            Email: self.signupEmail,
                                            Password: self.signupPassword,
                                            College: getUDValue(key: "college"),
                                            State: getUDValue(key: "state"),
                                            Field: getUDValue(key: "major_field"),
                                            Major: getUDValue(key: "major"),
                                            IP: getLocalIPAddress(),
                                            Usecase: getUDValue(key: "usecase")
                                        )).perform(action: complete_signup1_req) { statusCode, resp in
                                            guard
                                                let resp = resp,
                                                statusCode == 200
                                            else {
                                                self.signupSection = "select_major" /* MARK: Simply go to the "last" section if an error occurred. */
                                                
                                                if
                                                    let resp = resp,
                                                    let errorCode = resp["ErrorCode"]! as? Int
                                                {
                                                    if errorCode == 0x6970 {
                                                        self.signupError = .UserExists
                                                        return
                                                    }
                                                    
                                                    if errorCode == 0x7877 {
                                                        self.signupError = .InvalidEmail
                                                        return
                                                    }
                                                    
                                                    if errorCode == 0x6979 {
                                                        self.signupError = .EmailExists
                                                        return
                                                    }
                                                }
                                                
                                                /* TODO: I believe the "ErrorCode" value in `resp` entails what went wrong in the request. One of the codes will enable us to decipher whether the user/email exists. */
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            guard
                                                resp.keys.contains("Message"),
                                                let accountId = resp["Message"]! as? String
                                            else {
                                                self.signupSection = "select_major"
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            assignUDKey(key: "account_id", value: accountId)
                                            
                                            /* MARK: Redirect user to put in a code that was sent to their email. */
                                            self.signupSection = "code_input"
                                            
                                            return
                                        }
                                    }) {
                                        HStack {
                                            Text(value)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding([.leading, .top, .bottom], 5)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                .fontWeight(.bold)
                                                .minimumScaleFactor(0.6)
                                                .multilineTextAlignment(.leading)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)
                                            }
                                            .frame(maxWidth: 20, alignment: .trailing)
                                            .foregroundStyle(.gray)
                                            .padding(.trailing, 10)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(prop.isLargerScreen ? 10 : 8) /* MARK: Make the "cards" slightly smaller for smaller screens. */
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                    .shadow(color: Color.black, radius: 1.5)
                                        )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 8)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "code_input":
                            VStack {
                                TextField("", text: $signupConfirmCode)
                                .frame(width: prop.size.width - 70)
                                .padding(.vertical, 6.5)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .borderBottomWLColor(isError: self.signupError == .WrongCode, width: 0.5)
                                )
                                .overlay(
                                    HStack {
                                        if self.signupConfirmCode.isEmpty && !self.signupConfirmCodeFieldInFocus {
                                            Text(self.signupConfirmCode.isEmpty ? "Code..." : "")
                                                .font(
                                                    .system(
                                                        size: prop.isLargerScreen ? 18 : 15,
                                                        weight: .bold
                                                    )
                                                )
                                                .foregroundStyle(Color(.systemGray2))
                                                .padding(.leading, 10)
                                                .onTapGesture { self.signupConfirmCodeFieldInFocus = true }
                                            Spacer()
                                        } else {
                                            if self.signupConfirmCode.isEmpty {
                                                Text(self.signupConfirmCode.isEmpty ? "Code..." : "")
                                                    .font(
                                                        .system(
                                                            size: prop.isLargerScreen ? 18 : 15,
                                                            weight: .bold
                                                        )
                                                    )
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .padding(.leading, 10)
                                                    .onTapGesture { self.signupConfirmCodeFieldInFocus = true }
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                //.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .focused($signupConfirmCodeFieldInFocus)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                                .padding(.top) /* MARK: Add padding to the top to ensure spacing between "A code has been sent to <email>" and the textfield. */
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_plan":
                            VStack {
                                Plans(
                                    prop: prop,
                                    email: getUDValue(key: "email"),
                                    accountID: getUDValue(key: "account_id"),
                                    isLargerScreen: prop.isLargerScreen,
                                    action: {
                                        self.userHasSignedIn = true
                                        assignUDKey(key: "logged_in", value: true)
                                        removeUDKey(key: "selecting_plan") /* MARK: Ensure `selecting_plan` gets removed from `UserDefaults` as it is no longer needed. */
                                    }
                                )
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "registering_account": /* MARK: Nothing more than a loading screen. */
                            VStack {
                                Spacer()
                                
                                LoadingView(message: "Registering your account...")
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case "hang_tight_screen":
                            VStack {
                                LoadingView(message: "Hang Tight...")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(.title2)
                        default: VStack { }.onAppear { self.signupSection = "usecase" }
                        }
                        
                        Spacer()
                        
                        if (self.signupSection == "credentials" || self.signupSection == "code_input") && (self.signupSection != "hang_tight_screen" && self.signupSection != "select_plan") {
                            Button(action: {
                                switch(self.signupSection) {
                                case "credentials":
                                    self.signupSection = "hang_tight_screen"
                                    
                                    if self.signupUsername.isEmpty || self.signupUsername.count < 4 {
                                        setSignupErrorAndSection(error: .TooShortUsername, section: "credentials")
                                        return
                                    }
                                    
                                    /* MARK: Ensure the username does not exist in the database. */
                                    RequestAction<CheckUsernameRequestData>(parameters: CheckUsernameRequestData(
                                        Username: self.signupUsername
                                    )).perform(action: check_username_req) { statusCode, resp in
                                        if statusCode != 200 {
                                            setSignupErrorAndSection(error: .UserExists, section: "credentials")
                                            self.signupUsernameFieldInFocus = true /* MARK: Force username textfield into focus. */
                                            return
                                        }
                                        
                                        /* MARK: If the username does not exist, proceed with checking the email. */
                                        if self.signupEmail.isEmpty || !self.signupEmail.contains("@") {
                                            setSignupErrorAndSection(error: .InvalidEmail, section: "credentials")
                                            self.signupEmailFieldInFocus = true /* MARK: Force email textfield into focus. */
                                            return
                                        }
                                        
                                        let emailSegments = self.signupEmail.split(separator: "@")
                                        
                                        if let domainSegments = emailSegments.last?.split(separator: ".") {
                                            if !["org", "com", "gov", "net"].contains(domainSegments.last!) {
                                                setSignupErrorAndSection(error: .InvalidEmail, section: "credentials")
                                                self.signupEmailFieldInFocus = true /* MARK: Force email textfield into focus. */
                                                return
                                            }
                                        } else {
                                            setSignupErrorAndSection(error: .InvalidEmail, section: "credentials")
                                            self.signupEmailFieldInFocus = true /* MARK: Force email textfield into focus. */
                                            return
                                        }
                                        
                                        /* MARK: Ensure the email does not exist in the database. */
                                        RequestAction<CheckEmailRequestData>(parameters: CheckEmailRequestData(
                                            Email: self.signupEmail
                                        )).perform(action: check_email_req) { statusCode, resp in
                                            if statusCode != 200 {
                                                setSignupErrorAndSection(error: .EmailExists, section: "credentials")
                                                self.signupEmailFieldInFocus = true /* MARK: Force email textfield into focus. */
                                                return
                                            }
                                            
                                            /* MARK: If the email does not exist, proceed with checking the password. */
                                            if self.signupPassword.isEmpty || self.signupPassword.count < 8 {
                                                setSignupErrorAndSection(error: .TooShortPassword, section: "credentials")
                                                self.signupPasswordFieldInFocus = true /* MARK: Force password textfield into focus. */
                                                return
                                            }
                                            
                                            /* MARK: If the password prerequisites check out, proceed with figuring out what to do next after credentials based on the users selected usecase. */
                                            
                                            /* MARK: If all above checks succeed, save the credentials to `UserDefaults`. */
                                            assignUDKey(key: "username", value: self.signupUsername)
                                            assignUDKey(key: "email", value: self.signupEmail)
                                            assignUDKey(key: "password", value: self.signupPassword)
                                            
                                            if getUDValue(key: "usecase") != "school" {
                                                /* MARK: If the usecase is not school, go ahead and send a request to the server to register the account. There is no further information needed. If the usecase is school, then we will prompt the user to select their state, college, major field and major. */
                                                RequestAction<SignUpRequestData>(parameters: SignUpRequestData(
                                                    Username: self.signupUsername,
                                                    Email: self.signupEmail,
                                                    Password: self.signupPassword,
                                                    College: "N/A",
                                                    State: "N/A",
                                                    Field: "N/A",
                                                    Major: "N/A",
                                                    IP: getLocalIPAddress(),
                                                    Usecase: getUDValue(key: "usecase")
                                                )).perform(action: complete_signup1_req) { statusCode, resp in
                                                    guard
                                                        let resp = resp,
                                                        statusCode == 200
                                                    else {
                                                        if
                                                            let resp = resp,
                                                            let errorCode = resp["ErrorCode"]! as? Int
                                                        {
                                                            /*if errorCode == 0x6970 {
                                                                setSignupErrorAndSection(error: .UserExists, section: "credentials")
                                                                self.signupError = .UserExists
                                                                return
                                                            }*/
                                                            
                                                            if errorCode == 0x7877 {
                                                                setSignupErrorAndSection(error: .InvalidEmail, section: "credentials")
                                                                self.signupEmailFieldInFocus = true /* MARK: Force email textfield into focus. */
                                                                return
                                                            }
                                                            
                                                            /*if errorCode == 0x6979 {
                                                                self.signupError = .EmailExists
                                                                return
                                                            }*/
                                                        }
                                                        
                                                        /* TODO: I believe the "ErrorCode" value in `resp` entails what went wrong in the request. One of the codes will enable us to decipher whether the user/email exists. */
                                                        setSignupErrorAndSection(error: .ServerError, section: "credentials")
                                                        return
                                                    }
                                                    
                                                    guard
                                                        resp.keys.contains("Message"),
                                                        let accountId = resp["Message"]! as? String
                                                    else {
                                                        setSignupErrorAndSection(error: .ServerError, section: "credentials")
                                                        return
                                                    }
                                                    
                                                    assignUDKey(key: "account_id", value: accountId)
                                                    
                                                    /* MARK: Redirect user to put in a code that was sent to their email. */
                                                    setSignupErrorAndSection(error: .None, section: "code_input")
                                                    
                                                    return
                                                }
                                                
                                                return
                                            } else {
                                                setSignupErrorAndSection(section: "select_state")
                                            }
                                        }
                                    }
                                    
                                    break
                                case "code_input":
                                    self.signupSection = "registering_account"
                                    
                                    RequestAction<SignUp2RequestData>(parameters: SignUp2RequestData(
                                        AccountID: getUDValue(key: "account_id"),
                                        UserInputtedCode: self.signupConfirmCode
                                    )).perform(action: complete_signup2_req) { statusCode, resp in
                                        /* TODO: Check "ErrorCode" value in `resp` to see what exactly went wrong instead of just assuming the code is wrong. */
                                        guard
                                            statusCode == 200
                                        else {
                                            setSignupErrorAndSection(error: .WrongCode, section: "code_input") /* MARK: Ensure we "go back" to the last section if the code is wrong */
                                            return
                                        }
                                        
                                        setSignupErrorAndSection(section: "select_plan")
                                        assignUDKey(key: "selecting_plan", value: true) /* MARK: Needed as there is no other way to track whether the user left the app selecting a plan or not. */
                                    }
                                default: break
                                }
                            }) {
                                Text("Continue")
                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.EZNotesOrange)
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        
                        if self.signupSection != "hang_tight_screen" && self.signupSection != "select_plan" {
                            Button(action: {
                                /* MARK: Ensure errors are cleared out if the user goes back. */
                                if self.signupError != .None { self.signupError = .None }
                                
                                switch(self.signupSection) {
                                case "usecase":
                                    self.isLoggingIn = true
                                    break
                                case "credentials":
                                    self.signupSection = "usecase"
                                    break
                                case "select_state":
                                    self.signupSection = "credentials"
                                    break
                                case "select_college":
                                    self.signupSection = "select_state"
                                    break
                                case "select_major_field":
                                    self.signupSection = "hang_tight_screen"
                                    
                                    /* MARK: Check if `colleges` array is empty. If it is, we need to populate it before "going back". */
                                    if self.colleges.isEmpty {
                                        RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(
                                            State: getUDValue(key: "state")
                                        )).perform(action: get_colleges) { statusCode, resp in
                                            self.loadingColleges = false
                                            
                                            guard
                                                let resp = resp,
                                                resp.keys.contains("Colleges"),
                                                statusCode == 200
                                            else {
                                                setSignupErrorAndSection(error: .ServerError, section: "select_major_field")
                                                return
                                            }
                                            
                                            if let colleges = resp["Colleges"]! as? [String] {
                                                for c in colleges {
                                                    if !self.colleges.contains(c) { self.colleges.append(c) }
                                                }
                                                
                                                self.colleges.append("Other")
                                                return
                                            }
                                            
                                            setSignupErrorAndSection(error: .ServerError, section: "select_major_field")
                                            return
                                        }
                                    }
                                    
                                    self.signupSection = "select_college"
                                    break
                                case "select_major":
                                    self.signupSection = "select_major_field"
                                    break
                                case "code_input":
                                    self.signupSection = "hang_tight_screen"
                                    
                                    /* MARK: Ensure we delete the temporary account data in the server because, by going back, new account data is generated. */
                                    RequestAction<DeleteSignupProcessData>(parameters: DeleteSignupProcessData(
                                        AccountID: getUDValue(key: "account_id")
                                    )).perform(action: delete_signup_process_req) { statusCode, resp in
                                        guard
                                            statusCode == 200
                                        else {
                                            guard
                                                let resp = resp,
                                                resp.keys.contains("ErrorCode"),
                                                let errorCode = resp["ErrorCode"] as? Int
                                            else {
                                                setSignupErrorAndSection(error: .ErrorOccurred, section: "usecase")
                                                return
                                            }
                                            
                                            setSignupErrorAndSection(error: .ForceRestart, section: "usecase")
                                            
                                            if errorCode != 0x0223 {
                                                /* MARK: If the error code is not 0x0223, then there was an error. Else, the users account data wasn't found for some reason so the app will force them to restart*/
                                                self.signupError = .ErrorOccurred
                                            }
                                            
                                            return
                                        }
                                        
                                        if getUDValue(key: "usecase") == "school" { self.signupSection = "select_major"; return }
                                        
                                        setSignupErrorAndSection(section: "credentials")
                                        return
                                    }
                                    
                                    break
                                default: break
                                }
                            }) {
                                Text("Go Back")
                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.EZNotesBlue)
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(.bottom, prop.isLargerScreen ? 30 : 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard, edges: .all) /* MARK: Ensure the overall view doesn't move with the keyboard. */
                .background(
                    Image("Background")
                )
                .ignoresSafeArea(.keyboard, edges: .all) /* MARK: Ensure the background doesn't move with the keyboard. */
                .background(.primary)
            }
            //.ignoresSafeArea(.keyboard, edges: .bottom)
            /*StartupScreen(
                userHasSignedIn: $userHasSignedIn,
                userNotFound: $userNotFound,
                goBackToLogin: $goBackToLogin//,
                //faceIDAuthenticated: $faceIDAuthenticated
            )
            /*.onChange(of: self.networkMonitor.isConnectedToWiFi) {
                if !self.networkMonitor.isConnectedToWiFi {
                    if !self.networkMonitor.isConnectedToCellular {
                        self.needsNoWifiBanner = true
                        return
                    }
                    
                    if self.needsNoWifiBanner { self.needsNoWifiBanner = false }
                }
                
                if self.needsNoWifiBanner { self.needsNoWifiBanner = false }
            }
            .onChange(of: self.networkMonitor.isConnectedToCellular) {
                if !self.networkMonitor.isConnectedToCellular {
                    if !self.networkMonitor.isConnectedToWiFi {
                        self.needsNoWifiBanner = true
                        return
                    }
                    
                    if self.needsNoWifiBanner { self.needsNoWifiBanner = false }
                }
                if self.needsNoWifiBanner { self.needsNoWifiBanner = false }
            }*/
            .onAppear(perform: {
                if UserDefaults.standard.object(forKey: "faceID_enabled") == nil {
                    UserDefaults.standard.set("not_enabled", forKey: "faceID_enabled")
                    UserDefaults.standard.set(false, forKey: "faceID_initialized")
                }
            })*/
        } else {
            ResponsiveView { prop in
                VStack {
                    switch(self.section) {
                    case "upload":
                        //ResponsiveView { prop in
                        UploadSection(
                            model: self.model,
                            images_to_upload: self.images_to_upload,
                            topBanner: $topBanner,
                            lastSection: $lastSection,
                            section: $section,
                            prop: prop,
                            userHasSignedIn: $userHasSignedIn
                        )
                        .onAppear {
                            self.model.startSession()
                        }
                        .onDisappear {
                            self.model.stopSession()
                        }
                    case "home":
                        HomeView(
                            section: $section,
                            prop: prop,
                            userHasSignedIn:$userHasSignedIn,
                            model: self.model//,
                            //images_to_upload: self.images_to_upload
                        )
                    case "upload_review":
                        UploadReview(
                            images_to_upload: self.images_to_upload,
                            topBanner: $topBanner,
                            localUpload: $localUpload,
                            createOneCategory: $createOneCategory,
                            section: $section,
                            lastSection: $lastSection,
                            errorType: $errorType,
                            prop: prop
                        )
                    case "chat":
                        ChatView(section: $section, userHasSignedIn: $userHasSignedIn)
                    default: VStack { }.onAppear { self.section = "upload" }
                    }
                    
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .inactive || scenePhase == .background {
                        UserDefaults.standard.set(true, forKey: "requires_faceID")
                    }
                }
                /*.task {
                    RequestAction<GetClientsFriendsData>(parameters: GetClientsFriendsData(
                        AccountId: self.accountInfo.accountID
                    )).perform(action: get_clients_friends_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            return
                        }
                        
                        if let resp = resp as? [String: [String: Any]] {
                            for user in resp.keys {
                                guard resp[user] != nil else { continue }
                                
                                if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                    if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                        self.accountInfo.friends[user] = Image(
                                            uiImage: UIImage(
                                                data: userPFPData
                                            )!
                                        )
                                    } else {
                                        self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                    }
                                } else {
                                    self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                }
                            }
                        }
                    }
                    //}
                    
                    //DispatchQueue.global(qos: .background).async {
                    
                }*/
                .onChange(of: self.scenePhase) {
                    if self.scenePhase == .active {
                        Task {
                            //if self.accountInfo.friends.isEmpty {
                            await self.accountInfo.getFriends(accountID: self.accountInfo.accountID) { statusCode, resp in
                                guard resp != nil && statusCode == 200 else {
                                    return
                                }
                                
                                if let resp = resp as? [String: [String: Any]] {
                                    for user in resp.keys {
                                        guard resp[user] != nil else { continue }
                                        
                                        if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                            if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                                self.accountInfo.friends[user] = Image(
                                                    uiImage: UIImage(
                                                        data: userPFPData
                                                    )!
                                                )
                                            } else {
                                                self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                            }
                                        } else {
                                            self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                        }
                                    }
                                }
                                
                                if !self.accountInfo.friends.isEmpty {
                                    RequestAction<GetClientsMessagesData>(parameters: GetClientsMessagesData(
                                        AccountId: self.accountInfo.accountID
                                    )).perform(action: get_clients_messages_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            if let resp = resp { print(resp) }
                                            return
                                        }
                                        
                                        if let resp = resp as? [String: Array<[String: String]>] {
                                            resp.keys.forEach { user in
                                                if let friendImage = self.accountInfo.friends[user] {
                                                    self.accountInfo.allChats.append([user: friendImage])
                                                } else {
                                                    self.accountInfo.allChats.append([user: Image(systemName: "person.crop.circle.fill")])
                                                }
                                                
                                                /* MARK: Automatically assume there is no chat history with `user`. */
                                                if !self.accountInfo.messages.keys.contains(user) {
                                                    self.accountInfo.messages[user] = []
                                                }
                                                
                                                if !resp[user]!.isEmpty {
                                                    
                                                    resp[user]!.forEach { message in
                                                        let messageData = FriendMessageDetails(
                                                            MessageID: message["MessageID"]!,
                                                            ContentType: message["ContentType"]!,
                                                            MessageContent: message["MessageContent"]!,
                                                            From: message["From"]!,
                                                            dateSent: ISO8601DateFormatter().date(from: message["dateSent"]!)!
                                                        )
                                                        
                                                        if !self.accountInfo.messages[user]!.contains(where: { $0.MessageID == messageData.MessageID }) {
                                                            self.accountInfo.messages[user]!.append(messageData)
                                                        }
                                                    }
                                                    
                                                    /*if let messageHistoryWithUser = resp[user]! as? Array<FriendMessageDetails> {
                                                     print(messageHistoryWithUser)
                                                     /*messageHistoryWithUser.forEach { message in
                                                      self.accountInfo.messages[user]!.append(message)
                                                      }*/
                                                     }*/
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            //}
                        }
                    }
                }
                .onAppear(perform: { /* MARK: The below code is placed in the `.onAppear`, regardless if the user logged in, signed up or just re-launched the app. All of the users data, unless further noticed, will be stored in `UserDefaults`. */
                    // else {
                    //Task {
                        /* TODO: If the below request fails, we need to figure out a way to ensure that the user still gets into the app. */
                        RequestAction<ReqPlaceholder>(
                            parameters: ReqPlaceholder()
                        )
                        .perform(action: check_server_active_req) { statusCode, resp in
                            guard resp != nil && statusCode == 200 else {
                                self.topBanner = .NetworkCheckFailure
                                return
                            }
                            
                            /* MARK: First, check to see if `account_id` exists in `UserDefaults`. If it doesn't, something went wrong. */
                            if !udKeyExists(key: "account_id") {
                                self.userHasSignedIn = false
                                self.userNotFound = true
                                assignUDKey(key: "logged_in", value: false)
                                return
                            }
                            
                            self.accountInfo.setAccountID(accountID: getUDValue(key: "account_id"))
                            
                            /* MARK: If all is well, check to see if `username` is in `UserDefaults`. If it isn't, force user to homescreen and display "User Not Found" error, forcing user to log back in. If it is, double check that the username exists in the database. */
                            if !udKeyExists(key: "username") {
                                self.userHasSignedIn = false
                                self.userNotFound = true
                                assignUDKey(key: "logged_in", value: false)
                                return
                            }
                            
                            RequestAction<CheckUsernameRequestData>(parameters: CheckUsernameRequestData(
                                Username: getUDValue(key: "username")
                            )).perform(action: check_username_req) { statusCode, resp in
                                /* MARK: If `statusCode` is not 200, that means the username exists otherwise it does not. If it does not, we need to throw an error. */
                                if statusCode == 200 {
                                    self.userHasSignedIn = false
                                    self.userNotFound = true
                                    assignUDKey(key: "logged_in", value: false)
                                    return
                                }
                                
                                /* MARK: If all is well, get the value of `username` in `UserDefaults` and assign it to `username` in `accountInfo`. */
                                self.accountInfo.setUsername(username: getUDValue(key: "username"))
                                
                                if udKeyExists(key: "usecase") {
                                    self.accountInfo.setUsage(usage: getUDValue(key: "usecase"))
                                }
                                
                                if udKeyExists(key: "email") {
                                    self.accountInfo.setEmail(email: getUDValue(key: "email"))
                                }
                                
                                if udKeyExists(key: "college") {
                                    self.accountInfo.setCollegeName(collegeName: getUDValue(key: "college"))
                                }
                                
                                if udKeyExists(key: "major") {
                                    self.accountInfo.setMajorName(majorName: getUDValue(key: "major"))
                                }
                                
                                if udKeyExists(key: "major_field") {
                                    self.accountInfo.setMajorField(field: getUDValue(key: "major_field"))
                                }
                                
                                if udKeyExists(key: "state") {
                                    self.accountInfo.setCollegeState(collegeState: getUDValue(key: "state"))
                                }
                                
                                PFP(accountID: self.accountInfo.accountID)
                                    .requestGetPFP() { statusCode, pfp, resp in
                                        guard pfp != nil && statusCode == 200 else {
                                            guard resp != nil else { return }
                                            
                                            /* MARK: If `ErrorCode` is 0x6966 means the user was not found in the database. */
                                            if resp!["ErrorCode"] as! Int == 0x6966 {
                                                /* MARK: If the error code is `0x6966`, remove all the data over the user from `UserDefaults`, ensure the "User Not Found" banner will show and "redirect" the user back to the home screen. */
                                                udRemoveAllAccountInfoKeys()
                                                
                                                self.userHasSignedIn = false
                                                self.userNotFound = true
                                            }
                                            
                                            return
                                        }
                                        
                                        accountInfo.setProfilePicture(pfp: UIImage(data: pfp!)!)
                                    }
                                //}
                                
                                //DispatchQueue.global(qos: .background).async {
                                PFP(accountID: self.accountInfo.accountID)
                                    .requestGetPFPBg() { statusCode, pfp_bg in
                                        guard pfp_bg != nil && statusCode == 200 else { return }
                                        
                                        accountInfo.setProfilePictureBackground(bg: UIImage(data: pfp_bg!)!)
                                    }
                                
                                /* MARK: I do not believe we need to use `Task` here. */
                                Task {
                                    //if self.accountInfo.friends.isEmpty {
                                    await self.accountInfo.getFriends(accountID: self.accountInfo.accountID) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            return
                                        }
                                        
                                        if let resp = resp as? [String: [String: Any]] {
                                            for user in resp.keys {
                                                guard resp[user] != nil else { continue }
                                                
                                                if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                                    if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                                        self.accountInfo.friends[user] = Image(
                                                            uiImage: UIImage(
                                                                data: userPFPData
                                                            )!
                                                        )
                                                    } else {
                                                        self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                                    }
                                                } else {
                                                    self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                                }
                                            }
                                        }
                                        
                                        if !self.accountInfo.friends.isEmpty {
                                            RequestAction<GetClientsMessagesData>(parameters: GetClientsMessagesData(
                                                AccountId: self.accountInfo.accountID
                                            )).perform(action: get_clients_messages_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    if let resp = resp { print(resp) }
                                                    return
                                                }
                                                
                                                if let resp = resp as? [String: Array<[String: String]>] {
                                                    resp.keys.forEach { user in
                                                        if let friendImage = self.accountInfo.friends[user] {
                                                            self.accountInfo.allChats.append([user: friendImage])
                                                        } else {
                                                            self.accountInfo.allChats.append([user: Image(systemName: "person.crop.circle.fill")])
                                                        }
                                                        
                                                        /* MARK: Automatically assume there is no chat history with `user`. */
                                                        if !self.accountInfo.messages.keys.contains(user) {
                                                            self.accountInfo.messages[user] = []
                                                        }
                                                        
                                                        if !resp[user]!.isEmpty {
                                                            
                                                            resp[user]!.forEach { message in
                                                                let messageData = FriendMessageDetails(
                                                                    MessageID: message["MessageID"]!,
                                                                    ContentType: message["ContentType"]!,
                                                                    MessageContent: message["MessageContent"]!,
                                                                    From: message["From"]!,
                                                                    dateSent: ISO8601DateFormatter().date(from: message["dateSent"]!)!
                                                                )
                                                                
                                                                if !self.accountInfo.messages[user]!.contains(where: { $0.MessageID == messageData.MessageID }) {
                                                                    self.accountInfo.messages[user]!.append(messageData)
                                                                }
                                                            }
                                                            
                                                            /*if let messageHistoryWithUser = resp[user]! as? Array<FriendMessageDetails> {
                                                             print(messageHistoryWithUser)
                                                             /*messageHistoryWithUser.forEach { message in
                                                              self.accountInfo.messages[user]!.append(message)
                                                              }*/
                                                             }*/
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //}
                                }
                            }
                        }
                        
                        /* MARK: If `topBanner` is `networkCheckFailure`, which will be set above, just exit from the rest of this code. */
                        /* TODO: We need to figure out a way to ensure that the rest of the `accountInfo` gets assigned when the server is responsive again. */
                        /*if self.topBanner == .NetworkCheckFailure { return }
                        //}
                        
                        /* MARK: If this `.onAppear` runs, there should be a key `username` in `UserDefaults.standard`. If there isn't, then there is a problem.
                         * */
                        if udKeyExists(key: "usecase") {
                            accountInfo.setUsage(usage: getUDValue(key: "usecase"))
                        }
                        
                        if udKeyExists(key: "username") {
                            accountInfo.setUsername(username: getUDValue(key: "username"))
                        }
                        
                        if udKeyExists(key: "email") {
                            accountInfo.setEmail(email: getUDValue(key: "email"))
                        }
                        
                        if udKeyExists(key: "college") {
                            accountInfo.setCollegeName(collegeName: getUDValue(key: "college"))
                        }
                        
                        if udKeyExists(key: "major") {
                            accountInfo.setMajorName(majorName: getUDValue(key: "major"))
                        }
                    
                    if udKeyExists(key: "major_field") {
                        accountInfo.setMajorField(field: getUDValue(key: "major_field"))
                    }
                    
                        if udKeyExists(key: "state") {
                            accountInfo.setCollegeState(collegeState: getUDValue(key: "state"))
                        }
                        
                        if udKeyExists(key: "account_id") {
                            accountInfo.setAccountID(accountID: getUDValue(key: "account_id"))
                            
                            Task {
                                //if self.accountInfo.friends.isEmpty {
                                await self.accountInfo.getFriends(accountID: self.accountInfo.accountID) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        return
                                    }
                                    
                                    if let resp = resp as? [String: [String: Any]] {
                                        for user in resp.keys {
                                            guard resp[user] != nil else { continue }
                                            
                                            if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                                if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                                    self.accountInfo.friends[user] = Image(
                                                        uiImage: UIImage(
                                                            data: userPFPData
                                                        )!
                                                    )
                                                } else {
                                                    self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                                }
                                            } else {
                                                self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                            }
                                        }
                                    }
                                    
                                    if !self.accountInfo.friends.isEmpty {
                                        RequestAction<GetClientsMessagesData>(parameters: GetClientsMessagesData(
                                            AccountId: self.accountInfo.accountID
                                        )).perform(action: get_clients_messages_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                if let resp = resp { print(resp) }
                                                return
                                            }
                                            
                                            if let resp = resp as? [String: Array<[String: String]>] {
                                                resp.keys.forEach { user in
                                                    if let friendImage = self.accountInfo.friends[user] {
                                                        self.accountInfo.allChats.append([user: friendImage])
                                                    } else {
                                                        self.accountInfo.allChats.append([user: Image(systemName: "person.crop.circle.fill")])
                                                    }
                                                    
                                                    /* MARK: Automatically assume there is no chat history with `user`. */
                                                    if !self.accountInfo.messages.keys.contains(user) {
                                                        self.accountInfo.messages[user] = []
                                                    }
                                                    
                                                    if !resp[user]!.isEmpty {
                                                        
                                                        resp[user]!.forEach { message in
                                                            let messageData = FriendMessageDetails(
                                                                MessageID: message["MessageID"]!,
                                                                ContentType: message["ContentType"]!,
                                                                MessageContent: message["MessageContent"]!,
                                                                From: message["From"]!,
                                                                dateSent: ISO8601DateFormatter().date(from: message["dateSent"]!)!
                                                            )
                                                            
                                                            if !self.accountInfo.messages[user]!.contains(where: { $0.MessageID == messageData.MessageID }) {
                                                                self.accountInfo.messages[user]!.append(messageData)
                                                            }
                                                        }
                                                        
                                                        /*if let messageHistoryWithUser = resp[user]! as? Array<FriendMessageDetails> {
                                                         print(messageHistoryWithUser)
                                                         /*messageHistoryWithUser.forEach { message in
                                                          self.accountInfo.messages[user]!.append(message)
                                                          }*/
                                                         }*/
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                //}
                            }
                            
                            if self.accountInfo.username == "" {
                                /* MARK: Upon any error ocurring whilst getting the users username by account ID, we will assume the user cannot be found and, therefore, show a "User Not Found" error. */
                                RequestAction<GetClientsUsernameData>(parameters: GetClientsUsernameData(
                                    AccountId: self.accountInfo.accountID
                                )).perform(action: get_clients_username_req) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        self.userHasSignedIn = false
                                        self.userNotFound = true
                                        return
                                    }
                                    
                                    if let resp = resp as? [String: String] {
                                        guard resp.keys.contains("Username") else {
                                            self.userHasSignedIn = false
                                            self.userNotFound = true
                                            return
                                        }
                                        
                                        self.accountInfo.setUsername(username: resp["Username"]!)
                                    } else {
                                        self.userHasSignedIn = false
                                        self.userNotFound = true
                                    }
                                }
                            }
                            
                            //DispatchQueue.global(qos: .background).async {
                            PFP(accountID: UserDefaults.standard.string(forKey: "account_id"))
                                .requestGetPFP() { statusCode, pfp, resp in
                                    guard pfp != nil && statusCode == 200 else {
                                        guard resp != nil else { return }
                                        
                                        /* MARK: If `ErrorCode` is 0x6966 means the user was not found in the database. */
                                        if resp!["ErrorCode"] as! Int == 0x6966 {
                                            /* MARK: If the error code is `0x6966`, remove all the data over the user from `UserDefaults`, ensure the "User Not Found" banner will show and "redirect" the user back to the home screen. */
                                            udRemoveAllAccountInfoKeys()
                                            
                                            self.userHasSignedIn = false
                                            self.userNotFound = true
                                        }
                                        
                                        return
                                    }
                                    
                                    accountInfo.setProfilePicture(pfp: UIImage(data: pfp!)!)
                                }
                            //}
                            
                            //DispatchQueue.global(qos: .background).async {
                            PFP(accountID: UserDefaults.standard.string(forKey: "account_id"))
                                .requestGetPFPBg() { statusCode, pfp_bg in
                                    guard pfp_bg != nil && statusCode == 200 else { return }
                                    
                                    accountInfo.setProfilePictureBackground(bg: UIImage(data: pfp_bg!)!)
                                }
                            //}
                            
                            //DispatchQueue.global(qos: .background).async {
                            //}
                        }
                        
                        /*if UserDefaults.standard.object(forKey: "client_sub_id") != nil {
                            accountInfo.setClientSubID(subID: UserDefaults.standard.string(forKey: "client_sub_id")!)
                        }*/*/
                    //}
                    
                    /*if UserDefaults.standard.string(forKey: "faceID_enabled") == "enabled" {
                        if !(UserDefaults.standard.bool(forKey: "faceID_initialized")) {
                            authenticate(initializing: true)
                        } else {
                            self.faceIDAuthenticated = false
                            authenticate(initializing: false)
                        }
                    } else {
                        self.faceIDAuthenticated = true
                    }*/
                })
            }
        }
    }
}
