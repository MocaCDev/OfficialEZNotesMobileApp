//
//  CategoryInternalsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/9/24.
//
import SwiftUI

/* MARK: `CIError` - Category Internals (CI) Error states. */
enum CIError: Error {
    case None
    case NewSetNameEmpty
    case NewSetNotesEmpty
    case NewSetNameExists
}

private struct ShowLongAndShortNameSets: View {
    @EnvironmentObject private var categoryData: CategoryData
    
    var prop: Properties
    var categoryName: String
    var longerSetNames: Array<String>
    var shorterSetNames: Array<String>
    var categoryTitleColor: Color?
    var categoryBackgroundColor: Color?
    
    @Binding public var setName: String
    @Binding public var notesContent: String
    @Binding public var originalContet: String
    @Binding public var launchedSet: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible())]) {
                ForEach(self.longerSetNames, id: \.self) { longSetName in
                    Button(action: {
                        self.setName = longSetName
                        
                        for setData in self.categoryData.setAndNotes[self.categoryName]! {
                            /* MARK: Each dictionary one has one key/value. Each dictionary of the array represents one set. Therefore, we only need the first value of the dictionary. */
                            if setData.first!.key == longSetName {
                                self.notesContent = setData[longSetName]!
                                self.originalContet = self.notesContent
                                break
                            }
                        }
                        
                        self.launchedSet = true
                    }) {
                        VStack {
                            HStack {
                                Text(longSetName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                    .padding(.leading, 15)
                                    .font(Font.custom("Poppins-SemiBold", size: 18))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                
                                ZStack {
                                    Image(systemName: "chevron.forward")
                                        .resizable()
                                        .frame(width: 10, height: 15)
                                        .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .gray)
                                }
                                .frame(maxWidth: 20, alignment: .trailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(/*index == self.setAndNotes[self.categoryName]!.count - 1
                                      ? [.top, .bottom, .leading, .trailing]
                                      : [.top, .leading, .trailing],*/
                                self.categoryData.setAndNotes[self.categoryName]!.count == 1 ? 8 : 4
                            )
                        }
                        .frame(maxWidth: prop.size.width - 20)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                        )
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
            }
            .padding(.top, 15)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(self.shorterSetNames, id: \.self) { shortSetName in
                    Button(action: {
                        self.setName = shortSetName
                        
                        for setData in self.categoryData.setAndNotes[self.categoryName]! {
                            if setData.first!.key == shortSetName {
                                self.notesContent = setData[shortSetName]!
                                self.originalContet = self.notesContent
                                break
                            }
                        }
                        
                        self.launchedSet = true
                    }) {
                        VStack {
                            HStack {
                                Text(shortSetName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                    .padding(.leading, 15)
                                    .font(Font.custom("Poppins-SemiBold", size: 18))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                
                                ZStack {
                                    Image(systemName: "chevron.forward")
                                        .resizable()
                                        .frame(width: 10, height: 15)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: 20, alignment: .trailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(/*index == self.setAndNotes[self.categoryName]!.count - 1
                                      ? [.top, .bottom, .leading, .trailing]
                                      : [.top, .leading, .trailing],*/
                                self.categoryData.setAndNotes[self.categoryName]!.count == 1 ? 8 : 4
                            )
                        }
                        .frame(maxWidth: prop.size.width - 20)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                        )
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
            }
            
            /* MARK: Ensure there is spacing between the bottom of the screen and the last element in the scrollview. */
            VStack { }.frame(maxWidth: .infinity).padding(.bottom, 30)
        }
        .padding(.top, -27)
    }
}

struct CategoryInternalsView: View {
    @EnvironmentObject private var categoryData: CategoryData
    @EnvironmentObject private var messageModel: MessagesModel
    @EnvironmentObject private var settings: SettingsConfigManager
    @EnvironmentObject private var accountInfo: AccountDetails
    
    /* MARK: Needed for the "Create Set by Image". */
    /* MARK: See `TODO` in `UploadSectionView.swift` (line 16). */
    @ObservedObject public var model: FrameHandler
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var loadingCameraView: Bool = false
    @State private var targetX: CGFloat = 0
    @State private var targetY: CGFloat = 0
    @ObservedObject public var images_to_upload: ImagesUploads//@State private var imageUploadsForSets: Array<[String: UIImage]> = []
    @State private var showUploadPreview: Bool = false
    
    var prop: Properties
    @Binding public var categoryName: String
    var creationDate: String
    @State public var categoryTitleColor: Color?
    @State public var categoryBackgroundColor: Color?
    var categoryBackground: Image
    
    @State private var categoryDescription: String? = nil
    @State private var generatingDesc: Bool = false
    @State private var errorGenerating: Bool = false
    @State private var setsYOffset: CGFloat = 0
    @State private var internalInfoOpacity: CGFloat = 0

    @Binding public var launchCategory: Bool
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    //@Binding public var messages: Array<MessageDetails> /* TODO: Add a new interface for messages. */
    //@ObservedObject public var accountInfo: AccountDetails
    
    @State private var show_category_internal_title: Bool = false
    
    @State private var categoryBeingEdited: String = ""
    @State private var editCategoryDetails: Bool = false
    @State private var newCategoryDescription: String = ""
    @State private var newCategoryDisplayColor: Color = Color.EZNotesOrange
    @State private var newCategoryTextColor: Color = Color.white
    @State private var categoryAlert: Bool = false
    @State private var alertType: AlertTypes = .None
    @State private var categoryToDelete: String = ""
    
    private func resetAlert() {
        if self.alertType == .DeleteCategoryAlert {
            self.categoryToDelete.removeAll()
        }
        
        self.categoryAlert = false
        self.alertType = .None
    }
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY || textFrame.minY > scrollViewFrame.maxY {
            self.show_category_internal_title = true
        } else {
            self.show_category_internal_title = false
        }
    }
    
    @State private var launchedSet: Bool = false
    
    /* MARK: If a set has been clicked, store the set name as well as the content of the notes for the set. */
    @State private var setName: String = ""
    @State private var notesContent: String = ""
    @State private var originalContet: String = "" /* MARK: This variable stores the current value of the notes. It will not be edited rather it will be used to re-assign `notesContent` in `ShowNotesView.swift` if "Undo Changes" is pressed. */
    
    private func textHeight(for text: String, width: CGFloat) -> CGFloat {
        /*let font = UIFont.systemFont(ofSize: 17)  // Customize this to match your font
         let constrainedSize = CGSize(width: width - 20, height: .infinity)  // Add padding to the width
         let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return boundingRect.height*/
        let textView = UITextView()
        textView.text += "\n\n"
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        let fixedWidth = width - 16 // Account for padding
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return max(size.height + 40, 100) // Add a buffer and ensure a minimum height
    }
    
    /* MARK: Variables regarding the + button on bottom right of screen. */
    @State private var testPopup: Bool = false
    @State private var createNewSet: Bool = false
    @State private var createNewSetByImage: Bool = false
    @State private var newSetName: String = ""
    @FocusState private var newSetNameFocused: Bool
    @State private var newSetNotes: String = ""
    @FocusState private var newSetNotesFocused: Bool
    @State private var error: CIError = .None
    
    /* MARK: Variables regarding search bar. */
    @State private var setSearch: String = ""
    @FocusState private var setSearchFocus: Bool
    
    /* MARK: Variables for figuring out what set names are longer and what set names are shorter. The shorter set names will be displayed in a grid layout with 2 sets on each line. The longer set names will be displayed in a grid layout with 1 set on each line. */
    @State private var longerSetNames: Array<String> = []
    @State private var shorterSetNames: Array<String> = []
    
    @Binding public var topBanner: [String: TopBanner]
    
    @State private var showDescription: Bool = false
    
    /* MARK: States for if `settings.displayUserCreatedSetsSeparatly` is true. */
    @State private var allUserCreatedSets: [String: Array<[String: String]>] = [:]
    @State private var selectedView: String = "generated" /* MARK: Two values: "Generated" - shows all categories generated by the AI; "User Created" - shows all categories created by the user. Only used if `settings.displayUserCreatedCategoriesSeparatly` is true. */
    @State private var userCreatedLongSetNames: Array<String> = []
    @State private var userCreatedShortSetNames: Array<String> = []
    @State private var autoLaunchNewSet: Bool = false
    
    @State private var editDescription: Bool = false
    @State private var editDescriptionText: String = ""
    @FocusState private var editDescriptionTextFocused: Bool
    @State private var generatingNewDescription: Bool = false
    
    @State private var aiChat: Bool = false
    @State private var topContentOpacity: CGFloat = 1
    @State private var topContentHeight: CGFloat = UIScreen.main.bounds.height / 2.5
    
    @State private var secondaryNavbarOpacity: CGFloat = 0
    
    @State private var blurredImageHeight: CGFloat = UIScreen.main.bounds.height - 100
    
    var body: some View {
        if !self.launchedSet {
            ZStack {
                if self.showDescription {
                    VStack {
                        Spacer()
                        
                        VStack {
                            HStack {
                                ZStack {
                                    Button(action: { self.showDescription = false}) {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(
                                                width: 15,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                                height: 15//prop.size.height / 2.5 > 300 ? 45 : 40
                                            )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: 20, maxHeight: 20)
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                                        .shadow(color: Color.black, radius: 1.5)
                                )
                                //.padding(.top, 2.5)
                                
                                HStack {
                                    Spacer()
                                    
                                    VStack {
                                        Text("Description For")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundStyle(.white)
                                        
                                        Text("\(self.categoryName)")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 26 : 22))
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                                ZStack { }.frame(maxWidth: 20, alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity, minHeight: 30)
                            
                            HStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.white)
                                .padding(.bottom, 15)
                            
                            if self.categoryDescription != nil {
                                if !self.editDescription && !self.generatingNewDescription {
                                    Text(self.categoryDescription!)
                                        .frame(maxWidth: .infinity, alignment: .center)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                        .padding([.bottom, .leading], 8) /* MARK: Pad the bottom to ensure space between the text and the sets information. Pad to the lefthand side (`.leading`) to have a indentation. */
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))//.setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 15 : 13)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                        .truncationMode(.tail)
                                        .padding()
                                } else {
                                    if self.editDescription {
                                        TextField("", text: $editDescriptionText)
                                            .frame(maxWidth: .infinity, alignment: .center)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                            .padding([.bottom, .leading], 8)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .focused($editDescriptionTextFocused)
                                            .overlay(
                                                VStack {
                                                    if self.editDescriptionText.isEmpty || !self.editDescriptionTextFocused {
                                                        Text(self.categoryDescription!)
                                                            .frame(maxWidth: .infinity, alignment: .center)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                                            .padding([.bottom, .leading], 8) /* MARK: Pad the bottom to ensure space between the text and the sets information. Pad to the lefthand side (`.leading`) to have a indentation. */
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))//.setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 15 : 13)
                                                            .minimumScaleFactor(0.5)
                                                            .multilineTextAlignment(.center)
                                                            .truncationMode(.tail)
                                                            .padding()
                                                            .onTapGesture {
                                                                self.editDescriptionTextFocused = true
                                                            }
                                                    }
                                                }
                                            )
                                    } else {
                                        LoadingView(message: "Generating Description")
                                    }
                                }
                            } else {
                                Text("No Description")
                                    .frame(maxWidth: .infinity, alignment: .center)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                    .padding([.bottom, .leading], 8) /* MARK: Pad the bottom to ensure space between the text and the sets information. Pad to the lefthand side (`.leading`) to have a indentation. */
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 22 : 20))//.setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 15 : 13)
                                    .multilineTextAlignment(.center)
                                    .truncationMode(.tail)
                                    .padding()
                            }
                            
                            HStack {
                                Button(action: { }) {
                                    Text("Generate Description")
                                        .frame(maxWidth: 200, alignment: .center)
                                        .padding([.top, .bottom], 5)
                                        .foregroundStyle(
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
                                            ])
                                        )
                                        .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                                .strokeBorder(.white, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Button(action: { self.editDescription = true }) {
                                    Text("Edit Description")
                                        .frame(maxWidth: 200, alignment: .center)
                                        .padding([.top, .bottom], 5)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                                .strokeBorder(.white, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                        }
                        .frame(maxWidth: prop.size.width - 70)
                        .padding()
                        /*.background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.EZNotesBlack)
                                .shadow(color: Color.black, radius: 4.5)
                        )*/
                        .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding([.leading, .trailing])
                        .padding(.top)
                        .padding(.bottom, 40)
                        .cornerRadius(15)
                        .onTapGesture {
                            /* MARK: Do nothing, just capture the tap gesture event so the one on the parent view doesn't get triggered and close out the entire view. */
                            return
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.EZNotesBlack.opacity(0.45))
                    .onTapGesture {
                        self.showDescription = false
                    }
                    .zIndex(1)
                }
                
                if self.createNewSet {
                    VStack {
                        Spacer()
                        
                        /*VStack {
                            HStack {
                                ZStack {
                                    Button(action: {
                                        /* MARK: Ensure the error states are set to .None*/
                                        self.error = .None
                                        
                                        self.newSetNotes.removeAll()
                                        self.newSetName.removeAll()
                                        self.createNewSet = false
                                        self.testPopup = false
                                    }) {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(
                                                width: 15,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                                height: 15//prop.size.height / 2.5 > 300 ? 45 : 40
                                            )
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: 20, maxHeight: 20)
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                                )
                                //.padding(.top, 2.5)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Create Set")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 26 : 22))
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                                ZStack { }.frame(maxWidth: 20, alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            
                            HStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.white)
                                .padding(.bottom, 15)
                            
                            if self.error == .NewSetNameEmpty || self.error == .NewSetNotesEmpty {
                                Text(self.error == .NewSetNameEmpty
                                     ? "The set name is empty. Ensure you apply a name to the new set."
                                     : "The notes for the set **\(self.newSetName)** you are creating are empty.")
                                    .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(
                                        .system(
                                            size: prop.isIpad || prop.isLargerScreen
                                            ? 15
                                            : 13
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 15)
                            }
                            
                            Text("Set Name")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 80,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 10)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 22 : 18))
                                .foregroundStyle(.white)
                            
                            TextField("New Set Name...", text: $newSetName)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: prop.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], prop.isLargerScreen ? 15 : 5)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .borderBottomWLColor(
                                            isError: self.newSetName == "" && self.error == .NewSetNameEmpty
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding(prop.isLargerScreen ? 10 : 4)
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.bottom, 15)
                                /*.focused($usernameTextfieldFocus)
                                .onChange(of: usernameTextfieldFocus) {
                                    if !self.usernameTextfieldFocus { assignUDKey(key: "temp_username", value: self.username) }
                                }*/
                            
                            Text("Notes")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 80,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 10)
                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 22 : 18))
                                .foregroundStyle(.white)
                                .padding(.bottom, 10)
                            
                            TextField(
                                "Write your notes...",
                                text: $newSetNotes,
                                axis: .vertical
                            )
                            .frame(minHeight: textHeight(for: self.newSetNotes, width: UIScreen.main.bounds.width), alignment: .leading)
                            .padding([.leading], 15)
                            .padding(7)
                            .background(Color(.systemGray6))
                            .cornerRadius(7.5)
                            .lineLimit(5...20)
                            .border(width: 1, edges: [.bottom], color: self.error == .NewSetNotesEmpty ? Color.EZNotesRed : Color.clear)
                            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                            
                            Button(action: {
                                if self.newSetName.isEmpty { self.error = .NewSetNameEmpty; return }
                                if self.newSetNotes.isEmpty { self.error = .NewSetNotesEmpty; return }
                                
                                self.error = .None
                                
                                self.categoryData.categoriesAndSets[self.categoryName]!.append(self.newSetName)
                                self.categoryData.setAndNotes[self.categoryName]!.append([self.newSetName: self.newSetNotes])
                                
                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                
                                if self.settings.trackUserCreatedSets {
                                    self.categoryData.userCreatedSetNames.append(self.newSetName)
                                    writeUserCreatedSetNames(userCreatedSetNames: self.categoryData.userCreatedSetNames)
                                    
                                    if self.newSetName.count > 15 { self.userCreatedLongSetNames.append(self.newSetName) }
                                    else { self.userCreatedShortSetNames.append(self.newSetName) }
                                } else {
                                    if self.newSetName.count > 15 { self.longerSetNames.append(self.newSetName) }
                                    else { self.shorterSetNames.append(self.newSetName) }
                                }
                                
                                self.newSetName.removeAll()
                                self.newSetNotes.removeAll()
                                
                                /* MARK: Ensure the popup goes away. */
                                self.createNewSet = false
                                self.testPopup = false
                            }) {
                                HStack {
                                    Text("Create")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(.top, 15)
                        }
                        .frame(maxWidth: prop.size.width - 70)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.EZNotesBlack)
                                .shadow(color: Color.black, radius: 2.5)
                        )
                        .cornerRadius(15)
                        .onTapGesture {
                            /* MARK: Do nothing, just capture the tap gesture event so the one on the parent view doesn't get triggered and close out the entire view. */
                            return
                        }*/
                        
                        /*VStack {
                            if self.error == .NewSetNameEmpty || self.error == .NewSetNotesEmpty || self.error == .NewSetNameExists {
                                Text(self.error == .NewSetNameEmpty
                                     ? "The set name is empty. Ensure you apply a name to the new set"
                                     : self.error == .NewSetNotesEmpty
                                        ? "The notes for the set **\(self.newSetName)** you are creating are empty"
                                        : "The set **\(self.newSetName)** already exists")
                                .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                .foregroundStyle(Color.EZNotesRed)
                                .font(
                                    .system(
                                        size: prop.isIpad || prop.isLargerScreen
                                        ? 15
                                        : 13
                                    )
                                )
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 15)
                            }
                            
                            /*if self.newSetNameFocused {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: { self.newSetNameFocused = false }) {
                                        Text("Done")
                                            .font(Font.custom("Poppins-SemiBold", size: 16))
                                            .foregroundStyle(Color.EZNotesBlue)
                                    }
                                }
                                .padding(.horizontal)//([.trailing, .leading])
                            }*/
                            //VStack {
                                HStack {
                                    TextField(
                                        "",
                                        text: $newSetName,
                                        axis: .vertical
                                    )
                                    .frame(
                                        maxWidth: .infinity
                                    )
                                    .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                    .focused($newSetNameFocused)
                                    .autocorrectionDisabled(true)
                                    .lineLimit(2)
                                    .overlay(
                                        HStack {
                                            if self.newSetName.isEmpty && !self.newSetNameFocused {
                                                Text("Set name...")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                                    .padding(.leading, 10)
                                            }
                                            
                                            if self.newSetNameFocused {
                                                Spacer()
                                                
                                                Button(action: { self.newSetNameFocused = false }) {
                                                    Text("Done")
                                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                }
                                            }
                                        }
                                        .onTapGesture { self.newSetNameFocused = true }
                                    )
                                    .onChange(of: self.newSetName) {
                                        if self.error != .None { self.error = .None }
                                        
                                        if self.newSetName.count > 30 { /* MARK: Testing number. User created category names cannot surpass 30 characters. */
                                            self.newSetName = String(self.newSetName.prefix(30))
                                        }
                                    }
                                    .padding(.bottom, 10) /* MARK: Push the below border down by 10 pixels. */
                                    .border(width: 1, edges: [.bottom], color: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                                    
                                    
                                    /*ZStack {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .frame(width: 10, height: 15)
                                            .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .gray)
                                    }
                                    .frame(maxWidth: 20, alignment: .trailing)
                                    .padding(.trailing, 15)*/
                                }
                                //.frame(maxWidth: .infinity)
                                /*.padding(/*index == self.setAndNotes[self.categoryName]!.count - 1
                                          ? [.top, .bottom, .leading, .trailing]
                                          : [.top, .leading, .trailing],*/
                                    8//self.categoryData.setAndNotes[self.categoryName]!.count == 1 ? 8 : 4
                                )*/
                            //}
                            .frame(maxWidth: prop.size.width - 20)
                            .padding(10)
                            /*.background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                            )
                            .cornerRadius(15)*/
                            .padding([.leading, .trailing])
                            
                            if self.newSetNotesFocused {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: { self.newSetNotesFocused = false }) {
                                        Text("Done")
                                            .font(Font.custom("Poppins-SemiBold", size: 16))
                                            .foregroundStyle(Color.EZNotesBlue)
                                    }
                                }
                                .padding(.horizontal)//([.trailing, .leading])
                            }
                            
                            TextField(
                                "Write your notes...",
                                text: $newSetNotes,
                                axis: .vertical
                            )
                            .frame(minHeight: textHeight(for: self.newSetNotes, width: UIScreen.main.bounds.width), alignment: .leading)
                            .padding([.leading], 15)
                            .padding(7)
                            //.background(Color(.systemGray5))
                            .cornerRadius(7.5)
                            .lineLimit(5...20)
                            .border(width: 1, edges: [.bottom], color: self.error == .NewSetNotesEmpty ? Color.EZNotesRed : Color.clear)
                            .cornerRadius(15)
                            .padding([.leading, .trailing])
                            .focused($newSetNotesFocused)
                            
                            Button(action: {
                                if self.newSetName.isEmpty { self.error = .NewSetNameEmpty; return }
                                if self.newSetNotes.isEmpty { self.error = .NewSetNotesEmpty; return }
                                if self.categoryData.setAndNotes[self.categoryName]!.contains(where: { $0.keys.first! == self.newSetName }) {
                                    self.error = .NewSetNameExists
                                    return
                                }
                                
                                self.error = .None
                                
                                self.categoryData.categoriesAndSets[self.categoryName]!.append(self.newSetName)
                                self.categoryData.setAndNotes[self.categoryName]!.append([self.newSetName: self.newSetNotes])
                                
                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                
                                if self.settings.trackUserCreatedSets {
                                    self.categoryData.userCreatedSetNames.append(self.newSetName)
                                    writeUserCreatedSetNames(userCreatedSetNames: self.categoryData.userCreatedSetNames)
                                    
                                    if self.newSetName.count > 15 { self.userCreatedLongSetNames.append(self.newSetName) }
                                    else { self.userCreatedShortSetNames.append(self.newSetName) }
                                } else {
                                    if self.newSetName.count > 15 { self.longerSetNames.append(self.newSetName) }
                                    else { self.shorterSetNames.append(self.newSetName) }
                                }
                                
                                self.newSetName.removeAll()
                                self.newSetNotes.removeAll()
                                
                                /* MARK: Ensure the popup goes away. */
                                self.createNewSet = false
                                self.testPopup = false
                            }) {
                                HStack {
                                    Text("Create")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(15)
                                .padding([.leading, .trailing])
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .padding(6)
                        .padding(.vertical)
                        .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .onTapGesture { return }*/
                        
                        VStack {
                            if self.error == .NewSetNameEmpty || self.error == .NewSetNotesEmpty {
                                Text(self.error == .NewSetNameEmpty
                                     ? "The set name is empty. Ensure you apply a name to the new set."
                                     : "The notes for the set **\(self.newSetName)** you are creating are empty.")
                                    .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(
                                        .system(
                                            size: prop.isIpad || prop.isLargerScreen
                                            ? 15
                                            : 13
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 15)
                            }
                            
                            HStack {
                                TextField(
                                    "",
                                    text: $newSetName,
                                    axis: .vertical
                                )
                                .frame(
                                    maxWidth: .infinity
                                )
                                .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                .focused($newSetNameFocused)
                                .autocorrectionDisabled(true)
                                .lineLimit(2)
                                .overlay(
                                    HStack {
                                        if self.newSetName.isEmpty && !self.newSetNameFocused {
                                            Text("Set name...")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                                .padding(.leading, 10)
                                        }
                                        
                                        if self.newSetNameFocused {
                                            Spacer()
                                            
                                            Button(action: { self.newSetNameFocused = false }) {
                                                Text("Done")
                                                    .font(Font.custom("Poppins-SemiBold", size: 16))
                                                    .foregroundStyle(Color.EZNotesBlue)
                                            }
                                        }
                                    }
                                    .onTapGesture { self.newSetNameFocused = true }
                                )
                                .onChange(of: self.newSetName) {
                                    if self.error != .None { self.error = .None }
                                    
                                    if self.newSetName.count > 30 { /* MARK: Testing number. User created category names cannot surpass 30 characters. */
                                        self.newSetName = String(self.newSetName.prefix(30))
                                    }
                                }
                                
                                ZStack {
                                    Image(systemName: "chevron.forward")
                                        .resizable()
                                        .frame(width: 10, height: 15)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: 20, alignment: .trailing)
                                .padding(.leading, 10)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: prop.size.width - 20)
                            .padding(/*index == self.setAndNotes[self.categoryName]!.count - 1
                                      ? [.top, .bottom, .leading, .trailing]
                                      : [.top, .leading, .trailing],*/
                                4//self.categoryData.setAndNotes[self.categoryName]!.count == 1 ? 8 : 4
                            )
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                            )
                            .cornerRadius(15)
                            .padding(.horizontal)
                            
                            Button(action: {
                                if self.newSetName.isEmpty { self.error = .NewSetNameEmpty; return }
                                //if self.newSetNotes.isEmpty { self.error = .NewSetNotesEmpty; return }
                                if self.categoryData.setAndNotes[self.categoryName]!.contains(where: { $0.keys.first! == self.newSetName }) {
                                    self.error = .NewSetNameExists
                                    return
                                }
                                
                                self.error = .None
                                
                                self.categoryData.categoriesAndSets[self.categoryName]!.append(self.newSetName)
                                self.categoryData.setAndNotes[self.categoryName]!.append([self.newSetName: ""])
                                
                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                
                                if self.settings.trackUserCreatedSets {
                                    self.categoryData.userCreatedSetNames.append(self.newSetName)
                                    writeUserCreatedSetNames(userCreatedSetNames: self.categoryData.userCreatedSetNames)
                                    
                                    if self.newSetName.count > 15 { self.userCreatedLongSetNames.append(self.newSetName) }
                                    else { self.userCreatedShortSetNames.append(self.newSetName) }
                                } else {
                                    if self.newSetName.count > 15 { self.longerSetNames.append(self.newSetName) }
                                    else { self.shorterSetNames.append(self.newSetName) }
                                }
                                
                                if self.autoLaunchNewSet {
                                    self.launchedSet = true
                                    
                                    self.setName = self.newSetName
                                    self.notesContent = ""
                                    self.originalContet = self.notesContent
                                }
                                
                                self.newSetName.removeAll()
                                //self.newSetNotes.removeAll()
                                
                                /* MARK: Ensure the popup goes away. */
                                self.createNewSet = false
                                self.testPopup = false
                            }) {
                                HStack {
                                    Text("Create")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(15)
                                .padding([.leading, .trailing])
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            HStack {
                                Toggle(isOn: $autoLaunchNewSet) {
                                    Text("Automatically launch new set")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .toggleStyle(CheckBox())
                                .foregroundStyle(Color.EZNotesBlue)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.vertical, .horizontal])
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        .padding(6)
                        .padding(.vertical)
                        .padding(.top, 10) /* MARK: I don't know why, but adding 10 more pixels of padding to the top makes it look better. */
                        .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                        .cornerRadius(15)
                        .onTapGesture {
                            /* MARK: Capture tap gesture to avoid the `.onTapGesture` on the overarching `VStack`. */
                            return
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.7))
                    .onTapGesture {
                        self.createNewSet = false
                    }
                    .zIndex(1)
                } else {
                    if self.createNewSetByImage {
                        if !self.showUploadPreview {
                            VStack {
                                HStack {
                                    Button(action: {
                                        /* MARK: Ensure the error states are set to .None*/
                                        self.error = .None
                                        
                                        self.createNewSetByImage = false
                                    }) {
                                        ZStack {
                                            Image(systemName: "multiply")
                                                .resizable()
                                                .frame(
                                                    width: 15,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                                    height: 15//prop.size.height / 2.5 > 300 ? 45 : 40
                                                )
                                        }
                                        .frame(maxWidth: 20, maxHeight: 20)
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(Color.EZNotesLightBlack.opacity(0.5))
                                        )
                                        .padding(.leading, 15)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    if self.topBanner.keys.contains(self.categoryName) && self.topBanner[self.categoryName]! != .None {
                                        switch(self.topBanner[self.categoryName]!) {
                                        case .LoadingUploads:
                                            HStack {
                                                Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                                    .padding(.trailing, 5)
                                                
                                                ProgressView()
                                                    .controlSize(.mini)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                                            .background(Color.EZNotesLightBlack.opacity(0.8))
                                            .cornerRadius(15)
                                            .padding(.trailing, 10)
                                            //.padding(.top, prop.isLargerScreen ? 25 : 15)
                                        default: VStack { }.onAppear { self.topBanner[self.categoryName] = .None }
                                        }
                                    } else { Spacer() }
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                
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
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.bottom, self.images_to_upload.images_to_upload.count > 0 ? 15 : 30)
                                    
                                    VStack { }.frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                if self.images_to_upload.images_to_upload.count > 0 {
                                    VStack {
                                        HStack {
                                            Button(action: { self.images_to_upload.images_to_upload.removeAll() }) {
                                                ZStack {
                                                    HStack {
                                                        Text("Remove All")
                                                            .frame(alignment: .center)
                                                            .padding(10)
                                                            .foregroundStyle(.white)
                                                            .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 16 : 14)
                                                            .minimumScaleFactor(0.5)
                                                        
                                                        Image(systemName: "trash")
                                                            .resizable()
                                                            .frame(width: 15, height: 15)
                                                            .foregroundStyle(.gray)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.EZNotesLightBlack.opacity(0.8))
                                                .cornerRadius(20)
                                                .padding(.leading, 15)
                                            }
                                            
                                            Button(action: {
                                                self.showUploadPreview = true
                                            }) {
                                                HStack {
                                                    HStack {
                                                        Text("Review")
                                                            .frame(alignment: .center)
                                                            .padding(10)
                                                            .foregroundStyle(.white)
                                                            .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 16 : 14)
                                                            .minimumScaleFactor(0.5)
                                                        
                                                        Image(systemName: "chevron.forward")
                                                            .resizable()
                                                            .frame(width: 10, height: 15)
                                                            .foregroundStyle(.gray)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                                .background(Color.EZNotesLightBlack.opacity(0.8))
                                                .cornerRadius(20)
                                                .padding(.trailing, 15)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.bottom)
                                        .padding(.top, 5)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .bottom)
                                    .background(
                                        Rectangle()
                                            .fill(Color.EZNotesBlack)
                                            .shadow(color: Color.black, radius: 2.5, y: -2.5)
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                self.model.startSession()
                            }
                            .onDisappear {
                                self.model.stopSession()
                            }
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
                                          /*.gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
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
                                           )*/
                                )
                                : AnyView(Color.EZNotesBlack)
                            )
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                                    targetX = CGFloat.random(in: -4...8) // Random X offset
                                    targetY = CGFloat.random(in: -4...8) // Random Y offset
                                }
                            }
                            .zIndex(1)
                        } else {
                            SetUploadReview(
                                prop: self.prop,
                                categoryName: self.categoryName,
                                action: { response in
                                    self.longerSetNames.removeAll()
                                    self.shorterSetNames.removeAll()
                                    
                                    for setData in response.setAndNotes[self.categoryName]! {
                                        if setData.first!.key.count >= 15 { self.longerSetNames.append(setData.first!.key) }
                                        else { self.shorterSetNames.append(setData.first!.key) }
                                    }
                                },
                                images_to_upload: self.images_to_upload,
                                showUploadPreview: $showUploadPreview,
                                topBanner: $topBanner
                                //categoryData: self.categoryData
                            )/* { newCategoryData in
                                VStack { }.onAppear { self.categoryData = newCategoryData }
                            }*/
                            .zIndex(1)
                        }
                    }
                }
                
                //ScrollView(.vertical, showsIndicators: false) {
                /*VStack {
                    TopNavCategoryView(
                        prop: self.prop,
                        categoryName: self.categoryName,
                        numberOfSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                        creationDate: self.creationDate,
                        categoryBackground: self.categoryBackground,
                        categoryBackgroundColor: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesLightBlack,
                        totalSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                        launchCategory: $launchCategory,
                        showTitle: $show_category_internal_title,
                        //tempChatHistory: $tempChatHistory,
                        //messages: $messages,
                        accountInfo: self.accountInfo,
                        topBanner: $topBanner,
                        images_to_upload: self.images_to_upload
                    )
                    
                    Spacer()
                    
                    /*VStack {
                        VStack {
                            HStack {
                                Text(self.categoryName)
                                    .frame(alignment: .leading)
                                    .padding(.top, prop.isLargerScreen ? 20 : -24)
                                    .padding(.bottom, prop.isLargerScreen ? 0 : 283)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 28 : 30))//.setFontSizeAndWeight(weight: .semibold, size: prop.isLargerScreen ? 35 : 30)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(2)//prop.isLargerScreen ? 2 : 1)
                                    .multilineTextAlignment(.leading)
                                
                                if self.categoryDescription != nil {
                                    Button(action: { self.showDescription = true }) {
                                        Text("Show Description")
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .font(.system(size: 13))
                                            .underline()
                                            .padding(6)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.top, prop.isLargerScreen ? 25 : -16)
                                    .padding(.bottom, prop.isLargerScreen ? 0 : 24)
                                } else {
                                    VStack {
                                        if !self.generatingDesc {
                                            Button(action: {
                                                self.generatingDesc = true
                                                
                                                RequestAction<GenerateDescRequestData>(
                                                    parameters: GenerateDescRequestData(
                                                        Subject: self.categoryName
                                                    )
                                                ).perform(action: generate_desc_req) { statusCode, resp in
                                                    guard resp != nil && statusCode == 200 else {
                                                        if let resp = resp {
                                                            print(resp)
                                                        }
                                                        
                                                        self.generatingDesc = false
                                                        return
                                                    }
                                                    
                                                    self.categoryData.categoryDescriptions[self.categoryName] = resp!["Desc"] as? String
                                                    self.categoryDescription = resp!["Desc"] as? String
                                                    writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                                }
                                            }) {
                                                if #available(iOS 18.0, *) {
                                                    Text("Generate Description")
                                                        .frame(maxWidth: 200, alignment: .center)
                                                        .padding([.top, .bottom], 5)
                                                        .foregroundStyle(
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
                                                            ])
                                                        )
                                                        .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .fill(.white)
                                                                .strokeBorder(.white, lineWidth: 1)
                                                        )
                                                } else {
                                                    Text("Generate Description")
                                                        .frame(maxWidth: 200, alignment: .center)
                                                        .padding([.top, .bottom], 5)
                                                        .foregroundStyle(.black)
                                                        .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .fill(.white)
                                                                .strokeBorder(.white, lineWidth: 1)
                                                        )
                                                }
                                            }
                                            .padding([.top, .bottom], 15)
                                            
                                            if self.errorGenerating {
                                                Text("Error generating description.. try again")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .setFontSizeAndWeight(weight: .medium, size: 16)
                                                    .minimumScaleFactor(0.5)
                                            }
                                        } else {
                                            VStack {
                                                Text("Generating Description...")
                                                    .frame(alignment: .center)
                                                    .foregroundStyle(.white)
                                                    .setFontSizeAndWeight(weight: .medium, size: 12)
                                                
                                                ProgressView()
                                                    .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
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
                                                    ]))//(.blue)
                                            }
                                        }
                                    }
                                    .padding(.top, prop.isLargerScreen ? 25 : -22)
                                    .padding(.bottom, prop.isLargerScreen ? 0 : 24)
                                    .padding(.leading, 15)
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                HStack {
                                    Text("\(self.categoryData.categoriesAndSets[self.categoryName]!.count) \(self.categoryData.categoriesAndSets[self.categoryName]!.count > 1 ? "Sets" : self.categoryData.categoriesAndSets[self.categoryName]!.count == 0 ? "Sets" : "Set")")
                                        .frame(alignment: .leading)
                                        .foregroundStyle(.white)
                                        .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                                    //.padding([.leading, .trailing], 8)
                                    //.padding([.top, .bottom], 2.5)
                                    
                                    Divider()
                                        .background(.white)
                                    
                                    Text("Created \(self.creationDate)")
                                        .frame(alignment: .trailing)
                                        .foregroundStyle(.white)
                                        .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                                    //.padding([.leading, .trailing], 8)
                                    //.padding([.top, .bottom], 2.5)
                                }
                                .frame(alignment: .leading)
                                //.padding(.trailing, 15)
                                
                                HStack {
                                    Button(action: {
                                        self.categoryToDelete = self.categoryName
                                        self.categoryAlert = true
                                        self.alertType = .DeleteCategoryAlert
                                    }) {
                                        ZStack {
                                            Image(systemName: "trash")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.red)
                                        }
                                        .frame(alignment: .leading)
                                        .padding(.trailing, 10)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .alert("Are you sure?", isPresented: $categoryAlert) {
                                        Button(action: {
                                            self.launchCategory = false
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                if self.categoryData.categoriesAndSets.count == 1 {
                                                    self.categoryData.categoriesAndSets.removeAll()
                                                    self.categoryData.setAndNotes.removeAll()
                                                    self.categoryData.categoryCustomTextColors.removeAll()
                                                    self.categoryData.categoryCustomColors.removeAll()
                                                    self.categoryData.categoryDescriptions.removeAll()
                                                } else {
                                                    self.categoryData.categoriesAndSets.removeValue(forKey: self.categoryToDelete)
                                                    self.categoryData.setAndNotes.removeValue(forKey: self.categoryToDelete)
                                                    
                                                    if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryToDelete) {
                                                        self.categoryData.categoryCustomTextColors.removeValue(forKey: self.categoryToDelete)
                                                    }
                                                    
                                                    if self.categoryData.categoryCustomColors.keys.contains(self.categoryToDelete) {
                                                        self.categoryData.categoryCustomColors.removeValue(forKey: self.categoryToDelete)
                                                    }
                                                    
                                                    if self.categoryData.categoryDescriptions.keys.contains(self.categoryToDelete) {
                                                        self.categoryData.categoryDescriptions.removeValue(forKey: self.categoryToDelete)
                                                    }
                                                }
                                                
                                                /* MARK: Ensure the cache is up to date. */
                                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                                writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                                writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                                writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                                
                                                resetAlert()
                                            }
                                            
                                            /* TODO: Add support for actually storing category information in the database. That will, thereby, prompt us to need to send a request to the server to delete the given category from the database. */
                                        }) {
                                            Text("Yes")
                                        }
                                        
                                        Button(action: { resetAlert() }) { Text("No") }
                                    } message: {
                                        Text(self.alertType == .DeleteCategoryAlert
                                             ? "Once deleted, the category **\"\(self.categoryToDelete)\"** will be removed from cloud or local storage and cannot be recovered."
                                             : "") /* TODO: Finish this. There will presumably be more alert types. */
                                    }
                                    
                                    Button(action: {
                                        if self.categoryData.categoryDescriptions.keys.contains(self.categoryName) {
                                            self.newCategoryDescription = self.categoryData.categoryDescriptions[self.categoryName]!
                                        } else { self.newCategoryDescription = "" }
                                        
                                        if self.categoryData.categoryCustomColors.keys.contains(self.categoryName) {
                                            self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[self.categoryName]!
                                        } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                                        
                                        if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryName) {
                                            self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[self.categoryName]!
                                        } else { self.newCategoryTextColor = .white }
                                        
                                        self.categoryBeingEdited = self.categoryName
                                        //self.categoryBeingEditedImage = self.categoryData.categoryImages[self.categoryName]!
                                        self.editCategoryDetails = true
                                    }) {
                                        ZStack {
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(Color.EZNotesBlue)
                                        }
                                        .frame(alignment: .leading)
                                        .padding(.trailing, 10)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .popover(isPresented: $editCategoryDetails) {
                                        EditCategory(
                                            prop: self.prop,
                                            categoryBeingEditedImage: self.categoryBackground,
                                            categoryBeingEdited: $categoryBeingEdited,
                                            categoryLaunched: $categoryName,
                                            categoryData: self.categoryData,
                                            newCategoryDisplayColor: $newCategoryDisplayColor,
                                            newCategoryTextColor: $newCategoryTextColor
                                        )
                                        .onDisappear {
                                            self.categoryBackgroundColor = self.categoryData.categoryCustomColors[self.categoryName]
                                            self.categoryTitleColor = self.categoryData.categoryCustomTextColors[self.categoryName]
                                        }
                                    }
                                    
                                    
                                    ShareLink(
                                        item: self.categoryBackground,
                                        subject: Text(self.categoryName),
                                        message: Text(
                                            self.categoryDescription != nil
                                                ? "\(self.categoryDescription!)\n\nCreated with the support of **EZNotes**"
                                                : ""
                                        ),
                                        preview: SharePreview(self.categoryName, image: self.categoryBackground))
                                    {//(item: URL(string: "https://apps.apple.com/us/app/light-speedometer/id6447198696")!) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                            .foregroundStyle(Color.EZNotesBlue)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading) /* MARK: `maxWidth` is in this as it's the last element in the HStack, thus pushing all the other content over. */
                                }
                                .frame(alignment: .trailing)
                                .padding(.leading, prop.isLargerScreen ? 10 : 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                            .padding(.top, -15)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, prop.isLargerScreen ? 10 : -10)
                    }
                    .frame(maxWidth: prop.size.width - 40, alignment: .top)
                    .padding(.bottom, -15) /* MARK: Bring the below divider closer to the above content. */
                    
                    TextField(
                        "Search...",
                        text: $setSearch
                    )
                    .frame(
                        maxWidth: prop.size.width - 20
                    )
                    .padding(14)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 25)
                            
                            if self.setSearch != "" {
                                Button(action: {
                                    self.setSearch = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 25)
                                }
                            }
                        }
                    )
                    .padding(.top, 25)
                    .onSubmit {
                        
                    }
                    .focused($setSearchFocus)
                    .onTapGesture {
                        self.setSearchFocus = true
                    }
                    
                    if self.settings.displayUserCreatedSetsSeparately {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: { self.selectedView = "generated" }) {
                                        HStack {
                                            Text("Generated")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "generated" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "generated" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { self.selectedView = "user_created" }) {
                                        HStack {
                                            Text("User Created")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "user_created" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "user_created" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding(.top, 10)
                    }
                    
                    VStack { }.frame(maxWidth: prop.size.width - 20, maxHeight: 1.5).background(
                        MeshGradient(width: 3, height: 3, points: [
                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ], colors: [
                            .indigo, .indigo, Color.EZNotesBlue,
                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                        ])
                    )
                    .cornerRadius(20)
                    .padding(.top, 5.5)
                    .padding(.bottom, -30)*/
                    
                    if self.settings.displayUserCreatedSetsSeparately {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: { self.selectedView = "generated" }) {
                                        HStack {
                                            Text("Generated")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "generated" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "generated" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { self.selectedView = "user_created" }) {
                                        HStack {
                                            Text("User Created")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "user_created" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "user_created" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding(.top, 10)
                        
                        VStack { }.frame(maxWidth: prop.size.width - 20, maxHeight: 1.5).background(
                            MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ])
                        )
                        .cornerRadius(20)
                        .padding(.top, 5.5)
                        .padding(.bottom, -30)
                    }
                    
                    VStack {
                        VStack {
                            if self.settings.displayUserCreatedSetsSeparately {
                                switch(self.selectedView) {
                                case "generated":
                                    if self.longerSetNames.isEmpty && self.shorterSetNames.isEmpty {
                                        Text("No AI-generated sets or notes in this category.")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                    } else {
                                        ShowLongAndShortNameSets(
                                            prop: self.prop,
                                            categoryName: self.categoryName,
                                            longerSetNames: self.longerSetNames,
                                            shorterSetNames: self.shorterSetNames,
                                            categoryTitleColor: self.categoryTitleColor,
                                            categoryBackgroundColor: self.categoryBackgroundColor,
                                            setName: $setName,
                                            notesContent: $notesContent,
                                            originalContet: $originalContet,
                                            launchedSet: $launchedSet
                                        )
                                    }
                                case "user_created":
                                    if self.userCreatedLongSetNames.isEmpty && self.userCreatedShortSetNames.isEmpty {
                                        Text("No user created sets or notes in this category.")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                    } else {
                                        ShowLongAndShortNameSets(
                                            prop: self.prop,
                                            categoryName: self.categoryName,
                                            longerSetNames: self.userCreatedLongSetNames,
                                            shorterSetNames: self.userCreatedShortSetNames,
                                            categoryTitleColor: self.categoryTitleColor,
                                            categoryBackgroundColor: self.categoryBackgroundColor,
                                            setName: $setName,
                                            notesContent: $notesContent,
                                            originalContet: $originalContet,
                                            launchedSet: $launchedSet
                                        )
                                    }
                                default: VStack { }.onAppear { self.selectedView = "generated" }
                                }
                            } else {
                                if self.categoryData.setAndNotes[self.categoryName]!.isEmpty {
                                    Text("No sets or notes in this category.")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                } else {
                                    ShowLongAndShortNameSets(
                                        prop: self.prop,
                                        categoryName: self.categoryName,
                                        longerSetNames: self.longerSetNames,
                                        shorterSetNames: self.shorterSetNames,
                                        categoryTitleColor: self.categoryTitleColor,
                                        categoryBackgroundColor: self.categoryBackgroundColor,
                                        setName: $setName,
                                        notesContent: $notesContent,
                                        originalContet: $originalContet,
                                        launchedSet: $launchedSet
                                    )
                                }
                            }
                        }
                        .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                    }
                    .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity, alignment: .top)
                    .padding()
                    //.padding(.top, -5)
                    .cornerRadius(15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: [.top, .bottom])
                .padding(.top, prop.isLargerScreen ? 115 : 110)
                //}
                .padding(.top, -90)
                
                CategoryInternalsPlusButton(
                    prop: self.prop,
                    categoryBackground: self.categoryBackground,
                    categoryName: $categoryName,
                    categoryDescription: $categoryDescription,
                    launchCategory: $launchCategory,
                    categoryBackgroundColor: $categoryBackgroundColor,
                    categoryTitleColor: $categoryTitleColor,
                    alertType: $alertType,
                    showDescription: $showDescription,
                    testPopup: $testPopup,
                    createNewSet: $createNewSet,
                    createNewSetByImage: $createNewSetByImage
                )
                .padding(.bottom, 20)*/
                ZStack {
                    /*if self.topContentOpacity == 0 {
                        VStack {
                            VStack {
                                TopNavCategoryView(
                                    prop: self.prop,
                                    categoryName: self.categoryName,
                                    numberOfSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                                    creationDate: self.creationDate,
                                    categoryBackground: self.categoryBackground,
                                    categoryBackgroundColor: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesLightBlack,
                                    totalSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                                    launchCategory: $launchCategory,
                                    showTitle: $show_category_internal_title,
                                    //tempChatHistory: $tempChatHistory,
                                    //messages: $messages,
                                    accountInfo: self.accountInfo,
                                    topBanner: $topBanner,
                                    images_to_upload: self.images_to_upload
                                )
                                .opacity(self.secondaryNavbarOpacity)
                                .animation(.smooth(duration: 0.5), value: self.secondaryNavbarOpacity)
                                
                                if self.settings.displayUserCreatedSetsSeparately {
                                    HStack {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                Button(action: { self.selectedView = "generated" }) {
                                                    HStack {
                                                        Text("Generated")
                                                            .frame(alignment: .center)
                                                            .padding([.top, .bottom], 4)
                                                            .padding([.leading, .trailing], 8.5)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(self.selectedView == "generated" ? Color.EZNotesBlue : .clear)
                                                            )
                                                            .foregroundStyle(self.selectedView == "generated" ? .black : .secondary)
                                                            .font(Font.custom("Poppins-SemiBold", size: 12))
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                
                                                Button(action: { self.selectedView = "user_created" }) {
                                                    HStack {
                                                        Text("User Created")
                                                            .frame(alignment: .center)
                                                            .padding([.top, .bottom], 4)
                                                            .padding([.leading, .trailing], 8.5)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(self.selectedView == "user_created" ? Color.EZNotesBlue : .clear)
                                                            )
                                                            .foregroundStyle(self.selectedView == "user_created" ? .black : .secondary)
                                                            .font(Font.custom("Poppins-SemiBold", size: 12))
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 10)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 15)
                                    .padding(.top, 10)
                                    
                                    VStack { }.frame(maxWidth: prop.size.width - 20, maxHeight: 1.5).padding(.vertical, 0.5).background(
                                        MeshGradient(width: 3, height: 3, points: [
                                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                                        ], colors: [
                                            .indigo, .indigo, Color.EZNotesBlue,
                                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                        ])
                                    )
                                    .cornerRadius(20)
                                    .padding(.top, 5.5)
                                    //.padding(.bottom, -30)
                                }
                            }
                            .zIndex(1)
                            .background(Color.EZNotesBlack)
                            
                            Spacer()
                        }
                    }*/
                    
                    VStack {
                        if self.topContentOpacity == 0 {
                            TopNavCategoryView(
                                prop: self.prop,
                                categoryName: self.categoryName,
                                numberOfSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                                creationDate: self.creationDate,
                                categoryBackground: self.categoryBackground,
                                categoryBackgroundColor: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesLightBlack,
                                totalSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                                launchCategory: $launchCategory,
                                showTitle: $show_category_internal_title,
                                //tempChatHistory: $tempChatHistory,
                                //messages: $messages,
                                accountInfo: self.accountInfo,
                                topBanner: $topBanner,
                                images_to_upload: self.images_to_upload
                            )
                            .opacity(self.secondaryNavbarOpacity)
                            .animation(.smooth(duration: 0.5), value: self.secondaryNavbarOpacity)
                            
                            if self.settings.displayUserCreatedSetsSeparately {
                                HStack {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            Button(action: { self.selectedView = "generated" }) {
                                                HStack {
                                                    Text("Generated")
                                                        .frame(alignment: .center)
                                                        .padding([.top, .bottom], 4)
                                                        .padding([.leading, .trailing], 8.5)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .fill(self.selectedView == "generated" ? Color.EZNotesBlue : .clear)
                                                        )
                                                        .foregroundStyle(self.selectedView == "generated" ? .black : .secondary)
                                                        .font(Font.custom("Poppins-SemiBold", size: 12))
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                            
                                            Button(action: { self.selectedView = "user_created" }) {
                                                HStack {
                                                    Text("User Created")
                                                        .frame(alignment: .center)
                                                        .padding([.top, .bottom], 4)
                                                        .padding([.leading, .trailing], 8.5)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .fill(self.selectedView == "user_created" ? Color.EZNotesBlue : .clear)
                                                        )
                                                        .foregroundStyle(self.selectedView == "user_created" ? .black : .secondary)
                                                        .font(Font.custom("Poppins-SemiBold", size: 12))
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 10)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 15)
                                .padding(.top, 10)
                                
                                VStack { }.frame(maxWidth: prop.size.width - 20, maxHeight: 1.5).background(
                                    MeshGradient(width: 3, height: 3, points: [
                                        .init(0, 0), .init(0.3, 0), .init(1, 0),
                                        .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                                    ], colors: [
                                        .indigo, .indigo, Color.EZNotesBlue,
                                        Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                        .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                    ])
                                )
                                .cornerRadius(20)
                                .padding(.top, 5.5)
                                //.padding(.bottom, -30)
                            }
                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack {
                                //GeometryReader { g in
                                self.categoryBackground
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2) /* MARK: The overall `ZStack` has a height of `prop.size.height / 2.5`, however to ensure the background image spans the entire top of the screen we divide by `2`, not `2.5`. */
                                    .overlay(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                                /*.frame(maxWidth: .infinity, maxHeight: self.blurredImageHeight)
                                 .scaledToFill()
                                 .overlay(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                                 .onAppear {
                                 print(g.size.height)
                                 if g.size.height < 288 {
                                 self.blurredImageHeight = prop.size.height + 100
                                 }
                                 }*/
                                //}
                                //.frame(maxWidth: .infinity, maxHeight: self.blurredImageHeight)
                                
                                VStack {
                                    Spacer()
                                    
                                    VStack {
                                        
                                    }
                                    .frame(maxHeight: 240)
                                    
                                    //GeometryReader { geo in
                                    HStack {
                                        VStack {
                                            Button(action: { self.launchCategory = false }) {
                                                Image(systemName: "arrow.left")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(Color.EZNotesBlue)
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                            .padding(12)
                                            .background(
                                                Circle()
                                                    .fill(Color.EZNotesBlack)
                                            )
                                            .padding([.leading], 20)
                                        }
                                        .frame(maxWidth: 95, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        self.categoryBackground
                                            .resizable()
                                            .frame(width: 95, height: 95)
                                            .scaledToFit()
                                            .cornerRadius(10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .shadow(color: Color.black, radius: 2.5)
                                            )
                                            .padding(2.5)
                                        
                                        Spacer()
                                        
                                        ZStack {
                                            VStack {
                                                Button(action: { self.aiChat = true }) {
                                                    Image("AI-Chat-Icon")
                                                        .resizable()
                                                        .frame(
                                                            width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                                            height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                                                        )
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .popover(isPresented: $aiChat) {
                                                    AIChat(
                                                        prop: self.prop,
                                                        accountInfo: self.accountInfo
                                                    )
                                                }
                                            }
                                            .frame(
                                                width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                                height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                                            )
                                            .padding(6)
                                            .background(
                                                Circle()
                                                    .fill(Color.EZNotesBlack)
                                            )
                                            .padding([.trailing], 20)
                                        }.frame(maxWidth: 95, alignment: .trailing)
                                    }
                                    //.frame(height: 95)
                                    .overlay(
                                        GeometryReader { geo in
                                            Color.clear.onChange(of: geo.frame(in: .global).minY) {
                                                if geo.frame(in: .global).minY < -120 {
                                                    withAnimation(.smooth(duration: 0.5)) {
                                                        self.topContentOpacity = 0
                                                        self.topContentHeight = 0
                                                        
                                                        self.secondaryNavbarOpacity = 1
                                                    }
                                                } else {
                                                    if self.topContentOpacity == 0 && geo.frame(in: .global).minY > 77 {//-84 {
                                                        withAnimation(.smooth(duration: 0.5)) {
                                                            self.secondaryNavbarOpacity = 0
                                                            
                                                            self.topContentOpacity = 1
                                                            self.topContentHeight = UIScreen.main.bounds.height / 2.5
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    )
                                    /*.onChange(of: geo.frame(in: .global).minY) {
                                     
                                     if geo.frame(in: .global).minY < -120 {
                                     withAnimation(.smooth(duration: 0.5)) {
                                     self.topContentOpacity = 0
                                     self.topContentHeight = 0
                                     
                                     self.secondaryNavbarOpacity = 1
                                     }
                                     } else {
                                     if self.topContentOpacity == 0 && geo.frame(in: .global).minY > -84 {
                                     withAnimation(.smooth(duration: 0.5)) {
                                     self.secondaryNavbarOpacity = 0
                                     
                                     self.topContentOpacity = 1
                                     self.topContentHeight = UIScreen.main.bounds.height / 2.5
                                     }
                                     }
                                     }
                                     }*/
                                    //}
                                    //.frame(maxHeight: 125)
                                    
                                    Text(self.categoryName)
                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                        .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen || prop.isMediumScreen ? 30 : 26))
                                        .foregroundStyle(.white)
                                        .lineLimit(1...4)
                                        .multilineTextAlignment(.center)
                                        //.minimumScaleFactor(0.8)
                                    
                                    if self.topBanner.keys.contains(self.categoryName) && self.topBanner[self.categoryName]! != .None {
                                        switch(self.topBanner[self.categoryName]!) {
                                        case .LoadingUploads:
                                            HStack {
                                                Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                                
                                                ProgressView()
                                                    .controlSize(.mini)
                                                    .tint(Color.EZNotesBlue)
                                            }
                                            .frame(maxWidth: prop.size.width - 120, alignment: .center)
                                            .padding(.top, -16)
                                            .padding(.bottom, -6)
                                            //.padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 25 : 10)
                                        default: VStack { }.onAppear { self.topBanner[self.categoryName] = .None }
                                        }
                                    }
                                    
                                    HStack {
                                        Text("\(self.categoryData.categoriesAndSets[self.categoryName]!.count) \(self.categoryData.categoriesAndSets[self.categoryName]!.count > 1 ? "Sets" : self.categoryData.categoriesAndSets[self.categoryName]!.count == 0 ? "Sets" : "Set")")
                                            .frame(alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen || prop.isMediumScreen ? 12.5 : 10.5)
                                        
                                        Divider()
                                            .background(.white)
                                        
                                        Text("Created \(self.creationDate)")
                                            .frame(alignment: .trailing)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen || prop.isMediumScreen ? 12.5 : 10.5)
                                    }
                                    .frame(maxHeight: 13)
                                    .padding(.bottom, prop.isLargerScreen || prop.isMediumScreen ? 16 : 8)
                                    
                                    HStack {
                                        Button(action: {
                                            self.categoryToDelete = self.categoryName
                                            self.categoryAlert = true
                                            self.alertType = .DeleteCategoryAlert
                                        }) {
                                            ZStack {
                                                Image(systemName: "trash")
                                                    .resizable()
                                                    .frame(width: prop.isLargerScreen || prop.isMediumScreen ? 20 : 17, height: prop.isLargerScreen || prop.isMediumScreen ? 20 : 17)
                                                    .foregroundStyle(.red)
                                            }
                                            .frame(alignment: .leading)
                                            .padding(.trailing, 10)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .alert("Are you sure?", isPresented: $categoryAlert) {
                                            Button(action: {
                                                self.launchCategory = false
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    if self.categoryData.categoriesAndSets.count == 1 {
                                                        self.categoryData.categoriesAndSets.removeAll()
                                                        self.categoryData.setAndNotes.removeAll()
                                                        self.categoryData.categoryCustomTextColors.removeAll()
                                                        self.categoryData.categoryCustomColors.removeAll()
                                                        self.categoryData.categoryDescriptions.removeAll()
                                                    } else {
                                                        self.categoryData.categoriesAndSets.removeValue(forKey: self.categoryToDelete)
                                                        self.categoryData.setAndNotes.removeValue(forKey: self.categoryToDelete)
                                                        
                                                        if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryToDelete) {
                                                            self.categoryData.categoryCustomTextColors.removeValue(forKey: self.categoryToDelete)
                                                        }
                                                        
                                                        if self.categoryData.categoryCustomColors.keys.contains(self.categoryToDelete) {
                                                            self.categoryData.categoryCustomColors.removeValue(forKey: self.categoryToDelete)
                                                        }
                                                        
                                                        if self.categoryData.categoryDescriptions.keys.contains(self.categoryToDelete) {
                                                            self.categoryData.categoryDescriptions.removeValue(forKey: self.categoryToDelete)
                                                        }
                                                    }
                                                    
                                                    /* MARK: Ensure the cache is up to date. */
                                                    writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                                    writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                                    writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                                    writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                                    writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                                    
                                                    resetAlert()
                                                }
                                                
                                                /* TODO: Add support for actually storing category information in the database. That will, thereby, prompt us to need to send a request to the server to delete the given category from the database. */
                                            }) {
                                                Text("Yes")
                                            }
                                            
                                            Button(action: { resetAlert() }) { Text("No") }
                                        } message: {
                                            Text(self.alertType == .DeleteCategoryAlert
                                                 ? "Once deleted, the category **\"\(self.categoryToDelete)\"** will be removed from cloud or local storage and cannot be recovered."
                                                 : "") /* TODO: Finish this. There will presumably be more alert types. */
                                        }
                                        
                                        Button(action: {
                                            if self.categoryData.categoryDescriptions.keys.contains(self.categoryName) {
                                                self.newCategoryDescription = self.categoryData.categoryDescriptions[self.categoryName]!
                                            } else { self.newCategoryDescription = "" }
                                            
                                            if self.categoryData.categoryCustomColors.keys.contains(self.categoryName) {
                                                self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[self.categoryName]!
                                            } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                                            
                                            if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryName) {
                                                self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[self.categoryName]!
                                            } else { self.newCategoryTextColor = .white }
                                            
                                            self.categoryBeingEdited = self.categoryName
                                            //self.categoryBeingEditedImage = self.categoryData.categoryImages[self.categoryName]!
                                            self.editCategoryDetails = true
                                        }) {
                                            ZStack {
                                                Image(systemName: "pencil")
                                                    .resizable()
                                                    .frame(width: prop.isLargerScreen || prop.isMediumScreen ? 20 : 17, height: prop.isLargerScreen || prop.isMediumScreen ? 20 : 17)
                                                    .foregroundStyle(Color.EZNotesBlue)
                                            }
                                            .frame(alignment: .leading)
                                            .padding(.trailing, 10)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        //.padding(.trailing, 6)
                                        .popover(isPresented: $editCategoryDetails) {
                                            EditCategory(
                                                prop: self.prop,
                                                categoryBeingEditedImage: self.categoryBackground,
                                                categoryBeingEdited: $categoryBeingEdited,
                                                categoryLaunched: $categoryName,
                                                categoryData: self.categoryData,
                                                newCategoryDisplayColor: $newCategoryDisplayColor,
                                                newCategoryTextColor: $newCategoryTextColor
                                            )
                                            .onDisappear {
                                                self.categoryBackgroundColor = self.categoryData.categoryCustomColors[self.categoryName]
                                                self.categoryTitleColor = self.categoryData.categoryCustomTextColors[self.categoryName]
                                            }
                                        }
                                        
                                        ShareLink(
                                            item: self.categoryBackground,
                                            subject: Text(self.categoryName),
                                            message: Text(
                                                self.categoryDescription != nil
                                                ? "\(self.categoryDescription!)\n\nCreated with the support of **EZNotes**"
                                                : ""
                                            ),
                                            preview: SharePreview(self.categoryName, image: self.categoryBackground))
                                        {//(item: URL(string: "https://apps.apple.com/us/app/light-speedometer/id6447198696")!) {
                                            Label("", systemImage: "square.and.arrow.up")
                                                .font(prop.isLargerScreen || prop.isMediumScreen ? .title2 : .title3)
                                                .foregroundStyle(Color.EZNotesBlue)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center) /* MARK: `maxWidth` is in this as it's the last element in the HStack, thus pushing all the other content over. */
                                        .padding(.bottom, 4)
                                        //.padding(.leading, 6)
                                        
                                        Button(action: { }) {
                                            ZStack {
                                                Image(systemName: "paperplane")
                                                    .resizable()
                                                    .frame(width: prop.isLargerScreen || prop.isMediumScreen ? 20 : 18, height: prop.isLargerScreen || prop.isMediumScreen ? 20 : 18)
                                                    .foregroundStyle(Color.EZNotesBlue)
                                            }
                                            .frame(alignment: .leading)
                                            .padding(.trailing, 10)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        //.padding(.trailing, 6)
                                        
                                        Button(action: { self.showDescription = true }) {
                                            ZStack {
                                                Image(systemName: "info.square")
                                                    .resizable()
                                                    .frame(width: prop.isLargerScreen || prop.isMediumScreen ? 20 : 18, height: prop.isLargerScreen || prop.isMediumScreen ? 20 : 18)
                                                    .foregroundStyle(Color.EZNotesBlue)
                                            }
                                            .frame(alignment: .leading)
                                            .padding(.trailing, 10)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: prop.size.width - 120)
                                    .padding(.top, prop.isLargerScreen || prop.isMediumScreen
                                             ? self.topBanner.keys.contains(self.categoryName) && self.topBanner[self.categoryName]! != .None ? 0 : 16
                                             : 0)
                                    .padding(.vertical)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 30)
                                
                                /*VStack {
                                 HStack {
                                 Button(action: { self.launchCategory = false }) {
                                 Image(systemName: "arrow.left")
                                 .resizable()
                                 .frame(width: 15, height: 15)
                                 .foregroundStyle(Color.EZNotesBlue)
                                 }
                                 .buttonStyle(NoLongPressButtonStyle())
                                 .padding(12)
                                 .background(
                                 Circle()
                                 .fill(Color.EZNotesBlack)
                                 )
                                 .padding([.leading], 20)
                                 
                                 Spacer()
                                 }
                                 .frame(maxHeight: prop.isLargerScreen || prop.isMediumScreen ? 50 : 40)
                                 .padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 35 : 10)
                                 .padding(.bottom, 8)
                                 
                                 VStack {
                                 self.categoryBackground
                                 .resizable()
                                 .frame(maxWidth: prop.size.width - 70, maxHeight: (prop.size.height / 2.5) - 120)
                                 .aspectRatio(1, contentMode: .fill)
                                 .cornerRadius(15)
                                 }
                                 .background(
                                 RoundedRectangle(cornerRadius: 15)
                                 .shadow(color: Color.black, radius: 2.5)
                                 )
                                 .padding(2.5)
                                 .padding(.top)
                                 }
                                 .padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 30 : 15)*/
                            }
                            .frame(maxHeight: self.topContentHeight)//prop.size.height / 2.5)
                            .opacity(self.topContentOpacity)
                            .animation(.smooth(duration: 0.5), value: self.topContentOpacity)
                            .padding(.bottom, self.topContentOpacity == 1 ? 20 : -16)//46)//prop.isLargerScreen || prop.isMediumScreen ? 30 : 28)
                            
                            VStack {
                                if self.settings.displayUserCreatedSetsSeparately {
                                    if self.topContentOpacity == 1 {
                                        HStack {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    Button(action: { self.selectedView = "generated" }) {
                                                        HStack {
                                                            Text("Generated")
                                                                .frame(alignment: .center)
                                                                .padding([.top, .bottom], 4)
                                                                .padding([.leading, .trailing], 8.5)
                                                                .background(
                                                                    RoundedRectangle(cornerRadius: 15)
                                                                        .fill(self.selectedView == "generated" ? Color.EZNotesBlue : .clear)
                                                                )
                                                                .foregroundStyle(self.selectedView == "generated" ? .black : .secondary)
                                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    
                                                    Button(action: { self.selectedView = "user_created" }) {
                                                        HStack {
                                                            Text("User Created")
                                                                .frame(alignment: .center)
                                                                .padding([.top, .bottom], 4)
                                                                .padding([.leading, .trailing], 8.5)
                                                                .background(
                                                                    RoundedRectangle(cornerRadius: 15)
                                                                        .fill(self.selectedView == "user_created" ? Color.EZNotesBlue : .clear)
                                                                )
                                                                .foregroundStyle(self.selectedView == "user_created" ? .black : .secondary)
                                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 10)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 15)
                                        .padding(.top, self.topContentOpacity == 1 ? -15 : -5)
                                        
                                        VStack { }.frame(maxWidth: prop.size.width - 20, maxHeight: 1.5).padding(.vertical, 0.5).background(
                                            MeshGradient(width: 3, height: 3, points: [
                                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                                            ], colors: [
                                                .indigo, .indigo, Color.EZNotesBlue,
                                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                            ])
                                        )
                                        .cornerRadius(20)
                                        .padding(.top, 5.5)
                                        //.padding(.bottom, -30)
                                    }
                                }
                                
                                if self.settings.displayUserCreatedSetsSeparately {
                                    switch(self.selectedView) {
                                    case "generated":
                                        if self.longerSetNames.isEmpty && self.shorterSetNames.isEmpty {
                                            Spacer()
                                            
                                            Text("No AI-generated sets or notes in this category.")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                        } else {
                                            ShowLongAndShortNameSets(
                                                prop: self.prop,
                                                categoryName: self.categoryName,
                                                longerSetNames: self.longerSetNames,
                                                shorterSetNames: self.shorterSetNames,
                                                categoryTitleColor: self.categoryTitleColor,
                                                categoryBackgroundColor: self.categoryBackgroundColor,
                                                setName: $setName,
                                                notesContent: $notesContent,
                                                originalContet: $originalContet,
                                                launchedSet: $launchedSet
                                            )
                                            .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                                            .padding(.top, 10)
                                        }
                                    case "user_created":
                                        if self.userCreatedLongSetNames.isEmpty && self.userCreatedShortSetNames.isEmpty {
                                            Spacer()
                                            
                                            Text("No user created sets or notes in this category.")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                        } else {
                                            ShowLongAndShortNameSets(
                                                prop: self.prop,
                                                categoryName: self.categoryName,
                                                longerSetNames: self.userCreatedLongSetNames,
                                                shorterSetNames: self.userCreatedShortSetNames,
                                                categoryTitleColor: self.categoryTitleColor,
                                                categoryBackgroundColor: self.categoryBackgroundColor,
                                                setName: $setName,
                                                notesContent: $notesContent,
                                                originalContet: $originalContet,
                                                launchedSet: $launchedSet
                                            )
                                            .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                                            .padding(.top, 10)
                                        }
                                    default: VStack { }.onAppear { self.selectedView = "generated" }
                                    }
                                } else {
                                    if self.categoryData.setAndNotes[self.categoryName]!.isEmpty {
                                        Text("No sets or notes in this category.")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                    } else {
                                        ShowLongAndShortNameSets(
                                            prop: self.prop,
                                            categoryName: self.categoryName,
                                            longerSetNames: self.longerSetNames,
                                            shorterSetNames: self.shorterSetNames,
                                            categoryTitleColor: self.categoryTitleColor,
                                            categoryBackgroundColor: self.categoryBackgroundColor,
                                            setName: $setName,
                                            notesContent: $notesContent,
                                            originalContet: $originalContet,
                                            launchedSet: $launchedSet
                                        )
                                        .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                                        .padding(.top, 10)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            //.padding(.top, self.topContentOpacity == 1 ? 0 : -36)
                            //.padding(.top, self.topContentOpacity == 1 ? 0 :
                            //            prop.isLargerScreen ? 160 : prop.isMediumScreen ? 145 : 135)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, self.topContentOpacity == 0 ? -6 : 0) /* MARK: Move the scrollview up by 4 pixels to ensure when scrolling the content looks as though it's going "under" the top part of the view. */
                    }
                    //.zIndex(1)
                    
                    CategoryInternalsPlusButton(
                        prop: self.prop,
                        categoryBackground: self.categoryBackground,
                        categoryName: $categoryName,
                        categoryDescription: $categoryDescription,
                        launchCategory: $launchCategory,
                        categoryBackgroundColor: $categoryBackgroundColor,
                        categoryTitleColor: $categoryTitleColor,
                        alertType: $alertType,
                        showDescription: $showDescription,
                        testPopup: $testPopup,
                        createNewSet: $createNewSet,
                        createNewSetByImage: $createNewSetByImage
                    )
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.EZNotesBlack)
            //.edgesIgnoringSafeArea([.top])
            .ignoresSafeArea(edges: self.createNewSetByImage ? [.bottom] : [.top, .bottom])
            .onAppear {
                self.categoryDescription = self.categoryData.categoryDescriptions[self.categoryName]
                self.setsYOffset = prop.size.height - 100
                
                /* TODO: Figure out a better way to handle this. As of now, when the `CategoryInternalsView` becomes visible this runs. However, when the user goes to view the notes and comes back this `.onAppear` re-runs. */
                self.longerSetNames.removeAll()
                self.shorterSetNames.removeAll()
                
                if self.categoryData.setAndNotes[self.categoryName]!.isEmpty { return }
                
                if self.settings.displayUserCreatedSetsSeparately {
                    self.allUserCreatedSets[self.categoryName] = []
                    
                    self.userCreatedLongSetNames.removeAll()
                    self.userCreatedShortSetNames.removeAll()
                    
                    for categorySet in self.categoryData.setAndNotes[self.categoryName]! {
                        if self.categoryData.userCreatedSetNames.contains(categorySet.first!.key) {
                            self.allUserCreatedSets[self.categoryName]!.append(categorySet)
                        }
                    }
                    
                    for setData in self.allUserCreatedSets[self.categoryName]! {
                        if setData.first!.key.count >= 15 { self.userCreatedLongSetNames.append(setData.first!.key) }
                        else { self.userCreatedShortSetNames.append(setData.first!.key) }
                    }
                }
                
                for setData in self.categoryData.setAndNotes[self.categoryName]! {
                    if setData.first!.key.count >= 15 { self.longerSetNames.append(setData.first!.key) }
                    else {
                        self.shorterSetNames.append(setData.first!.key)
                    }
                    //if setData.first!.key.count >= 15 { self.longerSetNames.append(setData.first!.key) }
                    //else { self.shorterSetNames.append(setData.first!.key) }
                }
                
                
                /* TODO: Is this needed? Keep for now just in case. */
                withAnimation(.easeIn(duration: 0.65)) {
                    self.setsYOffset = 0
                    self.internalInfoOpacity = 1
                }
            }
            .onTapGesture {
                /* MARK: If the user taps anywhere within the view, check the below states. We want to know if we need to hide the views the below states dictate or not. */
                if self.testPopup { self.testPopup = false }
                if self.setSearchFocus {
                    self.setSearchFocus = false
                    
                    // MARK: Below line is not needed, but wouldn't hurt to include in deployed build
                    //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        } else {
            ShowNotes(
                prop: self.prop,
                categoryName: self.categoryName,
                setName: self.setName,
                categoryBackgroundColor: self.categoryBackgroundColor,
                categoryTitleColor: self.categoryTitleColor,
                originalContent: self.originalContet,
                notesContent: $notesContent,
                launchedSet: $launchedSet,
                categoryData: self.categoryData//setAndNotes: $setAndNotes
            )
        }
    }
}
