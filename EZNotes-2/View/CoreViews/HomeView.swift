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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
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

struct HomeView: View {
    @Binding public var messages: Array<MessageDetails>
    @Binding public var section: String
    @ObservedObject public var categoryData: CategoryData
    /*@Binding public var categoriesAndSets: [String: Array<String>]
    @Binding public var setAndNotes: [String: Array<[String: String]>]
    @Binding public var categoryImages: [String: UIImage]
    @Binding var categoryCreationDates: [String: Date]
    
    /* MARK: The below bindings are all custom to the category cards. The values below will be set via the edit popup. */
    @Binding public var categoryDescriptions: [String: String]
    @Binding public var categoryCustomColors: [String: Color]
    @Binding public var categoryCustomTextColors: [String: Color]*/
    
    /* MARK: (Edit popup) changing category background image */
    @State private var photoPicker: PhotosPickerItem?
    @State private var showSaveAlert: Bool = false
    
    /* MARK: (Edit popup) variables for triggering edit popup and storing the name of the category being edited. */
    @State private var editCategoryDetails: Bool = false
    @State private var categoryBeingEdited: String = ""
    @State private var categoryBeingEditedImage: UIImage! = UIImage(systemName: "plus")!
    
    /* MARK: (Edit popup) what section of the edit popup are we in? Can be "edit" or "preview". */
    @State private var editSection: String = "edit"
    
    /* MARK: (Edit popup) variables for updating categories name and/or adding a description. */
    @State private var newCategoryName: String = ""
    @State private var newCategoryDescription: String = ""
    @FocusState private var newCategoryDescriptionFocus: Bool
    
    /* MARK: (Edit Popup) changing category "cards" text/display colors. */
    @State private var toggleCategoryBackgroundColorPicker: Bool = false
    @State private var toggleCategoryTextColorPicker: Bool = false
    @State private var newCategoryDisplayColor: Color = Color.EZNotesOrange
    @State private var newCategoryTextColor: Color = Color.white
    
    @State private var home_section: String = "main"
    @State private var show_categories_title: Bool = false
    @State private var topNavOpacity: Double = 0.0
    
    @State private var scrollOffset: CGFloat = 0 // Store the scroll offset
    //@State private var currentBackgroundOpacity: Double = 1.0 // Background opacity
    //@State private var currentNavOpacity: Double = 1.0
    
    @State private var launchCategory: Bool = false
    @State private var categoryDescription: String? = nil
    @State private var categoryTitleColor: Color? = nil
    @State private var categoryBackgroundColor: Color? = nil
    @State private var categoryLaunched: String = ""
    @State private var categoryBackground: UIImage = UIImage(systemName: "arrow.left")! /* TODO: Figure out how to initialize a UIImage variable. */
    
    @State private var categorySearch: String = ""
    @State private var searchDone: Bool = false
    @State private var lookedUpCategoriesAndSets: [String: Array<String>] = [:]
    
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    @Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    
    /* TODO: Eventually the app will enable users to set the outline of there categories as they please. Get this implemented. */
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /*private func opacityForBackground(scrollOffset: CGFloat) -> Double {
        /*let navigationBarHeight: CGFloat = 100 // Height of the navigation bar
         let maxOffset: CGFloat = -navigationBarHeight // Max offset (when content hits the navbar)
         let minOffset: CGFloat = 0 // Min offset (when content is at the top of the screen)
         
         // Calculate opacity based on scroll offset
         //let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
         //return Double((maxOffset - normalizedOffset) / (maxOffset - minOffset))
         let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
         
         return Double((maxOffset - normalizedOffset) / (maxOffset - minOffset))*/
        let navigationBarHeight: CGFloat = 0 // Height of the navigation bar
        let maxOffset: CGFloat = -navigationBarHeight // Max offset (when content hits the navbar)
        let minOffset: CGFloat = -300 // Extended range for more gradual change
        
        print("SO: \(scrollOffset)\nMIN_OFFSET: \(minOffset)\nMAX_OFFSET: \(maxOffset)")
        
        // Calculate opacity based on scroll offset
        let normalizedOffset = min(max(scrollOffset, minOffset), maxOffset)
        let opacity = (maxOffset - normalizedOffset) / (maxOffset - minOffset)
        
        // Clamp opacity to 0.0 - 1.0 range
        return max(0.0, min(Double(opacity), 1.0))
    }*/
    
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
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY + 130 || textFrame.minY > scrollViewFrame.maxY {
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
    
    var body: some View {
        if !self.launchCategory {
            VStack {
                TopNavHome(
                    accountInfo: accountInfo,
                    categoryData: self.categoryData,
                    prop: prop,
                    backgroundColor: Color.EZNotesLightBlack,
                    //categoriesAndSets: categoriesAndSets,
                    changeNavbarColor: $show_categories_title,
                    navbarOpacity: $topNavOpacity,
                    categorySearch: $categorySearch,
                    searchDone: $searchDone,
                    messages: $messages,
                    lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets,
                    userHasSignedIn: $userHasSignedIn,
                    tempChatHistory: $tempChatHistory
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
                            VStack {
                                GeometryReader { geometry in
                                    ScrollView(showsIndicators: false) {
                                        VStack {
                                            GeometryReader { innerGeometry in
                                                HStack {
                                                    Text(self.lookedUpCategoriesAndSets.count == 0
                                                         ? "Categories(\(self.categoryData.categoriesAndSets.count))"
                                                         : "Results: \(self.lookedUpCategoriesAndSets.count)")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 30))
                                                    .fontWeight(.semibold)
                                                    .padding([.leading], 15)
                                                    .onChange(of: innerGeometry.frame(in: .global)) {
                                                        checkIfOutOfFrame(innerGeometry: innerGeometry, outerGeometry: geometry)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 50)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 50)
                                        .padding([.top], 130)
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
                                        
                                        //LazyVGrid(columns: columns, spacing: 10) {
                                        VStack {
                                            ForEach(Array(self.lookedUpCategoriesAndSets.count == 0
                                                          ? self.categoryData.categoriesAndSets.keys
                                                          : self.lookedUpCategoriesAndSets.keys), id: \.self) { key in
                                                HStack {
                                                    Button(action: {
                                                        self.launchCategory = true
                                                        self.categoryLaunched = key
                                                        self.categoryDescription = self.categoryData.categoryDescriptions[key]
                                                        self.categoryTitleColor = self.categoryData.categoryCustomTextColors[key]
                                                        self.categoryBackgroundColor = self.categoryData.categoryCustomColors[key]
                                                        self.categoryBackground = self.categoryData.categoryImages[key]!
                                                    }) {
                                                        HStack {
                                                            HStack {
                                                                ZStack {
                                                                    Image(uiImage: self.categoryData.categoryImages[key]!)
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .zIndex(1)
                                                                        .cornerRadius(10)
                                                                }
                                                                .frame(alignment: .leading)
                                                                .shadow(color: .black, radius: 2.5)
                                                                
                                                                VStack {
                                                                    Spacer()
                                                                    
                                                                    Text(key)
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .truncationMode(.tail)
                                                                        .multilineTextAlignment(.leading)
                                                                        .foregroundStyle(.white)
                                                                        .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 20 : 16))
                                                                    
                                                                    Spacer()
                                                                    
                                                                    Text("Created \(self.categoryData.categoryCreationDates[key]!.formatted(date: .numeric, time: .omitted))")
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .font(Font.custom("Poppins-ExtraLight", size: 12))
                                                                        .foregroundStyle(.white)
                                                                    
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
                                                                        
                                                                        if self.categoryData.categoryCustomColors.keys.contains(key) {
                                                                            self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[key]!
                                                                        } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                                                                        
                                                                        if self.categoryData.categoryCustomTextColors.keys.contains(key) {
                                                                            self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[key]!
                                                                        } else { self.newCategoryTextColor = .white }
                                                                        
                                                                        self.categoryBeingEditedImage = self.categoryData.categoryImages[key]!
                                                                        self.categoryBeingEdited = key
                                                                        self.categoryBeingEditedImage = self.categoryData.categoryImages[key]!
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
                                                                }
                                                            }
                                                            .frame(maxWidth: 80, alignment: .trailing)
                                                            
                                                            Spacer()
                                                        }
                                                        .frame(maxWidth: prop.size.width - 20, maxHeight: 100)
                                                        .padding(12.5)
                                                        /*HStack {
                                                            VStack {
                                                                HStack {
                                                                    /* MARK: When the image is clicked, the app will open the photo gallery for the user to select a new photo for the category.
                                                                     * MARK: By default, the categories background image is the first image uploaded in which curated a set of notes within the category.
                                                                     * */
                                                                    Image(uiImage: self.categoryData.categoryImages[key]!)
                                                                        .resizable()
                                                                        .frame(width: 150.5, height: 190.5)
                                                                        .scaledToFit()
                                                                        .zIndex(1)
                                                                        .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                                                    
                                                                    VStack {
                                                                        VStack {
                                                                            HStack {
                                                                                Text(key)
                                                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                                                    .foregroundStyle(
                                                                                        self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                                                            ? self.categoryData.categoryCustomTextColors[key]!
                                                                                            : .white
                                                                                    )
                                                                                    .font(.system(size: 18.5, design: .rounded))
                                                                                    .fontWeight(.semibold)
                                                                                    .multilineTextAlignment(.center)
                                                                                
                                                                                Divider()
                                                                                    .frame(height: 25)
                                                                                    .overlay(.black)
                                                                                
                                                                                Text("Sets: \(self.categoryData.categoriesAndSets[key]!.count)")
                                                                                    .frame(maxWidth: 80, alignment: .trailing)
                                                                                    .foregroundStyle(
                                                                                        self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                                                            ? self.categoryData.categoryCustomTextColors[key]!
                                                                                            : .white
                                                                                    )
                                                                                    .font(.system(size: 18.5, design: .rounded))
                                                                                    .fontWeight(.medium)
                                                                                    .multilineTextAlignment(.center)
                                                                            }
                                                                            .frame(maxWidth: (prop.size.width - 20) - 180, maxHeight: .infinity, alignment: .center)
                                                                            .border(width: 0.5, edges: [.bottom], color: .white)
                                                                        }
                                                                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .top)
                                                                        .background(
                                                                            self.categoryData.categoryCustomColors.keys.contains(key)
                                                                                ? AnyView(self.categoryData.categoryCustomColors[key].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                            : AnyView(Color.EZNotesOrange.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                        )
                                                                        .cornerRadius(15, corners: [.topRight])
                                                                        .padding([.leading], -20)
                                                                        
                                                                        VStack {
                                                                            VStack {
                                                                                VStack {
                                                                                    if self.categoryData.categoryDescriptions.count > 0 && self.categoryData.categoryDescriptions.keys.contains(key) {
                                                                                        //ZStack {
                                                                                        Text(self.categoryData.categoryDescriptions[key]!)
                                                                                            .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 100, alignment: .leading)
                                                                                            .foregroundStyle(
                                                                                                self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                                                                : .white
                                                                                            )
                                                                                            .padding([.leading], 20)
                                                                                            .minimumScaleFactor(0.2)
                                                                                            .truncationMode(.tail)
                                                                                            .fontWeight(.light)
                                                                                            .multilineTextAlignment(.leading)
                                                                                    } else {
                                                                                        Text("No Description")
                                                                                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                                                                                            .foregroundStyle(
                                                                                                self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                                                                    : .white
                                                                                            )
                                                                                            .padding([.leading], 20)
                                                                                            .font(.system(size: 16))
                                                                                            .fontWeight(.medium)
                                                                                            .padding()
                                                                                            .multilineTextAlignment(.leading)
                                                                                    }
                                                                                    
                                                                                    Text("Created \(self.categoryData.categoryCreationDates[key]!.formatted(date: .numeric, time: .omitted))")
                                                                                        .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 20, alignment: .leading)
                                                                                        .padding([.bottom], 5)
                                                                                        .padding([.leading], 20)
                                                                                        .foregroundStyle(
                                                                                            self.categoryData.categoryCustomTextColors.keys.contains(key)
                                                                                                ? self.categoryData.categoryCustomTextColors[key]!
                                                                                                : .white
                                                                                        )
                                                                                        .fontWeight(.medium)
                                                                                        .font(.system(size: 10))
                                                                                        .multilineTextAlignment(.leading)
                                                                                }
                                                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                                                .padding([.leading], 30)
                                                                                
                                                                                HStack {
                                                                                    Button(action: {
                                                                                        if self.categoryData.categoryDescriptions.keys.contains(key) {
                                                                                            self.newCategoryDescription = self.categoryData.categoryDescriptions[key]!
                                                                                        } else { self.newCategoryDescription = "" }
                                                                                        
                                                                                        if self.categoryData.categoryCustomColors.keys.contains(key) {
                                                                                            self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[key]!
                                                                                        } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                                                                                        
                                                                                        if self.categoryData.categoryCustomTextColors.keys.contains(key) {
                                                                                            self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[key]!
                                                                                        } else { self.newCategoryTextColor = .white }
                                                                                        
                                                                                        self.categoryBeingEditedImage = self.categoryData.categoryImages[key]!
                                                                                        self.categoryBeingEdited = key
                                                                                        self.categoryBeingEditedImage = self.categoryData.categoryImages[key]!
                                                                                        self.editCategoryDetails = true
                                                                                    }) {
                                                                                        Image(systemName: "pencil")
                                                                                            .resizable()
                                                                                            .frame(width: 14.5, height: 14.5)
                                                                                            .foregroundStyle(Color.EZNotesBlue)
                                                                                            .padding([.trailing], 10)
                                                                                        
                                                                                        Text("Edit")
                                                                                            .foregroundStyle(.white)
                                                                                            .font(.system(size: 14))
                                                                                            .fontWeight(.medium)
                                                                                            .padding([.leading], -10)
                                                                                    }
                                                                                    .padding([.leading], 10)
                                                                                    .padding([.trailing], 5)
                                                                                    
                                                                                    Button(action: {
                                                                                        print(key)
                                                                                        
                                                                                        self.categoryToDelete = key
                                                                                        self.categoryAlert = true
                                                                                        self.alertType = .DeleteCategoryAlert
                                                                                    }) {
                                                                                        Image(systemName: "trash")
                                                                                            .resizable()
                                                                                            .frame(width: 14.5, height: 14.5)
                                                                                            .foregroundStyle(.red)
                                                                                            .padding([.trailing, .top, .bottom], 10)
                                                                                        
                                                                                        Text("Delete")
                                                                                            .foregroundStyle(.white)
                                                                                            .font(.system(size: 13))
                                                                                            .fontWeight(.medium)
                                                                                            .padding([.leading], -10)
                                                                                    }
                                                                                    .padding([.trailing], 5)
                                                                                    
                                                                                    Button(action: { print("Share") }) {
                                                                                        Image(systemName: "square.and.arrow.up")
                                                                                            .resizable()
                                                                                            .frame(width: 14.5, height: 19.5)
                                                                                            .foregroundStyle(Color.EZNotesBlue)
                                                                                            .padding([.trailing, .bottom], 10)
                                                                                            .padding([.top], 5)
                                                                                        
                                                                                        Text("Share")
                                                                                            .foregroundStyle(.white)
                                                                                            .font(.system(size: 13))
                                                                                            .fontWeight(.medium)
                                                                                            .padding([.leading], -10)
                                                                                    }
                                                                                    .padding([.trailing], 5)
                                                                                }
                                                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                                                .background(
                                                                                    Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).shadow(color: .black, radius: 2.5, x: 0, y: -1)
                                                                                )
                                                                                .padding([.leading], 20)
                                                                            }
                                                                            .padding([.leading], -20)
                                                                        }
                                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                        .background(
                                                                            self.categoryData.categoryCustomColors.keys.contains(key)
                                                                                ? AnyView(self.categoryData.categoryCustomColors[key])
                                                                                : AnyView(Color.EZNotesOrange)
                                                                        )
                                                                        .padding([.leading], -20)
                                                                    }
                                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                    .background(
                                                                        self.categoryData.categoryCustomColors.keys.contains(key)
                                                                            ? AnyView(self.categoryData.categoryCustomColors[key])
                                                                            : AnyView(Color.EZNotesOrange)
                                                                    )
                                                                    .alert("Are you sure?", isPresented: $categoryAlert) {
                                                                        Button(action: {
                                                                            if self.categoryData.categoriesAndSets.count == 1 {
                                                                                self.categoryData.categoriesAndSets.removeAll()
                                                                                self.categoryData.setAndNotes.removeAll()
                                                                            } else {
                                                                                self.categoryData.categoriesAndSets.removeValue(forKey: self.categoryToDelete)
                                                                                self.categoryData.setAndNotes.removeValue(forKey: self.categoryToDelete)
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
                                                                             ? "Once deleted, the category \(self.categoryToDelete) will be removed from cloud or local storage and cannot be recovered."
                                                                             : "")
                                                                    }
                                                                }
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                            }
                                                            .frame(maxWidth: .infinity, maxHeight: 190)
                                                            .background(
                                                                self.categoryData.categoryCustomColors.keys.contains(key)
                                                                    ? self.categoryData.categoryCustomColors[key]!
                                                                    : Color.EZNotesOrange
                                                            )
                                                            .cornerRadius(15)
                                                            .padding([.top, .bottom], 10)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 20, maxHeight: 190)*/
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                }
                                                .frame(maxWidth: prop.size.width - 20)
                                                //.background(RoundedRectangle(cornerRadius: 15).fill(Color.EZNotesBlack.opacity(0.65)).shadow(color: Color.EZNotesBlack, radius: 4))
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.categoryData.categoryCustomColors.keys.contains(key)
                                                              ? self.categoryData.categoryCustomColors[key]!
                                                              : Color.EZNotesOrange)//(Color.EZNotesBlack)
                                                )
                                                .padding([.bottom], 5)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding([.top], 35)
                                        .padding([.bottom], 10)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    //.padding([.top], 20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, -130)
                            .popover(isPresented: $editCategoryDetails) {
                                EditCategory(
                                    prop: self.prop,
                                    categoryBeingEditedImage: self.categoryBeingEditedImage,
                                    categoryBeingEdited: $categoryBeingEdited,
                                    categoryData: self.categoryData
                                )
                            }
                        }
                    } else {
                        VStack {
                            Text("No Categories")
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                                .font(.system(size: 25, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                VStack {
                    ButtomNavbar(
                        section: $section,
                        backgroundColor: Color.EZNotesLightBlack,
                        prop: prop
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //.edgesIgnoringSafeArea(.top)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .black,
                            .black,
                            .black,
                            Color.EZNotesLightBlack
                        ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width < 0 {
                        self.section = "upload"
                    }
                })
            )
        } else {
            /* MARK: Show Category Information */
            CategoryInternalsView(
                prop: prop,
                categoryName: categoryLaunched,
                creationDate: "\(self.categoryData.categoryCreationDates[self.categoryLaunched]!.formatted(date: .numeric, time: .omitted))",
                categoryTitleColor: self.categoryTitleColor,
                categoryBackgroundColor: self.categoryBackgroundColor,
                categoryBackground: categoryBackground,
                categoryData: self.categoryData,
                launchCategory: $launchCategory
            )
        }
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
