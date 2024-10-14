//
//  HomeView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

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
    var categoryImages: [String: UIImage]
    
    @State private var home_section: String = "main"
    @State private var show_categories_title: Bool = false
    
    @State private var launchCategory: Bool = false
    @State private var categoryLaunched: String = ""
    @State private var categoryBackground: UIImage = UIImage(systemName: "arrow.left")! /* TODO: Figure out how to initialize a UIImage variable. */
    
    @State private var categorySearch: String = ""
    
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
                        categorySearch: $categorySearch
                    )
                    
                    if self.categoriesAndSets.count > 0 {
                        VStack {
                            GeometryReader { geometry in
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                         GeometryReader { innerGeometry in
                                             HStack {
                                                 Text("Categories(\(self.categoriesAndSets.count))")
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
                                    .opacity(self.show_categories_title ? 0 : 1)
                                    
                                    //LazyVGrid(columns: columns, spacing: 10) {
                                    VStack {
                                        ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                                            HStack {
                                                Button(action: {
                                                    self.launchCategory = true
                                                    self.categoryLaunched = key
                                                    self.categoryBackground = self.categoryImages[key]!
                                                }) {
                                                    HStack {
                                                        VStack {
                                                            HStack {
                                                                Image(uiImage: self.categoryImages[key]!)
                                                                    .resizable()
                                                                    .frame(width: 150, height: 190)
                                                                    .cornerRadius(15, corners: [.topLeft, .bottomLeft, .topRight, .bottomRight])
                                                                    //.cornerRadius(10, corners: [.topRight, .bottomRight])
                                                                    .scaledToFit()
                                                                    /*.mask(LinearGradient(gradient: Gradient(stops: [
                                                                                .init(color: .black, location: 0),
                                                                                .init(color: .clear, location: 1),
                                                                                .init(color: .black, location: 1),
                                                                                .init(color: .clear, location: 1)
                                                                            ]), startPoint: .leading, endPoint: .trailing))*/
                                                                    //.padding([.leading], 5)
                                                                
                                                                VStack {
                                                                    Text(key)
                                                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
                                                                        .padding([.leading], 12)
                                                                        .foregroundStyle(.white)
                                                                        .font(.system(size: 20, design: .monospaced))
                                                                        .fontWeight(.medium)
                                                                        .multilineTextAlignment(.center)
                                                                    
                                                                    Text("Sets: \(self.categoriesAndSets[key]!.count)")
                                                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
                                                                        .padding([.leading], 12)
                                                                        .foregroundStyle(.white)
                                                                        .font(.system(size: 18, design: .rounded))
                                                                        .fontWeight(.medium)
                                                                        .multilineTextAlignment(.center)
                                                                    
                                                                    Text("Created 04/20/24")
                                                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
                                                                        .padding([.leading], 12)
                                                                        .foregroundStyle(.white)
                                                                        .font(.system(size: 13, design: .rounded))
                                                                        .fontWeight(.thin)
                                                                        .multilineTextAlignment(.center)
                                                                }
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                            }
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: 190, alignment: .leading)
                                                        .padding([.top, .bottom], 10)
                                                        
                                                        //Spacer()
                                                        
                                                        /*VStack {
                                                            Text("Sets: \(self.categoriesAndSets[key]!.count)")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 18, design: .rounded))
                                                                .fontWeight(.medium)
                                                                .multilineTextAlignment(.center)
                                                                .frame(maxWidth: .infinity, maxHeight: 20)
                                                        }
                                                        .frame(maxWidth: 85, alignment: .center)*/
                                                        
                                                        //Spacer()
                                                    }
                                                    .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                                }
                                                .buttonStyle(.borderless)
                                                //.padding([.bottom], 5)
                                                
                                                /*VStack {
                                                    Image(systemName: "pencil")
                                                        .resizable()
                                                        .frame(width: 18, height: 18)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .padding([.trailing], 10)
                                                    
                                                    Image(systemName: "ellipsis")
                                                        .resizable()
                                                        .frame(width: 20, height: 5)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .padding([.trailing, .top, .bottom], 10)
                                                    
                                                    Image(systemName: "trash")
                                                        .resizable()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(Color.EZNotesRed)
                                                        .padding([.trailing], 10)
                                                }
                                                .frame(maxWidth: 55, maxHeight: 130, alignment: .trailing)
                                                .padding([.trailing], 15)*/
                                            }
                                            .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.EZNotesBlack.opacity(0.35)).shadow(color: Color.EZNotesBlack, radius: 4))
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
                    } else {
                        VStack {
                            Text("No Categories")
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                                .font(.system(size: 25, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    //.padding([.top], 40)
                    
                    /*HStack {
                     Image(systemName: "person.crop.circle.fill")
                     .resizable()
                     .frame(maxWidth: 30, maxHeight: 30)
                     .padding([.leading], 20)
                     .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                     
                     Spacer()
                     
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
                     .frame(
                     maxWidth: .infinity,
                     maxHeight: prop.size.height / 2.5 > 300 ? 100 : 50
                     )
                     .background(Color.EZNotesLightBlack.opacity(0.4).blur(radius: 3.5))
                     .edgesIgnoringSafeArea(.top)*/
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
                /*Image("Background12")
                    .overlay(Color.EZNotesBlack.opacity(0.4))
                    .blur(radius: 6.5)*/
                //Color.EZNotesBlack
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .black,
                            .black,
                            .black,
                            Color.EZNotesLightBlack
                            /*Color.EZNotesBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesLightBlack*/
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
        
        /*ZStack {
            VStack {
                HStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 80, alignment: .top)
                .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))//(.ultraThinMaterial, in: Color.EZNotesBlack)//.background(Color.clear.blur(radius: 4, opaque: true))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .edgesIgnoringSafeArea(.top)
            .zIndex(1)
            
            VStack {
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            GeometryReader { innerGeometry in
                                Text("Categories:")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30, design: .rounded))
                                    .fontWeight(.bold)
                                    .padding([.leading], 20)
                                    .padding([.top], prop.size.height / 2.5 > 300 ? 50 : 0)
                                //.frame(maxWidth: .infinity, alignment: .leading)
                                    .onChange(of: innerGeometry.frame(in: .global)) {
                                        checkIfOutOfFrame(innerGeometry: innerGeometry, outerGeometry: geometry)
                                    }
                            }
                        }
                        .padding([.bottom], 40)
                        .opacity(self.show_categories_title ? 0 : 1)
                        
                        VStack {
                            ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                                ZStack {
                                    Image(uiImage: self.categoryImages[key]!)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(.rect(cornerRadius: 25))
                                        .overlay(RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.clear))
                                        .shadow(color: .white, radius: 3.5)
                                    
                                    VStack {
                                        Text(key)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 24, design: .monospaced))
                                            .fontWeight(.heavy)
                                            .padding([.leading], 15)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                            .padding([.top], 25)
                                    }
                                    .frame(maxWidth: prop.size.width - 60, maxHeight: 650)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.EZNotesBlack.opacity(0.45))
                                    )
                                }
                                .frame(maxWidth: prop.size.width - 50, maxHeight: 680)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.padding([.top], 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)*/
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
