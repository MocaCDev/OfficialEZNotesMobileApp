//
//  ResponsiveView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI

struct ResponsiveView<Content: View>: View {
    var eventTypeToIgnore: SafeAreaRegions = .init() /* MARK: Ignore any. */
    var edgesToIgnore: Edge.Set = .init()
    
    var content: (Properties)->Content
    
    /* MARK: Needed to keep responsive sizes consistent with the devices geometry. */
    /* MARK: For example, when the keyboard is active the geometry of the view (in height) shrinks to accomdate the keyboard. */
    @State public var isLargerScreen: Bool = false
    @State public var lastHeight: CGFloat = 0
    @State public var screenHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let isLandScape = (size.width > size.height)
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            content(
                Properties(
                    isLandscape: isLandScape,
                    isIpad: isIpad,
                    size: size,
                    isLargerScreen: self.isLargerScreen
                )
            )
            .onAppear(perform: {
                self.isLargerScreen = size.height / 2.5 > 300
                self.lastHeight = size.height
                self.screenHeight = self.lastHeight
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                        // Handle denial of request.
                    }
                }
            })
            .onChange(of: size.height) {
                if size.height < self.lastHeight {
                    self.isLargerScreen = size.height / 2.5 > 200 || size.height / 2.5 > 180
                } else {
                    if size.height == self.screenHeight {
                        self.isLargerScreen = size.height / 2.5 > 300
                    } else {
                        self.isLargerScreen = size.height / 2.5 > 200
                    }
                }
            }
            .frame(
                width: size.width,
                height: size.height,
                alignment: .center
            )
        }
        .ignoresSafeArea(self.eventTypeToIgnore, edges: self.edgesToIgnore)
    }
}

struct Properties {
    var isLandscape: Bool
    var isIpad: Bool
    var size: CGSize
    var isLargerScreen: Bool
}
