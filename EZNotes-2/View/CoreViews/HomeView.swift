//
//  HomeView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import PhotosUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct NoLongPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.0 : 1.0) // No scaling
            .opacity(configuration.isPressed ? 1.0 : 1.0) // No change in opacity
            .contentShape(Rectangle()) // Define the tappable area
    }
}

enum HomeError {
    case None
    case CreateNewCategoryNameEmpty
    case CreateNewCategoryDescriptionEmpty
    case CategoryExists
}

/* MARK: The below view will be used to display "Categories(<number_of_categories>)" or "Results:". */
private struct SearchResult: View {
    @EnvironmentObject private var settings: SettingsConfigManager
    @EnvironmentObject private var categoryData: CategoryData
    
    var prop: Properties
    @Binding public var toDisplay: [String: Array<String>]
    var showingUserCreated: Bool = false
    var showingGenerated: Bool = false
    var showAllTogether: Bool = true
    
    /* MARK: States that will be used if `showAllTogether` is false; if `showAllTogether` is false, either `showingUserCreated` or `showingGenerated` has to be true. */
    @State private var userCreatedCategories: Array<String> = []
    @State private var generatedCategories: Array<String> = []
    
    @Binding public var lookedUpCategoriesAndSets: [String: Array<String>]
    @Binding public var show_categories_title: Bool
    @Binding public var topNavOpacity: Double
    @Binding public var scrollOffset: CGFloat
    public var geometry: GeometryProxy
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        let plusAmount: CGFloat = self.settings.displayUserCreatedCategoriesSeparatly ? -20 : 130
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY + plusAmount || textFrame.minY > scrollViewFrame.maxY {
            self.show_categories_title = true
            self.topNavOpacity += 0.2
        } else {
            self.show_categories_title = false
            self.topNavOpacity = 0
        }
    }
    
    private func calculateNavOpacity(scrollOffset: CGFloat) -> Double {
        let navigationBarHeight: CGFloat = 200
        let maxOffset: CGFloat = -navigationBarHeight
        let minOffset: CGFloat = 0 // When content is at the top
        
        guard scrollOffset < maxOffset else {
            return self.topNavOpacity
        }
        
        let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
        let opacity = (maxOffset - normalizedOffset) / (maxOffset - minOffset)
        return max(0.0, min(Double(opacity), 1.0))
    }
    
    private func updateScrollOffset(innerGeometry: GeometryProxy) {
        let newOffset = innerGeometry.frame(in: .global).minY
        //let newBackgroundOpacity = calculateBackgroundOpacity(scrollOffset: newOffset)
        let newNavOpacity = calculateNavOpacity(scrollOffset: newOffset)
        
        if newOffset < scrollOffset {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.topNavOpacity = newNavOpacity
            }
        }
        
        scrollOffset = newOffset
    }
    
    private func populateArrays() {
        /* MARK: Needed to ensure we don't over-populate the array. This function is called in a `.onChange` modifier. */
        self.generatedCategories.removeAll()
        self.userCreatedCategories.removeAll()
        
        if !self.showAllTogether {
            if self.showingGenerated {
                for key in self.toDisplay.keys {
                    if !self.categoryData.userCreatedCategoryNames.contains(key) { self.generatedCategories.append(key) }
                }
            } else {
                for key in self.toDisplay.keys {
                    if self.categoryData.userCreatedCategoryNames.contains(key) { self.userCreatedCategories.append(key) }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { innerGeometry in
                HStack {
                    Text(self.lookedUpCategoriesAndSets.count == 0
                         ? self.showAllTogether
                            ? "Categories(\(self.toDisplay.count))"
                            : self.showingUserCreated
                                ? "User Created(\(self.userCreatedCategories.count))"
                                : "Generated(\(self.generatedCategories.count))"
                         : "Results: \(self.lookedUpCategoriesAndSets.count)")
                    .foregroundStyle(.white)
                    .font(.system(size: 30, weight: .bold))
                    .padding([.leading], 15)
                    .onChange(of: innerGeometry.frame(in: .global)) {
                        checkIfOutOfFrame(innerGeometry: innerGeometry, outerGeometry: geometry)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding([.top], self.settings.displayUserCreatedCategoriesSeparatly ? 10 : 130)
        .padding([.bottom], 10)
        .background(
            GeometryReader { innerGeometry in
                Color.clear
                    .onAppear {
                        updateScrollOffset(innerGeometry: innerGeometry)
                    }
                    .onChange(of: innerGeometry.frame(in: .global).minY) {
                        updateScrollOffset(innerGeometry: innerGeometry)
                    }
            }
                .frame(height: 0)
        )
        .onAppear {
            populateArrays()
        }
        .onChange(of: self.toDisplay) {
            populateArrays()
        }
    }
}

private struct CategoryScrollview: View {
    @EnvironmentObject private var settings: SettingsConfigManager
    @EnvironmentObject private var categoryData: CategoryData
    
    var prop: Properties
    var skipUserCreated: Bool = false
    var onlyShowUserCreated: Bool = false
    
    @Binding public var toDisplay: [String: Array<String>]
    @Binding public var lookedUpCategoriesAndSets: [String: Array<String>]
    @Binding public var show_categories_title: Bool
    @Binding public var topNavOpacity: Double
    @Binding public var scrollOffset: CGFloat
    
    /* MARK: Bindings for when a category has been tapped. */
    @Binding public var launchCategory: Bool
    @Binding public var categoryLaunched: String
    @Binding public var categoryDescription: String?
    @Binding public var categoryTitleColor: Color?
    @Binding public var categoryBackgroundColor: Color?
    @Binding public var categoryBackground: Image
    
    /* MARK: Bindings for editing a category. */
    @Binding public var newCategoryDescription: String
    @Binding public var newCategoryDisplayColor: Color
    @Binding public var newCategoryTextColor: Color
    @Binding public var categoryBeingEditedImage: Image
    @Binding public var categoryBeingEdited: String
    @Binding public var editCategoryDetails: Bool
    
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
    
    /* MARK: The card that displays details of the category. */
    @State private var categoryView: (String) -> AnyView = { key in
        AnyView(Text(key)) /* MARK: Default value. */
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                SearchResult(
                    prop: self.prop,
                    toDisplay: $toDisplay,
                    showingUserCreated: self.onlyShowUserCreated,
                    showingGenerated: self.skipUserCreated,
                    showAllTogether: self.skipUserCreated == false && self.onlyShowUserCreated == false,
                    lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                    show_categories_title: $show_categories_title,
                    topNavOpacity: $topNavOpacity,
                    scrollOffset: $scrollOffset,
                    geometry: geometry
                )
                
                VStack {
                    ForEach(Array(self.lookedUpCategoriesAndSets.isEmpty
                                  ? self.toDisplay.keys
                                  : self.lookedUpCategoriesAndSets.keys), id: \.self) { key in
                        if self.onlyShowUserCreated {
                            if self.categoryData.userCreatedCategoryNames.contains(key) { self.categoryView(key) }
                        } else {
                            if self.skipUserCreated {
                                if !self.categoryData.userCreatedCategoryNames.contains(key) { self.categoryView(key) }
                            } else { self.categoryView(key) }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding([.top], 35)
                .padding([.bottom], 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, self.settings.displayUserCreatedCategoriesSeparatly ? -6 : 0)
            .padding(.bottom, -5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.categoryView = { key in
                AnyView(
                    HStack {
                        Button(action: {
                            self.launchCategory = true
                            self.categoryLaunched = key
                            self.categoryDescription = self.categoryData.categoryDescriptions[key]
                            self.categoryTitleColor = self.categoryData.categoryCustomTextColors[key]
                            self.categoryBackgroundColor = self.categoryData.categoryCustomColors[key]
                            
                            if self.categoryData.categoryImages.keys.contains(key) {
                                self.categoryBackground = Image(uiImage: self.categoryData.categoryImages[key]!)
                            } else {
                                self.categoryBackground = Image("UCTHB")
                            }
                        }) {
                            HStack {
                                HStack {
                                    ZStack {
                                        if self.categoryData.categoryImages.keys.contains(key) && !self.categoryData.userCreatedCategoryNames.contains(key) {
                                            Image(uiImage: self.categoryData.categoryImages[key]!)
                                                .resizable()
                                            //.frame(minWidth: 50, maxWidth: 120)//.frame(width: prop.isLargerScreen ? 80 : 70, height: prop.isLargerScreen ? 80 : 70)
                                                .scaledToFit()
                                                .zIndex(1)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))//.cornerRadius(10)
                                        } else {
                                            if self.categoryData.userCreatedCategoryNames.contains(key) {
                                                Image("UserCreated")
                                                    .resizable()
                                                    .frame(width: 60)//.frame(width: prop.isLargerScreen ? 80 : 70, height: prop.isLargerScreen ? 80 : 70)
                                                    .scaledToFit()
                                                    .zIndex(1)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            } else {
                                                Image("DefaultCategoryImage")
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .zIndex(1)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                        }
                                    }
                                    .frame(alignment: .leading)
                                    .shadow(color: .black, radius: 2.5)
                                    
                                    VStack {
                                        Spacer()
                                        
                                        Text(key)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .truncationMode(.tail)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(
                                                self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                : Color.white
                                            )
                                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 20 : 16))
                                        
                                        Spacer()
                                        
                                        Text("Created \(self.categoryData.categoryCreationDates[key]!.formatted(date: .numeric, time: .omitted))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(Font.custom("Poppins-ExtraLight", size: 12))
                                            .foregroundStyle(
                                                self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                : Color.white
                                            )
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 5)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack {
                                    Menu {
                                        Button(action: {
                                            if self.categoryData.categoryDescriptions.keys.contains(key) {
                                                self.newCategoryDescription = self.categoryData.categoryDescriptions[key]!
                                            } else { self.newCategoryDescription = "" }
                                            
                                            print(key, self.categoryData.categoryCustomColors.keys.contains(key))
                                            
                                            if self.categoryData.categoryCustomColors.keys.contains(key) {
                                                self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[key]!
                                            } else { self.newCategoryDisplayColor = Color.EZNotesLightBlack }
                                            
                                            if self.categoryData.categoryCustomTextColors.keys.contains(key) {
                                                self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[key]!
                                            } else { self.newCategoryTextColor = .white }
                                            
                                            if self.categoryData.categoryImages.keys.contains(key) {
                                                self.categoryBeingEditedImage = Image(uiImage: self.categoryData.categoryImages[key]!)
                                            } else {
                                                if self.categoryData.userCreatedCategoryNames.contains(key) {
                                                    self.categoryBeingEditedImage = Image("UserCreated")
                                                } else {
                                                    self.categoryBeingEditedImage = Image("UCTHB")
                                                }
                                            }
                                            
                                            self.categoryBeingEdited = key
                                            self.editCategoryDetails = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .frame(width: 14.5, height: 14.5)
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .padding([.trailing], 10)
                                            
                                            Text("Edit").foregroundStyle(.white)
                                        }
                                        
                                        Button(action: {
                                            self.categoryToDelete = key
                                            self.categoryAlert = true
                                            self.alertType = .DeleteCategoryAlert
                                        }) {
                                            Image(systemName: "trash")
                                                .resizable()
                                                .frame(width: 14.5, height: 14.5)
                                                .foregroundStyle(.red)
                                                .padding([.trailing, .top, .bottom], 10)
                                            Text("Delete").foregroundStyle(.white)
                                        }
                                        
                                        Button(action: { print("Share") }) {
                                            Image(systemName: "square.and.arrow.up")
                                                .resizable()
                                                .frame(width: 14.5, height: 19.5)
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .padding([.trailing, .bottom], 10)
                                                .padding([.top], 5)
                                            Text("Share").foregroundStyle(.white)
                                        }
                                    } label: {
                                        /*Image(systemName: "ellipsis")
                                         .resizable()
                                         .frame(width: 20, height: 80)
                                         .rotationEffect(90)*/
                                        Label("", systemImage: "ellipsis")
                                            .font(.title)
                                            .foregroundStyle(
                                                self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                : Color.white
                                            )
                                    }
                                }
                                .frame(maxWidth: 80, alignment: .trailing)
                                
                                Spacer()
                            }
                            .frame(maxWidth: prop.size.width - 20, maxHeight: 100)
                            .padding(12.5)
                            .alert("Are you sure?", isPresented: $categoryAlert) {
                                Button(action: {
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
                                        
                                        /* MARK: Ensure the cache is up to date. */
                                        writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                        writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                        writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                        writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                        writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                    }
                                    
                                    writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                    writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                    
                                    resetAlert()
                                    
                                    /* TODO: Add support for actually storing category information in the database. That will, thereby, prompt us to need to send a request to the server to delete the given category from the database. */
                                }) {
                                    Text("Yes")
                                }
                                
                                Button(action: { resetAlert() }) { Text("No") }
                            } message: {
                                Text(self.alertType == .DeleteCategoryAlert
                                     ? "Once deleted, the category **\"\(self.categoryToDelete)\"** will be removed from cloud or local storage and cannot be recovered."
                                     : "")
                            }
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                        .frame(maxWidth: prop.size.width - 20)
                    //.background(RoundedRectangle(cornerRadius: 15).fill(Color.EZNotesBlack.opacity(0.65)).shadow(color: Color.EZNotesBlack, radius: 4))
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(self.categoryData.categoryCustomColors.keys.contains(key)
                                      ? self.categoryData.categoryCustomColors[key]!
                                      : Color.EZNotesLightBlack)//(Color.EZNotesBlack)
                        )
                        .padding([.bottom], 5)
                )
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var categoryData: CategoryData
    @EnvironmentObject private var settings: SettingsConfigManager
    //@EnvironmentObject private var messageModel: MessagesModel
    
    /* MARK: Needed for `CategoryInternalsView.swift`, as there is the ability to create a set via images. */
    @ObservedObject public var model: FrameHandler
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @State private var error: HomeError = .None
    
    //@Binding public var messages: Array<MessageDetails>
    @Binding public var section: String
    
    /* MARK: (Edit popup) changing category background image */
    @State private var photoPicker: PhotosPickerItem?
    @State private var showSaveAlert: Bool = false
    
    /* MARK: (Edit popup) variables for triggering edit popup and storing the name of the category being edited. */
    @State private var editCategoryDetails: Bool = false
    @State private var categoryBeingEdited: String = ""
    @State private var categoryBeingEditedImage: Image = Image("UCTHB")
    
    /* MARK: (Edit popup) what section of the edit popup are we in? Can be "edit" or "preview". */
    @State private var editSection: String = "edit"
    
    /* MARK: (Edit popup) variables for updating categories name and/or adding a description. */
    @State private var newCategoryName: String = ""
    @State private var newCategoryDescription: String = ""
    @FocusState private var newCategoryDescriptionFocus: Bool
    
    /* MARK: (Edit Popup) changing category "cards" text/display colors. */
    @State private var toggleCategoryBackgroundColorPicker: Bool = false
    @State private var toggleCategoryTextColorPicker: Bool = false
    @State private var newCategoryDisplayColor: Color = Color.EZNotesLightBlack
    @State private var newCategoryTextColor: Color = Color.white
    
    @State private var home_section: String = "main"
    @State private var show_categories_title: Bool = false
    @State private var topNavOpacity: Double = 0.0
    
    @State private var scrollOffset: CGFloat = 0 // Store the scroll offset
    
    @State private var launchCategory: Bool = false
    @State private var categoryDescription: String? = nil
    @State private var categoryTitleColor: Color? = nil
    @State private var categoryBackgroundColor: Color? = nil
    @State private var categoryLaunched: String = ""
    @State private var categoryBackground: Image = Image(systemName: "arrow.left") /* TODO: Figure out how to initialize a UIImage variable. */
    
    @State private var categorySearch: String = ""
    @State private var searchDone: Bool = false
    @State private var lookedUpCategoriesAndSets: [String: Array<String>] = [:]
    
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    //@ObservedObject public var messageModel: MessagesModel//@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    
    /* TODO: Eventually the app will enable users to set the outline of there categories as they please. Get this implemented. */
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /* MARK: WIP (Work In Progress). Animations will get added overtime, they are a bit confusing in swift. */
    private func updateScrollOffset(innerGeometry: GeometryProxy) {
        let newOffset = innerGeometry.frame(in: .global).minY
        //let newBackgroundOpacity = calculateBackgroundOpacity(scrollOffset: newOffset)
        let newNavOpacity = calculateNavOpacity(scrollOffset: newOffset)
        
        if newOffset < scrollOffset {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.topNavOpacity = newNavOpacity
            }
        }
        
        scrollOffset = newOffset
    }

        // Calculate opacity for the background based on scroll offset
    private func calculateBackgroundOpacity(scrollOffset: CGFloat) -> Double {
        let navigationBarHeight: CGFloat = 50
        let maxOffset: CGFloat = -navigationBarHeight
        let minOffset: CGFloat = -300
        
        let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
        let opacity = (maxOffset - normalizedOffset) / (maxOffset - minOffset)
        return max(0.0, min(Double(opacity), 1.0))
    }
    
    private func calculateNavOpacity(scrollOffset: CGFloat) -> Double {
        let navigationBarHeight: CGFloat = 200
        let maxOffset: CGFloat = -navigationBarHeight
        let minOffset: CGFloat = 0 // When content is at the top
        
        guard scrollOffset < maxOffset else {
            return self.topNavOpacity
        }
        
        let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
        let opacity = (maxOffset - normalizedOffset) / (maxOffset - minOffset)
        return max(0.0, min(Double(opacity), 1.0))
    }
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        let plusAmount: CGFloat = self.settings.displayUserCreatedCategoriesSeparatly ? -20 : 130
        
        if textFrame.maxY < 50 {
            self.show_categories_title = true
            return
        }
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY + plusAmount || textFrame.minY > scrollViewFrame.maxY {
            self.show_categories_title = true
            self.topNavOpacity += 0.2
        } else {
            self.show_categories_title = false
            self.topNavOpacity = 0
        }
    }
    
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
    
    @State private var testPopup: Bool = false
    
    @State private var showAccount: Bool = false
    
    /* MARK: Variables for the popup menu that shows after "+" button is tapped. */
    @State private var createNewCategory: Bool = false
    @State private var createNewCategoryName: String = ""
    @FocusState private var createNewCategoryNameFocus: Bool
    @State private var createNewCategoryDescription: String = ""
    @FocusState private var createNewCategoryDescriptionFocus: Bool
    @State private var createNewCategoryDisplayColor: Color = Color.EZNotesLightBlack
    @State private var createNewCategoryTextColor: Color = Color.white
    
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
    
    /* MARK: Not directly used in this view, rather subviews that branch off from this view. */
    /* MARK: String will be the category name, value will be the `TopBanner` status of the category. Each cateegory can have a different `TopBanner` status. */
    @State private var topBanner: [String: TopBanner] = [:]
    
    /* MARK: States for if `settings.displayUserCreatedCategoriesSeparatly` is true. */
    @State private var allUserCreatedCategories: [String: Array<String>] = [:]
    @State private var selectedView: String = "generated" /* MARK: Two values: "Generated" - shows all categories generated by the AI; "User Created" - shows all categories created by the user. Only used if `settings.displayUserCreatedCategoriesSeparatly` is true. */
    
    var body: some View {
        if !self.showAccount {
            /* MARK: Needed just in case the user goes into their account in this view and toggles "Just Notes" on. */
            if !self.settings.justNotes {
                if !self.launchCategory {
                    ZStack {
                        if self.createNewCategory {
                            VStack {
                                Spacer()
                                
                                VStack {
                                    HStack {
                                        ZStack {
                                            Button(action: {
                                                /* MARK: Ensure the error states are set to .None */
                                                self.error = .None
                                                
                                                /* MARK: Reset all variables adherent to the creation of a new category. */
                                                self.createNewCategoryName.removeAll()
                                                self.createNewCategoryDescription.removeAll()
                                                self.createNewCategoryTextColor = .white
                                                self.createNewCategoryDisplayColor = Color.EZNotesLightBlack
                                                
                                                /* MARK: Hide the popup. */
                                                self.createNewCategory = false
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
                                            
                                            Text("Create Category")
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
                                    
                                    if self.error != .None {
                                        Text(self.error == .CreateNewCategoryNameEmpty
                                             ? "The category name is empty. Ensure you apply a name to the new category."
                                             : "The category **\(self.createNewCategoryName)** already exists.")
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
                                    
                                    //ScrollView(.vertical, showsIndicators: false) {
                                    Text("Category Name")
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
                                    
                                    TextField("New Category Name...", text: $createNewCategoryName)
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
                                                    isError: self.createNewCategoryName == "" && self.error == .CreateNewCategoryNameEmpty
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
                                        .focused($createNewCategoryNameFocus)
                                        .onChange(of: self.createNewCategoryNameFocus) {
                                            if !self.createNewCategoryNameFocus {
                                                if self.error != .None && !self.createNewCategoryName.isEmpty { self.error = .None }
                                            }
                                        }
                                    
                                    HStack {
                                        Text("Category Description")
                                            .frame(
                                                maxWidth: .infinity,
                                                alignment: .leading
                                            )
                                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 22 : 18))
                                            .foregroundStyle(.white)
                                        
                                        Button(action: {
                                            /* MARK: We only want the `Done` button to work if the focus is on the below `TextField`. */
                                            if self.createNewCategoryDescriptionFocus {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                        }) {
                                            Text("Done")
                                                .foregroundStyle(Color.EZNotesBlue)
                                                .font(.system(size: 16))
                                                .fontWeight(.semibold)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    TextField(
                                        "Category description...",
                                        text: $createNewCategoryDescription,
                                        axis: .vertical
                                    )
                                    .frame(minHeight: textHeight(for: self.createNewCategoryDescription, width: UIScreen.main.bounds.width), alignment: .leading)
                                    .padding([.leading], 15)
                                    .padding(7)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(7.5)
                                    .lineLimit(4...12)
                                    .focused($createNewCategoryDescriptionFocus)
                                    .border(width: 1, edges: [.bottom], color: self.error == .CreateNewCategoryDescriptionEmpty ? Color.EZNotesRed : Color.clear)
                                    .cornerRadius(15, corners: self.error == .CreateNewCategoryDescriptionEmpty ? [.bottomLeft, .bottomRight] : .init())
                                    .onChange(of: self.createNewCategoryDescription) {
                                        if self.createNewCategoryDescription.count > 150 {
                                            self.createNewCategoryDescription = String(self.createNewCategoryDescription.prefix(150))
                                        }
                                    }
                                    
                                    Text("\(self.createNewCategoryDescription.count) out of 150 characters")
                                        .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                                        .padding([.leading], 5)
                                        .foregroundStyle(
                                            self.createNewCategoryDescription.count < 150
                                            ? self.createNewCategoryDescription.count > 140 && self.createNewCategoryDescription.count < 150
                                            ? .yellow
                                            : Color.secondary
                                            : .red
                                        )
                                        .font(.system(size: 10, design: .rounded))
                                        .fontWeight(.medium)
                                        .padding(.bottom, 15)
                                    
                                    Button(action: {
                                        if self.createNewCategoryName.isEmpty { self.error = .CreateNewCategoryNameEmpty; return }
                                        
                                        if self.categoryData.categoriesAndSets.keys.contains(self.createNewCategoryName) {
                                            self.error = .CategoryExists
                                            return
                                        }
                                        
                                        self.error = .None
                                        
                                        if !self.createNewCategoryDescription.isEmpty {
                                            self.categoryData.categoryDescriptions[self.createNewCategoryName] = self.createNewCategoryDescription
                                            writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                        }
                                        
                                        if self.createNewCategoryDisplayColor != Color.EZNotesLightBlack {
                                            self.categoryData.categoryCustomColors[self.createNewCategoryName] = self.createNewCategoryDisplayColor
                                            writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                        }
                                        
                                        if self.createNewCategoryTextColor != Color.white {
                                            self.categoryData.categoryCustomTextColors[self.createNewCategoryName] = self.createNewCategoryTextColor
                                            writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                        }
                                        
                                        self.categoryData.categoriesAndSets[self.createNewCategoryName] = []
                                        writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                        
                                        self.categoryData.categoryCreationDates[self.createNewCategoryName] = Date.now
                                        writeCategoryCreationDates(categoryCreationDates: self.categoryData.categoryCreationDates)
                                        
                                        self.categoryData.setAndNotes[self.createNewCategoryName] = []
                                        writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                        
                                        if self.settings.trackUserCreatedCategories {
                                            self.categoryData.userCreatedCategoryNames.append(self.createNewCategoryName)
                                            writeUserCreatedCategoryNames(userCreatedCategoryNames: self.categoryData.userCreatedCategoryNames)
                                        }
                                        
                                        self.createNewCategoryName.removeAll()
                                        self.createNewCategoryDescription.removeAll()
                                        self.createNewCategoryTextColor = .white
                                        self.createNewCategoryDisplayColor = Color.EZNotesLightBlack
                                        
                                        self.createNewCategory = false
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
                                }
                                .frame(maxWidth: prop.size.width - 70)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesBlack)
                                        .shadow(color: Color.black, radius: 4.5)
                                )
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
                            .background(Color.EZNotesLightBlack.opacity(0.7))
                            .onTapGesture {
                                self.createNewCategory = false
                            }
                            .zIndex(1)
                        }
                        
                        VStack {
                            TopNavHome(
                                accountInfo: accountInfo,
                                categoryData: self.categoryData,
                                showAccountPopup: $showAccount,
                                prop: prop,
                                backgroundColor: Color.EZNotesLightBlack,
                                //categoriesAndSets: categoriesAndSets,
                                changeNavbarColor: $show_categories_title,
                                navbarOpacity: $topNavOpacity,
                                categorySearch: $categorySearch,
                                searchDone: $searchDone,
                                //messages: $messages,
                                lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                                userHasSignedIn: $userHasSignedIn
                                //tempChatHistory: $tempChatHistory
                            )
                            ZStack {
                                if self.categoryData.categoriesAndSets.count > 0 {
                                    if self.searchDone && self.lookedUpCategoriesAndSets.count == 0 {
                                        VStack {
                                            Text("No Results")
                                                .foregroundStyle(.secondary)
                                                .fontWeight(.bold)
                                                .font(.system(size: 25, design: .rounded))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                        .padding([.top], 50)
                                    } else {
                                        ZStack {
                                            VStack {
                                                if self.settings.displayUserCreatedCategoriesSeparatly {
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
                                                    .padding([.top], 130)
                                                    
                                                    EZNotesColoredDivider()
                                                            
                                                    VStack {
                                                        switch(self.selectedView) {
                                                        case "generated":
                                                            CategoryScrollview(
                                                                prop: self.prop,
                                                                skipUserCreated: true,
                                                                toDisplay: $categoryData.categoriesAndSets,
                                                                lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                                                                show_categories_title: $show_categories_title,
                                                                topNavOpacity: $topNavOpacity,
                                                                scrollOffset: $scrollOffset,
                                                                launchCategory: $launchCategory,
                                                                categoryLaunched: $categoryLaunched,
                                                                categoryDescription: $categoryDescription,
                                                                categoryTitleColor: $categoryTitleColor,
                                                                categoryBackgroundColor: $categoryBackgroundColor,
                                                                categoryBackground: $categoryBackground,
                                                                newCategoryDescription: $newCategoryDescription,
                                                                newCategoryDisplayColor: $newCategoryDisplayColor,
                                                                newCategoryTextColor: $newCategoryTextColor,
                                                                categoryBeingEditedImage: $categoryBeingEditedImage,
                                                                categoryBeingEdited: $categoryBeingEdited,
                                                                editCategoryDetails: $editCategoryDetails
                                                            )
                                                        case "user_created":
                                                            CategoryScrollview(
                                                                prop: self.prop,
                                                                onlyShowUserCreated: true,
                                                                toDisplay: $categoryData.categoriesAndSets,
                                                                lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                                                                show_categories_title: $show_categories_title,
                                                                topNavOpacity: $topNavOpacity,
                                                                scrollOffset: $scrollOffset,
                                                                launchCategory: $launchCategory,
                                                                categoryLaunched: $categoryLaunched,
                                                                categoryDescription: $categoryDescription,
                                                                categoryTitleColor: $categoryTitleColor,
                                                                categoryBackgroundColor: $categoryBackgroundColor,
                                                                categoryBackground: $categoryBackground,
                                                                newCategoryDescription: $newCategoryDescription,
                                                                newCategoryDisplayColor: $newCategoryDisplayColor,
                                                                newCategoryTextColor: $newCategoryTextColor,
                                                                categoryBeingEditedImage: $categoryBeingEditedImage,
                                                                categoryBeingEdited: $categoryBeingEdited,
                                                                editCategoryDetails: $editCategoryDetails
                                                            )
                                                        default: VStack { }.onAppear { self.selectedView = "generated" }
                                                        }
                                                    }
                                                } else {
                                                    CategoryScrollview(
                                                        prop: self.prop,
                                                        toDisplay: $categoryData.categoriesAndSets,
                                                        lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                                                        show_categories_title: $show_categories_title,
                                                        topNavOpacity: $topNavOpacity,
                                                        scrollOffset: $scrollOffset,
                                                        launchCategory: $launchCategory,
                                                        categoryLaunched: $categoryLaunched,
                                                        categoryDescription: $categoryDescription,
                                                        categoryTitleColor: $categoryTitleColor,
                                                        categoryBackgroundColor: $categoryBackgroundColor,
                                                        categoryBackground: $categoryBackground,
                                                        newCategoryDescription: $newCategoryDescription,
                                                        newCategoryDisplayColor: $newCategoryDisplayColor,
                                                        newCategoryTextColor: $newCategoryTextColor,
                                                        categoryBeingEditedImage: $categoryBeingEditedImage,
                                                        categoryBeingEdited: $categoryBeingEdited,
                                                        editCategoryDetails: $editCategoryDetails
                                                    )
                                                }
                                            }
                                            
                                            PlusButton(prop: self.prop, createNewCategory: $createNewCategory, testPopup: $testPopup)
                                                /*.padding(.bottom, prop.isLargerScreen ? 80 : 60) /* MARK: Ensure it is not placed on top of the bottom navbar. */
                                                .zIndex(1)*/
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.top, -130)
                                        .popover(isPresented: $editCategoryDetails) {
                                            EditCategory(
                                                prop: self.prop,
                                                categoryBeingEditedImage: self.categoryBeingEditedImage,
                                                categoryBeingEdited: $categoryBeingEdited,
                                                categoryData: self.categoryData,
                                                newCategoryDisplayColor: $newCategoryDisplayColor,
                                                newCategoryTextColor: $newCategoryTextColor
                                            )
                                        }
                                        .onTapGesture {
                                            if self.testPopup { self.testPopup = false }
                                        }
                                    }
                                } else {
                                    ZStack {
                                        Color.clear.edgesIgnoringSafeArea(.all)
                                        
                                        Text("No Categories")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 20 : 18))
                                            .minimumScaleFactor(0.5)
                                        
                                        PlusButton(prop: self.prop, createNewCategory: $createNewCategory, testPopup: $testPopup)
                                            /*.padding(.bottom, prop.isLargerScreen ? 80 : 60) /* MARK: Ensure it is not placed on top of the bottom navbar. */
                                            .zIndex(1)*/
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if self.testPopup { self.testPopup = false }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            Spacer()
                            
                            ButtomNavbar(
                                section: $section,
                                backgroundColor: Color.EZNotesLightBlack,
                                prop: prop
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .zIndex(self.createNewCategory ? 0 : 1)
                        
                        VStack {
                            Spacer()
                            
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                            .background(
                                Image("DefaultThemeBg2")
                                    .resizable()
                                    .scaledToFill()
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        /*VStack {
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                            /*.background(
                                Image("DefaultThemeBg3")
                                    .resizable()
                                    .scaledToFill()
                            )*/
                            .background(
                                Image("DefaultThemeBg5")
                                    .resizable()
                                    .scaledToFill()
                            )
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)*/
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .edgesIgnoringSafeArea(self.launchCategory && !prop.isLargerScreen ? [.top, .bottom] : [.bottom])
                    .background(.black)
                    .onAppear {
                        if self.settings.displayUserCreatedCategoriesSeparatly && !self.categoryData.userCreatedCategoryNames.isEmpty {
                            for category in self.categoryData.categoriesAndSets.keys {
                                if self.categoryData.userCreatedCategoryNames.contains(category) {
                                    self.allUserCreatedCategories[category] = self.categoryData.categoriesAndSets[category]!
                                }
                            }
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width < 0 {
                                self.section = "upload"
                            }
                        })
                    )
                    .zIndex(1)
                } else {
                    /* MARK: Show Category Information */
                    CategoryInternalsView(
                        model: self.model,
                        images_to_upload: self.images_to_upload,
                        prop: prop,
                        categoryName: categoryLaunched,
                        creationDate: "\(self.categoryData.categoryCreationDates[self.categoryLaunched]!.formatted(date: .numeric, time: .omitted))",
                        categoryTitleColor: self.categoryTitleColor,
                        categoryBackgroundColor: self.categoryBackgroundColor,
                        categoryBackground: categoryBackground,
                        //categoryData: self.categoryData,
                        launchCategory: $launchCategory,
                        //tempChatHistory: $tempChatHistory,
                        //messages: $messages,
                        accountInfo: self.accountInfo,
                        topBanner: $topBanner
                    )
                }
            } else { VStack { }.onAppear { self.section = "upload" } }
        } else {
            Account(
                prop: self.prop,
                showAccount: $showAccount,
                userHasSignedIn: $userHasSignedIn
            )
        }
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
