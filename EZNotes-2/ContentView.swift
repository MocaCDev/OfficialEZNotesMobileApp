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
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "FaceID is needed to allow access to the app."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    self.faceIDAuthenticated = true
                } else {
                    self.goBackToLogin = true
                    self.userHasSignedIn = false
                    
                    UserDefaults.standard.removeObject(forKey: "logged_in")
                    UserDefaults.standard.removeObject(forKey: "requires_faceID")
                }
            }
        } else {
            // no biometrics
        }
    }
    
    @State public var userHasSignedIn: Bool = UserDefaults.standard.bool(forKey: "logged_in")
    @State private var goBackToLogin: Bool = false
    @StateObject private var model: FrameHandler = FrameHandler()
    
    @State private var categoriesAndSets: [String: Array<String>] = getCategoryData() /* MARK: Key will be the category name, value will be the set names */
    @State private var categoryCreationDates: [String: Date] = getCategoryCreationDates()
    @State private var categoryImages: [String: UIImage] = getCategoriesImageData() /* MARK: Key will be the category name, value will be the categories image (first uploaded image for category). */
    @State private var categoryDescriptions: [String: String] = getCategoryDescriptions()
    @State private var categoryCustomColors: [String: Color] = getCategoryCustomColors()
    
    /* MARK: The below colors will apply only to text that is on the top of the right-side of the category details. */
    @State private var categoryCustomTextColors: [String: Color] = getCategoryCustomTextColors()
    
    //private let rotationChangePublisher = NotificationCenter.default
        //.publisher(for: UIDevice.orientationDidChangeNotification)
    
    var body: some View {
        if !userHasSignedIn {
            StartupScreen(
                userHasSignedIn: $userHasSignedIn
            )
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
                            categoryCustomTextColors: $categoryCustomTextColors
                        )
                    }
                } else {
                    if self.goBackToLogin {
                        StartupScreen(
                            userHasSignedIn: $userHasSignedIn
                        )
                    } else {
                        VStack {
                            Text("Unlock With FaceID")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .font(.system(size: 30, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Image("Background")
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
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .inactive || newPhase == .background {
                    UserDefaults.standard.set(true, forKey: "requires_faceID")
                }
            }
            .onAppear(perform: {
                if UserDefaults.standard.bool(forKey: "requires_faceID") {
                    self.faceIDAuthenticated = false
                    authenticate()
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
