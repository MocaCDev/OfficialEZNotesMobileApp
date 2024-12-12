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
    
    @State private var faceIDAuthenticated: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State public var reAuthReqFromLogin: Bool = false
    //@StateObject public var accountInfo: AccountDetails = AccountDetails()
    
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
    
    @StateObject public var categoryData: CategoryData = CategoryData()
    
    //@State private var messages: Array<MessageDetails> = []
    
    /* MARK: `UUID` will be the chat ID. */
    //@State private var temporaryStoredChats: [String: [UUID: Array<MessageDetails>]] = getTemporaryStoredChats()
    
    //private let rotationChangePublisher = NotificationCenter.default
        //.publisher(for: UIDevice.orientationDidChangeNotification)
    
    @State private var topBanner: TopBanner = .None
    //@State private var needsNoWifiBanner: Bool = false
    
    var body: some View {
        if !userHasSignedIn {
            StartupScreen(
                userHasSignedIn: $userHasSignedIn,
                userNotFound: $userNotFound,
                goBackToLogin: $goBackToLogin,
                faceIDAuthenticated: $faceIDAuthenticated
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
            })
        } else {
            VStack {
                if self.faceIDAuthenticated {
                    ResponsiveView { prop in
                        CoreApp(
                            prop: prop,
                            topBanner: $topBanner,
                            accountInfo: accountInfo,
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
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .inactive || scenePhase == .background {
                    UserDefaults.standard.set(true, forKey: "requires_faceID")
                }
            }
            .onAppear(perform: { /* MARK: The below code is placed in the `.onAppear`, regardless if the user logged in, signed up or just re-launched the app. All of the users data, unless further noticed, will be stored in `UserDefaults`. */
                // else {
                    RequestAction<ReqPlaceholder>(
                        parameters: ReqPlaceholder()
                    )
                    .perform(action: check_server_active_req)
                    { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            self.topBanner = .NoWifiConnection
                            return
                        }
                    }
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
