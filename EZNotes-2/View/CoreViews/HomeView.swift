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
    @Binding public var categoriesAndSets: [String: Array<String>]
    @Binding public var categoryImages: [String: UIImage]
    @Binding var categoryCreationDates: [String: Date]
    
    /* MARK: The below bindings are all custom to the category cards. The values below will be set via the edit popup. */
    @Binding public var categoryDescriptions: [String: String]
    @Binding public var categoryCustomColors: [String: Color]
    @Binding public var categoryCustomTextColors: [String: Color]
    
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
    
    var body: some View {
        if !self.launchCategory {
            VStack {
                TopNavHome(
                    accountInfo: accountInfo,
                    prop: prop,
                    backgroundColor: Color.EZNotesLightBlack,
                    categoriesAndSets: categoriesAndSets,
                    changeNavbarColor: $show_categories_title,
                    navbarOpacity: $topNavOpacity,
                    categorySearch: $categorySearch,
                    searchDone: $searchDone,
                    messages: $messages,
                    lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets
                )
                
                ZStack {
                    if self.categoriesAndSets.count > 0 {
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
                                                         ? "Categories(\(self.categoriesAndSets.count))"
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
                                                          ? self.categoriesAndSets.keys
                                                          : self.lookedUpCategoriesAndSets.keys), id: \.self) { key in
                                                HStack {
                                                    Button(action: {
                                                        self.launchCategory = true
                                                        self.categoryLaunched = key
                                                        self.categoryDescription = self.categoryDescriptions[key]
                                                        self.categoryTitleColor = self.categoryCustomTextColors[key]
                                                        self.categoryBackgroundColor = self.categoryCustomColors[key]
                                                        self.categoryBackground = self.categoryImages[key]!
                                                    }) {
                                                        HStack {
                                                            VStack {
                                                                HStack {
                                                                    /* MARK: When the image is clicked, the app will open the photo gallery for the user to select a new photo for the category.
                                                                     * MARK: By default, the categories background image is the first image uploaded in which curated a set of notes within the category.
                                                                     * */
                                                                    Image(uiImage: self.categoryImages[key]!)
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
                                                                                        self.categoryCustomTextColors.keys.contains(key)
                                                                                            ? self.categoryCustomTextColors[key]!
                                                                                            : .white
                                                                                    )
                                                                                    .font(.system(size: 18.5, design: .rounded))
                                                                                    .fontWeight(.semibold)
                                                                                    .multilineTextAlignment(.center)
                                                                                
                                                                                Divider()
                                                                                    .frame(height: 35)
                                                                                
                                                                                Text("Sets: \(self.categoriesAndSets[key]!.count)")
                                                                                    .frame(maxWidth: 80, alignment: .trailing)
                                                                                    .foregroundStyle(
                                                                                        self.categoryCustomTextColors.keys.contains(key)
                                                                                            ? self.categoryCustomTextColors[key]!
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
                                                                            self.categoryCustomColors.keys.contains(key)
                                                                                ? AnyView(self.categoryCustomColors[key].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                            : AnyView(Color.EZNotesOrange.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                        )
                                                                        .cornerRadius(15, corners: [.topRight])
                                                                        .padding([.leading], -20)
                                                                        
                                                                        VStack {
                                                                            VStack {
                                                                                VStack {
                                                                                    if self.categoryDescriptions.count > 0 && self.categoryDescriptions.keys.contains(key) {
                                                                                        //ZStack {
                                                                                        Text(self.categoryDescriptions[key]!)
                                                                                            .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 100, alignment: .leading)
                                                                                            .foregroundStyle(
                                                                                                self.categoryCustomTextColors.keys.contains(key)
                                                                                                ? self.categoryCustomTextColors[key]!
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
                                                                                                self.categoryCustomTextColors.keys.contains(key)
                                                                                                    ? self.categoryCustomTextColors[key]!
                                                                                                    : .white
                                                                                            )
                                                                                            .padding([.leading], 20)
                                                                                            .font(.system(size: 16))
                                                                                            .fontWeight(.medium)
                                                                                            .padding()
                                                                                            .multilineTextAlignment(.leading)
                                                                                    }
                                                                                    
                                                                                    Text("Created \(self.categoryCreationDates[key]!.formatted(date: .numeric, time: .omitted))")
                                                                                        .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 20, alignment: .leading)
                                                                                        .padding([.bottom], 5)
                                                                                        .padding([.leading], 20)
                                                                                        .foregroundStyle(
                                                                                            self.categoryCustomTextColors.keys.contains(key)
                                                                                                ? self.categoryCustomTextColors[key]!
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
                                                                                        if self.categoryDescriptions.keys.contains(key) {
                                                                                            self.newCategoryDescription = self.categoryDescriptions[key]!
                                                                                        } else { self.newCategoryDescription = "" }
                                                                                        
                                                                                        if self.categoryCustomColors.keys.contains(key) {
                                                                                            self.newCategoryDisplayColor = self.categoryCustomColors[key]!
                                                                                        } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                                                                                        
                                                                                        if self.categoryCustomTextColors.keys.contains(key) {
                                                                                            self.newCategoryTextColor = self.categoryCustomTextColors[key]!
                                                                                        } else { self.newCategoryTextColor = .white }
                                                                                        
                                                                                        self.categoryBeingEditedImage = self.categoryImages[key]!
                                                                                        self.categoryBeingEdited = key
                                                                                        self.categoryBeingEditedImage = self.categoryImages[key]!
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
                                                                                    
                                                                                    Button(action: { print("Delete Category") }) {
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
                                                                            self.categoryCustomColors.keys.contains(key)
                                                                                ? AnyView(self.categoryCustomColors[key])
                                                                                : AnyView(Color.EZNotesOrange)
                                                                        )
                                                                        .padding([.leading], -20)
                                                                    }
                                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                    .background(
                                                                        self.categoryCustomColors.keys.contains(key)
                                                                            ? AnyView(self.categoryCustomColors[key])
                                                                            : AnyView(Color.EZNotesOrange)
                                                                    )
                                                                }
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                            }
                                                            .frame(maxWidth: .infinity, maxHeight: 190)
                                                            .background(
                                                                self.categoryCustomColors.keys.contains(key)
                                                                    ? self.categoryCustomColors[key]!
                                                                    : Color.EZNotesOrange
                                                            )
                                                            .cornerRadius(15)
                                                            .padding([.top, .bottom], 10)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                }
                                                .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.EZNotesBlack.opacity(0.65)).shadow(color: Color.EZNotesBlack, radius: 4))
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
                                VStack {
                                    VStack {
                                        VStack {
                                            Text("Editing Category")
                                                .frame(maxWidth: .infinity, maxHeight: 25, alignment: .center)
                                                .padding([.bottom], -15)
                                                .foregroundStyle(Color.secondary)
                                                .font(.system(size: 25, design: .rounded))
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                            
                                            Text(self.categoryBeingEdited)
                                                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                                                .foregroundStyle(.white)
                                                .shadow(color: .white, radius: 2)
                                                .font(.system(size: 50, design: .rounded))
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                            
                                            HStack {
                                                VStack {
                                                    Button(action: {
                                                        self.editSection = "edit"
                                                    }) {
                                                        Text("Edit")
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                            .padding(5)
                                                            .foregroundStyle(self.editSection != "edit" ? Color.EZNotesBlack : Color.EZNotesOrange)
                                                            .font(.system(size: 18))
                                                            .fontWeight(.medium)
                                                    }
                                                    .buttonStyle(.borderless)
                                                    .animation(.easeIn(duration: 0.5), value: self.editSection == "edit")
                                                    .animation(.easeOut(duration: 0.5), value: self.editSection != "edit")
                                                }
                                                .frame(maxWidth: 150, maxHeight: .infinity)
                                                .background(
                                                    self.editSection == "edit"
                                                            ? AnyView(RoundedRectangle(cornerRadius: 15)
                                                                .fill(.gray.opacity(0.70))
                                                                .stroke(.white, lineWidth: 4))
                                                            : AnyView(RoundedRectangle(cornerRadius: 15)
                                                                .fill(.white.opacity(0.75)))
                                                )
                                                .cornerRadius(15)
                                                
                                                VStack {
                                                    Button(action: {
                                                        self.editSection = "preview"
                                                    }) {
                                                        Text("Preview")
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                            .padding(5)
                                                            .foregroundStyle(self.editSection != "preview" ? Color.EZNotesBlack : Color.EZNotesOrange)
                                                            .font(.system(size: 18))
                                                            .fontWeight(.medium)
                                                    }
                                                    .padding([.leading, .trailing], 30)
                                                    .buttonStyle(.borderless)
                                                    .animation(.easeIn(duration: 0.5), value: self.editSection == "preview")
                                                    .animation(.easeOut(duration: 0.5), value: self.editSection != "preview")
                                                }
                                                .frame(maxWidth: 150, maxHeight: .infinity)
                                                .background(self.editSection == "preview"
                                                            ? AnyView(RoundedRectangle(cornerRadius: 15)
                                                                .fill(.gray.opacity(0.70))
                                                                .stroke(.white, lineWidth: 4))
                                                            : AnyView(RoundedRectangle(cornerRadius: 15)
                                                                .fill(.white.opacity(0.75)))
                                                )
                                                .cornerRadius(15)
                                            }
                                            .frame(maxWidth: prop.size.width - 50, maxHeight: 40, alignment: .top)
                                            .cornerRadius(15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 265)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 265)
                                    .background(
                                        Image(uiImage: self.categoryBeingEditedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .overlay(
                                                Color.EZNotesLightBlack.opacity(0.45)
                                            )
                                            .blur(radius: 2.5)
                                    )
                                    
                                    VStack {
                                        /* MARK: "Padding". */
                                        VStack {
                                            
                                        }.frame(maxWidth: .infinity, maxHeight: 15)
                                        
                                        if self.editSection == "edit" {
                                            VStack {
                                                Text("Edit Details")
                                                    .frame(maxWidth: .infinity, maxHeight: 25)
                                                    .padding([.top], 15)
                                                    .font(.system(size: 20))
                                                    .fontWeight(.semibold)
                                                
                                                Divider()
                                                    .frame(width: prop.size.width - 50)
                                                
                                                VStack {
                                                    Text("Category Title: ")
                                                        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .fontWeight(.light)
                                                    
                                                    ZStack {
                                                        TextField("New Title...", text: $newCategoryName)
                                                            .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                            .padding([.leading], 15)
                                                            .padding(7)
                                                            .background(Color(.systemGray6))
                                                            .cornerRadius(7.5)
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                                    
                                                }
                                                .frame(maxWidth: prop.size.width - 80, maxHeight: 80)
                                                .padding([.top], 10)
                                                
                                                VStack {
                                                    HStack {
                                                        Text("Category Description")
                                                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 20, design: .rounded))
                                                            .fontWeight(.light)
                                                        
                                                        Button(action: {
                                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                            self.newCategoryDescriptionFocus = false
                                                        }) {
                                                            Text("Done")
                                                                .foregroundStyle(Color.EZNotesBlue)
                                                                .font(.system(size: 16))
                                                                .fontWeight(.semibold)
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: 25)
                                                    
                                                    TextField(
                                                        self.categoryDescriptions.keys.contains(self.categoryBeingEdited)
                                                            ? self.categoryDescriptions[self.categoryBeingEdited]!
                                                            : "Description...",
                                                        text: $newCategoryDescription,
                                                        axis: .vertical
                                                    )
                                                    .onTapGesture { print("TAP!") }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding([.leading], 15)
                                                    .padding(7)
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(7.5)
                                                    .lineLimit(3...5)
                                                    .onChange(of: self.newCategoryDescription) {
                                                        if self.newCategoryDescription.count > 150 {
                                                            self.newCategoryDescription = String(self.newCategoryDescription.prefix(150))
                                                        }
                                                    }
                                                    
                                                    Text("\(self.newCategoryDescription.count) out of 150 characters")
                                                        .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                                                        .padding([.leading], 5)
                                                        .foregroundStyle(
                                                            self.newCategoryDescription.count < 150
                                                                ? self.newCategoryDescription.count > 140 && self.newCategoryDescription.count < 150
                                                                    ? .yellow
                                                                    : Color.secondary
                                                                : .red
                                                        )
                                                        .font(.system(size: 10, design: .rounded))
                                                        .fontWeight(.medium)
                                                }
                                                .frame(maxWidth: prop.size.width - 80, maxHeight: 140)
                                                .padding([.top], 5)
                                                
                                                HStack {
                                                    VStack {
                                                        HStack {
                                                            Text("Category Color")
                                                                .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 18, design: .rounded))
                                                                .fontWeight(.light)
                                                            
                                                            //if self.toggleCategoryBackgroundColorPicker {
                                                                ColorPicker("", selection: $newCategoryDisplayColor)
                                                                    .frame(width: 38, height: 40)
                                                                    .padding(3.5)
                                                            //}
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                                        
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(
                                                                self.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                                ? self.newCategoryDisplayColor == self.categoryCustomColors[self.categoryBeingEdited]!
                                                                    ? self.categoryCustomColors[self.categoryBeingEdited]!
                                                                    : self.newCategoryDisplayColor
                                                                : self.newCategoryDisplayColor
                                                            )
                                                            .frame(maxWidth: prop.size.width - 80, maxHeight: 120)
                                                            .onTapGesture { self.toggleCategoryBackgroundColorPicker = true }
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    
                                                    VStack {
                                                        HStack {
                                                            Text("Text Color")
                                                                .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 18, design: .rounded))
                                                                .fontWeight(.light)
                                                            
                                                            //if self.toggleCategoryTextColorPicker {
                                                                ColorPicker("", selection: $newCategoryTextColor)
                                                                    .frame(width: 30, height: 40)
                                                            //}
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                                        
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(
                                                                self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                    ? self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                        ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                        : self.newCategoryTextColor
                                                                    : self.newCategoryTextColor
                                                            )
                                                            .frame(maxWidth: prop.size.width - 80, maxHeight: 120)
                                                            .onTapGesture { self.toggleCategoryTextColorPicker = true }
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                }
                                                .frame(maxWidth: prop.size.width - 80, maxHeight: 120)
                                                .padding([.top], 5)
                                                .padding([.bottom], 15)
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    self.toggleCategoryTextColorPicker = false
                                                    self.toggleCategoryBackgroundColorPicker = false
                                                    
                                                    self.showSaveAlert = true
                                                }) {
                                                    Text("Save Changes")
                                                        .frame(width: prop.size.width - 80, height: 25)
                                                        .padding(3.5)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 22))
                                                        .fontWeight(.medium)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(Color.EZNotesBlack.opacity(0.85))
                                                .alert("Hang On", isPresented: $showSaveAlert) {
                                                    Button(action: {
                                                        if self.newCategoryName.count > 0 && !(self.newCategoryName == self.categoryBeingEdited) {
                                                            let categoryData = self.categoriesAndSets[self.categoryBeingEdited]
                                                            let categoryImageData = self.categoryImages[self.categoryBeingEdited]
                                                            let categoryCreationDate = self.categoryCreationDates[self.categoryBeingEdited]
                                                            
                                                            self.categoriesAndSets.removeValue(forKey: self.categoryBeingEdited)
                                                            self.categoryImages.removeValue(forKey: self.categoryBeingEdited)
                                                            self.categoryCreationDates.removeValue(forKey: self.categoryBeingEdited)
                                                            
                                                            self.categoriesAndSets[self.newCategoryName] = categoryData
                                                            writeCategoryData(categoryData: self.categoriesAndSets)
                                                            
                                                            self.categoryImages[self.newCategoryName] = categoryImageData
                                                            writeCategoryImages(categoryImages: self.categoryImages)
                                                            
                                                            self.categoryCreationDates[self.newCategoryName] = categoryCreationDate
                                                            writeCategoryCreationDates(categoryCreationDates: self.categoryCreationDates)
                                                            
                                                            if self.categoryCustomColors.keys.contains(self.categoryBeingEdited) {
                                                                self.categoryCustomColors.removeValue(forKey: self.categoryBeingEdited)
                                                            }
                                                            
                                                            if self.categoryDescriptions.keys.contains(self.categoryBeingEdited) {
                                                                self.categoryDescriptions.removeValue(forKey: self.categoryBeingEdited)
                                                            }
                                                            
                                                            if self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) {
                                                                self.categoryCustomTextColors.removeValue(forKey: self.categoryBeingEdited)
                                                            }
                                                            
                                                            self.categoryBeingEdited = self.newCategoryName
                                                        }
                                                        
                                                        if self.newCategoryDisplayColor != Color.EZNotesOrange {
                                                            self.categoryCustomColors[self.categoryBeingEdited] = self.newCategoryDisplayColor
                                                            writeCategoryCustomColors(categoryCustomColors: self.categoryCustomColors)
                                                            //self.newCategoryDisplayColor = Color.EZNotesOrange
                                                        }
                                                        
                                                        if self.newCategoryTextColor != Color.white {
                                                            self.categoryCustomTextColors[self.categoryBeingEdited] = self.newCategoryTextColor
                                                            writeCategoryTextColors(categoryTextColors: self.categoryCustomTextColors)
                                                            //self.newCategoryTextColor = Color.white
                                                        }
                                                        
                                                        if self.newCategoryDescription.count > 0 {
                                                            let str = self.newCategoryDescription.filter{!$0.isWhitespace || !$0.isNewline}
                                                            
                                                            if str == "" { return }
                                                            
                                                            self.categoryDescriptions[self.categoryBeingEdited] = self.newCategoryDescription
                                                            writeCategoryDescriptions(categoryDescriptions: self.categoryDescriptions)
                                                            //self.newCategoryDescription.removeAll()
                                                        } else {
                                                            self.categoryDescriptions.removeValue(forKey: self.categoryBeingEdited)
                                                            writeCategoryDescriptions(categoryDescriptions: self.categoryDescriptions)
                                                        }
                                                    }) {
                                                        Text("Okay")
                                                    }
                                                    Button("Cancel", role: .cancel) { }
                                                } message: {
                                                    Text("Once you save, all changes are final.")
                                                }
                                                
                                                Button(action: { print("Resetting") }) {
                                                    Text("Reset")
                                                        .frame(width: prop.size.width - 80, height: 25)
                                                        .padding(3.5)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 22))
                                                        .fontWeight(.medium)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(Color.EZNotesBlack.opacity(0.85))
                                                .padding([.bottom], 35)
                                            }
                                            .frame(maxWidth: prop.size.width, maxHeight: .infinity)
                                            .cornerRadius(15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(.black)
                                                    .shadow(color: .black, radius: 6.5)
                                            )
                                            .edgesIgnoringSafeArea(.bottom)
                                            .onTapGesture {
                                                self.toggleCategoryTextColorPicker = false
                                                self.toggleCategoryBackgroundColorPicker = false
                                            }
                                        } else {
                                            VStack {
                                                Text("Preview Details")
                                                    .frame(maxWidth: .infinity, maxHeight: 25)
                                                    .padding([.top], 15)
                                                    .font(.system(size: 20))
                                                    .fontWeight(.semibold)
                                                
                                                Divider()
                                                    .frame(width: prop.size.width - 50)
                                                
                                                Spacer()
                                                
                                                VStack {
                                                    HStack {
                                                        Image(uiImage: self.categoryBeingEditedImage!)
                                                            .resizable()
                                                            .frame(width: 150.5, height: 190.5)
                                                            .scaledToFit()
                                                            .zIndex(1)
                                                            .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                                        
                                                        VStack {
                                                            VStack {
                                                                HStack {
                                                                    Text(self.newCategoryName.count > 0 ? self.newCategoryName : self.categoryBeingEdited)
                                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                                        .foregroundStyle(
                                                                            self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                                ? self.newCategoryTextColor != .white
                                                                                    ? self.newCategoryTextColor
                                                                                    : self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                : self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                                    ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                    : self.newCategoryTextColor != .white
                                                                                        ? self.newCategoryTextColor
                                                                                        : .white
                                                                        )
                                                                        .font(.system(size: 18.5, design: .rounded))
                                                                        .fontWeight(.semibold)
                                                                        .multilineTextAlignment(.center)
                                                                    
                                                                    Divider()
                                                                        .frame(height: 35)
                                                                    
                                                                    Text("Sets: \(self.categoriesAndSets[self.categoryBeingEdited]!.count)")
                                                                        .frame(maxWidth: 80, alignment: .trailing)
                                                                        .foregroundStyle(
                                                                            self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                                ? self.newCategoryTextColor != .white
                                                                                    ? self.newCategoryTextColor
                                                                                    : self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                : self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                                    ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                    : self.newCategoryTextColor != .white
                                                                                        ? self.newCategoryTextColor
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
                                                                self.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryCustomColors[self.categoryBeingEdited]!)
                                                                    ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                        ? AnyView(self.newCategoryDisplayColor.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                        : AnyView(self.categoryCustomColors[self.categoryBeingEdited].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                    : self.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                                        ? AnyView(self.categoryCustomColors[self.categoryBeingEdited].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                        : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                            ? AnyView(self.newCategoryDisplayColor.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                            : AnyView(Color.EZNotesOrange.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                            )
                                                            .cornerRadius(15, corners: [.topRight])
                                                            .padding([.leading], -20)
                                                            
                                                            VStack {
                                                                VStack {
                                                                    VStack {
                                                                        if self.newCategoryDescription != "" {
                                                                            //ZStack {
                                                                            Text(self.newCategoryDescription)
                                                                                .foregroundStyle(
                                                                                    self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                                        ? self.newCategoryTextColor != .white
                                                                                            ? self.newCategoryTextColor
                                                                                            : self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                        : self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                                            ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                            : self.newCategoryTextColor != .white
                                                                                                ? self.newCategoryTextColor
                                                                                                : .white
                                                                                )
                                                                                .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 40, alignment: .leading)
                                                                                .padding([.leading], 20)
                                                                                .minimumScaleFactor(0.5)
                                                                                .fontWeight(.light)
                                                                                .multilineTextAlignment(.leading)
                                                                        } else {
                                                                            Text("No Description")
                                                                                .foregroundStyle(
                                                                                    self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                                        ? self.newCategoryTextColor != .white
                                                                                            ? self.newCategoryTextColor
                                                                                            : self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                        : self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                                            ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                            : self.newCategoryTextColor != .white
                                                                                                ? self.newCategoryTextColor
                                                                                                : .white
                                                                                )
                                                                                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                                                                                .padding([.leading], 20)
                                                                                .minimumScaleFactor(0.6)
                                                                                .fontWeight(.medium)
                                                                                .padding()
                                                                                .multilineTextAlignment(.leading)
                                                                        }
                                                                        
                                                                        Text("Created \(self.categoryCreationDates[self.categoryBeingEdited]!.formatted(date: .numeric, time: .omitted))")
                                                                            .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 20, alignment: .leading)
                                                                            .padding([.bottom], 5)
                                                                            .padding([.leading], 20)
                                                                            .foregroundStyle(
                                                                                self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                                    ? self.newCategoryTextColor != .white
                                                                                        ? self.newCategoryTextColor
                                                                                        : self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                    : self.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                                        ? self.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                                        : self.newCategoryTextColor != .white
                                                                                            ? self.newCategoryTextColor
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
                                                                        
                                                                        Button(action: { print("Delete Category") }) {
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
                                                                self.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryCustomColors[self.categoryBeingEdited]!)
                                                                    ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                        ? self.newCategoryDisplayColor
                                                                        : self.categoryCustomColors[self.categoryBeingEdited]!
                                                                    : self.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                                        ? self.categoryCustomColors[self.categoryBeingEdited]!
                                                                        : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                            ? self.newCategoryDisplayColor
                                                                            : Color.EZNotesOrange
                                                            )
                                                            .padding([.leading], -20)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .background(
                                                            self.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryCustomColors[self.categoryBeingEdited]!)
                                                                ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                    ? self.newCategoryDisplayColor
                                                                    : self.categoryCustomColors[self.categoryBeingEdited]!
                                                                : self.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                                    ? self.categoryCustomColors[self.categoryBeingEdited]!
                                                                    : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                        ? self.newCategoryDisplayColor
                                                                        : Color.EZNotesOrange
                                                        )
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                }
                                                .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                .background(
                                                    self.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryCustomColors[self.categoryBeingEdited]!)
                                                        ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                            ? self.newCategoryDisplayColor
                                                            : self.categoryCustomColors[self.categoryBeingEdited]!
                                                        : self.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                            ? self.categoryCustomColors[self.categoryBeingEdited]!
                                                            : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                                ? self.newCategoryDisplayColor
                                                                : Color.EZNotesOrange
                                                )
                                                .cornerRadius(15)
                                                .padding([.top, .bottom], 10)
                                                
                                                Spacer()
                                            }
                                            .frame(maxWidth: prop.size.width, maxHeight: .infinity)
                                            .cornerRadius(15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(.black)
                                                    .shadow(color: .black, radius: 6.5)
                                            )
                                            .edgesIgnoringSafeArea(.bottom)
                                        }
                                    }
                                    .animation(.default, value: self.editSection == "edit" || self.editSection == "preview")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    /*LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                .black,
                                                .black,
                                                Color.EZNotesLightBlack
                                            ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )*/
                                    .white
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
            .edgesIgnoringSafeArea(.top)
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
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
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
                creationDate: "\(self.categoryCreationDates[self.categoryLaunched]!.formatted(date: .numeric, time: .omitted))",
                categoryDescription: self.categoryDescription,
                categoryTitleColor: self.categoryTitleColor,
                categoryBackgroundColor: self.categoryBackgroundColor,
                categoriesAndSets: categoriesAndSets,
                categoryBackground: categoryBackground,
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
