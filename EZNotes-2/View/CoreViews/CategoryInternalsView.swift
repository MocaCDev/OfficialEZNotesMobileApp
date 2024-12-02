//
//  CategoryInternalsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/9/24.
//
import SwiftUI

struct CategoryInternalsView: View {
    
    var prop: Properties
    var categoryName: String
    var creationDate: String
    @State public var categoryTitleColor: Color?
    @State public var categoryBackgroundColor: Color?
    //var categoriesAndSets: [String: Array<String>]
    var categoryBackground: UIImage
    //var categoriesSetsAndNotes: Array<[String: String]>
    
    @State private var categoryDescription: String? = nil
    @State private var generatingDesc: Bool = false
    @State private var errorGenerating: Bool = false
    @State private var setsYOffset: CGFloat = 0
    @State private var internalInfoOpacity: CGFloat = 0
    
    @ObservedObject public var categoryData: CategoryData
    @Binding public var launchCategory: Bool
    @Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    @Binding public var messages: Array<MessageDetails>
    @ObservedObject public var accountInfo: AccountDetails
    
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
    @State private var newSetName: String = ""
    @State private var newSetNotes: String = ""
    
    /* MARK: Variables regarding search bar. */
    @State private var setSearch: String = ""
    @FocusState private var setSearchFocus: Bool
    
    /* MARK: Teting stuff out. */
    @State private var longerSetNames: Array<String> = []
    @State private var shorterSetNames: Array<String> = []
    var body: some View {
        if !self.launchedSet {
            ZStack {
                if self.createNewSet {
                    VStack {
                        Spacer()
                        
                        VStack {
                            HStack {
                                ZStack {
                                    Button(action: {
                                        self.newSetNotes.removeAll()
                                        self.newSetName.removeAll()
                                        self.createNewSet = false
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
                                    
                                    Text("Create New Set")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 24))
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                                ZStack { }.frame(maxWidth: 20, alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            /*ZStack {
                                /* MARK: `VStack` exists to push the multiply to the top*/
                                VStack {
                                    HStack {
                                        ZStack {
                                            Button(action: {
                                                self.newSetNotes.removeAll()
                                                self.newSetName.removeAll()
                                                self.createNewSet = false
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
                                        .frame(
                                            width: 20,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                            height: 20//prop.size.height / 2.5 > 300 ? 45 : 40
                                        )
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(Color.EZNotesLightBlack.opacity(0.5))
                                        )
                                        .padding(.trailing, 15)
                                        .padding(.top, 2.5)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Create New Set")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 24))
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                //.padding([.top, .bottom])
                            }
                            .frame(maxWidth: .infinity, maxHeight: 30)*/
                            
                            HStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.white)
                                .padding(.bottom, 15)
                            
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
                                            isError: false
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
                            
                            Button(action: {
                                self.categoryData.categoriesAndSets[self.categoryName]!.append(self.newSetName)
                                self.categoryData.setAndNotes[self.categoryName]!.append([self.newSetName: self.newSetNotes])
                                
                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                
                                if self.newSetName.count > 15 { self.longerSetNames.append(self.newSetName) }
                                else { self.shorterSetNames.append(self.newSetName) }
                                
                                self.newSetName.removeAll()
                                self.newSetNotes.removeAll()
                            }) {
                                HStack {
                                    Text("Create")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                        .minimumScaleFactor(0.5)
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
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.EZNotesLightBlack.opacity(0.7))
                    .onTapGesture {
                        self.createNewSet = false
                    }
                    .zIndex(1)
                }
                
                //ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    TopNavCategoryView(
                        prop: self.prop,
                        categoryName: self.categoryName,
                        categoryBackground: self.categoryBackground,
                        categoryBackgroundColor: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesLightBlack,
                        totalSets: self.categoryData.categoriesAndSets[self.categoryName]!.count,
                        launchCategory: $launchCategory,
                        showTitle: $show_category_internal_title,
                        tempChatHistory: $tempChatHistory,
                        messages: $messages,
                        accountInfo: self.accountInfo
                    )
                    
                    VStack {
                        VStack {
                            HStack {
                                Text(self.categoryName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 20)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 28 : 24))//.setFontSizeAndWeight(weight: .semibold, size: prop.isLargerScreen ? 35 : 30)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                HStack {
                                    Text("\(self.categoryData.categoriesAndSets[self.categoryName]!.count) \(self.categoryData.categoriesAndSets[self.categoryName]!.count > 1 ? "Sets" : "Set")")
                                        .frame(alignment: .leading)
                                        .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                                    //.padding([.leading, .trailing], 8)
                                    //.padding([.top, .bottom], 2.5)
                                    
                                    Divider()
                                        .background(.white)
                                    
                                    Text("Created \(self.creationDate)")
                                        .frame(alignment: .trailing)
                                        .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                                    //.padding([.leading, .trailing], 8)
                                    //.padding([.top, .bottom], 2.5)
                                }
                                .frame(alignment: .leading)
                                .padding(.trailing, 15)
                                
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
                                                
                                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                                
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
                                        item: Image(uiImage: self.categoryBackground),
                                        subject: Text(self.categoryName),
                                        message: Text(
                                            self.categoryDescription != nil
                                                ? "\(self.categoryDescription!)\n\nCreated with the support of **EZNotes**"
                                                : ""
                                        ),
                                        preview: SharePreview(self.categoryName, image: Image(uiImage: self.categoryBackground)))
                                    {//(item: URL(string: "https://apps.apple.com/us/app/light-speedometer/id6447198696")!) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                            .foregroundStyle(Color.EZNotesBlue)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading) /* MARK: `maxWidth` is in this as it's the last element in the HStack, thus pushing all the other content over. */
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                            .padding(.top, -15)
                            
                            if self.categoryDescription != nil {
                                VStack {
                                    Text("Brief Description:")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-SemiBold", size: 20))
                                        .minimumScaleFactor(0.5)
                                    
                                    Text(self.categoryDescription!)
                                        .frame(maxWidth: .infinity, alignment: .leading)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                        .padding([.bottom, .leading], 8) /* MARK: Pad the bottom to ensure space between the text and the sets information. Pad to the lefthand side (`.leading`) to have a indentation. */
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))//.setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 15 : 13)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.leading)
                                        .truncationMode(.tail)
                                }
                                .padding([.top, .bottom], 5)
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
                                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 16 : 13)
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
                                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 16 : 13)
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
                                        Text("Generating Description...")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.top, 15)
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: prop.size.width - 40, alignment: .top)
                    .padding(.bottom, -15) /* MARK: Bring the below divider closer to the above content. */
                                 
                    /*Divider()
                        .frame(height: 1.5)
                        .background(MeshGradient(width: 3, height: 3, points: [
                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ], colors: [
                            .indigo, .indigo, Color.EZNotesBlue,
                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                        ]))
                        .frame(maxWidth: prop.size.width - 20)
                        .padding(.top, 15)
                        .padding(.bottom, -15) /* MARK: Move below content up to make it look like the scrollview goes under the above `Divider`. */
                        */
                    
                    TextField(
                        "Search...",
                        text: $setSearch
                    )
                    .frame(
                        maxWidth: prop.size.width - 20/*prop.isIpad
                                             ? UIDevice.current.orientation.isLandscape
                                             ? prop.size.width - 800
                                             : prop.size.width - 450
                                             : 150,*/
                        //maxHeight: prop.isLargerScreen ? 25 : 20
                    )
                    .padding(14)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray5))
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
                    .padding(.top, 15)
                    .onSubmit {
                        
                    }
                    .focused($setSearchFocus)
                    .onTapGesture {
                        self.setSearchFocus = true
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
                    .padding(.bottom, -30)
                    
                    VStack {
                        VStack {
                            if self.categoryData.setAndNotes[self.categoryName]!.count == 0 {
                                Text("No sets or notes in this category.")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(.top)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: 20))
                                    .minimumScaleFactor(0.5)
                            } else {
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
                                }
                                /*ScrollView(.vertical, showsIndicators: false) {
                                    LazyVGrid(columns: self.categoryData.setAndNotes[self.categoryName]!.count > 1
                                              ? [GridItem(.flexible())]//[GridItem(.flexible()), GridItem(.flexible())]
                                              : [GridItem(.flexible())]
                                    ) {
                                        ForEach(Array(self.categoryData.setAndNotes[self.categoryName]!.enumerated()), id: \.offset) { index, val in
                                            if val != [:] {
                                                ForEach(Array(val.keys), id: \.self) { key in
                                                    Button(action: {
                                                        self.setName = key
                                                        self.notesContent = val[key]!
                                                        self.originalContet = self.notesContent
                                                        self.launchedSet = true
                                                    }) {
                                                        VStack {
                                                            HStack {
                                                                Text(key)
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
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 15)
                                    .padding(.bottom, 25)
                                }
                                .padding(.top, -26.5)*/
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
                .padding(.top, 115)
                //}
                .padding(.top, -90)
                
                CategoryInternalsPlusButton(
                    prop: self.prop,
                    testPopup: $testPopup,
                    createNewSet: $createNewSet
                )
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.EZNotesBlack)
            .ignoresSafeArea(edges: [.top, .bottom])
            .onAppear {
                self.categoryDescription = self.categoryData.categoryDescriptions[self.categoryName]
                self.setsYOffset = prop.size.height - 100
                
                /* TODO: Figure out a better way to handle this. As of now, when the `CategoryInternalsView` becomes visible this runs. However, when the user goes to view the notes and comes back this `.onAppear` re-runs. */
                self.longerSetNames.removeAll()
                self.shorterSetNames.removeAll()
                
                for setData in self.categoryData.setAndNotes[self.categoryName]! {
                    if setData.first!.key.count >= 15 { self.longerSetNames.append(setData.first!.key) }
                    else { self.shorterSetNames.append(setData.first!.key) }
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
                    
                    // MARK: Below line is not needed, but would't hurt to include in deployed build
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
