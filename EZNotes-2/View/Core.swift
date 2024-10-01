//
//  Core.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/27/24.
//
import SwiftUI

extension Circle {
    func imageZoonSettingStyle() -> some View {
        self//.stroke(.white, lineWidth: 1)
            .fill(.clear)
            .frame(width: 35, height: 35)
            .opacity(0.5)
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

class ImagesUploads: ObservableObject {
    @Published var images_to_upload: Array<UIImage> = []
}

struct RightSideMenuButtonStyle: ButtonStyle {
    var fillColor: Color = Color.EZNotesBlue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                Circle()
                    .fill(configuration.isPressed
                        ? fillColor : Color.clear)
            )
    }
}

struct CoreApp: View {
    @StateObject public var model: FrameHandler
    public var prop: Properties
    
    @StateObject var images_to_upload: ImagesUploads = ImagesUploads() //@State private var images_to_upload: Array<UIImage> = []
    @State private var images: Array<UIImage> = []
    @State private var images_to_ignore: Array<Int> = []
    @State private var change = 0.0
    @State private var currentZoom: Double = 0.0
    @State private var localUpload: Bool = true
    
    @State private var categories: Array<String> = []
    @State private var sets: Array<String> = []
    
    /* MARK: Custom divider for menu at top-right of screen. */
    @ViewBuilder
    func RightSideMenuDivider() -> some View {
        Color.EZNotesBlue.frame(width: 30, height: 1 / UIScreen.main.scale)
            .padding([.trailing], 20)
            .padding([.top, .bottom], 3)
    }
    
    /* MARK: Automated button-creation for menu at top-right of screen. (reduces code size) */
    @ViewBuilder
    func RightSideMenuButton(menuButtonTitle: String, action: @escaping () -> Void) -> some View {
        Button(action: { action(); }) {
            Text(menuButtonTitle)
                .foregroundStyle(Color.EZNotesOrange)
                .font(.system(size: 15))
                .frame(width: 45, height: 45)
        }
        .buttonStyle(.borderless)
        //.buttonStyle(RightSideMenuButtonStyle(fillColor: Color.white))
        .frame(alignment: .topTrailing)
        .padding([.trailing], 20)
    }
    
    /* `section` can be: "upload", "review_upload", "home" or "chat". */
    @State private var section: String = "upload"
    @State private var lastSection: String = "upload"
    
    var body: some View {
        if self.section == "upload" {
            UploadSection(
                images_to_upload: images_to_upload,
                model: model,
                lastSection: $lastSection,
                section: $section,
                prop: prop
            )
        } else if self.section == "upload_review" {
            UploadReview(
                images_to_upload: images_to_upload,
                localUpload: $localUpload,
                section: $section,
                lastSection: $lastSection,
                categories: $categories,
                sets: $sets,
                prop: prop
            )
        } else if self.section == "review_new_categories" {
            ReviewNewCategories(
                section: $section,
                images_to_upload: images_to_upload,
                categories: categories,
                sets: sets,
                prop: prop
            )
        }
        
        if self.section != "upload_review" && self.section != "review_new_categories" {
            VStack {
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button(action: { self.section = "home" }) {
                        Image(self.section != "home" ? "Home" : "Home-Active")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: { self.section = "upload" }) {
                        Image(self.section != "upload" ? "Upload" : "History-Icon")
                            .resizable()
                            .frame(width: self.section != "upload" ? 30 : 40, height: self.section != "upload" ? 30 : 40)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: { self.section = "chat" }) {
                        Image(self.section != "chat" ? "Chat" : "Chat-Active")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(
                    Rectangle()
                        .fill(Color.EZNotesBlack.opacity(self.section == "upload" ? 0.85 : 1))
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(width: 0.2, edges: [.top], color: .white)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        
        /*VStack {
            if section == "upload" {
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
                            .opacity(images_to_upload.count > 0 ? 1 : 0)
                            /*RightSideMenuButton(menuButtonTitle: "1x", action: {
                             self.model.frameScale = 1.0
                             self.zoomSetting = "1x"
                             })
                             .background(
                             RoundedRectangle(cornerRadius: 5)
                             .fill(self.zoomSetting == "1x" ? Color.EZNotesBlue : Color.clear)
                             .opacity(0.5)
                             .frame(width: 28, height: 55)
                             .padding([.trailing], 20)
                             .padding([.bottom], -2.5)
                             )
                             .padding([.top], 58)
                             
                             //RightSideMenuDivider()
                             
                             RightSideMenuButton(menuButtonTitle: "2x", action: {
                             model.frameScale = 2.0
                             self.zoomSetting = "2x"
                             })
                             .background(
                             RoundedRectangle(cornerRadius: 5)
                             .fill(self.zoomSetting == "2x" ? Color.EZNotesBlue : Color.clear)
                             .opacity(0.5)
                             .frame(width: 28, height: 55)
                             .padding([.trailing], 20)
                             .padding([.bottom], 0)
                             )
                             
                             //RightSideMenuDivider()
                             
                             RightSideMenuButton(menuButtonTitle: "3x", action: {
                             model.frameScale = 3.0
                             self.zoomSetting = "3x"
                             })
                             .background(
                             RoundedRectangle(cornerRadius: 5)
                             .fill(self.zoomSetting == "3x" ? Color.EZNotesBlue : Color.clear)
                             .opacity(0.5)
                             .frame(width: 28, height: 55)
                             .padding([.trailing], 20)
                             .padding([.bottom], -1.5)
                             )
                             .padding([.bottom], -4)*/
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
                    .frame(width: 60, height: 350, alignment: .topTrailing)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.clear)//Color.EZNotesBlue)
                            .padding([.top], 40)
                            .padding([.trailing], 15)
                            .opacity(0.5)
                    )
                    
                    /*Text("b").foregroundStyle(.white)
                     .frame(alignment: .trailing)
                     .padding([.trailing], 10)*/
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
            } else if section == "upload_review" {
                /* TODO: Implement all images taken */
                VStack {
                    //VStack {
                        HStack(spacing: 0) {
                            Button(action: {
                                self.section = self.lastSection
                                self.lastSection = self.section
                            }) {
                                HStack {
                                    Image("Back")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding([.top, .leading], 20)
                                    
                                    /*Text("Back")
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .font(.system(size: 20))
                                        .padding([.top], 20)*/
                                }
                            }
                            //.frame(maxWidth: 100, alignment: .leading)//.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            Text("Review Uploads")
                                .foregroundStyle(Color.EZNotesBlack)
                                .font(.system(size: 30))
                                .padding([.top], 10)
                                .padding([.leading], -30)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    //}
                    
                    Toggle("Save upload to device", isOn: $localUpload)
                        .frame(maxWidth: prop.size.width - 150)
                        .foregroundStyle(Color.EZNotesBlack)
                        .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                    
                    if self.localUpload == false {
                        Text("All categories will be created and stored in the cloud.")
                            .frame(maxWidth: prop.size.width - 100)
                            .foregroundStyle(Color.EZNotesBlue)
                            .font(.system(size: 16))
                            .italic()
                            .fontWeight(.bold)
                            .padding([.top], -5)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("All categories will be created and stored on your device.")
                            .frame(maxWidth: prop.size.width - 100)
                            .foregroundStyle(Color.EZNotesBlue)
                            .font(.system(size: 16))
                            .italic()
                            .fontWeight(.bold)
                            .padding([.top], -5)
                            .multilineTextAlignment(.center)
                    }
                    
                    if self.images_to_upload.count == 1 {
                        VStack {
                            Image(uiImage: self.images_to_upload[0])
                                .resizable()
                                .frame(width: prop.size.width - 100, height: 550)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.clear)
                                         /*.stroke(Color.EZNotesBlue, lineWidth: 1)*/)
                                .shadow(color: Color.EZNotesBlack, radius: 6)
                            
                            HStack {
                                Button(action: {
                                    self.images_to_upload.remove(at: 0)
                                    
                                    if self.images_to_upload.count == 0 {
                                        self.section = self.lastSection
                                        self.lastSection = ""
                                    }
                                }) {
                                    Image("Delete")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    
                                    Text("Delete")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding([.top], 10)
                            .padding([.bottom], 30)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(self.images_to_upload.enumerated()), id: \.offset) { index, value in
                                    VStack {
                                        Image(uiImage: value)
                                            .resizable()
                                            .frame(width: prop.size.width - 100, height: 550)
                                            .clipShape(.rect(cornerRadius: 10))
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.clear)
                                                     /*.stroke(Color.EZNotesBlue, lineWidth: 1)*/)
                                            .shadow(color: Color.EZNotesBlack, radius: 6)
                                        
                                        HStack {
                                            Button(action: {
                                                self.images_to_upload.remove(at: index)
                                                
                                                if self.images_to_upload.count == 0 {
                                                    self.section = self.lastSection
                                                    self.lastSection = ""
                                                }
                                            }) {
                                                Image("Delete")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                
                                                Text("Delete")
                                                    .foregroundStyle(.red)
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .padding([.top], 10)
                                        .padding([.bottom], 30)
                                    }
                                    .padding([.trailing], 15)
                                    .padding([.leading], index == 0 ? 15 : 0)
                                }
                            }
                            .padding([.top], 30)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Button(action: {
                        print("Uploading")
                    }) {
                        Text("Upload")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 25))
                            .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                            .padding(5)
                    }
                    //.padding([.top], 10)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesOrange)//(Color.EZNotesOrange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.clear)
                            .stroke(Color.EZNotesOrange, lineWidth: 1)
                            .shadow(color: Color.EZNotesBlack, radius: 12)
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("Background8")
                        .blur(radius: 3.5)
                )
            } else if section == "home" {
                ZStack {
                    /* TODO: Implement `home` section. */
                    Text("HOME")
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Color.EZNotesBlack
                )
                //.background(Color.EZNotesBlack)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.width < 0 {
                            self.section = "upload"
                        }
                    }))
            } else {
                ZStack {
                    /* TODO: Implement `chat` section. */
                    Text("CHAT")
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesBlue)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.width > 0 {
                            self.section = "upload"
                        }
                    }))
            }
            /*Spacer()
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 35, height: 35)
                    Button(action: {
                        model.frameScale = 0.5
                    }) {
                        Text(".5X")
                            .foregroundStyle(Color.EZNotesOrange)
                            .font(.system(size: 15))
                    }
                }
                ZStack {
                    Circle()
                        .frame(width: 35, height: 35)
                    Button(action: {
                        model.frameScale = 1.0
                    }) {
                        Text("1X")
                            .foregroundStyle(Color.EZNotesOrange)
                            .font(.system(size: 15))
                    }
                }
                ZStack {
                    Circle()
                        .frame(width: 35, height: 35)
                    Button(action: {
                        model.frameScale = 3.0
                    }) {
                        Text("3X")
                            .foregroundStyle(Color.EZNotesOrange)
                            .font(.system(size: 15))
                    }
                }
            }
            .frame(width: 100, height: 30)*/
            //ProgressView()
            //Spacer()
            /*Button("Zoom", action: {
                if !(model.frameScale + 0.2 > 2.0) { model.frameScale = round((model.frameScale + 0.2) * 10) / 10.00 }
            })
            .padding()
            Button("Zoom Out", action: {
                if !(model.frameScale - 0.2 < 0.5) { model.frameScale = round((model.frameScale - 0.2) * 10) / 10.0 }
            })
             .padding()*/
            /*.background(
             .opacity(0)//Image("Background2")
             //    .opacity(0.5)
             )*/
            
            Spacer()
            HStack {
                if self.section == "upload" {
                    VStack {
                        Button(action: {
                            images_to_upload.append(
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
                    .padding([.bottom], -15)
                }/* else if self.section == "upload_review" {
                    VStack {
                        Button(action: {
                            print("Uploading")
                        }) {
                            Text("Done")
                                .foregroundStyle(.white)
                                .font(.system(size: 25))
                                .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                                .padding(5)
                        }
                        .padding([.top], 10)
                        .buttonStyle(.borderedProminent)
                        .tint(Color.EZNotesOrange)
                    }
                    .background(.clear)
                }*/
            }.padding([.bottom], section != "upload_review" ? 40 : 0)
            
            if self.section != "upload_review" {
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button(action: { self.section = "home" }) {
                        Image(self.section != "home" ? "Home" : "Home-Active")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: { self.section = "upload" }) {
                        Image(self.section != "upload" ? "Upload" : "Upload-Active")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: { self.section = "chat" }) {
                        Image(self.section != "chat" ? "Chat" : "Chat-Active")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding([.top], 10)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(
                    Rectangle()
                        .fill(Color.EZNotesBlack.opacity(self.section == "upload" ? 0.85 : 1))
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(width: 0.2, edges: [.top], color: .white)
                    
                    /*Image("Background12")
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.bottom)
                        .opacity(1)*/
                        //.blur(radius: 1)
                    /*Color.white.edgesIgnoringSafeArea(.all)
                     .opacity(0.8)*/
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                if self.section == "upload" {
                    FrameView(handler: model, image: model.frame, prop: prop, section: section)
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
                            }))
                    /*.onTapGesture {
                     images_to_upload.append(
                     UIImage(
                     cgImage: model.frame!
                     )
                     )//UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: model.frame!), nil, nil, nil)
                     }*/
                }
            }
        )*/
    }
}

struct Core_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
