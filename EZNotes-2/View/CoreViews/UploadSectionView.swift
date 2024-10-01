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
            VStack {
                VStack {
                    Button(action: {
                        print("Uploading")
                        /* TODO: Add screen the shows a loading circle while the images are being processed. */
                        /* TODO: Since the user can upload multiple images that are the same thing, we need to add a screen that
                         * TODO: enables users to review the upload to avoid repetitive categories from being created.
                         * */
                        /*UploadImages(imageUpload: images_to_upload)
                         .requestNativeImageUpload() { resp in
                         if resp.Bad != nil {
                         print("BAD RESPONSE: \(resp.Bad!)")
                         } else {
                         print("Category: \(resp.Good!.category)\nSet Name: \(resp.Good!.set_name)\nContent: \(resp.Good!.image_content)")
                         }
                         }*/
                        self.lastSection = self.section
                        self.section = "upload_review"
                    }) {
                        Text("Review")
                            .padding(5)
                            .foregroundStyle(.white)
                            .frame(width: 75, height: 20)
                    }
                    .padding([.top, .trailing], 20)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesBlue)//.buttonStyle(MyButtonStyle())
                    .opacity(images_to_upload.images_to_upload.count > 0 ? 1 : 0)
                    
                }
                .frame(width: 200, height: 40, alignment: .topTrailing)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.EZNotesBlack)
                        .stroke(.white, lineWidth: 1)
                        .padding([.trailing], 28)
                        .padding([.top], 54)
                        .opacity(0.5)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(.clear)
            
            VStack {
                VStack {
                    Button(action: {
                        images_to_upload.images_to_upload.append(
                            UIImage(
                                cgImage: model.frame!
                            ))
                    }) {
                        ZStack {
                            /*RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .frame(maxWidth: 110, maxHeight: 65)
                                .opacity(0.35)*/
                            
                            Image("Camera-Icon")
                                .resizable()
                                .frame(maxWidth: 135, maxHeight: 135)
                        }
                    }
                    
                    Text(String(round(self.model.frameScale * 10.00) / 10.00) + "x")
                        .foregroundStyle(.white)
                        .padding([.bottom], -10)
                }
                .padding([.bottom], 100)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            FrameView(handler: model, image: model.frame, prop: prop)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
