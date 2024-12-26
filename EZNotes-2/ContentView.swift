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
    @State public var loginError: Bool = false
    
    @State private var isLoggingIn: Bool = true
    @State private var signupSection: String = ""
    
    var body: some View {
        if !userHasSignedIn {
            ResponsiveView { prop in
                ZStack {
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
                                    self.isLoggingIn = true
                                    self.signupSection = ""
                                }) {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.trailing, 10) /* MARK: Ensure spacing between the text and the back button. */
                            }
                            
                            Text(self.isLoggingIn
                                 ? "Login"
                                 : self.signupSection == "usecase"
                                 ? "Select Usage"
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
                                        Text("Username or Email")
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
                                            .fontWeight(.medium)
                                        
                                        TextField("Username or Email...", text: $loginUsername)
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 100,
                                                height: 40
                                            )
                                            .padding(.leading, prop.isLargerScreen ? 15 : 5)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)
                                                    .borderBottomWLColor(isError: self.loginError)
                                            )
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 4)//.padding([.top, .leading, .trailing], prop.isLargerScreen ? 10 : 8)
                                            .tint(Color.EZNotesBlue)
                                            .font(.system(size: 18))
                                            .fontWeight(.medium)
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
                                                    size: prop.isLargerScreen ? 18 : 13
                                                )
                                            )
                                            .foregroundStyle(.white)
                                            .fontWeight(.medium)
                                        
                                        SecureField("Password...", text: $loginPassword)
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 100,
                                                height: 40
                                            )
                                            .padding(.leading, prop.isLargerScreen ? 15 : 5)
                                            .background(
                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                    .borderBottomWLColor(isError: self.loginError)
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
                                            self.isLoggingIn = false
                                            
                                            /* TODO: Depending on the last "state" of the sign up section, configure the view accordingly here. */
                                            self.signupSection = "usecase"
                                        }) {
                                            HStack {
                                                Text("Sign In")
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .padding([.top, .bottom], 8)
                                                    .foregroundStyle(.white)
                                                    .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 18 : 16)
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
                                    .padding(8)
                                    //.padding(.top, prop.isLargerScreen ? 25 : 20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.black)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .padding(3)
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: 300)
                            .padding()
                            .padding(.top, 10)
                            
                            Text("Or")
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .center
                                )
                                .padding(.vertical) /* MARK: Since the above `ZStack` adds padding to all sides, we only need to add padding to `.bottom` here. */
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
                                self.signupSection = "usecase"
                            }) {
                                HStack {
                                    Text("Sign Up")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding([.top, .bottom], 8)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 22 : 20)
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
                                        //self.section = "credentials"
                                        //assignUDKey(key: "last_signup_section", value: self.section)
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
                                        //self.section = "credentials"
                                        //assignUDKey(key: "last_signup_section", value: self.section)
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
                                        //self.section = "credentials"
                                        //assignUDKey(key: "last_signup_section", value: self.section)
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
                            default: VStack { }.onAppear { self.signupSection = "usecase" }
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
                .background(.black)//Color.EZNotesBlack)
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
                        
                        if udKeyExists(key: "college_name") {
                            accountInfo.setCollegeName(collegeName: getUDValue(key: "college_name"))
                        }
                        
                        if udKeyExists(key: "major_name") {
                            accountInfo.setMajorName(majorName: getUDValue(key: "major_name"))
                        }
                        
                        if udKeyExists(key: "college_state") {
                            accountInfo.setCollegeState(collegeState: getUDValue(key: "college_state"))
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
                        
                        if UserDefaults.standard.object(forKey: "client_sub_id") != nil {
                            accountInfo.setClientSubID(subID: UserDefaults.standard.string(forKey: "client_sub_id")!)
                        }
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
