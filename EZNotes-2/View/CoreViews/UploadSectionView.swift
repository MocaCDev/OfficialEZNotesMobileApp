//
//  UploadSectionView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/30/24.
//
import SwiftUI

struct UploadSection: View {
    @ObservedObject public var images_to_upload: ImagesUploads
    @ObservedObject public var model: FrameHandler
    
    @Binding public var lastSection: String
    @Binding public var section: String
    
    var prop: Properties
    
    var body: some View {
        VStack {
            TopNavUpload(
                section: $section,
                lastSection: $lastSection,
                images_to_upload: images_to_upload,
                prop: prop,
                backgroundColor: Color.clear
            )
            
            VStack {
                VStack {
                    Button(action: {
                        let width = self.model.frame!.width
                        let height = self.model.frame!.height
                        
                        // Calculate the cropped rectangle based on the zoom scale
                        let cropWidth = CGFloat(width) / self.model.frameScale
                        let cropHeight = CGFloat(height) / self.model.frameScale
                        let cropRect = CGRect(x: (CGFloat(width) - cropWidth) / 2,
                                              y: (CGFloat(height) - cropHeight) / 2,
                                              width: cropWidth,
                                              height: cropHeight)
                        
                        guard let croppedCGImage = self.model.frame!.cropping(to: cropRect) else {
                            self.section = "picture_error"
                            return
                        }
                        
                        self.images_to_upload.images_to_upload.append(
                            ["\(arc4random()).jpeg": UIImage(cgImage: croppedCGImage)]
                        )
                    }) {
                        ZStack {
                            /*RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .frame(maxWidth: 110, maxHeight: 65)
                                .opacity(0.35)*/
                            
                            /*Image("Camera-Icon")
                                .resizable()
                                .frame(maxWidth: 135, maxHeight: 135)*/
                            Image(systemName: "circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .tint(Color.EZNotesBlue)
                        }
                    }
                    
                    Text("\(String(round(self.model.frameScale * 10.00) / 10.00))x")
                        .foregroundStyle(.white)
                        .padding([.bottom], prop.size.height / 2.5 > 300 ? -10 : -40)
                }
                .padding([.bottom], 40)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            /*VStack {
                HStack(spacing: 5) {
                    Spacer()
                    
                    VStack {
                        Button(action: { self.section = "home" }) {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 30, height: 25)
                                .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                                .foregroundStyle(self.section != "home" ? Color.EZNotesBlue : Color.white)
                        }
                        .buttonStyle(.borderless)
                        Text("Categories")
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading], 15)
                    
                    Spacer()
                    //Spacer()
                    
                    VStack {
                        Button(action: { self.section = "upload" }) {
                            if self.section != "upload" {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                                    .foregroundStyle(Color.EZNotesBlue)
                            } else {
                                Image("History-Icon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding([.top], prop.size.height / 2.5 > 300 ? 15 : 5)
                            }
                        }
                        .buttonStyle(.borderless)
                        
                        Text(self.section != "upload" ? "Upload" : "History")
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    //Spacer()
                    
                    VStack {
                        Button(action: { self.section = "chat" }) {
                            Image(systemName: "message")//self.section != "chat" ? "Chat" : "Chat-Active")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                                .foregroundStyle(self.section != "chat" ? Color.EZNotesBlue : Color.white)
                        }
                        .buttonStyle(.borderless)
                        Text("Chat")
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing], 20)
                    
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: prop.size.height / 2.5 > 300 ? 40 : 45
                )
                .background(
                    Rectangle()
                        .fill(Color.EZNotesLightBlack.opacity(self.section == "upload" ? 0.85 : 1))
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .border(width: 0.2, edges: [.top], color: .white)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(Color.EZNotesLightBlack.opacity(0.85))*/
            ButtomNavbar(
                section: $section,
                backgroundColor: Color.EZNotesLightBlack.opacity(0.85),
                prop: prop
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            FrameView(handler: model, image: model.frame, prop: prop)
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .gesture(MagnifyGesture()
                    .onChanged { value in
                        if !(self.model.frameScale + self.model.currentZoom <= 1) && !(self.model.frameScale + self.model.currentZoom >= 6)
                        {
                            self.model.currentZoom = value.magnification - 1
                        }
                    }
                    .onEnded { value in
                        if !(self.model.frameScale + self.model.currentZoom < 1) && !(self.model.frameScale + self.model.currentZoom > 6) {
                            self.model.frameScale += self.model.currentZoom
                        } else {
                            if self.model.frameScale + self.model.currentZoom < 1
                            { self.model.frameScale = 1.01 }
                            else { self.model.frameScale = 5.9 }
                        }
                        self.model.currentZoom = 0
                    }
                )
                .accessibilityZoomAction { action in
                    if action.direction == .zoomIn {
                        print(self.model.frameScale)
                        self.model.frameScale += 1
                    } else {
                        print(self.model.frameScale)
                        self.model.frameScale -= 1
                    }
                }
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
    }
}
