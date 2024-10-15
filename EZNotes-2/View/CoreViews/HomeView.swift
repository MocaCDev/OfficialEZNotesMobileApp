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

struct HomeView: View {
    @Binding public var section: String
    var categoriesAndSets: [String: Array<String>]
    @Binding public var categoryImages: [String: UIImage]
    var categoryCreationDates: [String: Date]
    
    /* MARK: For changing background image of category. */
    @State private var photoPicker: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var editCategoryDetails: Bool = false
    @State private var categoryBeingEdited: String = ""
    @State private var categoryBeingEditedImage: UIImage = UIImage(systemName: "plus")!
    
    @State private var home_section: String = "main"
    @State private var show_categories_title: Bool = false
    
    @State private var launchCategory: Bool = false
    @State private var categoryLaunched: String = ""
    @State private var categoryBackground: UIImage = UIImage(systemName: "arrow.left")! /* TODO: Figure out how to initialize a UIImage variable. */
    
    @State private var categorySearch: String = ""
    @State private var searchDone: Bool = false
    @State private var lookedUpCategoriesAndSets: [String: Array<String>] = [:]
    
    var prop: Properties
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY + 15 || textFrame.minY > scrollViewFrame.maxY {
            self.show_categories_title = true
        } else {
            self.show_categories_title = false
        }
    }
    
    var body: some View {
        if !self.launchCategory {
            VStack {
                ZStack {
                    TopNavHome(
                        prop: prop,
                        backgroundColor: Color.EZNotesLightBlack,
                        categoriesAndSets: categoriesAndSets,
                        changeNavbarColor: $show_categories_title,
                        categorySearch: $categorySearch,
                        searchDone: $searchDone,
                        lookedUpCategoriesAndSets: $lookedUpCategoriesAndSets
                    )
                    
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
                                        .padding([.top], 25)
                                        .padding([.bottom], 10)
                                        .background(Color.clear)
                                        //.opacity(self.show_categories_title ? 0 : 1)
                                        
                                        //LazyVGrid(columns: columns, spacing: 10) {
                                        VStack {
                                            ForEach(Array(self.lookedUpCategoriesAndSets.count == 0
                                                          ? self.categoriesAndSets.keys
                                                          : self.lookedUpCategoriesAndSets.keys), id: \.self) { key in
                                                HStack {
                                                    Button(action: {
                                                        self.launchCategory = true
                                                        self.categoryLaunched = key
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
                                                                        .frame(width: 150, height: 190)
                                                                        .cornerRadius(15, corners: [.topLeft, .bottomLeft, .topRight, .bottomRight])
                                                                        .scaledToFit()
                                                                        .zIndex(1)
                                                                    
                                                                    VStack {
                                                                        VStack {
                                                                            HStack {
                                                                                Text(key)
                                                                                    .foregroundStyle(.white)
                                                                                    .font(.system(size: 18.5, design: .rounded))
                                                                                    .fontWeight(.semibold)
                                                                                    .multilineTextAlignment(.center)
                                                                                
                                                                                Divider()
                                                                                    .frame(height: 35)
                                                                                
                                                                                Text("Sets: \(self.categoriesAndSets[key]!.count)")
                                                                                    .foregroundStyle(.white)
                                                                                    .font(.system(size: 18.5, design: .rounded))
                                                                                    .fontWeight(.medium)
                                                                                    .multilineTextAlignment(.center)
                                                                            }
                                                                            .frame(maxWidth: (prop.size.width - 20) - 180, maxHeight: .infinity, alignment: .center)
                                                                        }
                                                                        .frame(maxWidth: .infinity, maxHeight: 90, alignment: .top)
                                                                        .background(Color.EZNotesOrange.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                                        .cornerRadius(15, corners: [.topRight])
                                                                        .padding([.leading], -20)
                                                                        
                                                                        HStack {
                                                                            Button(action: {
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
                                                                        .frame(maxWidth: .infinity, maxHeight: 30)
                                                                        .padding([.top], 5)
                                                                        
                                                                        Spacer()
                                                                        
                                                                        Text("Created \(self.categoryCreationDates[key]!.formatted(date: .numeric, time: .omitted))")
                                                                            .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
                                                                            .foregroundStyle(.white)
                                                                            .fontWeight(.light)
                                                                            .font(.system(size: 15))
                                                                        
                                                                        Spacer()
                                                                    }
                                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                }
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                            }
                                                            .frame(maxWidth: .infinity, maxHeight: 190)
                                                            .padding([.top, .bottom], 10)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                    }
                                                    .buttonStyle(.borderless)
                                                }
                                                .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.EZNotesBlack.opacity(0.65 )).shadow(color: Color.EZNotesBlack, radius: 4))
                                                .padding([.bottom], 5)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding([.top], 35)
                                        .padding([.bottom], 10)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding([.top], 20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .popover(isPresented: $editCategoryDetails) {
                                VStack {
                                    VStack {
                                        VStack {
                                            Text(self.categoryBeingEdited)
                                                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 500, design: .rounded))
                                                .minimumScaleFactor(0.01)
                                                .lineLimit(1)
                                                .fontWeight(.heavy)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 415, alignment: .center)
                                        .background(
                                            Image(uiImage: self.categoryBeingEditedImage)
                                                .resizable()
                                                .frame(width: nil, height: 415)
                                                .scaledToFit()
                                                .cornerRadius(15, corners: [.topLeft, .topRight])
                                                .overlay(
                                                    Color.EZNotesLightBlack.opacity(0.65)
                                                )
                                        )
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 400, alignment: .top)
                                    
                                    VStack {
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.black)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
