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
    @State private var signupSection: String = ""
    
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
    
    var body: some View {
        if !userHasSignedIn {
            ResponsiveView(eventTypeToIgnore: .keyboard, edgesToIgnore: [.bottom]) { prop in
                /*ZStack {
                    VStack {
                        Image("Logo")
                            .logoImageModifier(prop: prop)
                        
                        Spacer()
                    }
                    
                    /*VStack {
                        Spacer()
                        
                        VStack {
                            Text("Hello,")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 5)
                                .foregroundStyle(.white)
                                .font(
                                    .system(
                                        size: prop.isIpad
                                            ? 90
                                            : prop.isLargerScreen
                                                ? 30
                                                : 20
                                    )
                                )
                                .fontWeight(.bold)
                            
                            Text("What are we doing?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))
                                .foregroundStyle(.white)
                                .padding(.bottom, 20)
                            
                            Button(action: { }) {
                                HStack {
                                    Text("Logging In")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                        .foregroundStyle(.white)
                                        .padding(.leading, 15)
                                    
                                    Image(systemName: "chevron.right")
                                        .resizableImage(width: 10, height: 15)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 15)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Button(action: { }) {
                                HStack {
                                    Text("Signing Up")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                        .foregroundStyle(.white)
                                        .padding(.leading, 15)
                                    
                                    Image(systemName: "chevron.right")
                                        .resizableImage(width: 10, height: 15)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 15)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: prop.size.width - 70)
                        .padding()
                        
                        Spacer()
                    }*/
                    
                    VStack {
                        HStack {
                            if !self.isLoggingIn {
                                Button(action: {
                                    /* TODO: Check `signupSection` and depending either go to the last section or retreat back to the "main screen". */
                                    if self.signupSection == "usecase" {
                                        self.isLoggingIn = true
                                        return
                                    }
                                    
                                    switch(self.signupSection) {
                                    case "credentials": self.signupSection = "usecase";break
                                    case "select_state": self.signupSection = "credentials";break
                                    case "select_college": self.signupSection = "select_state";break
                                    case "select_major_field": self.signupSection = "select_college";break
                                    case "select_major": self.signupSection = "select_major_field";break
                                    default: self.signupSection = "usecase";break
                                    }
                                }) {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.trailing, 10) /* MARK: Ensure spacing between the text and the back button. */
                            }
                            
                            VStack {
                                Text(self.isLoggingIn
                                     ? "Login"
                                     : self.signupSection == "usecase"
                                     ? "Select Usage"
                                     : self.signupSection == "credentials"
                                     ? "Enter Credentials"
                                     : self.signupSection == "select_state_and_college"
                                     ? "Select State/College"
                                     : self.signupSection == "select_major_field"
                                     ? "Select Major Field"
                                     : self.signupSection == "select_major"
                                     ? "Select Major"
                                     : self.signupSection == "code_input"
                                     ? "Input Code"
                                     : "Select Plan")
                                .frame(maxWidth: prop.size.width - 50, alignment: .leading)
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
                                
                                if !self.isLoggingIn {
                                    if self.signupError != .None {
                                        Text(self.signupError == .TooShortUsername
                                             ? "Username too short"
                                             : self.signupError == .TooShortPassword
                                                ? "Password too short"
                                                : self.signupError == .InvalidEmail
                                                    ? "Invalid email"
                                                    : self.signupError == .UserExists
                                                        ? "Username exists"
                                                        : self.signupError == .EmailExists
                                                            ? "Email exists"
                                                            : self.signupError == .ServerError
                                                                ? "Something went wrong..."
                                                                : self.signupError == .WrongCode
                                                                    ? "Wrong code. Try again"
                                                                    : self.signupError == .NoSuchCollege
                                                                        ? "No such college exists"
                                                                        : "Something went wrong...")
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
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
                            }
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        
                        if self.isLoggingIn {
                            ZStack {
                                Color.EZNotesLightBlack
                                    .cornerRadius(15)
                                    .blur(radius: 14.5)
                                //.padding(5.5)
                                
                                VStack {
                                    if self.loginError {
                                        Text("Email, Username or Password is incorrect")
                                            .frame(maxWidth: prop.size.width - 100, alignment: .center)
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
                                        /*Text("Username or Email")
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 80,
                                                height: 5,
                                                alignment: .leading
                                            )
                                            .padding(.top)
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen ? 18 : 13
                                                )
                                            )
                                            .foregroundStyle(.white)
                                            .fontWeight(.medium)*/
                                        
                                        TextField("", text: $loginUsername)
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 100,
                                                height: 40
                                            )
                                            .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)
                                                    .borderBottomWLColor(isError: self.loginError, width: 0.5)
                                            )
                                            .overlay(
                                                HStack {
                                                    if self.loginUsername.isEmpty || !self.loginUsernameFieldInFocus {
                                                        Text("Username or Email")
                                                            .font(
                                                                .system(
                                                                    size: prop.isLargerScreen ? 18 : 13,
                                                                    weight: .medium
                                                                )
                                                            )
                                                            .foregroundStyle(Color(.systemGray2))
                                                            .padding(.leading, 10)
                                                            .onTapGesture { self.loginUsernameFieldInFocus = true }
                                                        Spacer()
                                                    }
                                                }
                                            )
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                            .tint(Color.EZNotesBlue)
                                            .font(.system(size: 18))
                                            .fontWeight(.medium)
                                            .focused($loginUsernameFieldInFocus)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .keyboardType(.alphabet)
                                        
                                        ZStack {
                                            HStack {
                                                /* TODO: Implement "Forgot Username" section. It will require the user to have remembered the email address used for the account. */
                                                Button(action: { print("Forgot Username") }) {
                                                    Text("Forgot Username?")
                                                        .frame(alignment: .leading)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .font(Font.custom("Poppins-Regular", size: 14))
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                
                                                Divider()
                                                    .background(Color.white)
                                                    .frame(maxHeight: 10)
                                                
                                                /* TODO: Implement "Forgot Email" section. It will require the user to have remembered the username used for the account. */
                                                Button(action: { print("Forgot Email") }) {
                                                    Text("Forgot Email?")
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .font(Font.custom("Poppins-Regular", size: 13))
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .frame(maxWidth: prop.isIpad
                                               ? UIDevice.current.orientation.isLandscape
                                               ? prop.size.width - 800
                                               : prop.size.width - 450
                                               : prop.size.width - 80)
                                        .padding(.bottom, 8)
                                        
                                        /*Text("Password")
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
                                                    size: prop.isLargerScreen ? 18 : 13
                                                )
                                            )
                                            .foregroundStyle(.white)
                                            .fontWeight(.medium)*/
                                        
                                        SecureField("", text: $loginPassword)
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 100,
                                                height: 40
                                            )
                                            .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                    .borderBottomWLColor(isError: self.loginError, width: 0.5)
                                            )
                                            .overlay(
                                                HStack {
                                                    if self.loginPassword.isEmpty || !self.loginPasswordFieldInFocus {
                                                        Text("Password...")
                                                            .font(
                                                                .system(
                                                                    size: prop.isLargerScreen ? 18 : 13,
                                                                    weight: .medium
                                                                )
                                                            )
                                                            .foregroundStyle(Color(.systemGray2))
                                                            .padding(.leading, 10)
                                                            .onTapGesture { self.loginPasswordFieldInFocus = true }
                                                        Spacer()
                                                    }
                                                }
                                            )
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                            .tint(Color.EZNotesBlue)
                                            .font(.system(size: 18))
                                            .fontWeight(.medium)
                                            .focused($loginPasswordFieldInFocus)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                        
                                        ZStack {
                                            Button(action: { print("Forgot Password") }) {
                                                Text("Forgot Password?")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(Color.EZNotesBlue)
                                                    .font(Font.custom("Poppins-Regular", size: 13))
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                        }
                                        .frame(maxWidth: prop.isIpad
                                               ? UIDevice.current.orientation.isLandscape
                                               ? prop.size.width - 800
                                               : prop.size.width - 450
                                               : prop.size.width - 80)
                                        
                                        Button(action: {
                                        }) {
                                            HStack {
                                                Text("Sign In")
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding(.vertical, 9.5)
                                                    .foregroundStyle(.white)
                                                    .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 20 : 18)
                                            }
                                            .frame(maxWidth: prop.size.width - 70) /* MARK: Make it 30 pixels shorter. */
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)
                                                    .stroke(Color.white, lineWidth: 0.5)
                                            )
                                            .cornerRadius(15)
                                            .padding(.top)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .padding(.horizontal)
                                    //.padding(8)
                                    //.padding(.top, prop.isLargerScreen ? 25 : 20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(4.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.black)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .padding(3)
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: 300)
                            .padding()
                            .padding(.top, 5)
                            
                            Text("Or")
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .center
                                )
                                .padding(.bottom) /* MARK: Since the above `ZStack` adds padding to all sides, we only need to add padding to `.bottom` here. */
                                .font(
                                    .system(
                                        size: prop.isLargerScreen ? 18 : 13
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            Button(action: {
                                self.isLoggingIn = false
                                
                                /* TODO: Depending on the last "state" of the sign up section, configure the view accordingly here. */
                                if udKeyExists(key: "usecase") {
                                    /* MARK: Check to see if all of the credentials needed to create an account exists. */
                                    if !udKeyExists(key: "username") { self.signupSection = "credentials"; return }
                                    if !udKeyExists(key: "email") { self.signupSection = "credentials"; return }
                                    if !udKeyExists(key: "password") { self.signupSection = "credentials"; return }
                                    
                                    /* MARK: Check the usecase. Depending, we will check what happens next. */
                                    if getUDValue(key: "usecase") == "school" {
                                        if !udKeyExists(key: "state") { self.section = "select_state"; return }
                                        if !udKeyExists(key: "college") {
                                            /* MARK: Regenerate the array of colleges to be displayed. */
                                            RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(
                                                State: getUDValue(key: "state")
                                            )).perform(action: get_colleges) { statusCode, resp in
                                                    self.loadingColleges = false
                                                    
                                                    guard
                                                        resp != nil,
                                                        resp!.keys.contains("Colleges"),
                                                        statusCode == 200
                                                    else {
                                                        self.signupError = .ServerError//self.error = .ServerError // self.serverError = true
                                                        return
                                                    }
                                                    
                                                    let respColleges = resp!["Colleges"] as! [String]
                                                    
                                                    for c in respColleges {
                                                        if !self.colleges.contains(c) { self.colleges.append(c) }
                                                    }
                                                    
                                                    self.colleges.append("Other")
                                                    //self.college = self.colleges[0]
                                                }
                                            
                                            self.signupSection = "select_college"
                                            return
                                        }
                                        if !udKeyExists(key: "major_field") {
                                            /* MARK: Regenerate all of the major fields to be displayed. */
                                            RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                State: getUDValue(key: "state"),
                                                College: getUDValue(key: "college")
                                            )).perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                self.loadingMajorFields = false
                                                
                                                //if let resp = resp { print(resp) }
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    guard let resp = resp else {
                                                        self.signupError = .ServerError // self.serverError = true
                                                        return
                                                    }
                                                    
                                                    guard resp.keys.contains("Message") else {
                                                        self.signupError = .ServerError // self.serverError = true
                                                        return
                                                    }
                                                    
                                                    /*if resp["Message"] as! String == "no_such_college_in_state" {
                                                        self.signupError = .NoSuchCollege
                                                        return
                                                    }*/
                                                    
                                                    self.signupError = .ServerError // self.serverError = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Fields") else {
                                                    self.signupError = .ServerError // self.serverError = true
                                                    return
                                                }
                                                
                                                self.majorFields = resp!["Fields"] as! [String]
                                                self.majorFields.append("Other")
                                                //self.majorField = self.majorFields[0]
                                            }
                                            
                                            self.signupSection = "select_major_field"
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
                                                self.loadingMajors = false
                                                
                                                guard resp != nil && statusCode == 200 else {
                                                    self.signupError = .ServerError // self.serverError = true
                                                    return
                                                }
                                                
                                                self.majors = resp!["Majors"] as! [String]
                                                self.majors.append("Other")
                                                //self.major = self.majors[0]
                                            }
                                            
                                            self.signupSection = "select_major"
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
                                        self.signupSection = "enter_code"
                                    }
                                } else {
                                    self.signupSection = "usecase"
                                }
                            }) {
                                HStack {
                                    Text("Sign Up")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 9.5)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 22 : 20)
                                }
                                .frame(maxWidth: prop.size.width - 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                )
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        } else {
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
                                        self.signupSection = "credentials"
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
                                        self.signupSection = "credentials"
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
                                }
                                .frame(maxWidth: prop.size.width - 40)
                                .padding(.top, 10)
                            case "credentials":
                                VStack {
                                    TextField("", text: $signupUsername)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupUsernameError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupUsername.isEmpty || !self.signupUsernameFieldInFocus {
                                                    Text(self.signupUsername.isEmpty ? "Username..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupUsernameFieldInFocus = true }
                                                    Spacer()
                                                }
                                            }
                                        )
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                        .tint(Color.EZNotesBlue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .focused($signupUsernameFieldInFocus)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.alphabet)
                                    
                                    TextField("", text: $signupEmail)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupEmailError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupEmail.isEmpty || !self.signupEmailFieldInFocus {
                                                    Text(self.signupEmail.isEmpty ? "Email..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupEmailFieldInFocus = true }
                                                    Spacer()
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
                                    
                                    SecureField("", text: $signupPassword)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupPasswordError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupPassword.isEmpty || !self.signupPasswordFieldInFocus {
                                                    Text("Password...")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupPasswordFieldInFocus = true }
                                                    Spacer()
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
                                }
                                .frame(maxWidth: prop.size.width - 25)
                            default: VStack { }.onAppear { self.signupSection = "usecase" }
                            }
                            
                            if self.signupSection != "usecase" && self.signupSection != "select_plan" {
                                Button(action: {
                                    if self.section == "credentials" {
                                        if self.signupUsername.isEmpty { self.signupError = .TooShortUsername; return }
                                        if self.signupEmail.isEmpty { self.signupError = .InvalidEmail; return }
                                        if self.signupPassword.isEmpty { self.signupError = .TooShortPassword; return }
                                        
                                    }
                                }) {
                                    HStack {
                                        Text("Continue")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 9.5)
                                            .foregroundStyle(.black)
                                            .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 22 : 20)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.top)
                            }
                        }
                        /*.padding()
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.black)//Color.EZNotesBlack)
                                .shadow(color: Color.EZNotesBlue, radius: 2.5)
                        )//.background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                        .padding(3)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal)*/
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)//Color.EZNotesBlack)*/
                /*ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Image("Logo")
                                .logoImageModifier(prop: prop)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
                    
                    if self.isLoggingIn {
                        VStack {
                            
                            Text("Welcome Back!")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 26 : 24))
                                .lineSpacing(1.5)
                                .foregroundStyle(.white)
                                .padding(.top, prop.isLargerScreen ? 16 : 10)
                                .padding(.bottom, 32)
                            
                            VStack {
                                //Spacer()
                                
                                if self.loginError == .ServerError {
                                    Text("Something went wrong. Try again.")
                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen ? 15 : 13
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
                                                            size: prop.isLargerScreen ? 18 : 13,
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
                                                                size: prop.isLargerScreen ? 18 : 13,
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
                                            size: prop.isLargerScreen ? 15 : 13
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
                                                            size: prop.isLargerScreen ? 18 : 13,
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
                                                                size: prop.isLargerScreen ? 18 : 13,
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
                                            size: prop.isLargerScreen ? 15 : 13
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
                                    
                                    RequestAction<LoginRequestData>(parameters: LoginRequestData(
                                        Username: self.loginUsername, Password: self.loginPassword
                                    )).perform(action: complete_login_req) { statusCode, resp in
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
                                        
                                        assignUDKey(key: "username", value: resp["Useranme"]! as! String)
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
                                    Text("Login")
                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                        .foregroundStyle(.black)
                                        .padding(10)
                                        .background(Color.EZNotesBlue)
                                        .cornerRadius(20)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.top, 10)
                                .padding(.bottom)
                                
                                /*Button(action: { }) {
                                 Text("Sign Up")
                                 .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                 .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                 .foregroundStyle(.black)
                                 .padding(12)
                                 .background(Color.EZNotesOrange)
                                 .cornerRadius(20)
                                 .padding(.horizontal)
                                 }
                                 .buttonStyle(NoLongPressButtonStyle())
                                 .padding(.vertical)
                                 .padding(.bottom)*/
                                
                                Button(action: { }) {
                                    Text("Having trouble signing in?")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundStyle(.gray)
                                }
                                
                                HStack {
                                    Text("Don't have an account?")
                                        .frame(alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: 14))
                                        .foregroundStyle(.white)
                                    
                                    Button(action: {
                                        self.isLoggingIn = false
                                        
                                        /* TODO: Depending on the last "state" of the sign up section, configure the view accordingly here. */
                                        if udKeyExists(key: "usecase") {
                                            /* MARK: Check to see if all of the credentials needed to create an account exists. */
                                            if !udKeyExists(key: "username") { self.signupSection = "credentials"; return }
                                            if !udKeyExists(key: "email") { self.signupSection = "credentials"; return }
                                            if !udKeyExists(key: "password") { self.signupSection = "credentials"; return }
                                            
                                            /* MARK: Check the usecase. Depending, we will check what happens next. */
                                            if getUDValue(key: "usecase") == "school" {
                                                if !udKeyExists(key: "state") { self.section = "select_state"; return }
                                                if !udKeyExists(key: "college") {
                                                    /* MARK: Regenerate the array of colleges to be displayed. */
                                                    RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(
                                                        State: getUDValue(key: "state")
                                                    )).perform(action: get_colleges) { statusCode, resp in
                                                        self.loadingColleges = false
                                                        
                                                        guard
                                                            resp != nil,
                                                            resp!.keys.contains("Colleges"),
                                                            statusCode == 200
                                                        else {
                                                            self.signupError = .ServerError//self.error = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        let respColleges = resp!["Colleges"] as! [String]
                                                        
                                                        for c in respColleges {
                                                            if !self.colleges.contains(c) { self.colleges.append(c) }
                                                        }
                                                        
                                                        self.colleges.append("Other")
                                                        //self.college = self.colleges[0]
                                                    }
                                                    
                                                    self.signupSection = "select_college"
                                                    return
                                                }
                                                if !udKeyExists(key: "major_field") {
                                                    /* MARK: Regenerate all of the major fields to be displayed. */
                                                    RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                        State: getUDValue(key: "state"),
                                                        College: getUDValue(key: "college")
                                                    )).perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                        self.loadingMajorFields = false
                                                        
                                                        //if let resp = resp { print(resp) }
                                                        guard
                                                            resp != nil,
                                                            statusCode == 200
                                                        else {
                                                            guard let resp = resp else {
                                                                self.signupError = .ServerError // self.serverError = true
                                                                return
                                                            }
                                                            
                                                            guard resp.keys.contains("Message") else {
                                                                self.signupError = .ServerError // self.serverError = true
                                                                return
                                                            }
                                                            
                                                            /*if resp["Message"] as! String == "no_such_college_in_state" {
                                                             self.signupError = .NoSuchCollege
                                                             return
                                                             }*/
                                                            
                                                            self.signupError = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        guard resp!.keys.contains("Fields") else {
                                                            self.signupError = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        self.majorFields = resp!["Fields"] as! [String]
                                                        self.majorFields.append("Other")
                                                        //self.majorField = self.majorFields[0]
                                                    }
                                                    
                                                    self.signupSection = "select_major_field"
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
                                                        self.loadingMajors = false
                                                        
                                                        guard resp != nil && statusCode == 200 else {
                                                            self.signupError = .ServerError // self.serverError = true
                                                            return
                                                        }
                                                        
                                                        self.majors = resp!["Majors"] as! [String]
                                                        self.majors.append("Other")
                                                        //self.major = self.majors[0]
                                                    }
                                                    
                                                    self.signupSection = "select_major"
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
                                                self.signupSection = "enter_code"
                                            }
                                        } else {
                                            self.signupSection = "usecase"
                                        }
                                    }) {
                                        Text("Sign Up")
                                            .frame(alignment: .leading)
                                            .font(Font.custom("Poppins-SemiBold", size: 14))
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .underline()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                                
                                //Spacer()
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .padding(.bottom)
                            .padding(.bottom)
                            
                            Spacer()
                            
                            /*VStack {
                             Button(action: { }) {
                             Text("Login")
                             .frame(maxWidth: prop.size.width - 40, alignment: .center)
                             .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                             .foregroundStyle(.black)
                             .padding(12)
                             .background(Color.EZNotesBlue)
                             .cornerRadius(15)
                             .padding(.horizontal)
                             }
                             .buttonStyle(NoLongPressButtonStyle())
                             
                             Button(action: { }) {
                             Text("Sign Up")
                             .frame(maxWidth: prop.size.width - 40, alignment: .center)
                             .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                             .foregroundStyle(.black)
                             .padding(12)
                             .background(Color.EZNotesOrange)
                             .cornerRadius(15)
                             .padding(.horizontal)
                             }
                             .buttonStyle(NoLongPressButtonStyle())
                             .padding(.bottom)
                             
                             Button(action: { }) {
                             Text("Having trouble signing in?")
                             .frame(maxWidth: .infinity, alignment: .center)
                             .foregroundStyle(.gray)
                             }
                             }
                             .frame(maxWidth: prop.size.width - 40, maxHeight: prop.size.height / 1.5)*/
                            
                            //Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea(.keyboard, edges: .all)
                        .padding(.top, prop.isLargerScreen ? 150 : 120)
                        // prop.isLargerScreen ? [.bottom] : [.top, .bottom])
                        .zIndex(1)
                    } else {
                        VStack {
                            Text(self.signupSection == "usecase"
                                 ? "Select Usage"
                                 : self.signupSection == "credentials"
                                    ? "Enter Your Credentials"
                                    : "Idk")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 26 : 24))
                                .lineSpacing(1.5)
                                .foregroundStyle(.white)
                                .padding(.top, prop.isLargerScreen ? 16 : 10)
                                .padding(.bottom, 32)
                            
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
                                        self.signupSection = "credentials"
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
                                        self.signupSection = "credentials"
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
                                }
                                .frame(maxWidth: prop.size.width - 40)
                            case "credentials":
                                VStack {
                                    TextField("", text: $signupUsername)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupUsernameError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupUsername.isEmpty || !self.signupUsernameFieldInFocus {
                                                    Text(self.signupUsername.isEmpty ? "Username..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupUsernameFieldInFocus = true }
                                                    Spacer()
                                                }
                                            }
                                        )
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                        .tint(Color.EZNotesBlue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .focused($signupUsernameFieldInFocus)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.alphabet)
                                    
                                    TextField("", text: $signupEmail)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupEmailError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupEmail.isEmpty || !self.signupEmailFieldInFocus {
                                                    Text(self.signupEmail.isEmpty ? "Email..." : "")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupEmailFieldInFocus = true }
                                                    Spacer()
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
                                        .padding(.vertical)
                                    
                                    SecureField("", text: $signupPassword)
                                        .frame(
                                            maxWidth: .infinity,/*prop.isIpad
                                            ? UIDevice.current.orientation.isLandscape
                                            ? prop.size.width - 800
                                            : prop.size.width - 450
                                            : prop.size.width - 100,*/
                                            maxHeight: 40
                                        )
                                        .padding(.leading, prop.isLargerScreen ? 10 : 5)
                                        .background(
                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                .fill(.clear)
                                                .borderBottomWLColor(isError: self.signupPasswordError, width: 0.5)
                                        )
                                        .overlay(
                                            HStack {
                                                if self.signupPassword.isEmpty || !self.signupPasswordFieldInFocus {
                                                    Text("Password...")
                                                        .font(
                                                            .system(
                                                                size: prop.isLargerScreen ? 18 : 13,
                                                                weight: .bold
                                                            )
                                                        )
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .padding(.leading, 10)
                                                        .onTapGesture { self.signupPasswordFieldInFocus = true }
                                                    Spacer()
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
                                }
                                .frame(maxWidth: prop.size.width - 40)
                            default: VStack { }.onAppear { self.signupSection = "usecase" }
                            }
                            
                            Spacer()
                            
                            if self.signupSection == "credentials" {
                                Button(action: { }) {
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
                            
                            Button(action: {
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
                                    self.signupSection = "select_college"
                                    break
                                case "select_major":
                                    self.signupSection = "select_major_field"
                                    break
                                default: VStack { }.onAppear { self.signupSection = "usecase" }
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
                            .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, prop.isLargerScreen ? 135 : 105)
                        .ignoresSafeArea(edges: prop.isLargerScreen ? [.bottom] : [.top, .bottom])
                        .zIndex(1)
                    }
                }
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("Background")
                        .resizable()
                                    .scaledToFill()
                                    .ignoresSafeArea()
                        //.ignoresSafeArea(edges: .bottom)
                        //.zIndex(0)
                    /*Image("Background")
                        .ignoresSafeArea(.all)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("Background")
                            .resizable()
                            .scaledToFill()
                            .overlay(.black.opacity(0.5))
                            .ignoresSafeArea(.keyboard)
                            .zIndex(0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)*/
                )
                .ignoresSafeArea(.keyboard, edges: .all)/*prop.isLargerScreen
                                 ? [.bottom, .leading, .trailing] //? self.isLoggingIn ? [.bottom, .leading, .trailing] : .init()
                                 : [.top, .bottom])*///.ignoresSafeArea(prop.isLargerScreen ? .init() : .keyboard, edges: prop.isLargerScreen ? [.bottom] : [.top, .bottom])
                /*.onAppear {
                    self.loginPasswordFieldInFocus = false
                    self.loginUsernameFieldInFocus = false
                    self.signupUsernameFieldInFocus = false
                    self.signupEmailFieldInFocus = false
                    self.signupPasswordFieldInFocus = false
                }
                .edgesIgnoringSafeArea(!self.loginPasswordFieldInFocus &&
                                       !self.loginUsernameFieldInFocus &&
                                       !self.signupUsernameFieldInFocus &&
                                       !self.signupEmailFieldInFocus &&
                                       !self.signupPasswordFieldInFocus ? .bottom : .init())*/
                .background(.black)*/
                /*.edgesIgnoringSafeArea(!self.loginPasswordFieldInFocus &&
                                       !self.loginUsernameFieldInFocus &&
                                       !self.signupUsernameFieldInFocus &&
                                       !self.signupEmailFieldInFocus &&
                                       !self.signupPasswordFieldInFocus ? .bottom : .init())*/
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
                                    if self.signupError == .ServerError {
                                        Button(action: { print("Report Problem") }) {
                                            Label("Report Problem", systemImage: "sun.max.trianglebadge.exclamationmark")
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    if self.section == "code_input" {
                                        Button(action: {
                                            //self.state.removeAll()
                                            self.colleges.removeAll()
                                            self.majorFields.removeAll()
                                            //self.major.removeAll()
                                            
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
                                            
                                            self.signupSection = "usecase"
                                        }) {
                                            Label("Restart Signup", systemImage: "arrow.trianglehead.counterclockwise")
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    /* MARK: Once the user gets to `code_input` or `select_plan`, they will not be eligible to go to the login screen. */
                                    if self.section != "select_plan" && self.section != "code_input" {
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
                                
                                RequestAction<LoginRequestData>(parameters: LoginRequestData(
                                    Username: self.loginUsername, Password: self.loginPassword
                                )).perform(action: complete_login_req) { statusCode, resp in
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
                                    
                                    assignUDKey(key: "username", value: resp["Useranme"]! as! String)
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
                                Text("Login")
                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.EZNotesBlue)
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(.top, 10)
                            .padding(.bottom)
                            
                            Button(action: { }) {
                                Text("Having trouble signing in?")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundStyle(.gray)
                            }
                            
                            HStack {
                                Text("Don't have an account?")
                                    .frame(alignment: .leading)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .foregroundStyle(.white)
                                
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
                                        
                                        /*if !udKeyExists(key: "account_id") {
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
                                            self.signupSection = "code_input"
                                        }*/
                                    } else {
                                        self.signupSection = "usecase"
                                    }
                                }) {
                                    Text("Sign Up")
                                        .frame(alignment: .leading)
                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .underline()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            
                            Spacer()
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
                                     self.signupSection != "select_major"
                                     ?
                                        prop.isLargerScreen
                                            ? 32
                                            : 20
                                     : 0)
                        }
                        
                        if self.signupError == .ServerError {
                            Text("Something went wrong. Try again")
                            .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                            .padding(.bottom, 5)
                            .foregroundStyle(Color.EZNotesRed)
                            .font(
                                .system(
                                    size: 13
                                )
                            )
                            .fontWeight(.medium)
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
                                    .frame(
                                        maxWidth: prop.size.width - 70,/*prop.isIpad
                                        ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                        : prop.size.width - 100,*/
                                        maxHeight: 40
                                    )
                                    .padding(.leading, prop.isLargerScreen ? 10 : 5)
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
                                         : "User exists. If this is your account, login")
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
                                    .frame(
                                        maxWidth: prop.size.width - 70,/*prop.isIpad
                                        ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                        : prop.size.width - 100,*/
                                        maxHeight: 40
                                    )
                                    .padding(.leading, prop.isLargerScreen ? 10 : 5)
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
                                    .padding(.vertical, self.signupError != .TooShortUsername && self.signupError != .UserExists ? 16 : 0)
                                    .padding(.bottom, self.signupError == .TooShortUsername || self.signupError == .UserExists ? 16 : 0)
                                
                                if self.signupError == .InvalidEmail || self.signupError == .EmailExists {
                                    Text(self.signupError == .InvalidEmail
                                         ? "Invalid email"
                                         : "Email exists. If this is your email, login.")
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
                                    .frame(
                                        maxWidth: prop.size.width - 70,/*prop.isIpad
                                        ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                        : prop.size.width - 100,*/
                                        maxHeight: 40
                                    )
                                    .padding(.leading, prop.isLargerScreen ? 10 : 5)
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
                                    Button(action: { }) {
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
                                
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "code_input":
                            VStack {
                                
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        case "select_plan":
                            VStack {
                                
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
                        default: VStack { }.onAppear { self.signupSection = "usecase" }
                        }
                        
                        Spacer()
                        
                        if (self.signupSection == "credentials" || self.signupSection == "code_input") && self.signupSection != "hang_tight_screen" {
                            Button(action: {
                                switch(self.signupSection) {
                                case "credentials":
                                    if self.signupUsername.isEmpty || self.signupUsername.count < 4 {
                                        self.signupError = .TooShortUsername
                                        return
                                    }
                                    
                                    if self.signupEmail.isEmpty || !self.signupEmail.contains("@") {
                                        self.signupError = .InvalidEmail
                                        return
                                    }
                                    
                                    if self.signupPassword.isEmpty || self.signupPassword.count < 8 {
                                        self.signupError = .TooShortPassword
                                        return
                                    }
                                    
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
                                                self.signupError = .ServerError
                                                return
                                            }
                                            
                                            assignUDKey(key: "account_id", value: accountId)
                                            
                                            /* MARK: Redirect user to put in a code that was sent to their email. */
                                            self.signupSection = "code_input"
                                            
                                            return
                                        }
                                        
                                        return
                                    }
                                    
                                    self.signupSection = "select_state"
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
                                            self.signupSection = "code_input" /* MARK: Ensure we "go back" to the last section if the code is wrong */
                                            self.signupError = .WrongCode
                                            return
                                        }
                                        
                                        self.signupSection = "select_plan"
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
                        
                        if self.signupSection != "hang_tight_screen" {
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
                                                self.signupSection = "select_major_field"
                                                
                                                self.signupError = .ServerError//self.error = .ServerError // self.serverError = true
                                                return
                                            }
                                            
                                            if let colleges = resp["Colleges"]! as? [String] {
                                                for c in colleges {
                                                    if !self.colleges.contains(c) { self.colleges.append(c) }
                                                }
                                                
                                                self.colleges.append("Other")
                                                return
                                            }
                                            
                                            self.signupSection = "select_major_field"
                                            self.signupError = .ServerError
                                            return
                                        }
                                    }
                                    
                                    self.signupSection = "select_college"
                                    break
                                case "select_major":
                                    self.signupSection = "select_major_field"
                                    break
                                default: VStack { }.onAppear { self.signupSection = "usecase" }
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
                /*VStack {
                    
                    //VStack {
                        Image("Logo")
                            .logoImageModifier(prop: prop)
                        
                        VStack {
                            Text("Hello,")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 5)
                                .foregroundStyle(.white)
                                .font(
                                    .system(
                                        size: prop.isIpad
                                            ? 90
                                            : prop.isLargerScreen
                                                ? 30
                                                : 20
                                    )
                                )
                                .fontWeight(.bold)
                            
                            Text("What are we doing?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))
                                .foregroundStyle(.white)
                                .padding(.bottom, 20)
                            
                            Button(action: { }) {
                                HStack {
                                    Text("Login")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                        .foregroundStyle(.white)
                                        .padding(.leading, 15)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Button(action: { }) {
                                HStack {
                                    Text("Signup")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                        .foregroundStyle(.white)
                                        .padding(.leading, 15)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: prop.size.width - 80)
                        .padding()
                        
                        /*Spacer()
                        
                        ZStack {
                            /*MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0.5), .init(0.5, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0, 0.3), .init(1, 0.3),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesRed
                                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                 Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                 Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                            ])
                            .frame(
                                maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 20,
                                maxHeight: prop.isIpad ? 500 : 350,
                                alignment: .top
                            )
                            .mask(
                                VStack {
                                    Text("No Pen, No Pencil")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .contrast(10)
                                        .shadow(color: .white, radius: 2.5)
                                        .fontWeight(.heavy)
                                        .font(Font.custom("Poppins-Regular", size: prop.isIpad
                                                          ? 65
                                                          : prop.size.height / 2.5 > 300
                                                          ? 40
                                                          : 30)
                                        )
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Never miss a detail—your notes are taken, sorted, and ready automatically for you.")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .contrast(10)
                                        .shadow(color: .white, radius: 2.5)
                                        .fontWeight(.heavy)
                                        .font(Font.custom("Poppins-ExtraLight", size: prop.isIpad
                                                          ? 28
                                                          : prop.size.height / 2.5 > 300
                                                          ? 18
                                                          : 14)
                                        )
                                        .multilineTextAlignment(.center)
                                }
                            )*/
                            Image("Test-Bg-3")
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            //.frame(maxWidth: prop.size.height / 2.5 > 300 ? .infinity : 100, maxHeight: prop.size.height / 2.5 > 300 ? .infinity : 100)
                                //.aspectRatio(1, contentMode: .fill)
                                .overlay(Color.EZNotesBlack.opacity(0.6))
                                .blur(radius: 2.5)
                            
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical)
                            .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                        }
                        .frame(maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 60, maxHeight: 260, alignment: .center)//(maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 20, maxHeight: 320)
                        /*.background(
                            Image("Test-Bg-3")
                                .resizable()
                            //.frame(maxWidth: prop.size.height / 2.5 > 300 ? .infinity : 100, maxHeight: prop.size.height / 2.5 > 300 ? .infinity : 100)
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(Color.EZNotesBlack.opacity(0.6))
                                .blur(radius: 2.5)
                        )*/
                        .padding(.top, prop.size.height / 2.5 > 300 ? 0 : 20)
                        
                        Spacer()*/
                    //}
                    //.frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesBlack)*/
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
                    /*if self.selectedTab == 1 && self.images_to_upload.images_to_upload.isEmpty {
                        TabView(selection: $selectedTab) {
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(0)
                            .background(Color.EZNotesBlack)
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
                            
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
                            .tag(1)
                            .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                                .onEnded({ value in
                                    if value.translation.width < 0 {
                                        //self.section = "chat"
                                        self.selectedTab = 2
                                        return
                                    }
                                    
                                    if value.translation.width > 0 {
                                        //self.section = "home"
                                        self.selectedTab = 1
                                        return
                                    }
                                })
                            )
                            .tabItem {
                                Label(self.section == "upload" ? "History" : "Upload", systemImage: self.section == "upload" ? "clock" : "plus")
                            }
                            /*VStack {
                             
                             }
                             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                             .edgesIgnoringSafeArea([.bottom])
                             .tag(1)
                             .onAppear {
                             self.model.startSession()
                             }
                             .onDisappear {
                             self.model.stopSession()
                             }
                             .background(
                             self.model.permissionGranted && self.model.cameraDeviceFound
                             ? AnyView(FrameView(handler: self.model, image: self.model.frame, prop: prop, loadingCameraView: $loadingCameraView)
                             .ignoresSafeArea()
                             .gesture(MagnificationGesture()
                             .onChanged { value in
                             //self.currentZoomFactor += value - 1.0 // Calculate the zoom factor change
                             //self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 20)
                             //self.model.setScale(scale: currentZoomFactor)
                             }
                             )
                             .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                             .onEnded({ value in
                             if value.translation.width < 0 {
                             //self.section = "chat"
                             self.selectedTab = 2
                             return
                             }
                             
                             if value.translation.width > 0 {
                             //self.section = "home"
                             self.selectedTab = 1
                             return
                             }
                             })
                             )
                             )
                             : AnyView(Color.EZNotesBlack)
                             )
                             .tabItem {
                             Label(self.section == "upload" ? "History" : "Upload", systemImage: self.section == "upload" ? "clock" : "plus")
                             }*/
                            
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(2)
                            .background(Color.EZNotesBlack)
                            .tabItem {
                                Label("Chat", systemImage: "message")
                            }
                        }
                    }
                    //.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))*/
                    
                    
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
                        /*ResponsiveView { prop in
                         HomeView(
                         section: $section,
                         prop: prop,
                         userHasSignedIn:$userHasSignedIn,
                         model: self.model//,
                         //images_to_upload: self.images_to_upload
                         )
                         }*/
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
                    /*if self.faceIDAuthenticated {
                     ResponsiveView { prop in
                     CoreApp(
                     prop: prop,
                     topBanner: $topBanner,
                     model: model,
                     userHasSignedIn: $userHasSignedIn
                     )
                     }
                     } else {
                     if self.goBackToLogin {
                     StartupScreen(
                     userHasSignedIn: $userHasSignedIn,
                     userNotFound: $userNotFound,
                     goBackToLogin: $goBackToLogin,
                     faceIDAuthenticated: $faceIDAuthenticated
                     )
                     } else {
                     ZStack {
                     if self.faceIDAuthenticated {
                     VStack {
                     ProgressView()
                     .tint(Color.EZNotesBlue)
                     .frame(width: 25, height: 25)
                     .controlSize(.large)
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(.black.opacity(0.5))
                     }
                     Text("Unlock With FaceID")
                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                     .foregroundStyle(.white)
                     .font(.system(size: 30, design: .rounded))
                     .fontWeight(.bold)
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(
                     Image(!self.faceIDAuthenticated ? "Background" : "Background2")
                     )
                     }
                     }*/
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
                        .perform(action: check_server_active_req)
                        { statusCode, resp in
                            guard resp != nil && statusCode == 200 else {
                                self.topBanner = .NetworkCheckFailure
                                return
                            }
                        }
                        
                        /* MARK: If `topBanner` is `networkCheckFailure`, which will be set above, just exit from the rest of this code. */
                        /* TODO: We need to figure out a way to ensure that the rest of the `accountInfo` gets assigned when the server is responsive again. */
                        if self.topBanner == .NetworkCheckFailure { return }
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
                        }*/
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
