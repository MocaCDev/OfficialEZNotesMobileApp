//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import PhotosUI
import Combine
import WebKit

struct ProfileIconView: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.EZNotesBlue)
                
            Button(action: { self.showAccountPopup = true }) {
                /*Image(systemName: "person.crop.circle.fill")*/
                self.accountInfo.profilePicture
                    .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                    .scaledToFill()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipShape(.circle)
                    
                    .foregroundStyle(.white)
            }
            .buttonStyle(NoLongPressButtonStyle())
        }
        .frame(width: 38, height: 38)
        .padding([.leading], 20)
    }
}

struct AccountPopup: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    
    @State private var launchPhotoGallery: Bool = false
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var photoGalleryLaunchedFor: String = "pfp" /* MARK: Value can be `pfp` or `pfp_bg`. */
    @State private var pfpUploadStatus: String = "none"
    @State private var pfpBgUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    @State private var errorUploadingPFPBg: Bool = false
    @State private var showPrivacyAndPolicy: Bool = false
    @State private var showTermsAndConditions: Bool = false
    @State private var changingProfilePic: Bool = false
    @State private var subscriptionInfo: SubscriptionInfo = .init(
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
    )
    @State private var accountPopupSection: String = "main"
    @State private var switchFieldAndMajorSection: String = "choose_field" /* MARK: Values will be "choose_field" or "choose_major". This variable is adherent strictly to the "switch_field_and_major" section. */
    
    /* MARK: This is for the binding `makeContentRed` for `Plans` view. */
    @State public var p: Bool = false
    
    func doSomething() { print("YES") }
    
    var borderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesBlue, Color.EZNotesOrange]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    var borderBottomColorError: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesRed, Color.EZNotesRed]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /* MARK: For time being, until I am able (have time) to move the code into a separate file, the below variables are used when buttons such as "Switch Schools" or "Switch States" are clicked. */
    @State private var colleges: Array<String> = []
    @State private var temporaryCollegeValue: String = ""
    @State private var majorFields: Array<String> = []
    @State private var temporaryMajorFieldValue: String = ""
    @State private var majors: Array<String> = []
    @State private var temporaryMajorValue: String = ""
    //@State private var temporaryStateValue: String = ""
    @State private var updateCollegeAlert: Bool = false
    @State private var updateMajorFieldAndMajorAlert: Bool = false
    //@State private var updateStateAlert: Bool = false
    @State private var loadingPlanDetailsSection: Bool = false
    @State private var errorLoadingPlanDetailsSection: Bool = false
    @State private var loadingChangeSchoolsSection: Bool = false
    @State private var errorLoadingChangeSchoolsSection: Bool = false
    @State private var loadingMajors: Bool = false
    @State private var errorLoadingMajors: Bool = false
    @State private var loadingMajorFields: Bool = false
    @State private var errorLoadingMajorFields: Bool = false
    //@State private var errorUpdatingStateName: Bool = false
    
    /* TODO: The exact same variable is in `SignUpScreen.swift`. We need to create a class that will hold these variables to be used anywhere. */
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
    
    
    /* MARK: Animation for the status bar the prompts whether or not the change of display or PFP was a success. */
    @State private var statusBarYOffset: CGFloat = 0
    
    /* MARK: Variable for y offset of the body (under the "Change PFP" and "Change Display" buttons). */
    @State private var bodyYOffset: CGFloat = 0
    
    /* MARK: Variable for y offset of top of the body (part that shows PFP, display background, username etc). */
    @State private var topBodyYOffset: CGFloat = 0
    
    /* MARK: Variables for `change_password` section. */
    /* TODO: Should we add a state for changing the bottom border of the password textfields to red? */
    @State private var newPassword: String = ""
    @State private var newPasswordTooShort: Bool = false
    @State private var oldPassword: String = ""
    @State private var oldPasswordTooShort: Bool = false
    @State private var changePasswordAlert: Bool = false
    @State private var wrongOldPassword: Bool = false
    @State private var errorUpdatingPassword: Bool = false
    @State private var passwordUpdated: Bool = false
    @State private var oldAndNewPasswordsAreTheSame: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                if self.pfpUploadStatus == "failed" || self.pfpBgUploadStatus == "failed" {
                    HStack {
                        ZStack {
                            
                        }
                        .frame(maxWidth: 25, alignment: .leading)
                        
                        if self.errorUploadingPFP {
                            Text("Error saving PFP. Try Again.")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .minimumScaleFactor(0.5)
                        } else {
                            Text("Error saving PFP Background. Try Again.")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .minimumScaleFactor(0.5)
                        }
                        
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
                        .frame(maxWidth: 25, maxHeight: .infinity, alignment: .trailing)
                        .padding(.trailing, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .background(Color.EZNotesRed)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 3)) {
                                self.statusBarYOffset = -prop.size.height //-UIScreen.main.bounds.height
                            }
                            
                            /* MARK: Wait another second and ensure the status bar view is invisible. */
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                                Text("Updated PFP")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    //.padding(.top, 8)
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Poppins-Regular", size: 12))
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text("Updated PFP Background")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    ///.padding(.top, 8)
                                    .foregroundStyle(.black)
                                    .font(Font.custom("Poppins-Regular", size: 12))//.setFontSizeAndWeight(weight: .medium)
                                    .minimumScaleFactor(0.5)
                            }
                            
                            ZStack {
                                Button(action: {
                                    if self.pfpUploadStatus != "none" { self.pfpUploadStatus = "none" }
                                    else {
                                        self.pfpBgUploadStatus = "none"
                                    }
                                }) {
                                    Image(systemName: "multiply")
                                        .resizableImage(width: 12, height: 12)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                            .frame(maxWidth: 25, maxHeight: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .background(Color.EZNotesGreen)
                        .offset(y: self.statusBarYOffset)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut(duration: 3)) {
                                    self.statusBarYOffset = -prop.size.height //-UIScreen.main.bounds.height
                                }
                                
                                /* MARK: Wait another second and ensure the status bar view is invisible. */
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if self.pfpUploadStatus != "none" { self.pfpUploadStatus = "none"; return }
                                    self.pfpBgUploadStatus = "none"
                                }
                            }
                        }
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
                                        //.resizableImageFill(width: prop.size.height / 2.5 > 300 ? 90 : 80, height: prop.size.height / 2.5 > 300 ? 90 : 80)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: prop.isLargerScreen ? 90 : 80, height: prop.isLargerScreen ? 90 : 80, alignment: .center)
                                            .minimumScaleFactor(0.8)
                                            .foregroundStyle(.white)
                                            .clipShape(.rect)
                                            .cornerRadius(15)
                                            .shadow(color: .black, radius: 2.5)
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
                                            )
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
                                                            self.errorUploadingPFP = true
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
                                .padding(.leading, 15)
                                .padding([.top, .bottom])
                                
                                VStack {
                                    HStack {
                                        Text("\(self.accountInfo.username)")
                                        //.frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .semibold, size: 20, design: .rounded)
                                        
                                        Divider()
                                            .background(.white)
                                            .frame(alignment: .leading)
                                        
                                        Text("0 Friends")
                                            .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .semibold, size: 18, design: .rounded)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                    
                                    Text(self.accountInfo.email)
                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .setFontSizeAndWeight(weight: .medium, size: 14, design: .rounded)
                                        .minimumScaleFactor(0.5)
                                    
                                    HStack {
                                        Text("Majoring in **\(self.accountInfo.major)** at **\(self.accountInfo.college)**")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.leading)
                                        /*Text(self.accountInfo.college != "" ? self.accountInfo.college : "No University")
                                            .frame(maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .light, size: 14, design: .rounded)
                                            .minimumScaleFactor(0.5)
                                        
                                        Divider()
                                            .frame(height: 10)
                                            .overlay(Color.white)
                                        
                                        Text(self.accountInfo.major != "" ? self.accountInfo.major : "No Major")
                                            .frame(maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .light, size: 14, design: .rounded)
                                            .minimumScaleFactor(0.5)*/
                                    }
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
                                        .fill(.gray.opacity(0.65))
                                        .stroke(.white, lineWidth: 1)
                                )
                                
                                ZStack {
                                    PhotosPicker(selection: $pfpBackgroundPhotoPicked) {
                                        Text("Change Display")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding()
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
                                        .fill(.gray.opacity(0.65))
                                        .stroke(.white, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: 30)
                            .padding(.leading, -10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 180, alignment: .bottomLeading)
                    .padding(.leading, 5)
                    .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding([.bottom], self.pfpUploadStatus != "none" || self.pfpBgUploadStatus != "none" ? -10 : -10)
                .padding(.top, self.pfpUploadStatus != "none" || self.pfpBgUploadStatus != "none" ? 2 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: 220)
            .background(
                accountInfo.profileBackgroundPicture
                    .resizableImageFill()
                    .overlay(Color.EZNotesBlack.opacity(0.35))
                    .blur(radius: 2.5)
            )
            .offset(y: self.topBodyYOffset)
            
            VStack {
                VStack {
                    HStack {
                        if self.accountPopupSection != "main" {
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
                        } else { ZStack { }.frame(maxWidth: 20, alignment: .leading).padding(.leading, 25) }
                        
                        Text(self.accountPopupSection == "main"
                             ? "Account Details"
                             : self.accountPopupSection == "planDetails"
                                ? self.subscriptionInfo.ProductName != nil
                                    ? self.subscriptionInfo.ProductName!
                                    : self.errorLoadingPlanDetailsSection ? "Plan Details" : "Select Plan"
                                : self.accountPopupSection == "switch_college"
                                    ? "Switch College"
                                    : self.accountPopupSection == "switch_field_and_major"
                                        ? "Switch Field/Major"
                                        : self.accountPopupSection == "switch_state"
                                            ? "Change States"
                                            : self.accountPopupSection == "change_username"
                                                ? "Change Username"
                                                : self.accountPopupSection == "update_password"
                                                    ? "Update Password"
                                                    : self.accountPopupSection == "themes"
                                                        ? "Themes"
                                                        : self.accountPopupSection == "settings"
                                                            ? "Settings"
                                                            /* MARK: Default value if all aforementioned checks fail (which should never happen). */
                                                            : "Account Details")
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .foregroundStyle(.white)
                        .padding([.top], 15)
                        .setFontSizeAndWeight(weight: .bold, size: 20)
                        
                        /* MARK: "spacing" to ensure above Text stays in the middle. */
                        ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                    }
                    
                    Divider()
                        .background(.white)
                        .frame(width: prop.size.width - 50)
                        .padding([.top, .bottom])
                    
                    if self.accountPopupSection == "main" {
                        VStack {
                            VStack { }.frame(maxWidth: .infinity, maxHeight: 5)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                Text("Account & Management")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .bold, size: 20)
                                    .minimumScaleFactor(0.5)
                                
                                VStack {
                                    Button(action: {
                                        self.accountPopupSection = "change_username"
                                    }) {
                                        HStack {
                                            Text("Change Username")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
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
                                        .overlay(.black)
                                    
                                    Button(action: {
                                        self.accountPopupSection = "update_password"
                                    }) {
                                        HStack {
                                            Text("Update Password")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
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
                                        .overlay(.black)
                                    
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
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
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
                                        .overlay(.black)
                                    
                                    Button(action: { self.accountPopupSection = "switch_state" }) {
                                        HStack {
                                            Text("Change States")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                                .padding(.leading, 15)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
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
                                        .overlay(.black)
                                    
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
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                            
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
                                        .fill(Color.EZNotesBlack)
                                        .shadow(color: Color.black, radius: 1.5)
                                    /*.stroke(LinearGradient(gradient: Gradient(
                                     colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                     ), startPoint: .leading, endPoint: .trailing), lineWidth: 1)*/
                                )
                                //.cornerRadius(15)
                                
                                /* MARK: Custom `spacer`. Scrollview makes all the views within it kind of funky. */
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 20)
                                
                                Text("Core Actions")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.bold)
                                
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
                                            self.accountPopupSection = "planDetails"
                                            self.loadingPlanDetailsSection = true
                                            
                                            RequestAction<GetSubscriptionInfoData>(parameters: GetSubscriptionInfoData(AccountID: self.accountInfo.accountID))
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
                                                }
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
                                
                                Divider()
                                    .background(Color.black)
                                    .padding([.top, .bottom], 10)
                                
                                Text("Privacy & Terms")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    .padding(.bottom, 10)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.bold)
                                
                                VStack {
                                    Button(action: { self.showPrivacyAndPolicy = true }) {
                                        HStack {
                                            Text("Privacy & Policy")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .popover(isPresented: $showPrivacyAndPolicy) {
                                        WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                                            .navigationBarTitle("Privacy Policy", displayMode: .inline)
                                    }
                                    
                                    Divider()
                                        .frame(width: prop.size.width - 80)
                                        .overlay(.black)
                                    
                                    Button(action: { self.showTermsAndConditions = true }) {
                                        HStack {
                                            Text("Terms & Conditions")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .popover(isPresented: $showTermsAndConditions) {
                                        WebView(url: URL(string: "https://www.eznotes.space/terms_and_conditions")!)
                                            .navigationBarTitle("Terms & Conditions", displayMode: .inline)
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 8)
                                .padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                                
                                /* MARK: More details will show the user their account ID, session ID etc. */
                                Text("Additional")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    .padding([.top, .bottom], 10)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .bold, size: 20)
                                    .minimumScaleFactor(0.5)
                                
                                VStack {
                                    Button(action: { print("View More Account Details") }) {
                                        HStack {
                                            Text("More Account Details")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 20, alignment: .trailing)
                                            .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .onTapGesture {
                                            print("Show more account details")
                                        }
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .frame(width: prop.size.width - 80)
                                        .overlay(.black)
                                    
                                    Button(action: { print("Report An Issue") }) {
                                        HStack {
                                            Text("Report An Issue")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .onTapGesture {
                                            print("Report An Issue")
                                        }
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 8)
                                .padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                                
                                Text("Account Actions")
                                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                    .padding([.top, .bottom], 10)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .bold, size: 20)
                                    .minimumScaleFactor(0.5)
                                
                                VStack {
                                    Button(action: { print("Delete Account") }) {
                                        HStack {
                                            Text("Delete Account")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Divider()
                                        .frame(width: prop.size.width - 80)
                                        .overlay(.black)
                                    
                                    Button(action: {
                                        assignUDKey(key: "logged_in", value: false)
                                        self.userHasSignedIn = false
                                        self.accountInfo.reset()
                                        
                                        udRemoveAllAccountInfoKeys()
                                    }) {
                                        HStack {
                                            Text("Logout")
                                                .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom])
                                                .foregroundStyle(.white)
                                                .setFontSizeAndWeight(weight: .semibold, size: 15)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 50)
                                .padding([.top, .bottom], 8)
                                .padding([.leading, .trailing], 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.EZNotesLightBlack)
                                )
                                .cornerRadius(15)
                                
                                Text("Joined 10/10/2024")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding([.top, .bottom], 40)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .medium)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, -20)
                    } else {
                        switch(self.accountPopupSection) {
                        case "setup_plan":
                            Plans(
                                prop: prop,
                                email: self.accountInfo.email,
                                accountID: self.accountInfo.accountID,
                                isLargerScreen: prop.isLargerScreen,
                                action: doSomething
                            )
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
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: prop.size.width - 40 , maxHeight: .infinity)
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
                        case "switch_field_and_major":
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
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
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
                        case "themes":
                            Themes(
                                prop: self.prop
                            )
                        case "settings":
                            Settings(
                                prop: self.prop
                            )
                        case "planDetails":
                            VStack {
                                if self.loadingPlanDetailsSection {
                                    LoadingView(message: "Loading Plan Details")
                                } else {
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
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        default:
                            ZStack { }.onAppear(perform: { self.accountPopupSection = "main" })
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Rectangle()
                        .fill(Color.EZNotesBlack)
                        .cornerRadius(15, corners: prop.isLargerScreen ? [.topLeft, .topRight, .bottomLeft, .bottomRight] : [.topLeft, .topRight])
                        .shadow(color: .black, radius: 6.5)
                )
                .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: self.bodyYOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .onAppear {
            /* MARK: Initiation for animations of the parts of the popup. */
            self.bodyYOffset = prop.size.height - 100
            self.topBodyYOffset = -prop.size.height
            
            /* MARK: 0.4 second duration seems to align well with the rate in which the popup comes into focus. */
            withAnimation(.easeOut(duration: 0.4)) {
                self.bodyYOffset = 0 //-UIScreen.main.bounds.height
                self.topBodyYOffset = 0
            }
        }
    }
}

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TopNavHome: View {
    @ObservedObject public var accountInfo: AccountDetails
    @ObservedObject public var categoryData: CategoryData
    
    @Binding public var showAccountPopup: Bool
    @State private var aiChatPopover: Bool = false
    
    var prop: Properties
    var backgroundColor: Color
    //var categoriesAndSets: [String: Array<String>]
    
    @Binding public var changeNavbarColor: Bool
    @Binding public var navbarOpacity: Double
    @Binding public var categorySearch: String
    @Binding public var searchDone: Bool
    
    @State private var deleteAllMessagesConfirmAlert: Bool = false
    @State private var showSearchBar: Bool = false
    @FocusState private var categorySearchFocus: Bool
    /*@State private var userSentMessages: Array<String> = []//["Hi!", "What is 2+2?", "Yes"]
    @State private var systemResponses: Array<String> = []*///["Hello, how can I help you?", "2+2 is 4, would you like to know more?"]
    //@State private var messages: [String: String] = [:] /* MARK: Key is the user sent message, value is the AI response. */
    @State private var systemResponses: [String: String] = [:] /* MARK: Key will be the user sent message, value will be the AI response */
    @State private var waitingToSend: Array<String> = []
    @State private var processingMessage: Bool = false
    @State private var messageInput: String = ""
    @State private var hideLeftsideContent: Bool = false
    @State private var aiIsTyping: Bool = false
    @State private var messageBoxTapped: Bool = false
    @State private var currentYPosOfMessageBox: CGFloat = 0
    @State private var chatIsLive: Bool = false
    @State private var creatingNewChat: Bool = false
    @State private var errorGeneratingTopicsForMajor: Bool = false
    
    @Binding public var messages: Array<MessageDetails>
    @Binding public var lookedUpCategoriesAndSets: [String: Array<String>]
    @Binding public var userHasSignedIn: Bool
    @Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    
    @State private var numberOfTheAnimationgBall = 3
    
    // MAKR: - Drawing Constants
    let ballSize: CGFloat = 10
    let speed: Double = 0.3
    let chatUUID: UUID = UUID()
    
    let topicsColumns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    @State private var loadingTopics: Bool = false
    @State private var generatedTopics: Array<String> = []
    @State private var generatedTopicsImages: [String: Data] = [:]
    @State private var topicPicked: String = ""
    
    var body: some View {
        HStack {
            HStack {
                VStack {
                    ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
                }
                .frame(alignment: .leading)
                .padding(.bottom, 20)//.padding(.top, prop.size.height / 2.5 > 300 ? 50 : 15) /* MARK: Aligns icon for larger screens. */
                //.padding(.bottom, prop.size.height / 2.5 > 300 ? 0 : 10) /* MARK: Aligns icon for smaller screens. */
                //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
                
                if self.showSearchBar {
                    VStack {
                        TextField(
                            prop.size.height / 2.5 > 300 ? "Search Categories..." : "Search...",
                            text: $categorySearch
                        )
                        .frame(
                            maxWidth: .infinity,/*prop.isIpad
                                                 ? UIDevice.current.orientation.isLandscape
                                                 ? prop.size.width - 800
                                                 : prop.size.width - 450
                                                 : 150,*/
                            maxHeight: prop.isLargerScreen ? 20 : 15
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
                                
                                //if self.categorySearchFocus || self.categorySearch != "" {
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
                                //}
                            }
                        )
                        .onSubmit {
                            if !(self.categorySearch == "") {
                                self.lookedUpCategoriesAndSets.removeAll()
                                
                                for (_, value) in self.categoryData.categoriesAndSets.keys.enumerated() {
                                    if value.lowercased() == self.categorySearch.lowercased() || value.lowercased().contains(self.categorySearch.lowercased()) {
                                        self.lookedUpCategoriesAndSets[value] = self.categoryData.categoriesAndSets[value]
                                        
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
                    .padding(.bottom, 20)
                    .padding(.trailing, 10)
                    .padding(.leading, -10)
                    //.padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)//.padding(.top, 10)
                }
            }
            .frame(maxWidth: self.showSearchBar ? .infinity : 90, alignment: .leading)
            
            if !self.showSearchBar {
                Spacer()
            }
    
            if self.changeNavbarColor {
                VStack {
                    Text("View Categories")
                        .foregroundStyle(.primary)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.semibold)
                    
                    Text("Total: \(self.categoryData.categoriesAndSets.count)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, 20)
                //.padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)
            }
            
            Spacer()
            
            HStack {
                ZStack {
                    Button(action: {
                        if self.categoryData.categoriesAndSets.count > 0 {
                            if self.showSearchBar { self.showSearchBar = false; return }
                            self.showSearchBar = true
                        }
                    }) {
                        Image("SearchIcon")//(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.EZNotesOrange)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(width: 30, height: 30)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                
                ZStack {
                    Button(action: { self.aiChatPopover = true }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                            )
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(
                    width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                    height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                )
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                .padding([.trailing], 20)
            }
            .frame(maxWidth: 90, maxHeight: .infinity, alignment: .trailing)
            //.padding(.top, prop.size.height / 2.5 > 300 ? 40 : 0)
            .padding(.bottom, 20)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
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
        .onChange(of: self.aiChatPopover) {
            if !self.aiChatPopover {
                
                /* MARK: Don't do anything if there was no topic picked. */
                if self.topicPicked == "" {
                    /* MARK: Remove generated topics if none were picked (that way when the popover is initiated again, the user has to click "New Chat". */
                    self.generatedTopics.removeAll()
                    return
                }
                
                self.tempChatHistory[self.topicPicked] = [self.accountInfo.aiChatID: self.messages]
                writeTemporaryChatHistory(chatHistory: self.tempChatHistory)
                
                self.topicPicked = ""
                self.generatedTopics.removeAll()
                self.chatIsLive = false
                self.messages.removeAll()
            }
        }
        /* TODO: Change from popover to an actual view. */
        .popover(isPresented: $aiChatPopover) {
            AIChat(
                prop: self.prop,
                accountInfo: self.accountInfo,
                tempChatHistory: $tempChatHistory,
                messages: $messages
            )
            /*VStack {
                if self.loadingTopics {
                    VStack {
                        Text("Loading Topics")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .setFontSizeAndWeight(weight: .medium, size: 20)
                            .minimumScaleFactor(0.5)
                        
                        ProgressView()
                            .tint(Color.EZNotesBlue)
                    }
                    .frame(maxWidth: prop.size.width - 100, maxHeight: .infinity, alignment: .center)
                    .padding()
                } else {
                    HStack {
                        if self.topicPicked != "" || self.chatIsLive {
                            Button(action: {
                                /* MARK: First, save the message history. */
                                self.tempChatHistory[self.topicPicked] = [self.accountInfo.aiChatID: self.messages]
                                writeTemporaryChatHistory(chatHistory: self.tempChatHistory)
                                
                                self.chatIsLive = false
                                
                                self.topicPicked = ""
                                self.generatedTopics.removeAll()
                                self.chatIsLive = false
                                self.messages.removeAll()
                            }) {
                                ZStack {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.EZNotesBlue)
                                }
                                .frame(maxWidth: 30, alignment: .leading)
                            }
                        }
                        
                        Text(self.topicPicked == ""
                             ? self.chatIsLive
                                ? "Unknown Topic"
                                : self.generatedTopics.count == 0
                                    ? "EZNotes AI Chat"
                                    : "Select Topic"
                             : self.topicPicked)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .font(.system(size: prop.size.height / 2.5 > 300 ? 30 : 26, design: .rounded))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.5)
                        
                        if self.topicPicked != "" || self.chatIsLive { ZStack{ }.frame(maxWidth: 30, alignment: .trailing) }
                    }
                    .frame(maxWidth: prop.size.width - 40, maxHeight: 50, alignment: .top)
                    .border(width: 0.5, edges: [.bottom], color: .gray)
                    
                    if !self.chatIsLive {
                        if !self.errorGeneratingTopicsForMajor {
                            HStack {
                                Button(action: {
                                    self.loadingTopics = true
                                    
                                    RequestAction<GetCustomTopicsData>(parameters: GetCustomTopicsData(Major: self.accountInfo.major))
                                        .perform(action: get_custom_topics_req) { statusCode, resp in
                                            self.loadingTopics = false
                                            guard resp != nil && statusCode == 200 else {
                                                if let resp = resp { print(resp) }
                                                self.errorGeneratingTopicsForMajor = true
                                                return
                                            }
                                            
                                            self.generatedTopics = resp!["Topics"] as! [String]
                                            /*let images = resp!["Images"] as! [String: Any]
                                            
                                            for (key, value) in images {
                                                self.generatedTopicsImages[key] = Data(base64Encoded: value as! String)
                                            }
                                            
                                            print(self.generatedTopics)*/
                                        }
                                }) {
                                    HStack {
                                        Text("New Chat")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.medium)
                                    }
                                    .padding([.top, .bottom], 4)
                                    .padding([.leading, .trailing], 8)
                                    .background(Color.white.shadow(color: .black, radius: 2.5))
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding([.top, .bottom])
                                
                                Button(action: {
                                    self.deleteAllMessagesConfirmAlert = true
                                }) {
                                    HStack {
                                        Text("Delete All")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.medium)
                                    }
                                    .padding([.top, .bottom], 4)
                                    .padding([.leading, .trailing], 8)
                                    .background(Color.EZNotesRed.shadow(color: .black, radius: 2.5))
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding([.top, .bottom])
                                .alert("Are You Sure?", isPresented: $deleteAllMessagesConfirmAlert) {
                                    Button(action: {
                                        self.tempChatHistory.removeAll()
                                        writeTemporaryChatHistory(chatHistory: self.tempChatHistory)
                                    }) {
                                        Text("Yes")
                                    }
                                    
                                    Button("No", role: .cancel) { }
                                } message: {
                                    Text("By clicking Yes, you will effectively delete all of your \(self.tempChatHistory.count) chats.")
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        }
                    }
                    
                    if self.chatIsLive {
                        ZStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack {
                                        ForEach(messages, id: \.self) { message in
                                            MessageView(message: message, aiIsTyping: $aiIsTyping)
                                                .id(message)
                                        }
                                        
                                        if self.aiIsTyping {
                                            HStack(alignment: .firstTextBaseline) {
                                                ForEach(0..<3) { i in
                                                    Capsule()
                                                        .foregroundColor((self.numberOfTheAnimationgBall == i) ? .blue : Color(UIColor.darkGray))
                                                        .frame(width: self.ballSize, height: self.ballSize)
                                                        .offset(y: (self.numberOfTheAnimationgBall == i) ? -5 : 0)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .animation(Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1).speed(2), value: UUID())
                                            .onAppear {
                                                Timer.scheduledTimer(withTimeInterval: self.speed, repeats: true) { _ in
                                                    var randomNumb: Int
                                                    repeat {
                                                        randomNumb = Int.random(in: 0...2)
                                                    } while randomNumb == self.numberOfTheAnimationgBall
                                                    self.numberOfTheAnimationgBall = randomNumb
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: messages) {
                                        withAnimation {
                                            proxy.scrollTo(messages.last)
                                        }
                                    }
                                    /*.onChange(of: self.aiIsTyping) {
                                        //if self.aiIsTyping {
                                        //    proxy.scrollTo(self.chatUUID)
                                        //}
                                    }*/
                                    .onChange(of: self.messageBoxTapped) {
                                        withAnimation {
                                            proxy.scrollTo(messages.last)
                                        }
                                    }
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(messages.last, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            self.messageBoxTapped = false
                        }
                        
                        Spacer()
                        
                        HStack {
                            if !self.hideLeftsideContent {
                                VStack {
                                    Button(action: { print("Upload File") }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .frame(width: 15, height: 20)
                                            .foregroundStyle(.white)//(Color.EZNotesOrange)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 2.5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.leading, 10)
                                
                                VStack {
                                    Button(action: { print("Take live picture to get instant feedback") }) {
                                        Image(systemName: "camera")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                
                                VStack {
                                    Button(action: { print("Select category to talk to the AI chat about") }) {
                                        Image("Categories-Icon")
                                            .resizableImage(width: 15, height: 15)
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.trailing, 5)
                            }
                            
                            VStack {
                                TextField("Message...", text: $messageInput, axis: .vertical)
                                    .frame(maxWidth: prop.size.width - 40, minHeight: 30)
                                    .padding([.top, .bottom], 4)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 35)
                                    .cornerRadius(7.5)
                                    .padding(.horizontal, 5)
                                    .keyboardType(.alphabet)
                                    .background(
                                        self.hideLeftsideContent
                                        ? AnyView(RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .stroke(LinearGradient(gradient: Gradient(
                                                colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                            ), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
                                        : AnyView(RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .border(width: 1, edges: [.bottom], lcolor: LinearGradient(gradient: Gradient(
                                                colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                            ), startPoint: .leading, endPoint: .trailing)))
                                    )
                                    .foregroundStyle(.white)
                                    .overlay(
                                        HStack {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .preference(key: ViewPositionKey.self, value: geometry.frame(in: .global).minY)
                                            }.frame(width: 0, height: 0)
                                            
                                            /* MARK: Exists to push the `x` button to the end of the textfield. */
                                            VStack { }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            
                                            if self.messageInput.count > 0 {
                                                Button(action: {
                                                    self.messageInput.removeAll()
                                                }) {
                                                    Image(systemName: "multiply.circle.fill")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing, 15)
                                                }
                                            }
                                        }
                                    )
                                    .padding([.top, .bottom], 10)
                                    .onChange(of: self.messageInput) {
                                        if self.messageInput.count > 0 { self.hideLeftsideContent = true }
                                        else { self.hideLeftsideContent = false }
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, !self.hideLeftsideContent ? 15 : 0)
                            .padding(.leading, !self.hideLeftsideContent ? 0 : 10)
                            .onPreferenceChange(ViewPositionKey.self) { value in
                                if value < self.currentYPosOfMessageBox {
                                    self.messageBoxTapped = true
                                }
                                
                                self.currentYPosOfMessageBox = value
                            }
                            
                            if self.hideLeftsideContent {
                                VStack {
                                    Button(action: {
                                        self.aiIsTyping = true
                                        
                                        self.messages.append(MessageDetails(
                                            MessageID: UUID(),
                                            MessageContent: self.messageInput,
                                            userSent: true,
                                            dateSent: Date.now
                                        ))
                                        
                                        RequestAction<SendAIChatMessageData>(
                                            parameters: SendAIChatMessageData(
                                                ChatID: self.accountInfo.aiChatID,
                                                AccountId: self.accountInfo.accountID,
                                                Message: self.messageInput
                                            )
                                        ).perform(action: send_ai_chat_message_req) { statusCode, resp in
                                            self.aiIsTyping = false
                                            
                                            guard resp != nil && statusCode == 200 else {
                                                return
                                            }
                                            
                                            self.messages.append(MessageDetails(
                                                MessageID: UUID(),
                                                MessageContent: resp!["AIResponse"] as! String,
                                                userSent: false,
                                                dateSent: Date.now
                                            ))
                                        }
                                        
                                        self.messageInput.removeAll()
                                    }) {
                                        Image(systemName: "arrow.up")
                                            .resizableImage(width: 15, height: 20)
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.trailing, 10)
                                .padding(.leading, 5)
                            }
                        }
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 5)
                    } else {
                        if self.generatedTopics.count == 0 {
                            if !self.errorGeneratingTopicsForMajor {
                                VStack {
                                    Text("Chat History:")
                                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: 25))//.font(.system(size: 25))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.bold)
                                    
                                    if self.tempChatHistory == [:] {
                                        Text("No Chat History")
                                            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .center)
                                            .padding(.top)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-ExtraLight", size: 15))//.font(.system(size: 15, design: .rounded))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.light)
                                    } else {
                                        ScrollView(.vertical, showsIndicators: false) {
                                            VStack {
                                                ForEach(Array(self.tempChatHistory.keys), id: \.self) { key in
                                                    Button(action: {
                                                        self.topicPicked = key
                                                        
                                                        for (key, value) in self.tempChatHistory[key]! {
                                                            self.accountInfo.setAIChatID(chatID: key)
                                                            
                                                            self.messages = value
                                                        }
                                                        
                                                        self.chatIsLive = true
                                                        
                                                        /*RequestAction<StartAIChatData>(
                                                            parameters: StartAIChatData(
                                                                AccountId: self.accountInfo.accountID,
                                                                Major: self.accountInfo.major,
                                                                Topic: key
                                                            )
                                                        )
                                                        .perform(action: start_ai_chat_req) { statusCode, resp in
                                                            guard resp != nil && statusCode == 200 else {
                                                                /* self.aiChatStartError = true*/
                                                                return
                                                            }
                                                            
                                                            //self.accountInfo.setAIChatID(chatID: resp!["ChatID"]! as! String)
                                                            //self.aiChatPopover = true
                                                            self.chatIsLive = true
                                                            //self.messages = self.tempChatHistory[key]!
                                                        }*/
                                                    }) {
                                                        HStack {
                                                            HStack {
                                                                VStack {
                                                                    Text(key)
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .foregroundStyle(.white)
                                                                        .padding(.leading, 10)
                                                                        .setFontSizeAndWeight(weight: .bold, size: 18, design: .rounded)
                                                                        .minimumScaleFactor(0.5)
                                                                        .multilineTextAlignment(.leading)
                                                                        .cornerRadius(8)
                                                                    
                                                                    if self.tempChatHistory[key]!.keys.count != 0 {
                                                                        ForEach(Array(self.tempChatHistory[key]!.keys), id: \.self) { chatID in
                                                                            if self.tempChatHistory[key]![chatID]!.count > 0 {
                                                                                Text("Last Message On: \(self.tempChatHistory[key]![chatID]![self.tempChatHistory[key]![chatID]!.count - 1].dateSent.formatted(date: .numeric, time: .omitted))")
                                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                                    .padding([.top, .bottom], 5)
                                                                                    .foregroundStyle(.white)
                                                                                    .padding(.leading, 10)
                                                                                    .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                    .minimumScaleFactor(0.5)
                                                                                    .multilineTextAlignment(.leading)
                                                                            } else {
                                                                                Text("No Messages")
                                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                                    .padding([.top, .bottom], 5)
                                                                                    .foregroundStyle(.white)
                                                                                    .padding(.leading, 10)
                                                                                    .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                    .minimumScaleFactor(0.5)
                                                                                    .multilineTextAlignment(.leading)
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    //ForEach(self.tempChatHistory[key!]!.keys, id: \.self) { key2 in
                                                                        /*if self.tempChatHistory[key!]![key2].count > 0 {
                                                                            Text("Last Message On: \(self.tempChatHistory[key!]![key2]![self.tempChatHistory[key!]![key2]!.count - 1].dateSent.formatted(date: .numeric, time: .omitted))")
                                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                                .padding([.top, .bottom], 5)
                                                                                .foregroundStyle(.white)
                                                                                .padding(.leading, 10)
                                                                                .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                .minimumScaleFactor(0.5)
                                                                                .multilineTextAlignment(.leading)
                                                                        } else {
                                                                            Text("No Messages")
                                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                                .padding([.top, .bottom], 5)
                                                                                .foregroundStyle(.white)
                                                                                .padding(.leading, 10)
                                                                                .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                .minimumScaleFactor(0.5)
                                                                                .multilineTextAlignment(.leading)
                                                                        }*/
                                                                        //Text(key2)
                                                                    //}
                                                                    
                                                                    HStack {
                                                                        Button(action: {
                                                                            self.tempChatHistory.removeValue(forKey: key)
                                                                        }) {
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
                                                                        .padding([.leading], 10)
                                                                        
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
                                                                        .padding(.leading, 10)
                                                                    }
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                }
                                                                
                                                                ZStack {
                                                                    Image(systemName: "chevron.right")
                                                                        .resizableImage(width: 10, height: 15)
                                                                        .foregroundStyle(Color.EZNotesBlue)
                                                                }
                                                                .frame(maxWidth: 15, alignment: .trailing)
                                                                .padding(.trailing, 25)
                                                            }
                                                            .frame(maxWidth: prop.size.width - 80)
                                                            .padding(12)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(Color.EZNotesLightBlack.opacity(0.3))
                                                                    .shadow(color: Color.black, radius: 2.5)
                                                            )
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                    }
                                                }
                                            }
                                            .padding(.top, 10)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            } else {
                                VStack {
                                    Image(systemName: "exclamationmark.warninglight.fill")
                                        .resizable()
                                        .frame(width: 65, height: 60)
                                        .padding([.top, .bottom], 15)
                                        .foregroundStyle(Color.EZNotesRed)
                                    
                                    Text("Error generating topics for \(self.accountInfo.major)")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 25, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.medium)
                                    
                                    Button(action: {
                                        self.errorGeneratingTopicsForMajor = false
                                        
                                        /* MARK: Precautionary measure. */
                                        if self.chatIsLive { self.chatIsLive = false }
                                    }) {
                                        Text("Go Back")
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 90,
                                                height: 10
                                            )
                                            .padding([.top, .bottom])
                                            .font(.system(size: 25, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack)
                                    )
                                }
                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .top)
                            }
                        } else {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    ForEach(self.generatedTopics, id: \.self) { topic in
                                        Button(action: {
                                            self.topicPicked = topic
                                            var topicNumber = 0
                                            
                                            for (topic, _) in self.tempChatHistory {
                                                if topic.contains(self.topicPicked) { topicNumber += 1 }
                                            }
                                            
                                            if topicNumber > 0 {
                                                self.topicPicked = "\(self.topicPicked) \(topicNumber)"
                                            }
                                            
                                            RequestAction<StartAIChatData>(
                                                parameters: StartAIChatData(
                                                    AccountId: self.accountInfo.accountID,
                                                    Major: self.accountInfo.major,
                                                    Topic: topic
                                                )
                                            )
                                            .perform(action: start_ai_chat_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    /* self.aiChatStartError = true*/
                                                    return
                                                }
                                                
                                                //print(UUID(uuidString: resp!["ChatID"]! as! String)!)
                                                self.accountInfo.setAIChatID(chatID: UUID(uuidString: resp!["ChatID"]! as! String)!)
                                                //self.aiChatPopover = true
                                                self.tempChatHistory[topic] = [UUID(uuidString: resp!["ChatID"]! as! String)!: []]
                                                self.chatIsLive = true
                                            }
                                        }) {
                                            HStack {
                                                Text("\(topic)")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 10)
                                                    .setFontSizeAndWeight(weight: .bold, size: 22, design: .rounded)
                                                    .minimumScaleFactor(0.5)
                                                    .multilineTextAlignment(.leading)
                                                    .cornerRadius(8)
                                                    .foregroundColor(.white)
                                                
                                                ZStack {
                                                    Image(systemName: "chevron.right")
                                                        .resizableImage(width: 10, height: 15)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(maxWidth: 15, alignment: .trailing)
                                                .padding(.trailing, 25)
                                            }
                                            .frame(maxWidth: prop.size.width - 40)
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack)
                                                    .shadow(color: Color.black, radius: 2.5)
                                            )
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    Button(action: {
                                        self.topicPicked = "Other"
                                        
                                        RequestAction<StartAIChatData>(
                                            parameters: StartAIChatData(
                                                AccountId: self.accountInfo.accountID,
                                                Major: self.accountInfo.major,
                                                Topic: "Other"
                                            )
                                        )
                                        .perform(action: start_ai_chat_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                /* self.aiChatStartError = true*/
                                                return
                                            }
                                            
                                            //self.accountInfo.setAIChatID(chatID: resp!["ChatID"]! as! String)
                                            //self.aiChatPopover = true
                                            self.chatIsLive = true
                                        }
                                    }) {
                                        HStack {
                                            Text("Other Topic")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 10)
                                                .setFontSizeAndWeight(weight: .bold, size: 22, design: .rounded)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.leading)
                                                .cornerRadius(8)
                                                .foregroundColor(.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                                .shadow(color: Color.black, radius: 2.5)
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 60, maxHeight: .infinity)
                            .padding(.top, 15)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.EZNotesLightBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesBlack
                        ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                //guard self.tempChatHistory.count > 0 && self.tempChatHistory[self.tempChatHistory.count - 1].dateSent != nil else { return }
                /*for(chatTitle, value) in self.tempChatHistory {
                    
                    /*RequestAction<SaveChatHistoryData>(parameters: SaveChatHistoryData(
                        AccountID: self.accountInfo.accountID, ChatTitle: chatTitle, ChatHistory: []
                    ))
                    .perform(action: save_chat_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            return
                        }
                        
                        print(resp!)
                    }*/
                    /* MARK: If the most recent message date is not the current date, save it to the server. */
                    if value[value.count - 1].dateSent.formatted(date: .numeric, time: .omitted) != Date.now.formatted(date: .numeric, time: .omitted) {
                    }
                }*/
                //guard self.tempChatHistory != [:] && self.tempChatHistory.
                
                /*if self.tempChatHistory.last!.dateSent != Date.now {
                    /* TODO: Request to save message history. */
                    /* TODO: Remove messages. */
                    /* TODO: Add support for showing chat history. */
                } else {
                    print("NAH")
                }*/
            }*/
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
    var categoryBackground: Image
    var categoryBackgroundColor: Color
    var totalSets: Int
    
    @Binding public var launchCategory: Bool
    @Binding public var showTitle: Bool
    @Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    @Binding public var messages: Array<MessageDetails>
    @ObservedObject public var accountInfo: AccountDetails
    @Binding public var topBanner: [String: TopBanner]
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @State private var aiChat: Bool = false
    
    var body: some View {
        ZStack {
            ZStack {
                self.categoryBackground
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 125)
                //.aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay(Color.EZNotesBlack.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: 135)
            .background(
                Rectangle()
                    .shadow(color: self.categoryBackgroundColor, radius: 2.5, y: 2.5)
            )
            
            HStack {
                VStack {
                    Button(action: { self.launchCategory = false }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .tint(Color.EZNotesBlue)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding([.leading], 20)
                }
                .frame(maxWidth: 50, maxHeight: .infinity, alignment: .leading)
                .padding(.top, prop.isLargerScreen ? 25 : 15)
                
                if self.topBanner.keys.contains(self.categoryName) && self.topBanner[self.categoryName]! != .None {
                    switch(self.topBanner[self.categoryName]!) {
                    case .LoadingUploads:
                        HStack {
                            Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                .padding(.trailing, 5)
                            
                            ProgressView()
                                .controlSize(.mini)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.trailing, 10)
                        .padding(.top, prop.isLargerScreen ? 25 : 15)
                    default: VStack { }.onAppear { self.topBanner[self.categoryName] = .None }
                    }
                } else { Spacer() }
                
                //Spacer()
                
                VStack {
                    Button(action: { self.aiChat = true }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: prop.isLargerScreen ? 35 : 30,
                                height: prop.isLargerScreen ? 35 : 30
                            )
                            .padding([.trailing], 20)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: 50, maxHeight: .infinity, alignment: .trailing)
                .padding(.top, prop.isLargerScreen ? 25 : 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
        .padding([.top], 5)//.background(Color.EZNotesBlack.opacity(0.95))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .popover(isPresented: $aiChat) {
            AIChat(
                prop: self.prop,
                accountInfo: self.accountInfo,
                tempChatHistory: $tempChatHistory,
                messages: $messages
            )
        }
        //.zIndex(1)
    }
}

struct TopNavUpload: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @Binding public var topBanner: TopBanner
    @ObservedObject public var categoryData: CategoryData
    @ObservedObject public var imagesToUpload: ImagesUploads
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    @Binding public var section: String
    @Binding public var lastSection: String
    @Binding public var userHasSignedIn: Bool
    
    @ObservedObject public var images_to_upload: ImagesUploads
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 20)
            //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
            if self.topBanner != .None || self.networkMonitor.needsNoWifiBanner {
                if self.networkMonitor.needsNoWifiBanner {
                    HStack {
                        HStack {
                            Button(action: { self.topBanner = .None }) {
                                ZStack {
                                    Image(systemName: "multiply")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.white)
                                }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Text("No WiFi Connection")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(Color.EZNotesRed)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            /* TODO: Is this really needed since the `NetworkMonitor` class is consistently checking? */
                            self.networkMonitor.manualRetryCheckConnection()
                        }) {
                            ZStack {
                                Text("Retry")
                                    .frame(alignment: .trailing)
                                    .padding([.top, .bottom], 2.5)
                                    .padding([.leading, .trailing], 6.5)
                                    .background(.white)
                                    .cornerRadius(15)
                                    .foregroundStyle(.black)
                                    .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                            }
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                    .background(Color.EZNotesLightBlack.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.bottom, 20)
                    .padding(.trailing, 10)
                } else {
                    switch(self.topBanner) {
                    case .LoadingUploads:
                        HStack {
                            Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                .padding(.trailing, 5)
                            
                            ProgressView()
                                .controlSize(.mini)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, 10)
                    case .ErrorUploading:
                        HStack {
                            HStack {
                                Button(action: { self.topBanner = .None }) {
                                    ZStack {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.white)
                                    }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Text("Error Uploading. Try Again")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                print("Report Issue")
                            }) {
                                ZStack {
                                    Text("Report")
                                        .frame(alignment: .trailing)
                                        .padding([.top, .bottom], 2.5)
                                        .padding([.leading, .trailing], 6.5)
                                        .background(.white)
                                        .cornerRadius(15)
                                        .foregroundStyle(.black)
                                        .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, 10)
                    case .UploadsReadyToReview:
                        HStack {
                            HStack {
                                Button(action: {
                                    self.categoryData.saveNewCategories()
                                    self.imagesToUpload.images_to_upload.removeAll()
                                    self.topBanner = .None
                                }) {
                                    ZStack {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.white)
                                    }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Text("Uploading Finished")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(Color.EZNotesGreen)
                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                self.lastSection = self.section
                                self.section = "review_new_categories"
                                
                                self.topBanner = .None
                            }) {
                                ZStack {
                                    Text("Review")
                                        .frame(alignment: .trailing)
                                        .padding([.top, .bottom], 2.5)
                                        .padding([.leading, .trailing], 6.5)
                                        .background(.white)
                                        .cornerRadius(15)
                                        .foregroundStyle(.black)
                                        .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .padding([.top, .bottom], 6)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, 10)
                    default:
                        Spacer()
                    }
                }
            } else {
                Spacer()
            }
            
            /*VStack {
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
            .background(.clear)*/
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}

struct YouTubeVideoView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true // Enable inline media playback
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            return webView
        }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0?autoplay=1&mute=0") else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct TopNavChat: View {
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    @Binding public var friendSearch: String
    @Binding public var userHasSignedIn: Bool
    
    var prop: Properties
    var backgroundColor: Color
    
    @State private var rickRoll: Bool = false
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 20)
            //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
            Spacer()
            
            HStack {
                ZStack {
                    Button(action: { self.rickRoll = true }) {
                        Image(systemName: "person.badge.plus")//Image("Add-Friend-Icon")
                            .resizable()
                            .frame(maxWidth: 25, maxHeight: 25)
                            .foregroundStyle(Color.EZNotesBlue)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding(.leading, 5)
                }
                .frame(width: 30, height: 30, alignment: .center)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                .padding(.trailing, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 20)
            .popover(isPresented: $rickRoll) {
                /*WebView(url: URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0")!)
                    .navigationBarTitle("Get Rick Rolled, Boi", displayMode: .inline)*/
                YouTubeVideoView() // Replace with your YouTube video ID
                    .frame(maxWidth: .infinity, maxHeight: .infinity)//: 300) // Set height for the video player
                    .cornerRadius(10)
                    .padding()
            }
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}

#Preview {
    ContentView()
}
