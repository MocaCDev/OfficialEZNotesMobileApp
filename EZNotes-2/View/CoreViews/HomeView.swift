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
    
    var prop: Properties
    
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
        VStack {
            ZStack {
                VStack {
                    HStack {
                        VStack {
                            ProfileIconView(prop: prop)
                                //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                        }
                        .frame(maxWidth: 50, alignment: .leading)
                        .padding([.top], 45)//.padding([.bottom], 10)
                        
                        if self.show_categories_title {
                            Spacer()
                            
                            VStack {
                                Text("Categories")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 35, design: .rounded))
                                    .fontWeight(.medium)
                                    //.padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
                                    //.padding([.bottom], -5)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding([.top], 45)//.padding([.bottom], 10)
                        }
                        
                        Spacer()
                        
                        /* TODO: Change the below `Text` to a search bar (`TextField`) where user can search for specific categories.
                         * */
                        VStack {
                            Text("View Categories")
                                .foregroundStyle(.white)
                                .font(.system(size: 22, design: .rounded))
                                .fontWeight(.thin)
                            
                            Text("Total: \(self.categoriesAndSets.count)")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.thin)
                            //.padding([.top], prop.size.height / 2.5 > 300 ? 40 : 5)
                            //.padding([.bottom], -5)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.top], 45)
                        
                        Spacer()
                        
                        VStack {
                            Button(action: { print("POPUP!") }) {
                                Image("AI-Chat-Icon")
                                    .resizable()
                                    .frame(
                                        width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                        height: prop.size.height / 2.5 > 300 ? 45 : 40
                                    )
                                    .padding([.trailing], 20)
                                    //.padding([.top], prop.size.height / 2.5 > 300 ? 45 : 15)
                            }
                            .buttonStyle(.borderless)
                        }
                        .frame(maxWidth: 50, alignment: .trailing)
                        .padding([.top], 45)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
                    .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))//(.ultraThinMaterial, in: Color.EZNotesBlack)//.background(Color.clear.blur(radius: 4, opaque: true))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .edgesIgnoringSafeArea(.top)
                .zIndex(1)//TopNavHome(prop: prop, backgroundColor: Color.EZNotesLightBlack, show_categories_title: $show_categories_title)
                
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
                                
                                VStack {
                                    ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                                        ZStack {
                                            Image(uiImage: self.categoryImages[key]!)
                                                .resizable()
                                                .frame(width: prop.size.width - 20, height: 500)
                                                .scaledToFill()//.scaledToFit()
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
                                            .frame(width: prop.size.width - 50, height: 450)//(maxWidth: prop.size.width - 50, maxHeight: 480)
                                            .background(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(Color.EZNotesBlack.opacity(0.45))
                                            )
                                        }
                                        .frame(width: prop.size.width - 50, height: 450)
                                        //(maxWidth: prop.size.width - 50, maxHeight: 480)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding([.top], 90)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Text("No Categories")
                            .foregroundStyle(.white)
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
