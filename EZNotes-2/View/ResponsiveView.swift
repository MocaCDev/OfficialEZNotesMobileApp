//
//  ResponsiveView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI

struct ResponsiveView<Content: View>: View {
    var content: (Properties)->Content
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let isLandScape = (size.width > size.height)
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            
            content(
                Properties(
                    isLandscape: isLandScape,
                    isIpad: isIpad,
                    size: size
                )
            )
            .onAppear(perform: {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                        // Handle denial of request.
                    }
                }
            })
            .frame(
                width: size.width,
                height: size.height,
                alignment: .center
            )
        }
    }
}

struct Properties {
    var isLandscape: Bool
    var isIpad: Bool
    var size: CGSize
}
