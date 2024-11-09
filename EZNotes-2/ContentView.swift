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
    @State private var faceIDAuthenticated: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State public var reAuthReqFromLogin: Bool = false
    @StateObject public var accountInfo: AccountDetails = AccountDetails()
    
    init() {
        StripeAPI.defaultPublishableKey = "pk_test_51OdoXSDNLx34I7Pu22ELrZac5NUd5lrs8EXqK96SFOUJM6wZqOe8HQxyH0f3CR8emsCAVwQiqStwTWyGhCj1wRtM00T1fR9V2D"
    }
    
    public func authenticate(initializing: Bool) {
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
    }
    
    @State public var userHasSignedIn: Bool = UserDefaults.standard.bool(forKey: "logged_in")
    @State public var userNotFound: Bool = false
    @State private var goBackToLogin: Bool = false
    @StateObject private var model: FrameHandler = FrameHandler()
    
    @State private var categoriesAndSets: [String: Array<String>] = getCategoryData() /* MARK: Key will be the category name, value will be the set names */
    @State private var categoryCreationDates: [String: Date] = getCategoryCreationDates()
    @State private var categoryImages: [String: UIImage] = getCategoriesImageData() /* MARK: Key will be the category name, value will be the categories image (first uploaded image for category). */
    @State private var categoryDescriptions: [String: String] = getCategoryDescriptions()
    @State private var categoryCustomColors: [String: Color] = getCategoryCustomColors()
    
    /* MARK: The below colors will apply only to text that is on the top of the right-side of the category details. */
    @State private var categoryCustomTextColors: [String: Color] = getCategoryCustomTextColors()
    
    /* MARK: `UUID` will be the chat ID. */
    @State private var temporaryStoredChats: [String: [UUID: Array<MessageDetails>]] = getTemporaryStoredChats()
    
    @State private var messages: Array<MessageDetails> = []
    
    //private let rotationChangePublisher = NotificationCenter.default
        //.publisher(for: UIDevice.orientationDidChangeNotification)
    
    var body: some View {
        if !userHasSignedIn {
            StartupScreen(
                userHasSignedIn: $userHasSignedIn,
                userNotFound: $userNotFound,
                goBackToLogin: $goBackToLogin,
                faceIDAuthenticated: $faceIDAuthenticated
            )
            .onAppear(perform: {
                if UserDefaults.standard.object(forKey: "faceID_enabled") == nil {
                    UserDefaults.standard.set("not_enabled", forKey: "faceID_enabled")
                    UserDefaults.standard.set(false, forKey: "faceID_initialized")
                }
            })
        } else {
            VStack {
                if self.faceIDAuthenticated {
                    ResponsiveView { prop in
                        CoreApp(
                            model: model,
                            prop: prop,
                            categoriesAndSets: $categoriesAndSets,
                            categoryCreationDates: $categoryCreationDates,
                            categoryImages: $categoryImages,
                            categoryDescriptions: $categoryDescriptions,
                            categoryCustomColors: $categoryCustomColors,
                            categoryCustomTextColors: $categoryCustomTextColors,
                            accountInfo: accountInfo,
                            userHasSignedIn: $userHasSignedIn,
                            tempChatHistory: $temporaryStoredChats
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
                }
                /* TODO: Add "Core.swift". */
                //ResponsiveView { prop in
                    //CoreApp()
                //}
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.onReceive(rotationChangePublisher) { _ in
                    // This is called when there is a orientation change
                    // You can set back the orientation to the one you like even
                    // if the user has turned around their phone to use another
                    // orientation.
                    //if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    //    delegate.orientationLock = .portrait
                    //}//UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                //}
            }
            .onChange(of: scenePhase) {
                if scenePhase == .inactive || scenePhase == .background {
                    UserDefaults.standard.set(true, forKey: "requires_faceID")
                }
            }
            .onAppear(perform: {
                /* MARK: If this `.onAppear` runs, there should be a key `username` in `UserDefaults.standard`. If there isn't, then there is a problem.
                 * */
                if UserDefaults.standard.object(forKey: "username") != nil {
                    accountInfo.setUsername(username: UserDefaults.standard.string(forKey: "username")!)
                }
                
                if UserDefaults.standard.object(forKey: "email") != nil {
                    accountInfo.setEmail(email: UserDefaults.standard.string(forKey: "email")!)
                }
                
                if UserDefaults.standard.object(forKey: "college_name") != nil {
                    accountInfo.setCollegeName(collegeName: UserDefaults.standard.string(forKey: "college_name")!)
                }
                
                if UserDefaults.standard.object(forKey: "major_name") != nil {
                    accountInfo.setMajorName(majorName: UserDefaults.standard.string(forKey: "major_name")!)
                }
                
                if UserDefaults.standard.object(forKey: "college_state") != nil {
                    accountInfo.setCollegeState(collegeState: UserDefaults.standard.string(forKey: "college_state")!)
                }
                
                if UserDefaults.standard.object(forKey: "account_id") != nil {
                    accountInfo.setAccountID(accountID: UserDefaults.standard.string(forKey: "account_id")!)
                    
                    PFP(accountID: UserDefaults.standard.string(forKey: "account_id"))
                        .requestGetPFP() { statusCode, pfp, resp in
                            guard pfp != nil && statusCode == 200 else {
                                guard resp != nil else { return }
                                
                                if resp!["ErrorCode"] as! Int == 0x6966 {
                                    UserDefaults.standard.removeObject(forKey: "username")
                                    UserDefaults.standard.removeObject(forKey: "email")
                                    UserDefaults.standard.removeObject(forKey: "client_id")
                                    UserDefaults.standard.removeObject(forKey: "account_id")
                                    UserDefaults.standard.set(false, forKey: "logged_in")
                                    self.userHasSignedIn = false
                                    self.userNotFound = true
                                }
                                
                                return
                            }
                            
                            accountInfo.setProfilePicture(pfp: UIImage(data: pfp!)!)
                        }
                    
                    PFP(accountID: UserDefaults.standard.string(forKey: "account_id"))
                        .requestGetPFPBg() { statusCode, pfp_bg in
                            guard pfp_bg != nil && statusCode == 200 else { return }
                            
                            accountInfo.setProfilePictureBackground(bg: UIImage(data: pfp_bg!)!)
                        }
                }
                
                if UserDefaults.standard.object(forKey: "client_sub_id") != nil {
                    accountInfo.setClientSubID(subID: UserDefaults.standard.string(forKey: "client_sub_id")!)
                }
                
                if UserDefaults.standard.string(forKey: "faceID_enabled") == "enabled" {
                    if !(UserDefaults.standard.bool(forKey: "faceID_initialized")) {
                        authenticate(initializing: true)
                    } else {
                        self.faceIDAuthenticated = false
                        authenticate(initializing: false)
                    }
                } else {
                    self.faceIDAuthenticated = true
                }
            })
        }
    }
}

#Preview {
    ContentView()
}
