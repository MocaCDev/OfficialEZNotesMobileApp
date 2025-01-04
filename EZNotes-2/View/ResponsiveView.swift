//
//  ResponsiveView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI

struct Properties {
    var isLandscape: Bool
    var isIpad: Bool
    var size: CGSize
    var isLargerScreen: Bool
    var isMediumScreen: Bool
    var isSmallScreen: Bool
}

struct ResponsiveView<Content: View>: View {
    var eventTypeToIgnore: SafeAreaRegions = .init() /* MARK: Ignore any. */
    var edgesToIgnore: Edge.Set = .init()
    
    var content: (Properties)->Content
    
    /* MARK: Needed to keep responsive sizes consistent with the devices geometry. */
    /* MARK: For example, when the keyboard is active the geometry of the view (in height) shrinks to accomdate the keyboard. */
    @State public var isLargerScreen: Bool = false
    @State public var isMediumScreen: Bool = false
    @State public var isSmallScreen: Bool = false
    
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
                    isLargerScreen: self.isLargerScreen,
                    isMediumScreen: self.isMediumScreen,
                    isSmallScreen: self.isSmallScreen
                )
            )
            .onAppear(perform: {
                self.isLargerScreen = size.height / 2.5 >= 338
                
                /* MARK: Medium sized iPhone screens will be between 305.2 and 338 when dividing the height by 2.5. 338, as seen above, indicates a larger screen. */
                self.isMediumScreen = size.height / 2.5 >= 305.2 && size.height / 2.5 < 338
                self.isSmallScreen = !self.isLargerScreen && !self.isMediumScreen
                
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
                    self.isMediumScreen = (size.height / 2.5 >= 177 && size.height / 2.5 < 180) || (size.height / 2.5 >= 147.2 && size.height / 2.5 <= 177)
                    self.isSmallScreen = !self.isLargerScreen && !self.isMediumScreen
                    
                    print(self.isLargerScreen, self.isMediumScreen, self.isSmallScreen)
                } else {
                    if size.height == self.screenHeight {
                        self.isLargerScreen = size.height / 2.5 > 338
                        self.isMediumScreen = size.height / 2.5 >= 305.2 && size.height / 2.5 < 338
                        self.isSmallScreen = !self.isLargerScreen && !self.isMediumScreen
                    } else {
                        self.isLargerScreen = size.height / 2.5 > 200
                        self.isMediumScreen = size.height / 2.5 >= 177 && size.height / 2.5 < 200
                        self.isSmallScreen = !self.isLargerScreen && !self.isMediumScreen
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
