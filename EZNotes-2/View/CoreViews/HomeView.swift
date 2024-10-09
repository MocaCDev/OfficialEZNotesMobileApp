//
//  HomeView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

struct HomeView: View {
    @Binding public var section: String
    @ObservedObject public var images_to_upload: ImagesUploads
    var categoriesAndSets: [String: Array<String>]
    var categoryImages: [String: UIImage]
    
    @State private var home_section: String = "main"
    @State private var show_categories_title: Bool = false
    
    @State private var launchCategory: Bool = false
    @State private var categoryLaunched: String = ""
    @State private var categoryBackground: UIImage = UIImage(systemName: "arrow.left")! /* TODO: Figure out how to initialize a UIImage variable. */
    
    var prop: Properties
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY - 30 || textFrame.minY > scrollViewFrame.maxY {
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
                        categoriesAndSets: categoriesAndSets
                    )
                    
                    if self.categoriesAndSets.count > 0 {
                        VStack {
                            GeometryReader { geometry in
                                ScrollView(showsIndicators: false) {
                                    /*VStack {
                                     GeometryReader { innerGeometry in
                                     Text("Categories:")
                                     .foregroundStyle(.white)
                                     .font(.system(size: 30, design: .monospaced))
                                     .fontWeight(.bold)
                                     .padding([.leading], 20)
                                     .padding([.top], prop.size.height / 2.5 > 300 ? -5 : 0)
                                     //.frame(maxWidth: .infinity, alignment: .leading)
                                     .onChange(of: innerGeometry.frame(in: .global)) {
                                     checkIfOutOfFrame(innerGeometry: innerGeometry, outerGeometry: geometry)
                                     }
                                     }
                                     }
                                     .padding([.bottom], 40)
                                     .opacity(self.show_categories_title ? 0 : 1)*/
                                    
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                                            Button(action: {
                                                self.launchCategory = true
                                                self.categoryLaunched = key
                                                self.categoryBackground = self.categoryImages[key]!
                                            }) {
                                                ZStack {
                                                    Image(uiImage: self.categoryImages[key]!)
                                                        .resizable()
                                                        .frame(width: 200, height: 200)
                                                        .scaledToFill()//.scaledToFit()
                                                        .clipShape(.rect(cornerRadius: 25))
                                                        .overlay(RoundedRectangle(cornerRadius: 25)
                                                            .fill(Color.clear))
                                                        .shadow(color: .white, radius: 3.5)
                                                    
                                                    VStack {
                                                        /*VStack {
                                                         Button(action: { print("Open Menu") }) {
                                                         Image(systemName: "ellipsis")
                                                         .resizable()
                                                         .frame(maxWidth: 25, maxHeight: 5)
                                                         .foregroundStyle(.white)
                                                         .rotationEffect(.degrees(90))
                                                         }
                                                         .buttonStyle(.borderless)
                                                         .tint(Color.clear)
                                                         }
                                                         .frame(maxWidth: .infinity, maxHeight: 40, alignment: .topLeading)
                                                         .padding([.top], 25)
                                                         .padding([.leading], 5)*/
                                                        
                                                        VStack {
                                                            Text(key)
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 20, design: .rounded))
                                                            //.minimumScaleFactor(0.4)
                                                                .fontWeight(.bold)
                                                            //.padding([.leading], 15)
                                                                .multilineTextAlignment(.center)
                                                                .frame(maxWidth: .infinity, maxHeight: 35, alignment: .center)
                                                                .padding([.top], -15)
                                                            
                                                            Text("Sets: \(self.categoriesAndSets[key]!.count)")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 16, design: .rounded))
                                                            //.minimumScaleFactor(0.01)
                                                                .fontWeight(.medium)
                                                            //.padding([.leading], 15)
                                                                .multilineTextAlignment(.center)
                                                                .frame(maxWidth: .infinity, maxHeight: 35)
                                                            
                                                            Text("Created 04/20/2024")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 13, design: .rounded))
                                                                .fontWeight(.light)
                                                            //.padding([.leading], 15)
                                                                .multilineTextAlignment(.center)
                                                                .frame(maxWidth: .infinity, maxHeight: 35)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        
                                                        /*VStack {
                                                         HStack {
                                                         Button(action: { print("Launch Category!") }) {
                                                         Text("Launch")
                                                         .foregroundStyle(.white)
                                                         .font(.system(size: 18, design: .monospaced))
                                                         .fontWeight(.bold)
                                                         .frame(maxWidth: prop.size.width - 60)
                                                         //.padding([.top, .bottom], 5)
                                                         }
                                                         .buttonStyle(.borderedProminent)
                                                         .tint(Color.gray.opacity(0.4))
                                                         .overlay(
                                                         RoundedRectangle(cornerRadius: 15)
                                                         .stroke(.white, lineWidth: 3)
                                                         )
                                                         }
                                                         .frame(maxWidth: 150, maxHeight: 20)
                                                         }
                                                         .frame(maxWidth: .infinity, maxHeight: 20, alignment: .bottom)
                                                         .background(Color.clear)
                                                         .padding([.bottom], 20)*/
                                                    }
                                                    .frame(width: 200, height: 200)//(width: prop.size.width - 20, height: prop.size.height - 170)//(maxWidth: prop.size.width - 50, maxHeight: 480)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .fill(Color.EZNotesBlack.opacity(0.45))
                                                    )
                                                }
                                                .frame(width: 220, height: 200)//(width: prop.size.width - 20, height: prop.size.height - 170)
                                            }
                                            .buttonStyle(.borderless)
                                            //(maxWidth: prop.size.width - 50, maxHeight: 480)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding([.top], 65)
                                    .padding([.bottom], 10)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                Image("Background12")
                    .overlay(Color.EZNotesBlack.opacity(0.4))
                    .blur(radius: 6.5)
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
