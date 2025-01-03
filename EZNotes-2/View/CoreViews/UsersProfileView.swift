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
    
    @State private var pfpUploadStatus: String = "none"
    @State private var pfpBgUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    @State private var errorUploadingPFPBg: Bool = false
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var changingProfilePic: Bool = false
    @State private var editDescription: Bool = false
    @State private var accountDescription: String = "No Description"
    @State private var newAccountDescription: String = ""
    
    /* MARK: Animation for the status bar the prompts whether or not the change of display or PFP was a success. */
    @State private var statusBarYOffset: CGFloat = 0
    
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
                                    Button(action: { self.showAccount = false }) {
                                        ZStack {
                                            Image(systemName: "arrow.backward")
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
                    if self.accountInfo.usage == "school" {
                        if !self.editDescription {
                            Text(self.accountInfo.accountDescription)//("Majoring in **\(self.accountInfo.major)** at **\(self.accountInfo.college)**")
                                .frame(alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.top, 10)
                                .foregroundStyle(.white)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.leading)
                        } else {
                            VStack {
                                TextField(
                                    "Account description...",
                                    text: $newAccountDescription,
                                    axis: .vertical
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2...4)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .padding(10)
                                .background(Color.EZNotesLightBlack)//(Color(.systemGray6))
                                .cornerRadius(15)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
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
                            Text(self.accountInfo.accountDescription)
                                .frame(alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.top, 10)
                                .foregroundStyle(self.accountInfo.accountDescription == "No Description" ? .gray : .white)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.leading)
                        } else {
                            VStack {
                                TextField(
                                    "Account description...",
                                    text: $newAccountDescription,
                                    axis: .vertical
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2...4)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .padding(10)
                                .background(Color.EZNotesLightBlack)//(Color(.systemGray6))
                                .cornerRadius(15)
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
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
                    
                    if !self.editDescription {
                        Button(action: {
                            self.editDescription = true
                            
                            if self.accountDescription != "No Description" { self.newAccountDescription = self.accountDescription }
                        }) {
                            ZStack {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: prop.isLargerScreen ? 80 : 60, alignment: .trailing)
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    } else {
                        VStack {
                            Button(action: {
                                /* TODO: Add `account_description` to database; add API endpoint to server that will be used to update the `account_description` column for the given user. For now, storing the account description in `UserDefaults` works. */
                                assignUDKey(key: "account_description", value: self.newAccountDescription)
                                
                                //self.accountInfo.accountDescription = self.newAccountDescription
                                
                                RequestAction<SaveAccountDescriptionData>(parameters: SaveAccountDescriptionData(
                                    AccountId: self.accountInfo.accountID,
                                    NewDescription: self.newAccountDescription
                                )).perform(action: save_account_description_req) { statusCode, resp in
                                    self.editDescription = false
                                    
                                    guard resp != nil && statusCode == 200 else {
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
                Button(action: { self.addMoreTags = true }) {
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.white)
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
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
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
