//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import PhotosUI

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
    
    @Binding public var showAccountPopup: Bool
    
    var body: some View {
        Button(action: { self.showAccountPopup = true }) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(maxWidth: 30, maxHeight: 30)
                .padding([.leading], 20)
                .foregroundStyle(.white)
        }
        .buttonStyle(NoLongPressButtonStyle())
    }
}

struct AccountPopup: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var launchPhotoGallery: Bool = false
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var photoGalleryLaunchedFor: String = "pfp" /* MARK: Value can be `pfp` or `pfp_bg`. */
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                VStack {
                    PhotosPicker(selection: $pfpPhotoPicked, matching: .images) {
                        accountInfo.profilePicture
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90, alignment: .center)
                            .clipShape(.circle)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(color: .white, radius: 5)
                    }
                    .onChange(of: self.pfpPhotoPicked) {
                        Task {
                            if let image = try? await pfpPhotoPicked!.loadTransferable(type: Image.self) {
                                self.accountInfo.profilePicture = image
                            }
                        }
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: prop.size.width - 150, maxHeight: 250, alignment: .center)
                
                Spacer()
                
                HStack {
                    ZStack {
                        Button(action: { print("Add Custom PFP Background!") }) {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding([.trailing, .bottom], 15)
                }
                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: 265)
            .background(
                Image("Pfp-Default-Bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        Color.EZNotesLightBlack.opacity(0.45)
                    )
                    .blur(radius: 2.5)
            )
            
            VStack {
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.black)
                        .shadow(color: .black, radius: 6.5)
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}

struct TopNavHome: View {
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var showAccountPopup: Bool = false
    @State private var aiChatPopover: Bool = false
    
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
                    ProfileIconView(prop: prop, showAccountPopup: $showAccountPopup)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 50)
                .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
                
                Spacer()
                
                /* TODO: Change the below `Text` to a search bar (`TextField`) where user can search for specific categories.
                 * */
                if self.changeNavbarColor {
                    Text("View Categories")
                        .foregroundStyle(.primary)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.semibold)
                    
                    Text("Total: \(self.categoriesAndSets.count)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                }
                    VStack {
                        if self.showSearchBar {
                            TextField(
                                "Search Categories...",
                                text: $categorySearch
                            )
                            .frame(
                                maxWidth: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : 150,
                                maxHeight: prop.size.height / 2.5 > 300 ? 25 : 20
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
                                    
                                    if self.categorySearchFocus || self.categorySearch != "" {
                                        Button(action: {
                                            self.categorySearch = ""
                                            self.lookedUpCategoriesAndSets.removeAll()
                                            self.searchDone = false
                                            self.showSearchBar = false
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
                            .onChange(of: categorySearchFocus) {
                                if !self.categorySearchFocus && self.categorySearch == "" { self.showSearchBar = false }
                            }
                            .onTapGesture {
                                self.categorySearchFocus = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top], prop.size.height > 340 ? 55 : 50)
                /*} else {
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
                        .padding([.top], 55)//prop.size.height > 340 ? 55 : 50)
                    }
                }*/
                
                Spacer()
                
                VStack {
                    HStack {
                        //if self.changeNavbarColor && !self.showSearchBar {
                            Button(action: { self.showSearchBar = true }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.EZNotesOrange)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding([.top], 5)
                        //}
                        Button(action: { self.aiChatPopover = true }) {
                            Image("AI-Chat-Icon")
                                .resizable()
                                .frame(
                                    width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                    height: prop.size.height / 2.5 > 300 ? 45 : 40
                                )
                                .padding([.trailing], 20)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
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
        .popover(isPresented: $aiChatPopover) {
            VStack {
                VStack {
                    Text("EZNotes AI Chat")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .font(.system(size: 30, design: .rounded))
                        .shadow(color: .white, radius: 2)
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: 90, alignment: .top)
                .border(width: 0.5, edges: [.bottom], color: .gray)
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
                    .buttonStyle(NoLongPressButtonStyle())
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
                    .buttonStyle(NoLongPressButtonStyle())
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
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var showAccountPopup: Bool = false
    
    @Binding public var section: String
    @Binding public var lastSection: String
    
    @ObservedObject public var images_to_upload: ImagesUploads
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 10)
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
            
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
                    .tint(Color.EZNotesBlue)
                    .opacity(!self.images_to_upload.images_to_upload.isEmpty ? 1 : 0)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 5 : 0)
                    .padding([.trailing], 20)
                    .buttonStyle(NoLongPressButtonStyle())
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
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var showAccountPopup: Bool = false
    
    @Binding public var friendSearch: String
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 10)
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
            
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
                .buttonStyle(NoLongPressButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding([.bottom], 10)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}
