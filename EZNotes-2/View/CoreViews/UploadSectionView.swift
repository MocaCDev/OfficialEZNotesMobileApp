//
//  UploadSectionView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/30/24.
//
import SwiftUI

struct UploadSection: View {
    @State private var isFocused = false
    @State private var isScaled = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var loadingCameraView: Bool = false
    
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @ObservedObject public var model: FrameHandler
    
    @Binding public var lastSection: String
    @Binding public var section: String
    
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    
    var body: some View {
        VStack {
            TopNavUpload(
                accountInfo: accountInfo,
                section: $section,
                lastSection: $lastSection,
                userHasSignedIn: $userHasSignedIn,
                images_to_upload: images_to_upload,
                prop: prop,
                backgroundColor: Color.clear
            )
            
            if self.model.permissionGranted {
                if !self.model.cameraDeviceFound {
                    VStack {
                        VStack {
                            
                            Image(systemName: "exclamationmark.warninglight.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .padding([.top, .bottom], 15)
                                .foregroundStyle(Color.EZNotesRed)
                            
                            Text("Camera Device Not Found")
                                .frame(maxWidth: prop.size.width - 60, alignment: .center)
                                .setFontSizeAndWeight(weight: .medium, size: 30)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                            
                            Text("(Beta Testers) If you are using a older iPhone model, a iPhone with 2 lenses or have a older iOS version, please report this issue via TestFlight:\n\n• Open TestFlight on your iPhone\n• Select EZNotes-2\n• Select \"Send Feedback\"\n\t• Provide the iPhone model, iOS version and issue you are experiencing")
                                .frame(maxWidth: prop.size.width - 60, alignment: .center)
                                .padding(.top, 5)
                                .setFontSizeAndWeight(weight: .medium, size: 14)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    VStack {
                        VStack {
                            Button(action: {
                                if !self.loadingCameraView {
                                    self.images_to_upload.images_to_upload.append(
                                        ["\(arc4random()).jpeg": UIImage(cgImage: self.model.frame!)]
                                    )
                                }
                            }) {
                                ZStack {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .tint(!self.loadingCameraView ? Color.EZNotesBlue : Color.gray)
                                }
                            }
                            
                            Text("\(String(round(self.currentZoomFactor * 10.00) / 10.00))x")
                                .foregroundStyle(.white)
                                .padding([.bottom], prop.size.height / 2.5 > 300 ? -10 : -40)
                        }
                        .padding([.bottom], 40)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            } else {
                VStack {
                    VStack {
                        Text("Access to camera was denied.")
                            .frame(maxWidth: prop.size.width - 60, alignment: .center)
                            .setFontSizeAndWeight(weight: .medium, size: 30)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { self.model.requestPermission() }) {
                            Text("Allow access")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            ButtomNavbar(
                section: $section,
                backgroundColor: Color.EZNotesLightBlack.opacity(0.85),
                prop: prop
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            self.model.permissionGranted && self.model.cameraDeviceFound
            ? AnyView(FrameView(handler: model, image: model.frame, prop: prop, loadingCameraView: $loadingCameraView)
                .ignoresSafeArea()
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        self.currentZoomFactor += value - 1.0 // Calculate the zoom factor change
                        self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 20)
                        self.model.setScale(scale: currentZoomFactor)
                    }
                )
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.width < 0 {
                            self.section = "chat"
                            return
                        }
                        
                        if value.translation.width > 0 {
                            self.section = "home"
                            return
                        }
                    })
                )
            )
            : AnyView(Color.clear)
        )
        .onAppear(perform: { self.model.permissionGranted = false })
    }
}
