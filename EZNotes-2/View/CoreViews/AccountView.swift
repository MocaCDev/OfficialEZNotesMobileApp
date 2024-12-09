//
//  AccountView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/25/24.
//
import SwiftUI
import PhotosUI
import Combine

struct Account: View {
    @EnvironmentObject private var eznotesSubscriptionManager: EZNotesSubscriptionManager
    var prop: Properties
    
    @Binding public var showAccount: Bool
    @Binding public var userHasSignedIn: Bool
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var accountPopupSection: String = "main"
    /*@State private var subscriptionInfo: SubscriptionInfo = .init(
        TimeCreated: nil,
        DateCreated: nil,
        CurrentPeriodStart: nil,
        CurrentPeriodEnd: nil,
        Lifetime: nil,
        ProductName: nil,
        Price: nil,
        Interval: nil,
        PlanID: nil,
        PriceID: nil,
        ProductID: nil,
        CardHolderName: nil
    )*/
    @State private var errorLoadingPlanDetailsSection: Bool = false
    @State private var loadingChangeSchoolsSection: Bool = false
    @State private var errorLoadingChangeSchoolsSection: Bool = false
    @State private var colleges: Array<String> = []
    @State private var loadingMajorFields: Bool = false
    @State private var errorLoadingMajorFields: Bool = false
    @State private var majorFields: Array<String> = []
    @State private var loadingPlanDetailsSection: Bool = false
    @State private var updateCollegeAlert: Bool = false
    @State private var updateMajorFieldAndMajorAlert: Bool = false
    @State private var temporaryMajorValue: String = ""
    @State private var temporaryMajorFieldValue: String = ""
    @State private var temporaryCollegeValue: String = ""
    @State private var switchFieldAndMajorSection: String = "choose_field"
    @State private var loadingMajors: Bool = false
    @State private var errorLoadingMajors: Bool = false
    @State private var majors: Array<String> = []
    
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
        "Wisconsin", "Wyoming"
    ]
    
    let borderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesBlue, Color.EZNotesOrange]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    let borderBottomColorError: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesRed, Color.EZNotesRed]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var changingProfilePic: Bool = false
    @State private var pfpUploadStatus: String = "none"
    @State private var pfpBgUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    @State private var errorUploadingPFPBg: Bool = false
    @State private var showPrivacyAndPolicy: Bool = false
    @State private var showTermsAndConditions: Bool = false
    
    /* MARK: Animation for the status bar the prompts whether or not the change of display or PFP was a success. */
    @State private var statusBarYOffset: CGFloat = 0
    
    /* MARK: Variable for y offset of the body (under the "Change PFP" and "Change Display" buttons). */
    @State private var bodyYOffset: CGFloat = 0
    
    /* MARK: Variable for y offset of top of the body (part that shows PFP, display background, username etc). */
    @State private var topBodyYOffset: CGFloat = 0
    
    func doSomething() { print("YES") }
    
    @State private var getRickRolled: Bool = false
    
    /* MARK: States for triggering alerts about logging out/deleting account. */
    @State private var logoutAlert: Bool = false
    @State private var deleteAccountAlert: Bool = false
    
    @State private var testImage: Image?
    
    var body: some View {
        VStack {
            ZStack {
                if self.accountPopupSection == "main" {
                    accountInfo.profileBackgroundPicture
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
            }
            .frame(maxWidth: prop.size.width, maxHeight: self.accountPopupSection != "main" ? 15 : 100) /* MARK: Set `maxWidth` to `prop.size.width` to avoid images with larger width from stretching content. */
            
            VStack {
                if self.accountPopupSection == "main" {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.EZNotesBlue, Color.EZNotesBlack], startPoint: .top, endPoint: .bottom))
                            
                            self.accountInfo.profilePicture
                                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                .scaledToFill()
                                .frame(maxWidth: 70, maxHeight: 70)
                                .clipShape(.circle)
                                .overlay(
                                    VStack {
                                        if self.changingProfilePic {
                                            Text("Updating")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .setFontSizeAndWeight(weight: .medium, size: 12)
                                                .minimumScaleFactor(0.5)
                                            
                                            ProgressView()
                                                .tint(Color.EZNotesBlue)
                                        }
                                    }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .background(self.changingProfilePic ? Color.EZNotesBlack.opacity(0.6) : .clear)
                                        .clipShape(.circle)
                                )
                        }
                        .frame(width: 75, height: 75, alignment: .leading)
                        .padding(.leading, 20)
                        .zIndex(1)
                        
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
                                            
                                            PFP(pfp: image, accountID: self.accountInfo.accountID)
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
                                    .fill(.gray.opacity(0.25))
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
                                            PFP(pfpBg: image, accountID: self.accountInfo.accountID)
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
                                    .fill(.gray.opacity(0.25))
                                    .stroke(.white, lineWidth: 1)
                            )
                            .padding(.trailing, 15)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 30)
                        .padding(.leading, -15)
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("\(self.accountInfo.username)")
                            .frame(alignment: .leading)
                            .padding(.leading, 20)
                            .foregroundStyle(.white)
                            .font(.system(size: prop.isLargerScreen ? 30 : 24))//(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 22))
                        
                        Divider()
                            .background(.white)
                        
                        Text("0 Friends")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .font(.system(size: prop.isLargerScreen ? 20 : 16, weight: .light))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 20)
                    .padding(.top, 15)
                    
                    Text(self.accountInfo.email)
                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 10)
                        .foregroundStyle(.white)
                        .setFontSizeAndWeight(weight: .medium, size: 14)
                        .minimumScaleFactor(0.5)
                    
                    HStack {
                        Text("Majoring in **\(self.accountInfo.major)** at **\(self.accountInfo.college)**")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 10)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-Regular", size: 12))
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                        
                        ZStack { }.frame(maxWidth: prop.isLargerScreen ? 80 : 60, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text("Tags:")
                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                        .font(Font.custom("Poppins-SemiBold", size: 14))
                        .foregroundStyle(.white)
                        .padding(.top, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
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
                            
                            Button(action: { print("Add More Tags") }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                        .padding([.leading, .trailing], 8.5)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 10)
                        .padding(.leading, 2) /* MARK: Some of the first rounded rectangles border was cut off, this ensures that does not happen. */
                    }
                    .frame(maxWidth: prop.size.width - 40)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, prop.isLargerScreen ? -15 : -25)
            
            VStack {
                VStack {
                    if self.accountPopupSection == "main" {
                        VStack {
                            VStack { }.frame(maxWidth: .infinity, maxHeight: 5)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                Text("Account")
                                    .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                    .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                    .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                    .foregroundStyle(.white) // Applies color styling after setting the font.
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                
                                VStack {
                                    Button(action: {
                                        self.accountPopupSection = "change_username"
                                    }) {
                                        HStack {
                                            /*Text("Change Username")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))*/
                                            VStack {
                                                Text("Change Username")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                Text(self.accountInfo.username)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: 14))
                                                    .foregroundStyle(Color.white)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.bottom, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)//.frame(width: prop.size.width - 75)
                                    
                                    Button(action: {
                                        self.accountPopupSection = "update_password"
                                    }) {
                                        HStack {
                                            Text("Update Password")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding([.top, .bottom], 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: {
                                        if self.accountInfo.state == "" {
                                            self.accountPopupSection = "swich_state"
                                            return
                                        }
                                        
                                        self.accountPopupSection = "switch_college"
                                        self.loadingChangeSchoolsSection = true
                                        
                                        RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.accountInfo.state))
                                            .perform(action: get_colleges) { statusCode, resp in
                                                self.loadingChangeSchoolsSection = false
                                                
                                                /* TODO: Add loading screen while college names load. */
                                                guard
                                                    resp != nil,
                                                    resp!.keys.contains("Colleges"),
                                                    statusCode == 200
                                                else {
                                                    self.errorLoadingChangeSchoolsSection = true
                                                    
                                                    /* TODO: Add some sort of error checking. We can use the banner-thing that is used to signify a success or failure when updating PFP/PFP BG image. */
                                                    /* TODO: As has been aforementioned - lets go ahead and ensure the banner message can be used across the board, not just with update success/failures of PFP/PFP BG image. */
                                                    //self.serverError = true
                                                    if let resp = resp { print(resp) }
                                                    return
                                                }
                                                
                                                let respColleges = resp!["Colleges"] as! [String]
                                                
                                                /* MARK: Ensure the `colleges` array is empty. */
                                                self.colleges.removeAll()
                                                
                                                for c in respColleges {
                                                    if !self.colleges.contains(c) { self.colleges.append(c) }
                                                }
                                                
                                                self.colleges.append("Other")
                                                self.errorLoadingChangeSchoolsSection = false
                                                //self.college = self.colleges[0]
                                            }
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("Change Schools")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                Text(self.accountInfo.college)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: 14))
                                                    .foregroundStyle(Color.white)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding([.top, .bottom], 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: { self.accountPopupSection = "switch_state" }) {
                                        HStack {
                                            VStack {
                                                Text("Change States")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                Text(self.accountInfo.state)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: 14))
                                                    .foregroundStyle(Color.white)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding([.top, .bottom], 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: {
                                        self.accountPopupSection = "switch_field_and_major"
                                        self.loadingMajorFields = true
                                        
                                        RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                            State: self.accountInfo.state,
                                            College: self.accountInfo.college
                                        ))
                                        .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                            self.loadingMajorFields = false
                                            
                                            guard
                                                resp != nil,
                                                statusCode == 200
                                            else {
                                                /* TODO: Handle errors. For now, the below works. */
                                                self.errorLoadingMajorFields = true
                                                return
                                            }
                                            
                                            guard resp!.keys.contains("Fields") else {
                                                /* TODO: Handle errors. For now the below works. */
                                                //self.accountPopupSection = "main"
                                                self.errorLoadingMajorFields = true
                                                return
                                            }
                                            
                                            self.errorLoadingMajorFields = false
                                            
                                            /* MARK: Ensure the array is empty before populating it. */
                                            self.majorFields.removeAll()
                                            
                                            self.majorFields = resp!["Fields"] as! [String]
                                            self.majorFields.append("Other")
                                        }
                                    }) {
                                        HStack {
                                            VStack {
                                                Text("Change Field/Major")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                Text(self.accountInfo.major)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: 14))
                                                    .foregroundStyle(Color.white)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            .padding(.leading, 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.top, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 14)
                                //.padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                        .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                        //.shadow(color: Color.EZNotesLightBlack, radius: 1.5)
                                    /*.stroke(LinearGradient(gradient: Gradient(
                                     colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                     ), startPoint: .leading, endPoint: .trailing), lineWidth: 1)*/
                                )
                                .padding(.top, -5)
                                .padding(5) /* MARK: Ensure the shadow can be seen. */
                                //.cornerRadius(15)
                                
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                
                                Text("Core Actions")
                                    .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                    .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                    .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                    .foregroundStyle(.white) // Applies color styling after setting the font.
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                
                                VStack {
                                    HStack {
                                        Button(action: {
                                            self.accountPopupSection = "settings"
                                        }) {
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
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Button(action: {
                                            if self.eznotesSubscriptionManager.userSubscriptionIDs.isEmpty {
                                                self.accountPopupSection = "setup_plan"
                                                return
                                            }
                                            
                                            self.accountPopupSection = "planDetails"
                                            self.loadingPlanDetailsSection = true
                                            
                                            /*RequestAction<GetSubscriptionInfoData>(parameters: GetSubscriptionInfoData(AccountID: self.accountInfo.accountID))
                                                .perform(action: get_subscription_info_req) { statusCode, resp in
                                                    self.loadingPlanDetailsSection = false
                                                    
                                                    guard resp != nil && statusCode == 200 else {
                                                        if let resp = resp {
                                                            if resp["Message"] as! String == "plan_id_not_found_for_user" {
                                                                self.accountPopupSection = "setup_plan"
                                                                return
                                                            }
                                                        }
                                                        self.errorLoadingPlanDetailsSection = true
                                                        return
                                                    }
                                                    
                                                    if let resp = resp {
                                                        let d: TimeInterval = resp["PlanCreated"] as! TimeInterval
                                                        let date = Date(timeIntervalSince1970: d)
                                                        
                                                        /* MARK: Assign the according fields to be refereneced in the "Plan Details" section. */
                                                        self.subscriptionInfo.TimeCreated = "\(date.formatted(date: .omitted, time: .shortened))"
                                                        self.subscriptionInfo.DateCreated = Date(timeIntervalSince1970: resp["PlanCreated"] as! TimeInterval)
                                                        self.subscriptionInfo.CurrentPeriodStart = Date(timeIntervalSince1970: resp["PeriodStart"] as! TimeInterval)
                                                        self.subscriptionInfo.CurrentPeriodEnd = Date(timeIntervalSince1970: resp["PeriodEnd"] as! TimeInterval)
                                                        self.subscriptionInfo.Lifetime = (resp["Lifetime"] as! Int)
                                                        self.subscriptionInfo.ProductName = (resp["ProductName"] as! String)
                                                        self.subscriptionInfo.Price = (resp["Price"] as! String)
                                                        self.subscriptionInfo.Interval = (resp["Interval"] as! String)
                                                        self.subscriptionInfo.PlanID = (resp["UserSubID"] as! String)
                                                        self.subscriptionInfo.PriceID = (resp["PriceID"] as! String)
                                                        self.subscriptionInfo.ProductID = (resp["ProductID"] as! String)
                                                        self.subscriptionInfo.Last4 = (resp["LastFour"] as! String)
                                                        self.subscriptionInfo.CardBrand = (resp["CardBrand"] as! String)
                                                        self.subscriptionInfo.CardExpMonth = (resp["CardExpMonth"] as! String)
                                                        self.subscriptionInfo.CardExpYear = (resp["CardExpYear"] as! String)
                                                        self.subscriptionInfo.CardHolderName = (resp["CustomerName"] as! String)
                                                        self.subscriptionInfo.PaymentMethodCreatedOn = Date(timeIntervalSince1970: resp["PaymentMethodCreatedOn"] as! TimeInterval)
                                                        
                                                        // Get the index two characters before the end of the string
                                                        let splitIndex = self.subscriptionInfo.Price!.index(self.subscriptionInfo.Price!.endIndex, offsetBy: -2)
                                                        
                                                        // Split into prefix and suffix
                                                        let prefix = String(self.subscriptionInfo.Price![..<splitIndex])
                                                        let suffix = String(self.subscriptionInfo.Price![splitIndex...])
                                                        
                                                        self.subscriptionInfo.Price = "$\(prefix).\(suffix)"
                                                        self.errorLoadingPlanDetailsSection = false
                                                        return
                                                    }
                                                    
                                                    /* MARK: If the above if statement fails, there was an error obtaining the response. */
                                                    self.errorLoadingPlanDetailsSection = true
                                                }*/
                                        }) {
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
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 140)
                                    
                                    Button(action: {
                                        self.accountPopupSection = "themes"
                                    }) {
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
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 50, maxHeight: .infinity)
                                
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                
                                Text("Privacy & Terms")
                                    .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                    .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                    .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                    .foregroundStyle(.white) // Applies color styling after setting the font.
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                
                                VStack {
                                    Button(action: { self.showPrivacyAndPolicy = true }) {
                                        HStack {
                                            Text("Privacy & Policy")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.bottom, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .popover(isPresented: $showPrivacyAndPolicy) {
                                        WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                                            .navigationBarTitle("Privacy Policy", displayMode: .inline)
                                    }
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: { self.showTermsAndConditions = true }) {
                                        HStack {
                                            Text("Terms & Conditions")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.top, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .popover(isPresented: $showTermsAndConditions) {
                                        WebView(url: URL(string: "https://www.eznotes.space/terms_and_conditions")!)
                                            .navigationBarTitle("Terms & Conditions", displayMode: .inline)
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                        .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                )
                                .padding(5) /* MARK: Ensure the shadow can be seen. */
                                .cornerRadius(15)
                                
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                
                                /* MARK: More details will show the user their account ID, session ID etc. */
                                Text("Additional")
                                    .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                    .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                    .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                    .foregroundStyle(.white) // Applies color styling after setting the font.
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                
                                VStack {
                                    Button(action: { self.accountPopupSection = "moreAccountDetails" }) {
                                        HStack {
                                            Text("More Account Details")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.bottom, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: { self.accountPopupSection = "reportIssue" }) {
                                        HStack {
                                            Text("Report An Issue")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.top, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 14)
                                //.padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                        .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                )
                                .padding(5) /* MARK: Ensure the padding can be seen. */
                                .cornerRadius(15)
                                
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                
                                Text("Actions")
                                    .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                    .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                    .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                    .foregroundStyle(.white) // Applies color styling after setting the font.
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                
                                VStack {
                                    Button(action: { self.deleteAccountAlert = true }) {
                                        HStack {
                                            Text("Delete Account")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.bottom, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .alert("AYO!", isPresented: $deleteAccountAlert) {
                                        Button("Mmmm.. okay", role: .cancel) { }
                                    } message: {
                                        Text("Why do you even wanna do such a thing? Not like the app is North Korea dude🙄")
                                    }
                                    
                                    Divider()
                                        .overlay(Color(.systemGray4))
                                        .padding([.leading, .trailing], 15)
                                    
                                    Button(action: { self.logoutAlert = true }) {
                                        HStack {
                                            Text("Logout")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundStyle(Color.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(.top, 5)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .alert("Are You Sure?", isPresented: $logoutAlert) {
                                        Button(action: {
                                            assignUDKey(key: "logged_in", value: false)
                                            self.userHasSignedIn = false
                                            self.accountInfo.reset()
                                            
                                            udRemoveAllAccountInfoKeys()
                                        }) { Text("Yes") }
                                        
                                        Button("No", role: .cancel) { }
                                    } message: {
                                        Text("By selecting yes, you will effectively be logged out. Are you sure?")
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 14)
                                //.padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                        .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                )
                                .padding(5) /* MARK: Ensure the shadow can be seen. */
                                .cornerRadius(15)
                                
                                /*VStack {
                                    Text("Account")
                                        .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                        .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                        .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                        .foregroundStyle(.white) // Applies color styling after setting the font.
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    
                                    VStack {
                                        Button(action: {
                                            self.accountPopupSection = "change_username"
                                        }) {
                                            HStack {
                                                /*Text("Change Username")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18, design: .rounded))*/
                                                VStack {
                                                    Text("Change Username")
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .font(.system(size: 18, design: .rounded))
                                                        .foregroundStyle(Color.white)
                                                    
                                                    Text(self.accountInfo.username)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .font(Font.custom("Poppins-Regular", size: 14))
                                                        .foregroundStyle(Color.white)
                                                }
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.bottom, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)//.frame(width: prop.size.width - 75)
                                        
                                        Button(action: {
                                            self.accountPopupSection = "update_password"
                                        }) {
                                            HStack {
                                                Text("Update Password")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding([.top, .bottom], 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: {
                                            if self.accountInfo.state == "" {
                                                self.accountPopupSection = "swich_state"
                                                return
                                            }
                                            
                                            self.accountPopupSection = "switch_college"
                                            self.loadingChangeSchoolsSection = true
                                            
                                            RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.accountInfo.state))
                                                .perform(action: get_colleges) { statusCode, resp in
                                                    self.loadingChangeSchoolsSection = false
                                                    
                                                    /* TODO: Add loading screen while college names load. */
                                                    guard
                                                        resp != nil,
                                                        resp!.keys.contains("Colleges"),
                                                        statusCode == 200
                                                    else {
                                                        self.errorLoadingChangeSchoolsSection = true
                                                        
                                                        /* TODO: Add some sort of error checking. We can use the banner-thing that is used to signify a success or failure when updating PFP/PFP BG image. */
                                                        /* TODO: As has been aforementioned - lets go ahead and ensure the banner message can be used across the board, not just with update success/failures of PFP/PFP BG image. */
                                                        //self.serverError = true
                                                        if let resp = resp { print(resp) }
                                                        return
                                                    }
                                                    
                                                    let respColleges = resp!["Colleges"] as! [String]
                                                    
                                                    /* MARK: Ensure the `colleges` array is empty. */
                                                    self.colleges.removeAll()
                                                    
                                                    for c in respColleges {
                                                        if !self.colleges.contains(c) { self.colleges.append(c) }
                                                    }
                                                    
                                                    self.colleges.append("Other")
                                                    self.errorLoadingChangeSchoolsSection = false
                                                    //self.college = self.colleges[0]
                                                }
                                        }) {
                                            HStack {
                                                Text("Change Schools")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding([.top, .bottom], 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: { self.accountPopupSection = "switch_state" }) {
                                            HStack {
                                                Text("Change States")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding([.top, .bottom], 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: {
                                            self.accountPopupSection = "switch_field_and_major"
                                            self.loadingMajorFields = true
                                            
                                            RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                State: self.accountInfo.state,
                                                College: self.accountInfo.college
                                            ))
                                            .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                self.loadingMajorFields = false
                                                
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    /* TODO: Handle errors. For now, the below works. */
                                                    self.errorLoadingMajorFields = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Fields") else {
                                                    /* TODO: Handle errors. For now the below works. */
                                                    //self.accountPopupSection = "main"
                                                    self.errorLoadingMajorFields = true
                                                    return
                                                }
                                                
                                                self.errorLoadingMajorFields = false
                                                
                                                /* MARK: Ensure the array is empty before populating it. */
                                                self.majorFields.removeAll()
                                                
                                                self.majorFields = resp!["Fields"] as! [String]
                                                self.majorFields.append("Other")
                                            }
                                        }) {
                                            HStack {
                                                Text("Change Field/Major")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.top, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: prop.size.width - 30)
                                    .padding([.top, .bottom], 14)
                                    //.padding([.leading, .trailing], 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                            .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                            //.shadow(color: Color.EZNotesLightBlack, radius: 1.5)
                                        /*.stroke(LinearGradient(gradient: Gradient(
                                         colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                         ), startPoint: .leading, endPoint: .trailing), lineWidth: 1)*/
                                    )
                                    .padding(.top, -5)
                                    .padding(5) /* MARK: Ensure the shadow can be seen. */
                                    //.cornerRadius(15)
                                    
                                    /* MARK: Custom `spacer`. Scrollview makes all the views within it kind of funky. */
                                    VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                    
                                    Text("Core Actions")
                                        .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                        .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                        .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                        .foregroundStyle(.white) // Applies color styling after setting the font.
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    
                                    VStack {
                                        HStack {
                                            Button(action: {
                                                self.accountPopupSection = "settings"
                                            }) {
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
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                            
                                            Button(action: {
                                                if self.eznotesSubscriptionManager.userSubscriptionIDs.isEmpty {
                                                    self.accountPopupSection = "setup_plan"
                                                    return
                                                }
                                                
                                                self.accountPopupSection = "planDetails"
                                                self.loadingPlanDetailsSection = true
                                                
                                                /*RequestAction<GetSubscriptionInfoData>(parameters: GetSubscriptionInfoData(AccountID: self.accountInfo.accountID))
                                                    .perform(action: get_subscription_info_req) { statusCode, resp in
                                                        self.loadingPlanDetailsSection = false
                                                        
                                                        guard resp != nil && statusCode == 200 else {
                                                            if let resp = resp {
                                                                if resp["Message"] as! String == "plan_id_not_found_for_user" {
                                                                    self.accountPopupSection = "setup_plan"
                                                                    return
                                                                }
                                                            }
                                                            self.errorLoadingPlanDetailsSection = true
                                                            return
                                                        }
                                                        
                                                        if let resp = resp {
                                                            let d: TimeInterval = resp["PlanCreated"] as! TimeInterval
                                                            let date = Date(timeIntervalSince1970: d)
                                                            
                                                            /* MARK: Assign the according fields to be refereneced in the "Plan Details" section. */
                                                            self.subscriptionInfo.TimeCreated = "\(date.formatted(date: .omitted, time: .shortened))"
                                                            self.subscriptionInfo.DateCreated = Date(timeIntervalSince1970: resp["PlanCreated"] as! TimeInterval)
                                                            self.subscriptionInfo.CurrentPeriodStart = Date(timeIntervalSince1970: resp["PeriodStart"] as! TimeInterval)
                                                            self.subscriptionInfo.CurrentPeriodEnd = Date(timeIntervalSince1970: resp["PeriodEnd"] as! TimeInterval)
                                                            self.subscriptionInfo.Lifetime = (resp["Lifetime"] as! Int)
                                                            self.subscriptionInfo.ProductName = (resp["ProductName"] as! String)
                                                            self.subscriptionInfo.Price = (resp["Price"] as! String)
                                                            self.subscriptionInfo.Interval = (resp["Interval"] as! String)
                                                            self.subscriptionInfo.PlanID = (resp["UserSubID"] as! String)
                                                            self.subscriptionInfo.PriceID = (resp["PriceID"] as! String)
                                                            self.subscriptionInfo.ProductID = (resp["ProductID"] as! String)
                                                            self.subscriptionInfo.Last4 = (resp["LastFour"] as! String)
                                                            self.subscriptionInfo.CardBrand = (resp["CardBrand"] as! String)
                                                            self.subscriptionInfo.CardExpMonth = (resp["CardExpMonth"] as! String)
                                                            self.subscriptionInfo.CardExpYear = (resp["CardExpYear"] as! String)
                                                            self.subscriptionInfo.CardHolderName = (resp["CustomerName"] as! String)
                                                            self.subscriptionInfo.PaymentMethodCreatedOn = Date(timeIntervalSince1970: resp["PaymentMethodCreatedOn"] as! TimeInterval)
                                                            
                                                            // Get the index two characters before the end of the string
                                                            let splitIndex = self.subscriptionInfo.Price!.index(self.subscriptionInfo.Price!.endIndex, offsetBy: -2)
                                                            
                                                            // Split into prefix and suffix
                                                            let prefix = String(self.subscriptionInfo.Price![..<splitIndex])
                                                            let suffix = String(self.subscriptionInfo.Price![splitIndex...])
                                                            
                                                            self.subscriptionInfo.Price = "$\(prefix).\(suffix)"
                                                            self.errorLoadingPlanDetailsSection = false
                                                            return
                                                        }
                                                        
                                                        /* MARK: If the above if statement fails, there was an error obtaining the response. */
                                                        self.errorLoadingPlanDetailsSection = true
                                                    }*/
                                            }) {
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
                                            .buttonStyle(NoLongPressButtonStyle())
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 140)
                                        
                                        Button(action: {
                                            self.accountPopupSection = "themes"
                                        }) {
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
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                                    
                                    Divider()
                                        .background(Color.black)
                                        .frame(maxWidth: prop.size.width - 50)
                                        .padding([.top, .bottom], 10)
                                    
                                    Text("Privacy & Terms")
                                        .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                        .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                        .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                        .foregroundStyle(.white) // Applies color styling after setting the font.
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    
                                    VStack {
                                        Button(action: { self.showPrivacyAndPolicy = true }) {
                                            HStack {
                                                Text("Privacy & Policy")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.bottom, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .popover(isPresented: $showPrivacyAndPolicy) {
                                            WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                                                .navigationBarTitle("Privacy Policy", displayMode: .inline)
                                        }
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: { self.showTermsAndConditions = true }) {
                                            HStack {
                                                Text("Terms & Conditions")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.top, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .popover(isPresented: $showTermsAndConditions) {
                                            WebView(url: URL(string: "https://www.eznotes.space/terms_and_conditions")!)
                                                .navigationBarTitle("Terms & Conditions", displayMode: .inline)
                                        }
                                    }
                                    .frame(maxWidth: prop.size.width - 30)
                                    .padding([.top, .bottom], 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                            .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                    )
                                    .padding(5) /* MARK: Ensure the shadow can be seen. */
                                    .cornerRadius(15)
                                    
                                    /* MARK: More details will show the user their account ID, session ID etc. */
                                    Text("Additional")
                                        .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                        .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                        .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                        .foregroundStyle(.white) // Applies color styling after setting the font.
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    
                                    VStack {
                                        Button(action: { self.accountPopupSection = "moreAccountDetails" }) {
                                            HStack {
                                                Text("More Account Details")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 15)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.bottom, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: { self.accountPopupSection = "reportIssue" }) {
                                            HStack {
                                                Text("Report An Issue")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 15)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.top, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: prop.size.width - 50)
                                    .padding([.top, .bottom], 14)
                                    //.padding([.leading, .trailing], 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                            .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                    )
                                    .padding(5) /* MARK: Ensure the padding can be seen. */
                                    .cornerRadius(15)
                                    
                                    Text("Account Actions")
                                        .textCase(.uppercase) // Ensures the text is uppercased before styling.
                                        .font(Font.custom("Poppins-SemiBold", size: 18)) // Sets the font style and size.
                                        .minimumScaleFactor(0.5) // Adjusts scaling only if needed after applying the font.
                                        .foregroundStyle(.white) // Applies color styling after setting the font.
                                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    
                                    VStack {
                                        Button(action: { self.accountPopupSection = "moreAccountDetails" }) {
                                            HStack {
                                                Text("More Account Details")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 15)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.bottom, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: { self.accountPopupSection = "reportIssue" }) {
                                            HStack {
                                                Text("Report An Issue")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 15)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.top, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: prop.size.width - 50)
                                    .padding([.top, .bottom], 14)
                                    //.padding([.leading, .trailing], 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                            .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                    )
                                    .padding(5) /* MARK: Ensure the padding can be seen. */
                                    .cornerRadius(15)
                                    /*VStack {
                                        Button(action: { self.deleteAccountAlert = true }) {
                                            HStack {
                                                Text("Delete Account")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.bottom, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        /*.alert("AYO!", isPresented: $deleteAccountAlert) {
                                            Button("Mmmm.. okay", role: .cancel) { }
                                        } message: {
                                            Text("Why do you even wanna do such a thing? Not like the app is North Korea dude🙄")
                                        }*/
                                        
                                        Divider()
                                            .overlay(Color(.systemGray4))
                                            .padding([.leading, .trailing], 15)
                                        
                                        Button(action: { self.logoutAlert = true }) {
                                            HStack {
                                                Text("Logout")
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                    .padding(.leading, 15)
                                                    .font(.system(size: 18, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizable()
                                                        .frame(width: 10, height: 15)//.resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, maxHeight: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .padding(.top, 5)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        /*.alert("Are You Sure?", isPresented: $logoutAlert) {
                                            Button(action: {
                                                assignUDKey(key: "logged_in", value: false)
                                                self.userHasSignedIn = false
                                                self.accountInfo.reset()
                                                
                                                udRemoveAllAccountInfoKeys()
                                            }) { Text("Yes") }
                                            
                                            Button("No", role: .cancel) { }
                                        } message: {
                                            Text("By selecting yes, you will effectively be logged out. Are you sure?")
                                        }*/
                                    }
                                    .frame(maxWidth: prop.size.width - 30)
                                    .padding([.top, .bottom], 14)
                                    //.padding([.leading, .trailing], 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)//.fill(Color.EZNotesBlack)
                                            .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                    )
                                    .padding(5) /* MARK: Ensure the shadow can be seen. */
                                    .cornerRadius(15)*/
                                }
                                .frame(maxWidth: prop.size.width - 20)
                                .padding(.top, 5)
                                .padding()
                                //.background(Color.EZNotesBlack)
                                .cornerRadius(15)
                                .padding(.bottom, 40)*/
                                
                                Text("Joined 10/10/2024")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 40)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .medium)
                            }
                        }
                        .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity)
                        .padding(.top, -20)
                    } else {
                        switch(self.accountPopupSection) {
                        case "moreAccountDetails":
                            MoreAccountDetails(
                                prop: self.prop,
                                accountPopupSection: $accountPopupSection
                            )
                        case "reportIssue":
                            ReportIssue(
                                prop: self.prop,
                                accountPopupSection: $accountPopupSection
                            )
                        case "setup_plan":
                            ZStack {
                                VStack {
                                    VStack {
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                                    .background(
                                        Image("DefaultThemeBg3")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .padding(.top, 70)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .zIndex(0)
                                
                                VStack {
                                    HStack {
                                        Button(action: { self.accountPopupSection = "main" }) {
                                            ZStack {
                                                Image(systemName: "arrow.backward")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 20, alignment: .leading)
                                            .padding(.top, 15)
                                            .padding(.leading, 25)
                                        }
                                        
                                        Text("Setup Plan")
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .padding([.top], 15)
                                            .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                                            
                                        /* MARK: "spacing" to ensure above Text stays in the middle. */
                                        ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                    .padding(.top, prop.isLargerScreen ? 45 : 0)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                VStack { /* MARK: `VStack` needed to ensure spacing between header and content of the view (`Plans`). */
                                    Plans(
                                        prop: prop,
                                        email: self.accountInfo.email,
                                        accountID: self.accountInfo.accountID,
                                        isLargerScreen: prop.isLargerScreen,
                                        action: doSomething
                                    )
                                    .padding([.top, .bottom], -15) /* MARK: Needed to make it looks like content come up from the bottom of the screen. */
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 60)
                            }
                        case "change_username":
                            /* TODO: `isLargerScreen` should be moved into a class where it becomes a published variable. */
                            ChangeUsername(
                                prop: prop,
                                borderBottomColor: self.borderBottomColor,
                                accountInfo: self.accountInfo,
                                accountPopupSection: $accountPopupSection
                            )
                        case "update_password":
                            UpdatePassword(
                                prop: self.prop,
                                borderBottomColor: self.borderBottomColor,
                                accountInfo: self.accountInfo,
                                accountPopupSection: $accountPopupSection
                            )
                        case "switch_state":
                            SwitchState(
                                prop: self.prop,
                                accountInfo: self.accountInfo,
                                accountPopupSection: $accountPopupSection,
                                loadingChangeSchoolsSection: $loadingChangeSchoolsSection,
                                errorLoadingChangeSchoolsSection: $errorLoadingChangeSchoolsSection,
                                colleges: $colleges
                            )
                        case "switch_college":
                            ZStack {
                                VStack {
                                    VStack {
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                                    .background(
                                        Image("DefaultThemeBg3")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .padding(.top, 70)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .zIndex(0)
                                
                                VStack {
                                    HStack {
                                        Button(action: { self.accountPopupSection = "main" }) {
                                            ZStack {
                                                Image(systemName: "arrow.backward")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 20, alignment: .leading)
                                            .padding(.top, 15)
                                            .padding(.leading, 25)
                                        }
                                        
                                        Text("Switch College")
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .padding([.top], 15)
                                            .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                                            
                                        /* MARK: "spacing" to ensure above Text stays in the middle. */
                                        ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                    .padding(.top, prop.isLargerScreen ? 45 : 0)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                VStack {
                                    if self.loadingChangeSchoolsSection {
                                        Text("Loading colleges for \(self.accountInfo.state)")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .medium, size: 14)
                                            .minimumScaleFactor(0.5)
                                        
                                        ProgressView()
                                            .tint(Color.EZNotesBlue)
                                    } else {
                                        if self.errorLoadingChangeSchoolsSection {
                                            ErrorMessage(
                                                prop: prop,
                                                placement: .top,
                                                message: "Error obtaining colleges from \(self.accountInfo.state)",
                                                showReportProblemButton: true
                                            )
                                        } else {
                                            HStack {
                                                ZStack { }.frame(maxWidth: 10, alignment: .leading)
                                                
                                                ZStack {
                                                    Text("Select the college where you are actively enrolled.")
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: prop.isLargerScreen ? 16 : 12, weight: .light))
                                                        .multilineTextAlignment(.center)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                
                                                ZStack { }.frame(maxWidth: 10, alignment: .trailing)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.bottom, 30)
                                            .padding(.top, 10)
                                            
                                            ScrollView(.vertical, showsIndicators: false) {
                                                VStack {
                                                    ForEach(self.colleges, id: \.self) { college in
                                                        Button(action: {
                                                            self.temporaryCollegeValue = college
                                                            self.updateCollegeAlert = true
                                                        }) {
                                                            HStack {
                                                                Text(college)
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                    .padding([.leading, .top, .bottom], 10)
                                                                    .foregroundStyle(.white)
                                                                    .font(Font.custom("Poppins-Regular", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                                    .fontWeight(.bold)
                                                                    .minimumScaleFactor(0.5)
                                                                    .multilineTextAlignment(.leading)
                                                                
                                                                ZStack {
                                                                    Image(systemName: "chevron.right")
                                                                        .resizable()
                                                                        .frame(width: 10, height: 15)
                                                                }
                                                                .frame(maxWidth: 20, alignment: .trailing)
                                                                .foregroundStyle(.gray)
                                                                .padding(.trailing, 10)
                                                            }
                                                            .frame(maxWidth: .infinity)
                                                            .padding(10)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                                    .shadow(color: Color.black, radius: 1.5)
                                                            )
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, 60)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .padding([.top, .bottom], -15)
                                        }
                                    }
                                    
                                    //Spacer()
                                }
                                .frame(maxWidth: prop.size.width - 40 , maxHeight: .infinity)
                                .padding(.top, prop.isLargerScreen ? 80 : 40)
                                .alert("Are you sure?", isPresented: $updateCollegeAlert) {
                                    Button(action: {
                                        RequestAction<UpdateCollegeNameData>(parameters: UpdateCollegeNameData(
                                            NewCollegeName: self.temporaryCollegeValue, AccountID: self.accountInfo.accountID
                                        ))
                                        .perform(action: update_college_name_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                self.temporaryCollegeValue.removeAll()
                                                if let resp = resp { print(resp) }
                                                
                                                /* TODO: Display an error message. */
                                                
                                                return
                                            }
                                            
                                            assignUDKey(key: "college_name", value: self.temporaryCollegeValue)
                                            self.accountInfo.setCollegeName(collegeName: self.temporaryCollegeValue)
                                            
                                            self.accountPopupSection = "switch_field_and_major"
                                            self.loadingMajorFields = true
                                            
                                            /* MARK: Get new major fields for the school. */
                                            RequestAction<GetCustomCollegeFieldsData>(parameters: GetCustomCollegeFieldsData(
                                                State: self.accountInfo.state,
                                                College: self.temporaryCollegeValue
                                            ))
                                            .perform(action: get_custom_college_fields_req) { statusCode, resp in
                                                self.loadingMajorFields = false
                                                
                                                guard
                                                    resp != nil,
                                                    statusCode == 200
                                                else {
                                                    /* TODO: Handle errors. For now, the below works. */
                                                    //self.accountPopupSection = "main"
                                                    self.errorLoadingMajorFields = true
                                                    return
                                                }
                                                
                                                guard resp!.keys.contains("Fields") else {
                                                    /* TODO: Handle errors. For now the below works. */
                                                    //self.accountPopupSection = "main"
                                                    self.errorLoadingMajorFields = true
                                                    return
                                                }
                                                
                                                self.errorLoadingMajorFields = false
                                                self.majorFields = resp!["Fields"] as! [String]
                                                self.majorFields.append("Other")
                                                //self.majorField = self.majorFields[0]
                                            }
                                            
                                            /* MARK: Remove the data from the variable when we're done using it to perform the above actions. */
                                            self.temporaryCollegeValue.removeAll()
                                        }
                                    }) { Text("Yes") }
                                    
                                    Button("No", role: .cancel) { }
                                } message: {
                                    Text("Proceeding with this course of action will change your school and you will have to update your major field and major. Do you want to continue?")
                                }
                            }
                        case "switch_field_and_major":
                            ZStack {
                                VStack {
                                    VStack {
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                                    .background(
                                        Image("DefaultThemeBg3")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .padding(.top, 70)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .zIndex(0)
                                
                                VStack {
                                    HStack {
                                        Button(action: { self.accountPopupSection = "main" }) {
                                            ZStack {
                                                Image(systemName: "arrow.backward")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 20, alignment: .leading)
                                            .padding(.top, 15)
                                            .padding(.leading, 25)
                                        }
                                        
                                        Text("Switch Field/Major")
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .padding([.top], 15)
                                            .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                                            
                                        /* MARK: "spacing" to ensure above Text stays in the middle. */
                                        ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                    .padding(.top, prop.isLargerScreen ? 45 : 0)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                VStack {
                                    if self.loadingMajorFields || self.loadingMajors {
                                        Text(self.loadingMajorFields ? "Loading Major Fields" : "Loading Majors")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .medium, size: 14)
                                            .minimumScaleFactor(0.5)
                                        
                                        ProgressView()
                                            .tint(Color.EZNotesBlue)
                                    } else {
                                        if self.errorLoadingMajorFields || self.errorLoadingMajors {
                                            ErrorMessage(
                                                prop: self.prop,
                                                placement: .top,
                                                message: self.errorLoadingMajorFields ? "Failed to obtain major fields from \(self.accountInfo.college)" : "Failed to obtain majors for \(self.temporaryMajorFieldValue)",
                                                showReportProblemButton: true
                                            )
                                        } else {
                                            HStack {
                                                ZStack { }.frame(maxWidth: 10, alignment: .leading)
                                                
                                                ZStack {
                                                    Text(self.switchFieldAndMajorSection == "choose_field"
                                                         ? "Select your field of interest in which you are majoring"
                                                         : "Select your major within the \(temporaryMajorFieldValue) field")
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: prop.isLargerScreen ? 16 : 12, weight: .light))
                                                    .multilineTextAlignment(.center)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                
                                                ZStack { }.frame(maxWidth: 10, alignment: .trailing)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.bottom, 30)
                                            .padding(.top, 10)
                                            
                                            ScrollView(.vertical, showsIndicators: false) {
                                                VStack {
                                                    ForEach(self.switchFieldAndMajorSection == "choose_field"
                                                            ? self.majorFields
                                                            : self.majors, id: \.self) { value in
                                                        Button(action: {
                                                            if self.switchFieldAndMajorSection == "choose_field" {
                                                                self.loadingMajors = true
                                                                self.switchFieldAndMajorSection = "choose_major"
                                                                self.temporaryMajorFieldValue = value
                                                                
                                                                RequestAction<GetMajorsRequestData>(
                                                                    parameters: GetMajorsRequestData(
                                                                        College: self.accountInfo.college,
                                                                        MajorField: value
                                                                    ))
                                                                .perform(action: get_majors_req) { statusCode, resp in
                                                                    self.loadingMajors = false
                                                                    
                                                                    guard resp != nil && statusCode == 200 else {
                                                                        self.errorLoadingMajors = true
                                                                        return
                                                                    }
                                                                    
                                                                    self.majors = resp!["Majors"] as! [String]
                                                                    self.majors.append("Other")
                                                                    self.switchFieldAndMajorSection = "choose_major"
                                                                    //self.major = self.majors[0]
                                                                }
                                                            } else {
                                                                self.temporaryMajorValue = value
                                                                self.updateMajorFieldAndMajorAlert = true
                                                            }
                                                        }) {
                                                            HStack {
                                                                Text(value)
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                    .padding([.leading, .top, .bottom], 10)
                                                                    .foregroundStyle(.white)
                                                                    .font(Font.custom("Poppins-Regular", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                                    .fontWeight(.bold)
                                                                    .minimumScaleFactor(0.5)
                                                                    .multilineTextAlignment(.leading)
                                                                
                                                                ZStack {
                                                                    Image(systemName: "chevron.right")
                                                                        .resizable()
                                                                        .frame(width: 10, height: 15)
                                                                }
                                                                .frame(maxWidth: 20, alignment: .trailing)
                                                                .foregroundStyle(.gray)
                                                                .padding(.trailing, 10)
                                                            }
                                                            .frame(maxWidth: .infinity)
                                                            .padding(10)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                                    .shadow(color: Color.black, radius: 1.5)
                                                            )
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, 60)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .padding([.top, .bottom], -15)
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                                .padding(.top, prop.isLargerScreen ? 80 : 40)
                                .alert("Are you sure?", isPresented: $updateMajorFieldAndMajorAlert) {
                                    Button(action: {
                                        RequestAction<UpdateMajorFieldData>(parameters: UpdateMajorFieldData(
                                            NewMajorField: self.temporaryMajorFieldValue,
                                            AccountID: self.accountInfo.accountID
                                        ))
                                        .perform(action: update_major_field_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                /* TODO: Handle errors. For now this is okay. */
                                                self.accountPopupSection = "main"
                                                return
                                            }
                                            
                                            /* MARK: Upon the initial request being good, attempt to also update the major. */
                                            RequestAction<UpdateMajorData>(parameters: UpdateMajorData(
                                                NewMajor: self.temporaryMajorValue,
                                                AccountID: self.accountInfo.accountID
                                            ))
                                            .perform(action: update_major_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    /* TODO: Handl errors. For now this is okay. */
                                                    self.accountPopupSection = "main"
                                                    return
                                                }
                                                
                                                /* MARK: If updating the major is good, then update the UserDefault values. */
                                                assignUDKey(key: "major_field", value: self.temporaryMajorFieldValue)
                                                assignUDKey(key: "major_name", value: self.temporaryMajorValue)
                                                self.accountInfo.setMajorName(majorName: self.temporaryMajorValue)
                                                
                                                self.temporaryMajorFieldValue.removeAll()
                                                self.temporaryMajorValue.removeAll()
                                                
                                                /* MARK: Reset the "section" of the "Switch Field/Major" view. */
                                                self.switchFieldAndMajorSection = "choose_field"
                                                
                                                /* MARK: Once updating all the information after switching schools, go back to the main section. */
                                                self.accountPopupSection = "main"
                                            }
                                        }
                                    }) { Text("Yes") }
                                    
                                    Button(action: {
                                        self.switchFieldAndMajorSection = "choose_field"
                                    }) { Text("no") }
                                } message: {
                                    Text("Proceeding with this course of action will change your major field and major. Do you want to continue?")
                                }
                            }
                        case "themes":
                            Themes(
                                prop: self.prop,
                                accountPopupSection: $accountPopupSection
                            )
                        case "settings":
                            Settings(
                                prop: self.prop,
                                accountPopupSection: $accountPopupSection
                            )
                        case "planDetails":
                            ZStack {
                                VStack {
                                    VStack {
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                                    .background(
                                        Image("DefaultThemeBg3")
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .padding(.top, 70)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .zIndex(0)
                                
                                VStack {
                                    HStack {
                                        Button(action: { self.accountPopupSection = "main" }) {
                                            ZStack {
                                                Image(systemName: "arrow.backward")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 20, alignment: .leading)
                                            .padding(.top, 15)
                                            .padding(.leading, 25)
                                        }
                                        
                                        Text(self.eznotesSubscriptionManager.getSubscriptionName() != nil ? self.eznotesSubscriptionManager.getSubscriptionName()! : "Plan Details")
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .padding([.top], 15)
                                            .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                                            
                                        /* MARK: "spacing" to ensure above Text stays in the middle. */
                                        ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                    .padding(.top, prop.isLargerScreen ? 45 : 0)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                VStack {
                                    if self.eznotesSubscriptionManager.userSubscriptionIDs.isEmpty {
                                        ErrorMessage(
                                            prop: self.prop,
                                            placement: .center,
                                            message: "No Active Subscriptions"
                                        )
                                    } else {
                                        Spacer()
                                        
                                        Text("Coming Soon.. gotta figure out the new interface being used since Stripe is no longer used :)")
                                            .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 13))
                                        
                                        Button(action: { self.getRickRolled = true }) {
                                            HStack {
                                                Text("Go Back")
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .bold))
                                            }
                                            .frame(maxWidth: prop.size.width - 40)
                                            .padding()
                                            .background(Color.EZNotesBlue)
                                            .cornerRadius(15)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                        .popover(isPresented: $getRickRolled) {
                                            /*WebView(url: URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0")!)
                                             .navigationBarTitle("Get Rick Rolled, Boi", displayMode: .inline)*/
                                            YouTubeVideoView() // Replace with your YouTube video ID
                                                .frame(height: 300) // Set height for the video player
                                                .cornerRadius(10)
                                        }
                                        
                                        Spacer()
                                    }
                                    /*if self.eznotesSubscriptionManager.products.isEmpty {
                                     LoadingView(message: "Loading Plan Details")
                                     } else {
                                     Text("\(self.eznotesSubscriptionManager.products)")
                                     }*/
                                    /* else {
                                     if self.errorLoadingPlanDetailsSection {
                                     ErrorMessage(
                                     prop: prop,
                                     placement: .top,
                                     message: "Error loading plan details"
                                     )
                                     } else {
                                     ScrollView(.vertical, showsIndicators: false) {
                                     /*Text("Overview")
                                      .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                      .foregroundStyle(.white)
                                      .setFontSizeAndWeight(weight: .bold, size: 24)
                                      .minimumScaleFactor(0.5)*/
                                     
                                     HStack {
                                     Text("Next Payment:")
                                     .frame(alignment: .leading)
                                     .padding(.leading, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                     .fontWeight(.bold)
                                     
                                     Text("\(self.subscriptionInfo.CurrentPeriodEnd!.formatted(date: .numeric, time: .shortened))")
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-ExtraLight", size: prop.isLargerScreen ? 16 : 14))
                                     .fontWeight(.semibold)
                                     }
                                     .frame(maxWidth: .infinity)
                                     
                                     HStack {
                                     Text("Period Started:")
                                     .frame(alignment: .leading)
                                     .padding(.leading, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                     .fontWeight(.bold)
                                     
                                     Text("\(self.subscriptionInfo.CurrentPeriodStart!.formatted(date: .numeric, time: .shortened))")
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-ExtraLight", size: prop.isLargerScreen ? 16 : 14))
                                     .fontWeight(.semibold)
                                     }
                                     .frame(maxWidth: .infinity)
                                     
                                     VStack {
                                     Text("Payment")
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.top, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .bold, size: 24)
                                     .minimumScaleFactor(0.5)
                                     
                                     VStack {
                                     HStack {
                                     Text("Monthly Payment:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text(self.subscriptionInfo.Price!)
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-ExtraLight", size: 16))
                                     .fontWeight(.semibold)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom])
                                     
                                     HStack {
                                     Text("Frequency:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text(self.subscriptionInfo.Interval!)
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-ExtraLight", size: 16))
                                     .fontWeight(.semibold)
                                     }
                                     .frame(maxWidth: .infinity)
                                     
                                     HStack {
                                     Text("Total Payments:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text("\(self.subscriptionInfo.Lifetime!)")
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 30)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-ExtraLight", size: 16))
                                     .fontWeight(.semibold)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom])
                                     
                                     Divider()
                                     .background(.white)
                                     .frame(maxWidth: prop.size.width - 80)
                                     .padding(.bottom)
                                     
                                     VStack {
                                     HStack {
                                     VStack {
                                     ZStack {
                                     Text(self.subscriptionInfo.CardBrand!.uppercased())
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding([.top, .leading], 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .bold, size: 50)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(maxWidth: .infinity, maxHeight: 30, alignment: .top)
                                     
                                     Spacer()
                                     
                                     VStack {
                                     VStack {
                                     ZStack {
                                     Image("Debit-Card-Chip")
                                     .resizable()
                                     .frame(width: 30, height: 30)
                                     }
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.leading, 20)
                                     
                                     Text("XXXX XXXX XXXX \(self.subscriptionInfo.Last4!)")
                                     .frame(maxWidth: prop.size.width - 50, minHeight: 22, alignment: .leading)
                                     .padding(.leading, 20)
                                     .foregroundStyle(
                                     MeshGradient(width: 3, height: 3, points: [
                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                     ], colors: [
                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                     .white, Color.EZNotesBlue, Color.EZNotesOrange,
                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                     ])
                                     )
                                     .setFontSizeAndWeight(weight: .bold, size: 18)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(alignment: .leading)
                                     .padding(.top, 8)
                                     
                                     VStack {
                                     HStack {
                                     HStack {
                                     Text("Valid Thru")
                                     .frame(maxWidth: 25, alignment: .leading)//(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.leading, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .light, size: 10)
                                     .minimumScaleFactor(0.5)
                                     .multilineTextAlignment(.center)
                                     
                                     Text("\(self.subscriptionInfo.CardExpMonth!)/\(self.subscriptionInfo.CardExpYear!)")
                                     .frame(maxWidth: .infinity, alignment: .leading)//(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.leading, 5)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .medium, size: 13)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(alignment: .leading)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom], 8)
                                     
                                     Text("\(self.subscriptionInfo.CardHolderName!)")
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.leading, 20)
                                     .padding(.bottom, 8)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .light, size: 15)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(maxWidth: .infinity)
                                     }
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.top, 20)
                                     
                                     Spacer()
                                     
                                     
                                     }
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     
                                     VStack {
                                     Spacer() /* MARK: Shove the "logo" to the bottom. */
                                     
                                     ZStack {
                                     Image("Logo")
                                     .resizable()
                                     .frame(width: 60, height: 60)
                                     }
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 10)
                                     .padding(.bottom, 5)
                                     }
                                     .frame(maxWidth: 60, alignment: .trailing)
                                     }
                                     }
                                     .frame(maxWidth: prop.size.width - 70, minHeight: 200)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(.black)
                                     .shadow(color: Color.black, radius: 1.5)
                                     )
                                     .cornerRadius(15)
                                     
                                     VStack {
                                     Button(action: { print("Update card") }) {
                                     HStack {
                                     Text("Update Card Details")
                                     .frame(maxWidth: .infinity, alignment: .center)
                                     .padding([.top, .bottom], 8)
                                     .foregroundStyle(.black)
                                     .setFontSizeAndWeight(weight: .bold, size: 18)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(maxWidth: prop.size.width - 80)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(.white)
                                     )
                                     .cornerRadius(15)
                                     }
                                     .buttonStyle(NoLongPressButtonStyle())
                                     
                                     Text("This is not a real debit card, this is for visual purposes only.")
                                     .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                     .padding(.leading, 10)
                                     .padding([.top, .bottom], 5)
                                     .foregroundStyle(.gray)
                                     .setFontSizeAndWeight(weight: .light, size: 12)
                                     .minimumScaleFactor(0.5)
                                     .multilineTextAlignment(.leading)
                                     }
                                     .frame(maxWidth: prop.size.width - 60)
                                     .padding(.top, 8)
                                     }
                                     .frame(maxWidth: prop.size.width - 40)
                                     .padding([.top, .bottom], 14)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(Color.EZNotesBlack)
                                     .shadow(color: Color.black, radius: 1.5)
                                     )
                                     
                                     Text("Specifics")
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.top, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .bold, size: 24)
                                     .minimumScaleFactor(0.5)
                                     
                                     VStack {
                                     HStack {
                                     Text("Subscription ID:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 20)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text(self.subscriptionInfo.PlanID!)
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .heavy, size: 16)//(Font.custom("Poppins-ExtraLight", size: 16))
                                     // .fontWeight(.heavy)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom])
                                     
                                     HStack {
                                     Text("Subscription Price ID:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 20)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text(self.subscriptionInfo.PriceID!)
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .heavy, size: 16)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom])
                                     
                                     HStack {
                                     Text("Subscription Service ID:")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .padding(.leading, 20)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .fontWeight(.bold)
                                     
                                     Text(self.subscriptionInfo.ProductID!)
                                     .frame(maxWidth: .infinity, alignment: .trailing)
                                     .padding(.trailing, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .heavy, size: 16)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .padding([.top, .bottom])
                                     }
                                     .frame(maxWidth: prop.size.width - 40)
                                     .padding(.top, 14)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(Color.EZNotesBlack)
                                     .shadow(color: Color.black, radius: 1.5)
                                     )
                                     
                                     Text("These IDs enable you to have a more feasible experience with our team when problems arise with payments, plan conversions or cancellations. **Do not share this data with anyone.**")
                                     .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                                     .padding(.leading, 5)
                                     .foregroundStyle(.gray)
                                     .setFontSizeAndWeight(weight: .light, size: 12)
                                     .minimumScaleFactor(0.5)
                                     .multilineTextAlignment(.leading)
                                     
                                     Text("Actions")
                                     .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                     .padding(.top, 20)
                                     .foregroundStyle(.white)
                                     .setFontSizeAndWeight(weight: .bold, size: 24)
                                     .minimumScaleFactor(0.5)
                                     
                                     VStack {
                                     Button(action: {
                                     /* TODO: Add endpoint in backend the will remove the users subscription from stripe. */
                                     
                                     self.accountPopupSection = "setup_plan"
                                     }) {
                                     HStack {
                                     Text("Switch Plans")
                                     .frame(maxWidth: .infinity, alignment: .center)
                                     .padding([.top, .bottom], 8)
                                     .foregroundStyle(.black)
                                     .setFontSizeAndWeight(weight: .bold, size: 18)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(.white)
                                     )
                                     .cornerRadius(15)
                                     }
                                     .buttonStyle(NoLongPressButtonStyle())
                                     
                                     Button(action: {
                                     print("Deactivate Plan")
                                     
                                     /* TODO: Add endpoint that removes the users plan. Upon deactivating the plan, the account will be deleted. */
                                     }) {
                                     HStack {
                                     Text("Deactivate Plan")
                                     .frame(maxWidth: .infinity, alignment: .center)
                                     .padding([.top, .bottom], 8)
                                     .foregroundStyle(.black)
                                     .setFontSizeAndWeight(weight: .bold, size: 18)
                                     .minimumScaleFactor(0.5)
                                     }
                                     .frame(maxWidth: .infinity)
                                     .background(
                                     RoundedRectangle(cornerRadius: 15)
                                     .fill(Color.EZNotesRed)
                                     )
                                     .cornerRadius(15)
                                     }
                                     .buttonStyle(NoLongPressButtonStyle())
                                     .padding(.top, 5)
                                     }
                                     .frame(maxWidth: prop.size.width - 40)
                                     .padding(.bottom, 30)
                                     }
                                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                                     }
                                     }
                                     }*/
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 40)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        default:
                            ZStack { }.onAppear(perform: { self.accountPopupSection = "main" })
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    /*Rectangle()
                        .fill(.clear)
                        .cornerRadius(15, corners: prop.isLargerScreen ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.topLeft, .topRight])
                        .shadow(color: .black, radius: 6.5)*/
                    .clear
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.offset(y: self.bodyYOffset)
            .padding(.top, self.accountPopupSection == "main" ? 20 : 0)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea([.top, .bottom]/*self.accountPopupSection == "main"
                               ? [.bottom, .top]
                               : prop.isLargerScreen ? [.bottom] : [.top, .bottom]*/
        )
        .background(.black)
    }
}
