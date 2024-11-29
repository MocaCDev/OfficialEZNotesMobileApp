//
//  UploadSectionView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/30/24.
//
import SwiftUI

struct UploadSection: View {
    @EnvironmentObject private var categoryData: CategoryData
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    /* MARK: `topBanner` helps the view know what to display in it's banner (located to the right of the profile icon). */
    @Binding public var topBanner: TopBanner
    
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
    @State private var arrowUpAnimation: Bool = false
    
    @State private var showAccount: Bool = false
    
    var body: some View {
        if !self.showAccount {
            VStack {
                TopNavUpload(
                    topBanner: $topBanner,
                    categoryData: self.categoryData,
                    imagesToUpload: self.images_to_upload,
                    accountInfo: accountInfo,
                    showAccountPopup: $showAccount,
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
                                            
                                            Image(systemName: "chevron.up")
                                                .resizable()
                                                .frame(width: 15, height: 10)
                                                .offset(y: self.arrowUpAnimation ? 8 : 0)
                                                .animation(.easeIn(duration: 1.3), value: self.arrowUpAnimation)
                                                .animation(.easeOut(duration: 1.3), value: !self.arrowUpAnimation)
                                                .onAppear {
                                                    self.arrowUpAnimation.toggle()
                                                    
                                                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                                                        self.arrowUpAnimation.toggle()
                                                    }
                                                }
                                                .padding(.bottom, 5)
                                            
                                            Button(action: { self.showEntireSidePreview = true }) {
                                                Image(uiImage: self.images_to_upload.images_to_upload.first![self.images_to_upload.images_to_upload.first!.keys.first!]!)
                                                    .resizable()
                                                    .frame(width: 60, height: 100)
                                                    .scaledToFit()
                                                    .cornerRadius(15)
                                            }
                                            .padding(.bottom, 35)
                                        } else {
                                            Spacer()
                                            
                                            VStack {
                                                HStack {
                                                    Button(action: { self.showEntireSidePreview = false }) {
                                                        ZStack {
                                                            Image(systemName: "multiply")
                                                                .resizable()
                                                                .frame(width: 15, height: 15)
                                                                .foregroundStyle(.black)
                                                                .padding(4)
                                                                .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                .clipShape(.circle)
                                                        }
                                                        .frame(width: 30, height: 30, alignment: .leading)
                                                        .padding(.leading, 10)
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.top, 10)
                                                
                                                ScrollView(.vertical, showsIndicators: true) {
                                                    VStack {
                                                        ForEach(Array(self.images_to_upload.images_to_upload.enumerated()), id: \.offset) { index, value in
                                                            ForEach(Array(self.images_to_upload.images_to_upload[index].keys), id: \.self) { key in
                                                                Image(uiImage: self.images_to_upload.images_to_upload[index][key]!)
                                                                    .resizable()
                                                                    .frame(width: prop.isLargerScreen ? 80 : 60, height: prop.isLargerScreen ? 120 : 100)
                                                                    .scaledToFit()
                                                                    .cornerRadius(15)
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                }
                                                .frame(maxWidth: prop.size.height, alignment: .top)
                                                
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).shadow(color: Color.black, radius: 1.5))
                                            .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, self.showEntireSidePreview ? 0 : 15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                                targetX = CGFloat.random(in: -4...8) // Random X offset
                                targetY = CGFloat.random(in: -4...8) // Random Y offset
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
                
                if self.images_to_upload.images_to_upload.count == 0 {
                    ButtomNavbar(
                        section: $section,
                        backgroundColor: !(self.model.permissionGranted && self.model.cameraDeviceFound) ? Color.EZNotesBlack : Color.EZNotesLightBlack.opacity(0.85),
                        prop: prop
                    )
                } else {
                    VStack {
                        HStack {
                            Button(action: { self.images_to_upload.images_to_upload.removeAll() }) {
                                ZStack {
                                    HStack {
                                        Text("Remove All")
                                            .frame(alignment: .center)
                                            .padding(8)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .medium, size: 18)
                                            .minimumScaleFactor(0.5)
                                        
                                        Image(systemName: "trash")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.top, .bottom], 5)
                                .background(Color.EZNotesLightBlack.opacity(0.8))
                                .cornerRadius(20)
                                .padding(.leading, 10)
                            }
                            
                            Button(action: {
                                self.lastSection = self.section
                                self.section = "upload_review"
                            }) {
                                HStack {
                                    HStack {
                                        Text("Review")
                                            .frame(alignment: .center)
                                            .padding(8)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .medium, size: 18)
                                            .minimumScaleFactor(0.5)
                                        
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding([.top, .bottom], 5)
                                .background(Color.EZNotesLightBlack.opacity(0.8))
                                .cornerRadius(20)
                                .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 70, alignment: .bottom)
                    .background(Color.EZNotesBlack)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .edgesIgnoringSafeArea([.bottom])
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
        } else {
            Account(
                prop: self.prop,
                showAccount: $showAccount,
                userHasSignedIn: $userHasSignedIn,
                accountInfo: self.accountInfo
            )
        }
        //.onAppear(perform: { self.model.permissionGranted = false })
    }
}
