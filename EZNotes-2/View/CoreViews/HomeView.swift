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
    
    /* MARK: For editing category details */
    @State private var photoPicker: PhotosPickerItem?
    @State private var editCategoryDetails: Bool = false
    @State private var categoryBeingEdited: String = ""
    @State private var categoryBeingEditedImage: UIImage! = UIImage(systemName: "plus")!
    @State private var categoryCreationDate: Date! = Date.now
    @State private var editSection: String = "edit" /* MARK: Can be "edit" or "preview". */
    @State private var editSectionYPos: CGFloat = 0
    @State private var newCategoryName: String = ""
    
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
                                                .shadow(color: .white, radius: 3.5)
                                                .font(.system(size: 50, design: .rounded))
                                                //.lineLimit(1)
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                            
                                            HStack {
                                                //VStack {
                                                    Button(action: {
                                                        self.editSection = "edit"
                                                    }) {
                                                        Text("Edit")
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                            .padding(5)
                                                            .foregroundStyle(self.editSection != "edit" ? Color.EZNotesOrange : Color.EZNotesBlack)
                                                            .font(.system(size: 15))
                                                            .fontWeight(.bold)
                                                    }
                                                    .padding([.leading], 25)
                                                    .buttonStyle(.borderedProminent)
                                                    .cornerRadius(15)
                                                    .tint(self.editSection == "edit"
                                                          ? Color.white.opacity(0.35)
                                                          : Color.EZNotesBlack.opacity(0.75)
                                                    )
                                                    .animation(.easeIn(duration: 0.5), value: self.editSection == "edit")
                                                    .animation(.easeOut(duration: 0.5), value: self.editSection != "edit")
                                                /*}
                                                .frame(maxWidth: 125, maxHeight: 30, alignment: .leading)
                                                .cornerRadius(15)
                                                .background(self.editSection == "edit"
                                                    ? Color.white.opacity(0.55)
                                                    : Color.EZNotesBlack.opacity(0.75)
                                                )*/
                                                
                                                //VStack {
                                                    Button(action: {
                                                        self.editSection = "preview"
                                                    }) {
                                                        Text("Preview")
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                            .padding(5)
                                                            .foregroundStyle(self.editSection != "preview" ? Color.EZNotesOrange : Color.EZNotesBlack)
                                                            .font(.system(size: 15))
                                                            .fontWeight(.bold)
                                                    }
                                                    .padding([.leading, .trailing], 15)
                                                    .buttonStyle(.borderedProminent)
                                                    .cornerRadius(15)
                                                    .tint(self.editSection == "preview"
                                                          ? Color.white.opacity(0.55)
                                                          : Color.EZNotesBlack.opacity(0.75)
                                                    )
                                                    .animation(.easeIn(duration: 0.5), value: self.editSection == "preview")
                                                    .animation(.easeOut(duration: 0.5), value: self.editSection != "preview")
                                                    //.buttonStyle(.borderless)
                                                /*}
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                                .background(self.editSection == "preview"
                                                    ? Color.white.opacity(0.55)
                                                    : Color.EZNotesBlack.opacity(0.75)
                                                )*/
                                            }
                                            .frame(maxWidth: 300, maxHeight: 40, alignment: .top)
                                            //.cornerRadius(15)
                                            .padding([.top], 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 265)
                                        /*.background(
                                            /*Image("Category-Edit-Background")//uiImage: self.categoryBeingEditedImage)
                                                .resizable()
                                                .frame(width: nil, height: 265)
                                                .scaledToFit()
                                                .cornerRadius(15, corners: [.topLeft, .topRight])
                                                .overlay(
                                                    Color.EZNotesLightBlack.opacity(0.45)
                                                )
                                                .blur(radius: 2.5)
                                                .mask(LinearGradient(gradient: Gradient(stops: [
                                                            .init(color: .black, location: 0),
                                                            .init(color: .clear, location: 1),
                                                            .init(color: .black, location: 1),
                                                            .init(color: .clear, location: 1)
                                                        ]), startPoint: .top, endPoint: .bottom))*/
                                            .black
                                        )*/
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 265)
                                    .background(.black)
                                    
                                    VStack {
                                        /* MARK: "Padding". */
                                        VStack { }.frame(maxWidth: .infinity, maxHeight: 25)
                                        
                                        if self.editSection == "edit" {
                                            VStack {
                                                HStack {
                                                    VStack {
                                                        Text("Category Title: ")
                                                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                                            .padding([.leading], 15)
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 20, design: .rounded))
                                                            .fontWeight(.semibold)
                                                        
                                                        TextField("New Title...", text: $newCategoryName)
                                                            .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                            .padding(7)
                                                            .padding(.horizontal, 15)
                                                            .background(Color(.systemGray6))
                                                            .cornerRadius(7.5)
                                                            .padding(.horizontal, 5)
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                .frame(maxWidth: prop.size.width - 120, maxHeight: 80)
                                                .padding([.top], 40)
                                                .cornerRadius(10)
                                                
                                                Divider()
                                                    .frame(width: prop.size.width - 120)
                                                
                                                Spacer()
                                                
                                                Button(action: { print("Finished Editing!") }) {
                                                    Text("Save Changes")
                                                        .frame(width: prop.size.width - 80, height: 40)
                                                        .padding(5)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 22))
                                                        .fontWeight(.medium)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(Color.EZNotesBlack.opacity(0.75))
                                                .padding([.bottom], 35)
                                            }
                                            .frame(maxWidth: prop.size.width, maxHeight: .infinity)
                                            .cornerRadius(15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(
                                                        /*LinearGradient(
                                                            gradient: Gradient(
                                                                colors: [
                                                                    Color.EZNotesLightBlack,
                                                                    .black.opacity(0.50)
                                                                ]),
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )*/
                                                        .black
                                                    )
                                                    .shadow(color: .white, radius: 2.5)
                                                //(.clear)
                                                    //.shadow(color: .white, radius: 2.5)
                                                    /*.stroke(LinearGradient(
                                                        gradient: Gradient(
                                                            colors: [
                                                                Color.EZNotesLightBlack,
                                                                .black.opacity(0.50)
                                                            ]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ), lineWidth: 1)*/
                                                /*Image("Category-Edit-Background")//uiImage: self.categoryBeingEditedImage)
                                                    .resizable()
                                                    .blur(radius: 2.5)
                                                    .cornerRadius(15)*/
                                            ).edgesIgnoringSafeArea(.bottom) //(.black.opacity(0.50))
                                        } else {
                                            VStack {
                                                Text("Previewing...")
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    .black
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
