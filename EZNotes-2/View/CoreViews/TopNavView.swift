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
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    var body: some View {
        Button(action: { self.showAccountPopup = true }) {
            /*Image(systemName: "person.crop.circle.fill")*/
            self.accountInfo.profilePicture
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 30, maxHeight: 30)
                .clipShape(.circle)
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
    @State private var newUsername: String = ""
    @State private var updateUsername: Bool = false
    @State private var pfpUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                if self.pfpUploadStatus == "failed" {
                    HStack {
                        ZStack {
                            
                        }
                        .frame(maxWidth: 25, alignment: .leading)
                        
                        Text("Error saving PFP. Try Again.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                            .font(.system(size: 12))
                            .minimumScaleFactor(0.5)
                        
                        ZStack {
                            Button(action: { self.pfpUploadStatus = "none" }) {
                                Image(systemName: "multiply")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: 25, alignment: .trailing)
                        .padding(.trailing, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .background(Color.EZNotesRed)
                } else {
                    if self.pfpUploadStatus != "none" { /* MARK: We will assume if it isn't `none` and it isn't `failed` it is `good`. */
                        HStack {
                            ZStack {
                                
                            }
                            .frame(maxWidth: 25, alignment: .leading)
                            
                            Text("Updated PFP")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                                .font(.system(size: 12))
                                .minimumScaleFactor(0.5)
                            
                            ZStack {
                                Button(action: { self.pfpUploadStatus = "none" }) {
                                    Image(systemName: "multiply")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                            .frame(maxWidth: 25, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .background(Color.EZNotesGreen)
                    }
                }
                //Spacer()
                
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                ZStack {
                                    PhotosPicker(selection: $pfpPhotoPicked, matching: .images) {
                                        accountInfo.profilePicture
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: prop.size.height / 2.5 > 300 ? 90 : 80, height: prop.size.height / 2.5 > 300 ? 90 : 80, alignment: .center)
                                            .minimumScaleFactor(0.8)
                                            .foregroundStyle(.white)
                                            .clipShape(.rect)
                                            .cornerRadius(15)
                                            .shadow(color: .black, radius: 2.5)
                                    }
                                    .onChange(of: self.pfpPhotoPicked) {
                                        Task {
                                            if let image = try? await pfpPhotoPicked!.loadTransferable(type: Image.self) {
                                                self.accountInfo.profilePicture = image
                                                PFP(pfp: image, accountID: self.accountInfo.accountID)
                                                    .requestSavePFP() { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            self.pfpUploadStatus = "failed"
                                                            return
                                                        }
                                                        
                                                        if self.errorUploadingPFP { self.errorUploadingPFP = false }
                                                        self.pfpUploadStatus = "good"
                                                    }
                                            }
                                        }
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .padding(.leading, 15)
                                .padding([.top, .bottom])
                                
                                VStack {
                                    HStack {
                                        Text("\(self.accountInfo.username)")
                                            //.frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20, design: .rounded))
                                            .fontWeight(.semibold)
                                        
                                        Divider()
                                            .frame(alignment: .leading)
                                        
                                        Text("0 Friends")
                                            .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                    
                                    Text(self.accountInfo.email)
                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 14, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.medium)
                                    
                                    Text("Penn State University")
                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 14, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.light)
                                }
                                .padding(.leading, 5)
                            }
                            
                            HStack {
                                ZStack {
                                    PhotosPicker(selection: $pfpPhotoPicked, matching: .images) {
                                        Text("Change PFP")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding()
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                    }
                                    .onChange(of: self.pfpPhotoPicked) {
                                        Task {
                                            if let image = try? await pfpPhotoPicked!.loadTransferable(type: Image.self) {
                                                self.accountInfo.profilePicture = image
                                                PFP(pfp: image, accountID: self.accountInfo.accountID)
                                                    .requestSavePFP() { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            self.pfpUploadStatus = "failed"
                                                            return
                                                        }
                                                        
                                                        if self.errorUploadingPFP { self.errorUploadingPFP = false }
                                                        self.pfpUploadStatus = "good"
                                                    }
                                            }
                                        }
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.gray.opacity(0.65))
                                        .stroke(.white, lineWidth: 1)
                                )
                                
                                ZStack {
                                    PhotosPicker(selection: $pfpBackgroundPhotoPicked) {
                                        Text("Change Display")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding()
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                    }
                                    .onChange(of: self.pfpBackgroundPhotoPicked) {
                                        Task {
                                            if let image = try? await pfpBackgroundPhotoPicked!.loadTransferable(type: Image.self) {
                                                self.accountInfo.profileBackgroundPicture = image
                                                
                                                PFP(pfpBg: image, accountID: self.accountInfo.accountID)
                                                    .requestSavePFPBg() { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else { return }
                                                        
                                                        print(resp!)
                                                    }
                                            }
                                        }
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.gray.opacity(0.65))
                                        .stroke(.white, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: 30)
                            .padding(.leading, -10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 180, alignment: .bottomLeading)
                    .padding(.leading, 10)
                    .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: 235)
            .background(
                accountInfo.profileBackgroundPicture
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .overlay(Color.EZNotesBlack.opacity(0.35))
                    .blur(radius: 2.5)
            )
            .padding([.bottom], -10)
            
            VStack {
                VStack {
                    Text("Account Details")
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .foregroundStyle(.white)
                        .padding([.top], 15)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Divider()
                        .frame(width: prop.size.width - 50)
                    
                    VStack {
                        VStack { }.frame(maxWidth: .infinity, maxHeight: 5)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                HStack {
                                    Text("Plan Details")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, design: .rounded))
                                    
                                    ZStack {
                                        Button(action: { print("Show Plan Detail") }) {
                                            Image(systemName: "arrow.forward")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                    .padding(.trailing, 25)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                
                                Divider()
                                    .frame(width: prop.size.width - 80)
                                
                                HStack {
                                    Text("Change Username")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, design: .rounded))
                                    
                                    ZStack {
                                        Button(action: { print("Show Plan Detail") }) {
                                            Image(systemName: "arrow.forward")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                    .padding(.trailing, 25)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                
                                Divider()
                                    .frame(width: prop.size.width - 80)
                                
                                HStack {
                                    Text("Update Password")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, design: .rounded))
                                    
                                    ZStack {
                                        Button(action: { print("Show Plan Detail") }) {
                                            Image(systemName: "arrow.forward")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                    .padding(.trailing, 25)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                
                                Divider()
                                    .frame(width: prop.size.width - 80)
                                
                                HStack {
                                    Text("Change Schools")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, design: .rounded))
                                    
                                    ZStack {
                                        Button(action: { print("Show Plan Detail") }) {
                                            Image(systemName: "arrow.forward")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                    .padding(.trailing, 25)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom], 18)
                            .padding([.leading, .trailing], 8)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesLightBlack)
                                    .stroke(LinearGradient(gradient: Gradient(
                                        colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                    ), startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                            )
                            .cornerRadius(15)
                            
                            /* MARK: Custom `spacer`. Scrollview makes all the views within it kind of funky. */
                            VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                            
                            VStack {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "gearshape.fill")
                                                .resizable()
                                                .frame(width: 35, height: 35, alignment: .topTrailing)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 35, alignment: .topTrailing)
                                        
                                        Text("Settings")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20, design: .rounded))
                                            .fontWeight(.heavy)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.EZNotesOrange.gradient)
                                    .cornerRadius(15)
                                    
                                    VStack {
                                        ZStack {
                                            Image(systemName: "dollarsign.bank.building")
                                                .resizable()
                                                .frame(width: 35, height: 35, alignment: .topTrailing)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 35, alignment: .topTrailing)
                                        
                                        Text("Billing")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20, design: .rounded))
                                            .fontWeight(.heavy)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                    .padding()
                                    .background(Color.EZNotesGreen.gradient)
                                    .cornerRadius(15)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 140)
                                
                                VStack {
                                    ZStack {
                                        Image(systemName: "macwindow.on.rectangle")
                                            .resizable()
                                            .frame(width: 35, height: 35, alignment: .topTrailing)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 35, alignment: .topTrailing)
                                    
                                    Text("Themes")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 20, design: .rounded))
                                        .fontWeight(.heavy)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 140)
                                .padding()
                                .background(
                                    Color.EZNotesBlue.gradient
                                )
                                .cornerRadius(15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            Divider()
                                .padding([.top, .bottom], 10)
                            
                            /* MARK: More details will show the user their account ID, session ID etc. */
                            HStack {
                                Text("More Details")
                                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                ZStack {
                                    Button(action: { print("View More Account Details") }) {
                                        Image(systemName: "arrow.forward")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: prop.size.height / 2.5 > 300 ? 55 : 45)
                            .background(Color.EZNotesLightBlack)
                            .cornerRadius(15)
                            .onTapGesture {
                                print("Show more account details")
                            }
                            
                            HStack {
                                Text("Report An Issue")
                                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                ZStack {
                                    Button(action: { print("Report An Issue") }) {
                                        Image(systemName: "arrow.forward")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: prop.size.height / 2.5 > 300 ? 55 : 45)
                            .background(Color.EZNotesLightBlack)
                            .cornerRadius(15)
                            .onTapGesture {
                                print("Report An Issue")
                            }
                            
                            Divider()
                                .frame(width: prop.size.width - 140)
                                .padding([.top, .bottom])
                            
                            HStack {
                                Text("Logout")
                                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                    .padding(.leading, 15)
                                    .padding([.top, .bottom])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                ZStack {
                                    Button(action: {
                                        UserDefaults.standard.set(false, forKey: "logged_in")
                                    }) {
                                        Image(systemName: "door.left.hand.open")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: prop.size.height / 2.5 > 300 ? 55 : 45)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesLightBlack)
                                    .stroke(.red, lineWidth: 1)
                            )
                            .cornerRadius(15)
                            .onTapGesture {
                                print("Report An Issue")
                            }
                            
                            Text("Joined 10/10/2024")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 40)
                                .foregroundStyle(.white)
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: prop.size.width - 50, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Rectangle()
                        .fill(Color.EZNotesBlack)
                        .cornerRadius(15, corners: prop.size.height / 2.5 > 300 ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.topLeft, .topRight])
                        .shadow(color: .black, radius: 6.5)
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            //.frame(maxWidth: 90,  alignment: .leading)
            .padding(.top, prop.size.height / 2.5 > 300 ? 50 : 15) /* MARK: Aligns icon for larger screens. */
            //.padding(.bottom, prop.size.height / 2.5 > 300 ? 0 : 10) /* MARK: Aligns icon for smaller screens. */
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
            
            Spacer()
            
            if self.showSearchBar {
                VStack {
                    TextField(
                        "Search Categories...",
                        text: $categorySearch
                    )
                    .onAppear(perform: { print(prop.size.height / 2.5) })
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
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top], prop.size.height > 340 ? 50 : 45)
            } else {
                if self.changeNavbarColor {
                    VStack {
                        Text("View Categories")
                            .foregroundStyle(.primary)
                            .font(.system(size: 18, design: .rounded))
                            .fontWeight(.semibold)
                        
                        Text("Total: \(self.categoriesAndSets.count)")
                            .foregroundStyle(.white)
                            .font(.system(size: 14, design: .rounded))
                            .fontWeight(.thin)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.top, prop.size.height > 340 ? 55 : 50)
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: { self.showSearchBar.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.EZNotesOrange)
                }
                .buttonStyle(NoLongPressButtonStyle())
                //.padding([.top], 5)
                
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
            .frame(maxWidth: 90, maxHeight: .infinity, alignment: .trailing)
            .padding(.top, prop.size.height / 2.5 > 300 ? 55 : 0)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2.5 > 300 ? 115 : 65, alignment: .top)
        .padding(.top, 5)
        .background(
            !self.changeNavbarColor
                ? AnyView(Color.clear)
                : AnyView(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).opacity(navbarOpacity))
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .zIndex(1) /* MARK: The navbar will always exist on top of content. This enables content under the navbar to scroll "under" it. */
        .onTapGesture {
            if self.showSearchBar { self.showSearchBar = false }
        }
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
        /*VStack {
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
                if self.showSearchBar {
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
                            : 150,
                            maxHeight: prop.size.height / 2.5 > 300 ? 20 : 20
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top], prop.size.height > 340 ? 55 : 45)
                } else {
                    if self.changeNavbarColor {
                        VStack {
                            Text("View Categories")
                                .foregroundStyle(.primary)
                                .font(.system(size: 18, design: .rounded))
                                .fontWeight(.semibold)
                            
                            Text("Total: \(self.categoriesAndSets.count)")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.thin)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, prop.size.height > 340 ? 55 : 50)
                    }
                }
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
        }*/
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
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
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
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 10)
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
            
            Spacer()
            
            HStack {
                Text("Add Friend")
                    .foregroundStyle(.white)
                    .font(.system(size: 12.5, design: .rounded))
                    .fontWeight(.bold)
                
                Button(action: { print("Adding Friend!") }) {
                    Image(systemName: "person.badge.plus")//Image("Add-Friend-Icon")
                        .resizable()
                        .frame(maxWidth: 30, maxHeight: 30)
                        .foregroundStyle(Color.EZNotesBlue)
                }
                .buttonStyle(NoLongPressButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}
