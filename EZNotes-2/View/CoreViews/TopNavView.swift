//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

private extension View {
    func topNavSettings(prop: Properties, backgroundColor: Color) -> some View {
        self
            .frame(
                maxWidth: .infinity,
                maxHeight: prop.size.height / 2.5 > 300 ? 50 : 50
            )
            .background(backgroundColor.opacity(0.1).blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)
    }
}

struct ProfileIconView: View {
    var prop: Properties
    
    var body: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(maxWidth: 30, maxHeight: 30)
            .padding([.leading], 20)
            .foregroundStyle(.white)
    }
}

struct TopNavHome: View {
    
    var prop: Properties
    var backgroundColor: Color
    var categoriesAndSets: [String: Array<String>]
    
    @Binding public var changeNavbarColor: Bool
    @Binding public var navbarOpacity: Double
    @Binding public var categorySearch: String
    @Binding public var searchDone: Bool
    
    @State private var showSearchBar: Bool = false
    @FocusState private var categorySearchFocus: Bool
    
    @Binding public var lookedUpCategoriesAndSets: [String: Array<String>]
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    ProfileIconView(prop: prop)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 50)
                
                Spacer()
                
                /* TODO: Change the below `Text` to a search bar (`TextField`) where user can search for specific categories.
                 * */
                if self.changeNavbarColor {
                    VStack {
                        if !self.showSearchBar {
                            Text("View Categories")
                                .foregroundStyle(.primary)
                                .font(.system(size: 18, design: .rounded))
                                .fontWeight(.semibold)
                            
                            Text("Total: \(self.categoriesAndSets.count)")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.thin)
                        } else {
                            TextField(
                                "Search Categories...",
                                text: $categorySearch,
                                onEditingChanged: { isEditing in
                                    if !isEditing {
                                        self.showSearchBar = false
                                        self.categorySearchFocus = false
                                        return
                                    }
                                }
                            )
                            .frame(
                                maxWidth: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : 200,
                                maxHeight: prop.size.height / 2.5 > 300 ? 30 : 20
                            )
                            .padding([.leading], 15)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray)
                                    .opacity(0.6)
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .cornerRadius(15)
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($categorySearchFocus)
                            .onAppear { self.categorySearchFocus = true }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top], prop.size.height > 340 ? 55 : 50)
                } else {
                    if self.categoriesAndSets.count > 0 {
                        VStack {
                            TextField(
                                "Search Categories...",
                                text: $categorySearch
                            )
                            .frame(
                                maxWidth: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                                : 200,
                                maxHeight: prop.size.height / 2.5 > 300 ? 30 : 20
                            )
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                            .cornerRadius(7.5)
                            .padding(.horizontal, 10)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                    
                                    if self.categorySearchFocus {
                                        Button(action: {
                                            self.categorySearch = ""
                                            self.lookedUpCategoriesAndSets.removeAll()
                                            self.searchDone = false
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 15)
                                        }
                                    }
                                }
                            )
                            .onSubmit {
                                if !(self.categorySearch == "") {
                                    self.lookedUpCategoriesAndSets.removeAll()
                                    
                                    for (_, value) in self.categoriesAndSets.keys.enumerated() {
                                        if value.lowercased() == self.categorySearch.lowercased() || value.lowercased().contains(self.categorySearch.lowercased()) {
                                            self.lookedUpCategoriesAndSets[value] = self.categoriesAndSets[value]
                                            
                                            print(self.lookedUpCategoriesAndSets)
                                        }
                                    }
                                    
                                    self.searchDone = true
                                } else {
                                    self.lookedUpCategoriesAndSets.removeAll()
                                    self.searchDone = false
                                }
                                
                                self.categorySearchFocus = false
                            }
                            .focused($categorySearchFocus)
                            .onTapGesture {
                                self.categorySearchFocus = true
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 25, alignment: .center)
                        .padding([.top], 60)//prop.size.height > 340 ? 55 : 50)
                    }
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        if self.changeNavbarColor && !self.showSearchBar {
                            Button(action: { self.showSearchBar = true }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .tint(Color.EZNotesOrange)
                            }
                            .buttonStyle(.borderless)
                            .padding([.top], 5)
                        }
                        Button(action: { print("POPUP!") }) {
                            Image("AI-Chat-Icon")
                                .resizable()
                                .frame(
                                    width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                    height: prop.size.height / 2.5 > 300 ? 45 : 40
                                )
                                .padding([.trailing], 20)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .frame(maxWidth: 50, alignment: .trailing)
                .padding([.top], 50)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
            .background(!self.changeNavbarColor
                        ? AnyView(Color.black)
                        : AnyView(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).opacity(navbarOpacity))
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard)
        .zIndex(1)
    }
}

struct TopNavCategoryView: View {
    
    var prop: Properties
    var categoryName: String
    var totalSets: Int
    
    @Binding public var launchCategory: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: { self.launchCategory = false }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .tint(Color.EZNotesBlue)
                    }
                    .padding([.leading], 20)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 45)
                
                Spacer()
                
                VStack {
                    Text(categoryName)
                        .foregroundStyle(.primary)
                        .font(.system(size: 22, design: .rounded))
                        .fontWeight(.thin)
                    
                    Text("Sets: \(self.totalSets)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top], prop.size.height > 340 ? 50 : 45)
                
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
                    }
                    .buttonStyle(.borderless)
                }
                .frame(maxWidth: 50, alignment: .trailing)
                .padding([.top], 45)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
            .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .zIndex(1)
    }
}

struct TopNavUpload: View {
    
    @Binding public var section: String
    @Binding public var lastSection: String
    
    @ObservedObject public var images_to_upload: ImagesUploads
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop)
            }
            .padding([.bottom], 10)
            
            Spacer()
            
            VStack {
                VStack {
                    Button(action: {
                        self.lastSection = self.section
                        self.section = "upload_review"
                    }) {
                        Text("Review")
                            .padding(5)
                            .foregroundStyle(.white)
                            .frame(width: 75, height: 20)
                    }
                    .padding([.top], prop.size.height / 2.5 > 300 ? 5 : 0)
                    .padding([.trailing], 20)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesBlue)
                    .opacity(!self.images_to_upload.images_to_upload.isEmpty ? 1 : 0)
                    
                }
                .frame(width: 200, height: 40, alignment: .topTrailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(.clear)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}

struct TopNavChat: View {
    
    @Binding public var friendSearch: String
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop)
            }
            .padding([.bottom], 10)
            
            Spacer()
            
            VStack {
                Button(action: { print("Adding Friend!") }) {
                    Image("Add-Friend-Icon")
                        .resizable()
                        .frame(maxWidth: 25, maxHeight: 25)
                        .foregroundStyle(.white)
                    
                    Text("Add Friend")
                        .padding([.trailing], 20)
                        .foregroundStyle(.white)
                        .font(.system(size: 12, design: .rounded))
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderless)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding([.bottom], 10)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}
