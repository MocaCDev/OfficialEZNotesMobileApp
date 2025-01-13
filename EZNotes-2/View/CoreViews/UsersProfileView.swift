//
//  UsersProfileView.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/12/24.
//

/* MARK: This file is used to show the users pfp bg, pfp, username and # of friends. */
import SwiftUI
import PhotosUI
import Combine

struct UsersProfile: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    
    var prop: Properties
    var username: String = ""
    var usersPfpBg: Image = Image(systemName: "person.crop.circle")
    var usersPfp: Image = Image(systemName: "person.crop.circle")
    var usersDescription: String = ""
    var usersTags: Array<String> = []
    var isUserPreview: Bool = true
    var usersFriends: Int = 0
    
    /* MARK: All of the below bindings/states are used only if `isUserPreview` is false. */
    @Binding public var accountPopupSection: String
    @Binding public var showAccount: Bool
    @Binding public var addMoreTags: Bool
    @Binding public var accountViewY: CGFloat
    @Binding public var accountViewOpacity: CGFloat
    
    @State private var addTag: Bool = false
    @State private var addTagButtonRotationDegrees: CGFloat = 0
    @State private var newTagName: String = ""
    @FocusState private var newTagFieldInFocus: Bool
    
    @State private var pfpUploadStatus: String = "none"
    @State private var pfpBgUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    @State private var errorUploadingPFPBg: Bool = false
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var changingProfilePic: Bool = false
    @State private var editDescription: Bool = false
    @FocusState private var newAccountDescriptionFieldInFocus: Bool
    @State private var accountDescription: String = "No Description"
    @State private var newAccountDescription: String = ""
    
    /* MARK: Animation for the status bar the prompts whether or not the change of display or PFP was a success. */
    @State private var statusBarYOffset: CGFloat = 0
    
    @State private var tagHasBeenPressed: Bool = false
    @State private var tagThatHasBeenPressed: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                if !self.isUserPreview {
                    if self.accountPopupSection == "main" {
                        self.accountInfo.profileBackgroundPicture
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: prop.isLargerScreen ? 135 : 115)
                        //.aspectRatio(contentMode: .fill)
                            .clipped()
                            .overlay(Color.EZNotesBlack.opacity(0.3))
                    } else { Color.black }
                    
                    if self.accountPopupSection == "main" {
                        if self.pfpUploadStatus == "failed" || self.pfpBgUploadStatus == "failed" {
                            HStack {
                                ZStack {
                                    
                                }
                                .frame(maxWidth: 25, alignment: .leading)
                                
                                if self.errorUploadingPFP {
                                    VStack {
                                        Spacer()
                                        
                                        Text("Error saving PFP. Try Again.")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        //.padding(.top, 8)
                                            .foregroundStyle(.black)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .padding(.bottom, 4)
                                    }
                                } else {
                                    VStack {
                                        Spacer()
                                        
                                        Text("Error saving PFP Background. Try Again.")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        //.padding(.top, 8)
                                            .foregroundStyle(.black)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .padding(.bottom, 4)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(Color.EZNotesRed.opacity(0.8))
                            .offset(y: self.statusBarYOffset)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation(.easeOut(duration: 3)) {
                                        self.statusBarYOffset = -prop.size.height //-UIScreen.main.bounds.height
                                    }
                                    
                                    /* MARK: Wait another second and ensure the status bar view is invisible. */
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if self.pfpUploadStatus != "none" { self.pfpUploadStatus = "none"; return }
                                        self.pfpBgUploadStatus = "none"
                                    }
                                }
                            }
                        } else {
                            if self.pfpUploadStatus != "none" || self.pfpBgUploadStatus != "none" { /* MARK: We will assume if it isn't `none` and it isn't `failed` it is `good`. */
                                HStack {
                                    ZStack { }.frame(maxWidth: 25, alignment: .leading)
                                    
                                    if self.pfpUploadStatus == "good" {
                                        VStack {
                                            Spacer()
                                            
                                            Text("Updated PFP")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            //.padding(.top, 8)
                                                .foregroundStyle(.black)
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .minimumScaleFactor(0.5)
                                                .padding(.bottom, 4)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                            
                                            Text("Updated PFP Background")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            ///.padding(.top, 8)
                                                .foregroundStyle(.black)
                                                .font(Font.custom("Poppins-Regular", size: 16))//.setFontSizeAndWeight(weight: .medium)
                                                .minimumScaleFactor(0.5)
                                                .padding(.bottom, 4)
                                        }
                                    }
                                    
                                    ZStack { }.frame(maxWidth: 25, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 55)
                                .background(Color.EZNotesGreen.opacity(0.8))
                                .offset(y: self.statusBarYOffset)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.easeOut(duration: 3)) {
                                            self.statusBarYOffset = -prop.size.height //-UIScreen.main.bounds.height
                                        }
                                        
                                        /* MARK: Wait another second and ensure the status bar view is invisible. */
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            if self.pfpUploadStatus != "none" { self.pfpUploadStatus = "none"; return }
                                            self.pfpBgUploadStatus = "none"
                                        }
                                    }
                                }
                            } else {
                                HStack {
                                    Button(action: {
                                        withAnimation(.smooth(duration: 0.55)) {
                                            self.accountViewY = UIScreen.main.bounds.height
                                            self.accountViewOpacity = 0
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.53) {
                                            self.showAccount = false
                                        }
                                    }) {
                                        ZStack {
                                            Image(systemName: "multiply")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: 20, alignment: .leading)
                                        .padding(.top, prop.isLargerScreen ? 30 : 5)
                                        .padding(.leading, 25)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    ZStack {
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                } else {
                    self.usersPfpBg
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: prop.isLargerScreen ? 95 : 75)
                    //.aspectRatio(contentMode: .fill)
                        .clipped()
                        .overlay(Color.EZNotesBlack.opacity(0.3))
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                }
            }
            .frame(maxWidth: prop.size.width, maxHeight: !self.isUserPreview
                   ? self.accountPopupSection != "main"
                   ? 15
                   : 100
                   : 80
            )
            
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.EZNotesBlue, Color.EZNotesBlack], startPoint: .top, endPoint: .bottom))
                    
                    if self.isUserPreview {
                        self.usersPfp
                            .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                            .scaledToFill()
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(.circle)
                    } else {
                        self.accountInfo.profilePicture
                            .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                            .scaledToFill()
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(.circle)
                    }
                }
                .frame(width: 75, height: 75, alignment: .leading)
                .padding(.leading, 20)
                .zIndex(1)
                
                if !self.isUserPreview {
                    HStack {
                        ZStack {
                            PhotosPicker(selection: $pfpPhotoPicked, matching: .images) {
                                Text("Change PFP")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding([.top, .bottom], 6)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .medium, size: 14)
                            }
                            .onChange(of: self.pfpPhotoPicked) {
                                Task {
                                    if let image = try? await pfpPhotoPicked!.loadTransferable(type: Image.self) {
                                        self.changingProfilePic = true
                                        
                                        PFP(pfp: image, pfpBg: nil, accountID: self.accountInfo.accountID)
                                            .requestSavePFP() { statusCode, resp in
                                                self.changingProfilePic = false
                                                
                                                /* MARK: Reset the y-offset of the status bar at the top of the popup to ensure the "banner" actually shows. */
                                                self.statusBarYOffset = 0
                                                
                                                guard resp != nil && statusCode == 200 else {
                                                    self.pfpUploadStatus = "failed"
                                                    return
                                                }
                                                
                                                self.accountInfo.profilePicture = image
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
                                .fill(.clear)
                                .stroke(.white, lineWidth: 1)
                        )
                        .padding(.leading, 15)
                        
                        ZStack {
                            PhotosPicker(selection: $pfpBackgroundPhotoPicked) {
                                Text("Change Display")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding([.top, .bottom], 6)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .medium, size: 14)
                            }
                            .onChange(of: self.pfpBackgroundPhotoPicked) {
                                Task {
                                    if let image = try? await pfpBackgroundPhotoPicked!.loadTransferable(type: Image.self) {
                                        PFP(pfp: nil, pfpBg: image, accountID: self.accountInfo.accountID)
                                            .requestSavePFPBg() { statusCode, resp in
                                                /* MARK: Reset the y-offset of the status bar at the top of the popup to ensure the "banner" actually shows. */
                                                self.statusBarYOffset = 0
                                                
                                                guard resp != nil && statusCode == 200 else {
                                                    self.pfpBgUploadStatus = "failed"
                                                    //self.errorUploadingPFPBg = true
                                                    return
                                                }
                                                
                                                //if self.errorUploadingPFPBg { self.errorUploadingPFPBg = false }
                                                self.pfpBgUploadStatus = "good"
                                                
                                                self.accountInfo.profileBackgroundPicture = image
                                            }
                                    }
                                }
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .stroke(.white, lineWidth: 1)
                        )
                        .padding(.trailing, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 30)
                    .padding(.leading, -15)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, self.isUserPreview ? -30 : -20)
            
            HStack {
                Text(self.isUserPreview ? username : self.accountInfo.username)
                    .frame(alignment: .leading)
                    .padding(.leading, 20)
                    .foregroundStyle(.white)
                    .font(.system(size: prop.isLargerScreen ? 30 : 24))//(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 22))
                
                Divider()
                    .background(.white)
                    .frame(width: 1)
                    .padding(.top, 5)
                
                Text(self.isUserPreview ? "\(self.usersFriends) Friends" : "\(self.accountInfo.friends.count) Friend\(self.accountInfo.friends.count > 1 ? "s" : "")")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
                    .font(.system(size: prop.isLargerScreen ? 20 : 16, weight: .light))
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, maxHeight: 20)
            .padding(.top, 10)
            
            if self.isUserPreview {
                Text(self.usersDescription)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    .foregroundStyle(.white)
                    .font(Font.custom("Poppins-Regular", size: 12))
                    .multilineTextAlignment(.leading)
            } else {
                Text(self.accountInfo.email)
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    .foregroundStyle(.white)
                    .setFontSizeAndWeight(weight: .medium, size: 14)
                
                HStack {
                    /* MARK: Is the below if statement really needed? */
                    if self.accountInfo.usage == "school" {
                        if !self.editDescription {
                            if self.accountInfo.accountDescription == "" {
                                Button(action: {
                                    self.editDescription = true
                                    self.newAccountDescriptionFieldInFocus = true
                                }) {
                                    Text("Add Description")
                                        .frame(maxWidth: 200, alignment: .center)
                                        .padding(.vertical, 5)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                                .strokeBorder(.white, lineWidth: 1)
                                        )
                                        .padding(.top, 10)
                                        .padding(.leading, 20)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            } else {
                                Text(self.accountInfo.accountDescription)//("Majoring in **\(self.accountInfo.major)** at **\(self.accountInfo.college)**")
                                    .frame(alignment: .leading)
                                    .padding(.leading, 20)
                                    .padding(.top, 10)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: 12))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                    .onTapGesture {
                                        self.editDescription = true
                                        self.newAccountDescriptionFieldInFocus = true
                                    }
                            }
                        } else {
                            VStack {
                                TextField(
                                    "",
                                    text: $newAccountDescription,
                                    axis: .vertical
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2...4)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .padding(.bottom, 10)//.padding(10)
                                //.background(Color.EZNotesLightBlack)//(Color(.systemGray6))
                                //.cornerRadius(15)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .focused($newAccountDescriptionFieldInFocus)
                                .overlay(
                                    VStack {
                                        if !self.newAccountDescriptionFieldInFocus && self.newAccountDescription.isEmpty {
                                            Text(self.accountInfo.accountDescription)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 20)
                                                .padding(.bottom, 25)
                                                .font(Font.custom("Poppins-Regular", size: 12))
                                                .foregroundStyle(.white)
                                        } else {
                                            if self.newAccountDescription.isEmpty {
                                                Text(self.accountInfo.accountDescription)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 20)
                                                    .padding(.bottom, 25)
                                                    .font(Font.custom("Poppins-Regular", size: 12))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                )
                                .onChange(of: self.newAccountDescription) {
                                    if self.newAccountDescription.count > 80 {
                                        self.newAccountDescription = String(self.newAccountDescription.prefix(80))
                                    }
                                }
                                
                                Text("\(self.newAccountDescription.count) out of 80 characters")
                                    .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                                    .padding([.leading], 20)
                                    .foregroundStyle(
                                        self.newAccountDescription.count < 80
                                        ? self.newAccountDescription.count > 70 && self.newAccountDescription.count < 80
                                        ? .yellow
                                        : Color.gray
                                        : .red
                                    )
                                    .font(.system(size: 10, design: .rounded))
                                    .fontWeight(.medium)
                                    .padding(.bottom, 15)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 15)
                        }
                    } else {
                        if !self.editDescription {
                            if self.accountInfo.accountDescription == "" {
                                Text("Add Description")
                                    .frame(maxWidth: 200, alignment: .center)
                                    .padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                            .strokeBorder(.white, lineWidth: 1)
                                    )
                                    .padding(.top, 10)
                                    .padding(.leading, 20)
                            } else {
                                Text(self.accountInfo.accountDescription)
                                    .frame(alignment: .leading)
                                    .padding(.leading, 20)
                                    .padding(.top, 10)
                                    .foregroundStyle(self.accountInfo.accountDescription == "No Description" ? .gray : .white)
                                    .font(Font.custom("Poppins-Regular", size: 12))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                                    .onTapGesture {
                                        self.editDescription = true
                                        self.newAccountDescriptionFieldInFocus = true
                                    }
                            }
                        } else {
                            VStack {
                                TextField(
                                    "",
                                    text: $newAccountDescription,
                                    axis: .vertical
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2...4)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .padding(.bottom, 10)//.padding(10)
                                //.background(Color.EZNotesLightBlack)//(Color(.systemGray6))
                                //.cornerRadius(15)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .focused($newAccountDescriptionFieldInFocus)
                                .overlay(
                                    VStack {
                                        if !self.newAccountDescriptionFieldInFocus && self.newAccountDescription.isEmpty {
                                            Text(self.accountInfo.accountDescription)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 20)
                                                .padding(.bottom, 10)
                                                .font(Font.custom("Poppins-Regular", size: 12))
                                                .foregroundStyle(.white)
                                        } else {
                                            if self.newAccountDescription.isEmpty {
                                                Text(self.accountInfo.accountDescription)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 20)
                                                    .padding(.bottom, 10)
                                                    .font(Font.custom("Poppins-Regular", size: 12))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                )
                                .onChange(of: self.newAccountDescription) {
                                    if self.newAccountDescription.count > 80 {
                                        self.newAccountDescription = String(self.newAccountDescription.prefix(80))
                                    }
                                }
                                
                                Text("\(self.newAccountDescription.count) out of 80 characters")
                                    .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                                    .padding([.leading], 20)
                                    .foregroundStyle(
                                        self.newAccountDescription.count < 80
                                        ? self.newAccountDescription.count > 70 && self.newAccountDescription.count < 80
                                        ? .yellow
                                        : Color.gray
                                        : .red
                                    )
                                    .font(.system(size: 10, design: .rounded))
                                    .fontWeight(.medium)
                                    .padding(.bottom, 15)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 15)
                        }
                    }
                    
                    if self.editDescription {
                        VStack {
                            Button(action: {
                                if self.newAccountDescription.isEmpty {
                                    self.editDescription = false
                                    self.newAccountDescriptionFieldInFocus = false
                                    return
                                }
                                
                                /* TODO: Add `account_description` to database; add API endpoint to server that will be used to update the `account_description` column for the given user. For now, storing the account description in `UserDefaults` works. */
                                assignUDKey(key: "account_description", value: self.newAccountDescription)
                                
                                //self.accountInfo.accountDescription = self.newAccountDescription
                                
                                RequestAction<SaveAccountDescriptionData>(parameters: SaveAccountDescriptionData(
                                    AccountId: self.accountInfo.accountID,
                                    NewDescription: self.newAccountDescription
                                )).perform(action: save_account_description_req) { statusCode, resp in
                                    self.editDescription = false
                                    
                                    guard resp != nil && statusCode == 200 else {
                                        if let resp = resp { print(resp) }
                                        return /* TODO: Handle error. */
                                    }
                                    
                                    self.accountInfo.accountDescription = self.newAccountDescription
                                    self.newAccountDescription.removeAll()
                                }
                                
                                /*self.accountDescription = self.newAccountDescription
                                 self.newAccountDescription.removeAll()
                                 
                                 self.editDescription = false*/
                            }) {
                                Text("Save")
                                    .frame(maxWidth: prop.isLargerScreen ? 80 : 60, alignment: .center)
                                    .padding(4)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .background(.white)
                                    .cornerRadius(15)
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Button(action: {
                                self.newAccountDescription.removeAll()
                                
                                self.editDescription = false
                            }) {
                                Text("Cancel")
                                    .frame(maxWidth: prop.isLargerScreen ? 80 : 60, alignment: .center)
                                    .padding(4)
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .background(Color.EZNotesRed)
                                    .cornerRadius(15)
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            Text("Tags:")
                .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                .font(Font.custom("Poppins-SemiBold", size: 14))
                .foregroundStyle(.white)
                .padding(.leading, self.isUserPreview ? 20 : 0)
                .padding(.top, 10)
            
            HStack {
                Button(action: {
                    if !self.addTag {
                        self.addTag = true
                        self.newTagFieldInFocus = true
                    } else {
                        self.addTag = false
                        self.newTagFieldInFocus = false
                    }
                }) {
                    HStack {
                        if !self.accountInfo.accountTags.isEmpty {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                                .rotationEffect(Angle(degrees: self.addTagButtonRotationDegrees))
                                .animation(self.addTag ? .easeIn(duration: 0.5) : .easeOut(duration: 1), value: self.addTagButtonRotationDegrees)
                                .onChange(of: self.addTag) {
                                    withAnimation(self.addTag ? .easeIn(duration: 0.5) : .easeOut(duration: 1)) {
                                        self.addTagButtonRotationDegrees = self.addTag ? 45 : 0
                                    }
                                }
                        } else {
                            if !self.addTag {
                                Text("Add Tags")
                                    .frame(maxWidth: 200, alignment: .center)
                                    .padding(.vertical, 5)
                                    .foregroundStyle(.black)
                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 13 : 13)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                            .strokeBorder(.white, lineWidth: 1)
                                    )
                                    .padding(.top, 10)
                                    .padding(.leading, 20)
                            } else {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.white)
                                    .rotationEffect(Angle(degrees: self.addTagButtonRotationDegrees))
                                    .animation(self.addTag ? .easeIn(duration: 0.5) : .easeOut(duration: 1), value: self.addTagButtonRotationDegrees)
                                    .onAppear {
                                        self.addTagButtonRotationDegrees = 45
                                    }
                                    .onDisappear {
                                        self.addTagButtonRotationDegrees = 0
                                    }
                            }
                        }
                    }
                    .frame(alignment: .leading)
                    .padding(.leading, 20)//.padding([.leading, .trailing], 8.5)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if self.isUserPreview {
                            ForEach(self.usersTags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .frame(alignment: .center)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 8.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack.opacity(0.8))
                                            //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                                        )
                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                        .foregroundStyle(.white)
                                        .padding([.top, .bottom], 1.5)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            if self.addTag {
                                TextField("", text: $newTagName)
                                    .frame(alignment: .center)
                                    .padding([.top, .bottom], 4)
                                    .padding(.leading, 8.5)
                                    .padding(.trailing, self.newTagName.count < 10 ? 22 : 26)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            
                                            Text("\(self.newTagName.count)/20")
                                                .frame(alignment: .trailing)
                                                .padding([.top, .bottom], 4)
                                                .font(Font.custom("Poppins-Regular", size: 8))
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                    )
                                    .padding(.trailing, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack.opacity(0.8))
                                        //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                                    )
                                    .font(Font.custom("Poppins-SemiBold", size: 14))
                                    .foregroundStyle(.white)
                                    .padding([.top, .bottom], 1.5)
                                    .focused($newTagFieldInFocus)
                                    .onChange(of: self.newTagName) {
                                        if self.newTagName.count > 20 {
                                            self.newTagName = String(self.newTagName.prefix(20))
                                        }
                                    }
                                /*.onChange(of: self.newTagFieldInFocus) {
                                 if !self.newTagFieldInFocus && self.newTagName.isEmpty {
                                 self.addTag = false
                                 self.newTagFieldInFocus = false
                                 return
                                 } else {
                                 if !self.newTagFieldInFocus {
                                 self.accountInfo.accountTags.append(self.newTagName)
                                 self.addTag = false
                                 self.newTagName.removeAll()
                                 self.newTagFieldInFocus = false
                                 }
                                 }
                                 }*/
                                    .onSubmit {
                                        /* MARK: Check if the user just clicked "return". */
                                        if self.newTagName.isEmpty {
                                            self.addTag = false
                                            self.newTagFieldInFocus = false
                                            return
                                        }
                                        
                                        /* MARK: No two tags can be the same. */
                                        if self.accountInfo.accountTags.contains(self.newTagName) {
                                            self.addTag = false
                                            self.newTagFieldInFocus = false
                                            
                                            self.newTagName.removeAll()
                                            return
                                        }
                                        
                                        RequestAction<SaveTagsData>(parameters: SaveTagsData(
                                            AccountId: self.accountInfo.accountID,
                                            Tags: self.newTagName
                                        )).perform(action: save_tags_req) { statusCode, resp in
                                            self.addTag = false
                                            self.newTagFieldInFocus = false
                                            
                                            guard resp != nil && statusCode == 200 else {
                                                self.newTagName.removeAll()
                                                return /* TODO: Handle errors. */
                                            }
                                            
                                            self.accountInfo.accountTags.append(self.newTagName)
                                            
                                            self.newTagName.removeAll()
                                        }
                                    }
                            }
                            
                            ForEach(self.accountInfo.accountTags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .frame(alignment: .center)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 8.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack.opacity(0.8))
                                            //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                                        )
                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                        .foregroundStyle(.white)
                                        .padding([.top, .bottom], 1.5)
                                    
                                    if self.tagHasBeenPressed && tag == self.tagThatHasBeenPressed {
                                        Button(action: {
                                            RequestAction<RemoveTagData>(parameters: RemoveTagData(
                                                AccountId: self.accountInfo.accountID,
                                                TagToRemove: self.tagThatHasBeenPressed
                                            )).perform(action: remove_tag_req) { statusCode, resp in
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    return /* TODO: Handle errors. */
                                                }
                                                
                                                self.accountInfo.accountTags.removeAll(where: { $0 == self.tagThatHasBeenPressed })
                                                self.tagThatHasBeenPressed.removeAll()
                                                self.tagHasBeenPressed = false
                                            }
                                        }) {
                                            Image(systemName: "trash")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(Color.EZNotesRed)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    if self.tagHasBeenPressed {
                                        if tag == self.tagThatHasBeenPressed {
                                            self.tagHasBeenPressed = false
                                            self.tagThatHasBeenPressed.removeAll()
                                        } else {
                                            self.tagThatHasBeenPressed = tag
                                        }
                                    }
                                    else {
                                        self.tagHasBeenPressed = true
                                        self.tagThatHasBeenPressed = tag
                                    }
                                }
                            }
                            /*if self.accountInfo.usage == "school" {
                             HStack {
                             Text(self.accountInfo.college)
                             .frame(alignment: .center)
                             .padding([.top, .bottom], 4)
                             .padding([.leading, .trailing], 8.5)
                             .background(
                             RoundedRectangle(cornerRadius: 15)
                             .fill(Color.EZNotesLightBlack.opacity(0.8))
                             //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                             )
                             .font(Font.custom("Poppins-SemiBold", size: 14))
                             .foregroundStyle(.white)
                             .padding([.top, .bottom], 1.5)
                             }
                             .frame(maxWidth: .infinity, alignment: .leading)
                             
                             HStack {
                             Text(self.accountInfo.major)
                             .frame(alignment: .center)
                             .padding([.top, .bottom], 4)
                             .padding([.leading, .trailing], 8.5)
                             .background(
                             RoundedRectangle(cornerRadius: 15)
                             .fill(Color.EZNotesLightBlack.opacity(0.8))
                             //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                             )
                             .font(Font.custom("Poppins-SemiBold", size: 14))
                             .foregroundStyle(.white)
                             .padding([.top, .bottom], 1.5)
                             }
                             .frame(maxWidth: .infinity, alignment: .leading)
                             
                             HStack {
                             Text(self.accountInfo.state)
                             .frame(alignment: .center)
                             .padding([.top, .bottom], 4)
                             .padding([.leading, .trailing], 8.5)
                             .background(
                             RoundedRectangle(cornerRadius: 15)
                             .fill(Color.EZNotesLightBlack.opacity(0.8))
                             //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                             )
                             .font(Font.custom("Poppins-SemiBold", size: 14))
                             .foregroundStyle(.white)
                             .padding([.top, .bottom], 1.5)
                             }
                             .frame(maxWidth: .infinity, alignment: .leading)
                             }*/
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 10)
                    .padding(.leading, 2)
                }
                .frame(maxWidth: .infinity)
                //.padding(.leading, 20)
            }
        }
    }
}
