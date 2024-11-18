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
    
    @State private var targetX: CGFloat = 0
    @State private var targetY: CGFloat = 0
    @State private var showEntireSidePreview: Bool = false
    
    var body: some View {
        VStack {
            TopNavUpload(
                accountInfo: accountInfo,
                section: $section,
                lastSection: $lastSection,
                userHasSignedIn: $userHasSignedIn,
                images_to_upload: images_to_upload,
                prop: prop,
                backgroundColor: !(self.model.permissionGranted && self.model.cameraDeviceFound) ? Color.black : Color.clear
            )
            .background(!(self.model.permissionGranted && self.model.cameraDeviceFound) ? Color.EZNotesBlack : Color.clear)
            
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
                        //VStack { }.frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            VStack { }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack {
                                Spacer()
                                
                                Button(action: {
                                    if !self.loadingCameraView {
                                        self.images_to_upload.images_to_upload.append(
                                            ["\(arc4random()).jpeg": UIImage(cgImage: self.model.frame!)]
                                        )
                                    }
                                }) {
                                    /*ZStack {
                                        Image(systemName: "circle")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .tint(!self.loadingCameraView ? Color.EZNotesBlue : Color.gray)
                                    }*/
                                    ZStack {
                                        Circle()
                                            .fill(
                                        MeshGradient(width: 3, height: 3, points: [
                                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                                        ], colors: [
                                            .indigo, .indigo, Color.EZNotesBlue,
                                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                            /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                             Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                             Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                        ]))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .blur(radius: 10)
                                        .offset(x: targetX, y: targetY) // Offset controlled by targetX and targetY
                                        .animation(
                                            .easeInOut(duration: 0.4), // Smooth animation
                                            value: targetX
                                        )
                                        .animation(
                                            .easeInOut(duration: 0.4), // Smooth animation
                                            value: targetY
                                        )
                                        
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 90, height: 90)
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Text("\(String(round(self.currentZoomFactor * 10.00) / 10.00))x")
                                    .foregroundStyle(.white)
                                    .padding([.bottom], prop.size.height / 2.5 > 300 ? -10 : -40)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 20)
                            
                            VStack {
                                if self.images_to_upload.images_to_upload.count > 0 {
                                    if !self.showEntireSidePreview {
                                        Spacer()
                                        
                                        Image(uiImage: self.images_to_upload.images_to_upload.first![self.images_to_upload.images_to_upload.first!.keys.first!]!)
                                         .resizable()
                                         .scaledToFit()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        /*VStack {
                            Button(action: {
                                if !self.loadingCameraView {
                                    self.images_to_upload.images_to_upload.append(
                                        ["\(arc4random()).jpeg": UIImage(cgImage: self.model.frame!)]
                                    )
                                }
                            }) {
                                /*ZStack {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .tint(!self.loadingCameraView ? Color.EZNotesBlue : Color.gray)
                                }*/
                                ZStack {
                                    Circle()
                                        .fill(
                                    MeshGradient(width: 3, height: 3, points: [
                                        .init(0, 0), .init(0.3, 0), .init(1, 0),
                                        .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                                    ], colors: [
                                        .indigo, .indigo, Color.EZNotesBlue,
                                        Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                        .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                        /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                         Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                         Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                    ]))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .blur(radius: 10)
                                    .offset(x: targetX, y: targetY) // Offset controlled by targetX and targetY
                                    .animation(
                                        .easeInOut(duration: 0.4), // Smooth animation
                                        value: targetX
                                    )
                                    .animation(
                                        .easeInOut(duration: 0.4), // Smooth animation
                                        value: targetY
                                    )
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 90, height: 90)
                                }
                                .frame(width: 100, height: 100)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Text("\(String(round(self.currentZoomFactor * 10.00) / 10.00))x")
                                .foregroundStyle(.white)
                                .padding([.bottom], prop.size.height / 2.5 > 300 ? -10 : -40)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.bottom], self.images_to_upload.images_to_upload.count == 0 ? 40 : 20)*/
                        
                        /*VStack {
                            if self.images_to_upload.images_to_upload.count > 0 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(Array(self.images_to_upload.images_to_upload.enumerated()), id: \.offset) { index, value in
                                            ForEach(Array(self.images_to_upload.images_to_upload[index].keys), id: \.self) { key in
                                                Image(uiImage: self.images_to_upload.images_to_upload[index][key]!)
                                                    .resizable()
                                                    .frame(width: 80, height: 40)
                                                    .scaledToFit()
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }.frame(maxWidth: prop.size.width - 40, alignment: .trailing)//.padding(.trailing, 15)*/
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                            if self.section != "upload" {
                                timer.invalidate() // Stop the timer when animation is off
                            } else {
                                targetX = CGFloat.random(in: -4...8) // Random X offset
                                targetY = CGFloat.random(in: -4...8) // Random Y offset
                            }
                        }
                    }
                }
            } else {
                VStack {
                    VStack {
                        Image(systemName: "exclamationmark.warninglight.fill")
                            .resizable()
                            .frame(width: 65, height: 60)
                            .padding([.top, .bottom], 15)
                            .foregroundStyle(Color.EZNotesRed)
                        
                        Text("Access to camera was denied.")
                            .frame(maxWidth: prop.size.width - 60, alignment: .center)
                            .foregroundColor(.white)
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
                backgroundColor: !(self.model.permissionGranted && self.model.cameraDeviceFound) ? Color.EZNotesBlack : Color.EZNotesLightBlack.opacity(0.85),
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
                .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
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
            : AnyView(Color.EZNotesBlack)
        )
        //.onAppear(perform: { self.model.permissionGranted = false })
    }
}
