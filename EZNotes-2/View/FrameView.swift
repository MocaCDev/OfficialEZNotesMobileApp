//
//  FrameView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/27/24.
//
import SwiftUI

struct FrameView: View {
    var handler: FrameHandler
    var image: CGImage?
    var prop: Properties
    private let label = Text("frame")
    
    var body: some View {
        if let image = image {
            Image(image, scale: handler.frameScale, orientation: .up, label: label)
                .interpolation(.high)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(handler.currentZoom + handler.frameScale)
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(contentMode: .fill)
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
