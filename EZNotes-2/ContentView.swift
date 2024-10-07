//
//  ContentView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//

import SwiftUI
import Combine
import UIKit
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
    @State public var userHasSignedIn: Bool = UserDefaults.standard.bool(forKey: "logged_in")
    @StateObject private var model: FrameHandler = FrameHandler()
    
    //private let rotationChangePublisher = NotificationCenter.default
        //.publisher(for: UIDevice.orientationDidChangeNotification)
    
    var body: some View {
        /*if !userHasSignedIn {
            StartupScreen(
                userHasSignedIn: $userHasSignedIn
            )
        } else {*/
            VStack {
                ResponsiveView { prop in
                    CoreApp(model: model, prop: prop)
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
        //}
    }
}

#Preview {
    ContentView()
}
