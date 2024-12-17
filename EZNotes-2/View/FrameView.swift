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
    
    @Binding public var loadingCameraView: Bool
    
    var body: some View {
        if let image = image {
            Image(image, scale: 1, orientation: .up, label: label)
                .interpolation(.high)
                .resizable()
                .aspectRatio(contentMode: .fill)//scaledToFit()
                .onAppear(perform: { self.loadingCameraView = false })
        } else {
            if self.handler.permissionGranted {
                VStack {
                    VStack {
                        ProgressView()
                            .tint(Color.EZNotesBlue)
                            .frame(width: 25, height: 25)
                            .controlSize(.large)
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesBlack.opacity(0.75))
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesLightBlack)
                .onAppear(perform: { self.loadingCameraView = true })
            } else { /* MARK: builtInTelephotoCamera */
                VStack {
                    VStack {
                        Text("Camera Access Denied")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, design: .rounded))
                    }
                    .frame(width: 200, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesBlack.opacity(0.75))
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesLightBlack)
            }
        }
    }
}
