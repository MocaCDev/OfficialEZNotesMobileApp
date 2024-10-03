//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

private extension View {
    func topNavSettings(prop: Properties, backgroundColor: Color) -> some View {
        self
            .frame(
                maxWidth: .infinity,
                maxHeight: prop.size.height / 2.5 > 300 ? 100 : 50
            )
            .background(backgroundColor.blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)
    }
}

private struct ProfileIconView: View {
    var prop: Properties
    
    var body: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(maxWidth: 30, maxHeight: 30)
            .padding([.leading], 20)
            .foregroundStyle(.white)
    }
}

struct TopNavHome: View {
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            ProfileIconView(prop: prop)
                .padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
            
            Spacer()
            
            Button(action: { print("POPUP!") }) {
                Image("AI-Chat-Icon")
                    .resizable()
                    .frame(
                        width: prop.size.height / 2.5 > 300 ? 55 : 50,
                        height: prop.size.height / 2.5 > 300 ? 55 : 50
                    )
                    .padding([.trailing], 20)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 45 : 15)
            }
            .buttonStyle(.borderless)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
    }
}

struct TopNavUpload: View {
    
    @Binding public var section: String
    @Binding public var lastSection: String
    @ObservedObject public var images_to_upload: ImagesUploads
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            ProfileIconView(prop: prop)
                .padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
            
            Spacer()
            
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
                    .padding([.top], prop.size.height / 2.5 > 300 ? 55 : 0)
                    .padding([.trailing], 20)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesBlue)//.buttonStyle(MyButtonStyle())
                    .opacity(!self.images_to_upload.images_to_upload.isEmpty ? 1 : 0)
                    
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
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
    }
}

struct TopNavChat: View {
    
    @Binding public var friendSearch: String
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            ProfileIconView(prop: prop)
                .padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
            
            Spacer()
            
            Button(action: { print("Adding Friend!") }) {
                Image("Add-Friend-Icon")
                    .resizable()
                    .frame(maxWidth: 25, maxHeight: 25)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
                    .foregroundStyle(.white)
                
                Text("Add Friend")
                    .padding([.trailing], 20)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 42 : 5)
                    .foregroundStyle(.white)
                    .font(.system(size: 12, design: .rounded))
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderless)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
            
        /*
            if self.section == "upload" {
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
                        .padding([.top], prop.size.height / 2.5 > 300 ? 60 : 0)
                        .padding([.trailing], 20)
                        .buttonStyle(.borderedProminent)
                        .tint(Color.EZNotesBlue)//.buttonStyle(MyButtonStyle())
                        .opacity(!self.images_to_upload.images_to_upload.isEmpty ? 1 : 0)
                        
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
            } else if self.section == "chat" {
                Spacer()
                Button(action: { print("Adding Friend!") }) {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(maxWidth: 30, maxHeight: 30)
                        .padding([.trailing], 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderless)
            } else {
                Button(action: { print("POPUP!") }) {
                    Image("AI-Chat-Icon")
                        .resizable()
                        .frame(
                            width: prop.size.height / 2.5 > 300 ? 50 : 45,
                            height: prop.size.height / 2.5 > 300 ? 50 : 45
                        )
                        .padding([.trailing], -22)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                    
                    Text("Chat")
                        .foregroundStyle(Color.EZNotesBlue)
                        .font(.system(size: 15, design: .monospaced))
                        .fontWeight(.medium)
                        .padding([.trailing], 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: prop.size.height / 2.5 > 300 ? 100 : 50
        )
        .background(backgroundColor.blur(radius: 3.5))
        .edgesIgnoringSafeArea(.top)
         */
    }
}
