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
                maxHeight: prop.size.height / 2.5 > 300 ? 50 : 50
            )
            .background(backgroundColor.opacity(0.1).blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)
    }
}

struct ProfileIconView: View {
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
    var categoriesAndSets: [String: Array<String>]
    //@Binding public var show_categories_title: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    ProfileIconView(prop: prop)
                        //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 45)//.padding([.bottom], 10)
                
                Spacer()
                
                /* TODO: Change the below `Text` to a search bar (`TextField`) where user can search for specific categories.
                 * */
                VStack {
                    Text("View Categories")
                        .foregroundStyle(.primary)
                        .font(.system(size: 22, design: .rounded))
                        .fontWeight(.thin)
                    
                    Text("Total: \(self.categoriesAndSets.count)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                    //.padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
                    //.padding([.bottom], -5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top], prop.size.height > 340 ? 50 : 45)
                
                Spacer()
                
                VStack {
                    Button(action: { print("POPUP!") }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                height: prop.size.height / 2.5 > 300 ? 45 : 40
                            )
                            .padding([.trailing], 20)
                            //.padding([.top], prop.size.height / 2.5 > 300 ? 45 : 15)
                    }
                    .buttonStyle(.borderless)
                }
                .frame(maxWidth: 50, alignment: .trailing)
                .padding([.top], 45)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
            .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))//(.ultraThinMaterial, in: Color.EZNotesBlack)//.background(Color.clear.blur(radius: 4, opaque: true))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .zIndex(1)
    }
}

struct TopNavCategoryView: View {
    
    var prop: Properties
    var categoryName: String
    var totalSets: Int
    
    @Binding public var launchCategory: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: { self.launchCategory = false }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .tint(Color.EZNotesBlue)
                    }
                    .padding([.leading], 20)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 45)
                
                Spacer()
                
                VStack {
                    Text(categoryName)
                        .foregroundStyle(.primary)
                        .font(.system(size: 22, design: .rounded))
                        .fontWeight(.thin)
                    
                    Text("Sets: \(self.totalSets)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top], prop.size.height > 340 ? 50 : 45)
                
                Spacer()
                
                VStack {
                    Button(action: { print("POPUP!") }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                height: prop.size.height / 2.5 > 300 ? 45 : 40
                            )
                            .padding([.trailing], 20)
                            //.padding([.top], prop.size.height / 2.5 > 300 ? 45 : 15)
                    }
                    .buttonStyle(.borderless)
                }
                .frame(maxWidth: 50, alignment: .trailing)
                .padding([.top], 45)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
            .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .zIndex(1)
    }
}

struct TopNavUpload: View {
    
    @Binding public var section: String
    @Binding public var lastSection: String
    
    @Binding public var images_to_upload: Array<[String: UIImage]>
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop)
            }
            .padding([.bottom], 10)
            
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
                    .padding([.top], prop.size.height / 2.5 > 300 ? 5 : 0)
                    .padding([.trailing], 20)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesBlue)//.buttonStyle(MyButtonStyle())
                    .opacity(!self.images_to_upload.isEmpty ? 1 : 0)
                    
                }
                .frame(width: 200, height: 40, alignment: .topTrailing)
                /*.background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.EZNotesBlack)
                        .stroke(.white, lineWidth: 1)
                        .padding([.trailing], 28)
                        //.padding([.top], 54)
                        .opacity(0.5)
                )*/
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(.clear)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}

struct TopNavChat: View {
    
    @Binding public var friendSearch: String
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop)
                //.padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
            }
            .padding([.bottom], 10)
            
            Spacer()
            
            VStack {
                Button(action: { print("Adding Friend!") }) {
                    Image("Add-Friend-Icon")
                        .resizable()
                        .frame(maxWidth: 25, maxHeight: 25)
                        //.padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
                        .foregroundStyle(.white)
                    
                    Text("Add Friend")
                        .padding([.trailing], 20)
                        //.padding([.top], prop.size.height / 2.5 > 300 ? 42 : 5)
                        .foregroundStyle(.white)
                        .font(.system(size: 12, design: .rounded))
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderless)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding([.bottom], 10)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
            
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
