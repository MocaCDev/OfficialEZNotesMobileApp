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
        overlay(EdgeBorder(width: width, edges: edges).stroke(color,lineWidth: 1))//.foregroundColor(color))
    }
    func border(width: CGFloat, edges: [Edge], lcolor: LinearGradient) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).stroke(lcolor,lineWidth: 1))
    }
    func border(width: CGFloat, edges: [Edge], mgColor: MeshGradient) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).stroke(mgColor, lineWidth: 1))
    }
}

class ImagesUploads: ObservableObject {
    /* MARK: Dictionary format: `String` - filename, `UIImage` - file data. */
    @Published var images_to_upload: Array<[String: UIImage]> = []
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

enum TopBanner {
    case None
    case LoadingUploads
    case UploadsReadyToReview
    case ErrorUploading
    case NoWifiConnection
}

struct CoreApp: View {
    @EnvironmentObject private var categoryData: CategoryData
    
    public var prop: Properties
    @Binding public var topBanner: TopBanner
    
    @ObservedObject public var accountInfo: AccountDetails
    @ObservedObject public var model: FrameHandler
    //@ObservedObject public var messageModel: MessagesModel
    
    @Binding public var userHasSignedIn: Bool
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    
    @StateObject var images_to_upload: ImagesUploads = ImagesUploads()
    
    //@State private var topBanner: TopBanner = .None
    
    @State private var images: Array<UIImage> = []
    @State private var images_to_ignore: Array<Int> = []
    @State private var change = 0.0
    @State private var currentZoom: Double = 0.0
    @State private var localUpload: Bool = true
    
    /* MARK: In `UploadReviewView.view`, if this gets set to `true` the first image uploaded will be the one where the server gets the category name. Each image, including the one used to decipher the category name, will thus be used to curate a set, with the respective notes, all which will belong to the detected category. */
    @State private var createOneCategory: Bool = false
    
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
        .frame(alignment: .topTrailing)
        .padding([.trailing], 20)
    }
    
    /* `section` can be: "upload", "review_upload", "home" or "chat". */
    @State private var section: String = "upload"
    @State private var lastSection: String = "upload"
    
    @State private var errorType: String = ""
    
    //@Binding public var messages: Array<MessageDetails>
    
    var body: some View {
        ZStack {
            if self.section == "upload" {
                UploadSection(
                    topBanner: $topBanner,
                    images_to_upload: self.images_to_upload,
                    model: self.model,
                    lastSection: $lastSection,
                    section: $section,
                    prop: prop,
                    accountInfo: accountInfo,
                    userHasSignedIn: $userHasSignedIn
                )
            } else if self.section == "upload_review" {
                UploadReview(
                    images_to_upload: self.images_to_upload,
                    topBanner: $topBanner,
                    localUpload: $localUpload,
                    createOneCategory: $createOneCategory,
                    section: $section,
                    lastSection: $lastSection,
                    errorType: $errorType,
                    prop: self.prop
                )
            } else if self.section == "review_new_categories" {
                ReviewNewCategories(
                    section: $section,
                    images_to_upload: images_to_upload,
                    prop: prop
                )
            } else if self.section == "home" {
                HomeView(
                    model: self.model,
                    images_to_upload: self.images_to_upload,
                    section: $section,
                    prop: prop,
                    accountInfo: accountInfo,
                    userHasSignedIn: $userHasSignedIn
                )
            } else if self.section == "chat" {
                ChatView(
                    section: $section,
                    prop: prop,
                    accountInfo: accountInfo,
                    userHasSignedIn: $userHasSignedIn
                )
            } else if self.section == "upload_error" {
                VStack {
                    Text(self.errorType == "blank_image"
                         ? "No Content Found"
                         : self.errorType == "no_content"
                            ? "Internal Server Error"
                            : self.errorType == "confidential_upload"
                                ? "Confidential Upload Error"
                                : "Internal Server Error")
                        .font(
                            .system(size: 35, design: .monospaced)
                        )
                        .fontWeight(.bold)
                        .foregroundStyle(self.errorType == "blank_image" ? Color.yellow : Color.EZNotesRed)
                        .multilineTextAlignment(.center)
                    
                    Text(self.errorType == "blank_image"
                         ? "This error is due to your uploads having no visible content in them"
                         : self.errorType == "no_content"
                            ? "There was an error obtaining content from your uploads. This can be due to the server being down, the server having a fualty bug or a faulty Wi-Fi connection."
                            : self.errorType == "confidential_upload"
                                ? "confidential_upload"
                                : "There was an error obtaining content from your uploads. This can be due to the server being down, the server having a fualty bug or a faulty Wi-Fi connection.")
                        .fontWeight(.bold)
                        .font(
                            .system(
                                size: 18,
                                design: .rounded
                            )
                        )
                        .multilineTextAlignment(.center)
                        .frame(
                            maxWidth: prop.isIpad
                            ? prop.size.width - 520
                            : 380,
                            maxHeight: 110,
                            alignment: .top
                        )
                        .foregroundStyle(Color.white)
                    
                    Button(action: { self.section = "upload" }) {
                        Text("Okay")
                            .foregroundStyle(Color.EZNotesBlack)
                            .font(.system(size: 25))
                            .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                            .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.white)
                    
                    if self.section == "upload_error" {
                        Button(action: { self.section = "report" }) {
                            Text("Report")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 25))
                                .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                                .padding(5)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.EZNotesLightBlack)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("Background8")
                        .blur(radius: 3.5)
                        .overlay(Color.EZNotesBlack.opacity(0.4))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
    }
}

struct Core_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
