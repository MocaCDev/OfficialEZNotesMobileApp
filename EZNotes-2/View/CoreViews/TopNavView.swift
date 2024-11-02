//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import PhotosUI
import Combine

struct ProfileIconView: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    var body: some View {
        Button(action: { self.showAccountPopup = true }) {
            /*Image(systemName: "person.crop.circle.fill")*/
            self.accountInfo.profilePicture
                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                .scaledToFill()
                .frame(maxWidth: 35, maxHeight: 35)
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
    
    @Binding public var userHasSignedIn: Bool
    
    @State private var launchPhotoGallery: Bool = false
    @State private var pfpPhotoPicked: PhotosPickerItem?
    @State private var pfpBackgroundPhotoPicked: PhotosPickerItem?
    @State private var photoGalleryLaunchedFor: String = "pfp" /* MARK: Value can be `pfp` or `pfp_bg`. */
    @State private var newUsername: String = ""
    @State private var updateUsername: Bool = false
    @State private var pfpUploadStatus: String = "none"
    @State private var errorUploadingPFP: Bool = false
    @State private var showPrivacyAndPolicy: Bool = false
    @State private var showTermsAndConditions: Bool = false
    @State private var changingProfilePic: Bool = false
    
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
                        .frameAndPadding(maxWidth: 25, padEdges: .trailing, pad: 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .background(Color.EZNotesRed)
                } else {
                    if self.pfpUploadStatus != "none" { /* MARK: We will assume if it isn't `none` and it isn't `failed` it is `good`. */
                        HStack {
                            ZStack { }.frame(maxWidth: 25, alignment: .leading)
                            
                            Text("Updated PFP")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .medium)
                                .minimumScaleFactor(0.5)
                            
                            ZStack {
                                Button(action: { self.pfpUploadStatus = "none" }) {
                                    Image(systemName: "multiply")
                                        .resizableImage(width: 12, height: 12)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                            .frame(maxWidth: 25, alignment: .trailing)
                            .padding(.trailing, 10)
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
                                            //.resizableImageFill(width: prop.size.height / 2.5 > 300 ? 90 : 80, height: prop.size.height / 2.5 > 300 ? 90 : 80)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: prop.size.height / 2.5 > 300 ? 90 : 80, height: prop.size.height / 2.5 > 300 ? 90 : 80, alignment: .center)
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
                                .padding(.leading, 15)
                                .padding([.top, .bottom])
                                
                                VStack {
                                    HStack {
                                        Text("\(self.accountInfo.username)")
                                            //.frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .setFontSizeAndWeight(weight: .semibold, size: 20, design: .rounded)
                                        
                                        Divider()
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
                                        Text(self.accountInfo.college != "" ? self.accountInfo.college : "No University")
                                            .frame(minWidth: 60, maxHeight: 20, alignment: .leading)
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
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    .resizableImageFill()
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
                        .setFontSizeAndWeight(weight: .semibold, size: 20)
                    
                    Divider()
                        .frame(width: prop.size.width - 50)
                    
                    VStack {
                        VStack { }.frame(maxWidth: .infinity, maxHeight: 5)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            Text("Account, Plans & Management")
                                .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .bold, size: 20)
                                .minimumScaleFactor(0.5)
                            
                            VStack {
                                Button(action: { print("Show Plan Detail") }) {
                                    HStack {
                                        Text("Plan Details")
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
                                    //.frame(width: prop.size.width - 80)
                                    .overlay(.black)
                                
                                Button(action: { print("Change Username") }) {
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
                                    .padding([.top, .bottom], 5)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Divider()
                                    //.frame(width: prop.size.width - 80)
                                    .overlay(.black)
                                
                                Button(action: { print("Update Password") }) {
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
                                    //.frame(width: prop.size.width - 80)
                                    .overlay(.black)
                                
                                Button(action: { print("Change Schools") }) {
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
                                    //.frame(width: prop.size.width - 80)
                                    .overlay(.black)
                                
                                Button(action: { print("Change Field/Major") }) {
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
                                    Button(action: { print("Show Additional Settings") }) {
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
                                    
                                    Button(action: { print("Show Billing") }) {
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
                                
                                Button(action: { print("Show Themes") }) {
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
                                    UserDefaults.standard.set(false, forKey: "logged_in")
                                    self.userHasSignedIn = false
                                    self.accountInfo.reset()
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
                            /*HStack {
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
                            }*/
                            
                            Text("Joined 10/10/2024")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 40)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
    
    @State private var numberOfTheAnimationgBall = 3
    
    // MAKR: - Drawing Constants
    let ballSize: CGFloat = 10
    let speed: Double = 0.3
    let chatUUID: UUID = UUID()
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .frame(maxWidth: 90,  alignment: .leading)
            .padding(.bottom, 10)//.padding(.top, prop.size.height / 2.5 > 300 ? 50 : 15) /* MARK: Aligns icon for larger screens. */
            //.padding(.bottom, prop.size.height / 2.5 > 300 ? 0 : 10) /* MARK: Aligns icon for smaller screens. */
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
            Spacer()
            
            if self.showSearchBar && self.categoriesAndSets.count > 0 {
                VStack {
                    TextField(
                        prop.size.height / 2.5 > 300 ? "Search Categories..." : "Search...",
                        text: $categorySearch
                    )
                    .onAppear(perform: { print(prop.size.height / 2.5) })
                    .frame(
                        maxWidth: .infinity,/*prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                            : 150,*/
                        maxHeight: prop.size.height / 2.5 > 300 ? 20 : 15
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
                .padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)//.padding(.top, 10)
                //.padding([.top], prop.size.height > 340 ? 50 : 45)
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
                    .padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)
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
                .padding([.top], 5)
                
                Button(action: {
                    RequestAction<StartAIChatData>(
                        parameters: StartAIChatData(AccountId: self.accountInfo.accountID)
                    )
                    .perform(action: start_ai_chat_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            /* self.aiChatStartError = true*/
                            return
                        }
                        
                        //self.accountInfo.setAIChatID(chatID: resp!["ChatID"]! as! String)
                        self.aiChatPopover = true
                    }
                }) {
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
            //.padding(.top, prop.size.height / 2.5 > 300 ? 40 : 0)
            .padding(.bottom, 10)
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
        /* TODO: Change from popover to an actual view. */
        .popover(isPresented: $aiChatPopover) {
            VStack {
                VStack {
                    Text("EZNotes AI Chat")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .font(.system(size: 22, design: .rounded))
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: 50, alignment: .top)
                .border(width: 0.5, edges: [.bottom], color: .gray)
                
                if !self.errorGeneratingTopicsForMajor {
                    HStack {
                        Button(action: {
                            RequestAction<GetCustomTopicsData>(parameters: GetCustomTopicsData(Major: self.accountInfo.major))
                                .perform(action: get_custom_topics_req) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        self.errorGeneratingTopicsForMajor = true
                                        return
                                    }
                                    
                                    print(resp!)
                                }
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 15, height: 15, alignment: .leading)
                                    .foregroundStyle(.white)
                                
                                Text("New Chat")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                
                                ZStack { }.frame(maxWidth: 15, alignment: .trailing)
                            }
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], 10)
                            .background(Color.EZNotesLightBlack.shadow(color: .black, radius: 2.5))
                            .cornerRadius(15)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        .padding([.top, .bottom])
                        
                        Button(action: { print("Delete All Chats") }) {
                            HStack {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 15, height: 15, alignment: .leading)
                                    .foregroundStyle(.white)
                                
                                Text("Delete All")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                
                                ZStack { }.frame(maxWidth: 15, alignment: .trailing)
                            }
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], 10)
                            .background(Color.EZNotesRed.shadow(color: .black, radius: 2.5))
                            .cornerRadius(15)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        .padding([.top, .bottom])
                    }
                    .frame(maxWidth: prop.size.width - 40)
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
                                .onChange(of: self.aiIsTyping) {
                                    //if self.aiIsTyping {
                                    //    proxy.scrollTo(self.chatUUID)
                                    //}
                                }
                                .onChange(of: self.messageBoxTapped) {
                                    withAnimation {
                                        proxy.scrollTo(messages.last)
                                    }
                                }
                                /*.onReceive(Just(messages)) { _ in
                                 withAnimation {
                                 proxy.scrollTo(messages.last)
                                 }
                                 }
                                 .onReceive(Just(self.aiIsTyping)) { _ in
                                 if self.aiIsTyping {
                                 proxy.scrollTo(self.chatUUID)
                                 } else {
                                 proxy.scrollTo(messages.last)
                                 }
                                 }*/
                                .onAppear {
                                    withAnimation {
                                        proxy.scrollTo(messages.last, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        //ScrollView(.vertical) {
                        /*ForEach(self.messages.sorted(by: <), id: \.key) { key, value in//ForEach(Array(self.messages.keys), id: \.self) { key in
                         VStack {
                         VStack {
                         Text(key)
                         .frame(minWidth: 10, alignment: .trailing)
                         .padding(8)
                         .background(
                         RoundedRectangle(cornerRadius: 15)
                         .fill(Color.EZNotesBlue)
                         )
                         .font(.system(size: 13))
                         .minimumScaleFactor(0.5)
                         .multilineTextAlignment(.leading)
                         .fontWeight(.semibold)
                         }
                         .frame(maxWidth: 340, alignment: .trailing)
                         }
                         .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                         .padding(.bottom, 15)
                         
                         if value.count > 0 {
                         VStack {
                         VStack {
                         HStack {
                         Image("AI-Chat")//systemName: "sparkle")
                         .resizableImage(width: 20, height: 20)
                         
                         Text(value)
                         .frame(minWidth: 20,  alignment: .leading)
                         .foregroundStyle(.black)
                         .padding(8)
                         .background(
                         RoundedRectangle(cornerRadius: 15)
                         .fill(.white.opacity(0.85))
                         )
                         /*.background(
                          RoundedRectangle(cornerRadius: 10)
                          .fill(MeshGradient(width: 3, height: 3, points: [
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
                          ])).overlay(Color.EZNotesBlack.opacity(0.4))//(Color.EZNotesLightBlack)
                          )*/
                         .font(.system(size: 13))
                         .minimumScaleFactor(0.5)
                         .multilineTextAlignment(.leading)
                         .fontWeight(.semibold)
                         }
                         }
                         .frame(maxWidth: 340, alignment: .leading)
                         }
                         .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                         .padding(.bottom, 15)
                         }
                         }*/
                        
                        /*ForEach(Array(self.userSentMessages.enumerated()), id: \.offset) { index, item in
                         VStack {
                         VStack {
                         VStack {
                         VStack {
                         Text(item)
                         .frame(minWidth: 10, alignment: .trailing)
                         .padding(8)
                         .background(
                         RoundedRectangle(cornerRadius: 15)
                         .fill(Color.EZNotesBlue)
                         )
                         .font(.system(size: 13))
                         .minimumScaleFactor(0.5)
                         .multilineTextAlignment(.leading)
                         .fontWeight(.semibold)
                         }
                         .frame(maxWidth: 340, alignment: .trailing)
                         }
                         .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                         .padding(.bottom, 15)
                         
                         if !(index > self.systemResponses.count - 1) {
                         VStack {
                         VStack {
                         HStack {
                         Image("AI-Chat")//systemName: "sparkle")
                         .resizableImage(width: 20, height: 20)
                         
                         Text(self.systemResponses[index])
                         .frame(minWidth: 20,  alignment: .leading)
                         .foregroundStyle(.black)
                         .padding(8)
                         .background(
                         RoundedRectangle(cornerRadius: 15)
                         .fill(.white.opacity(0.85))
                         )
                         /*.background(
                          RoundedRectangle(cornerRadius: 10)
                          .fill(MeshGradient(width: 3, height: 3, points: [
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
                          ])).overlay(Color.EZNotesBlack.opacity(0.4))//(Color.EZNotesLightBlack)
                          )*/
                         .font(.system(size: 13))
                         .minimumScaleFactor(0.5)
                         .multilineTextAlignment(.leading)
                         .fontWeight(.semibold)
                         }
                         }
                         .frame(maxWidth: 340, alignment: .leading)
                         }
                         .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                         .padding(.bottom, 15)
                         }
                         }
                         .frame(maxWidth: .infinity, alignment: .trailing)
                         .padding(.trailing, 10)
                         }
                         .frame(maxWidth: .infinity)
                         }*/
                        //}
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
                                        .resizableImage(width: 20, height: 20)
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
                                .padding(4)
                                .foregroundStyle(.white)
                                .padding(.leading, 10)
                                .cornerRadius(15)
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
                                        parameters: SendAIChatMessageData(AccountId: self.accountInfo.accountID, Message: self.messageInput)
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
                    if !self.errorGeneratingTopicsForMajor {
                        VStack {
                            Text("No Chat History")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .font(.system(size: 25, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.EZNotesBlack)
            .onAppear {
                guard self.messages.last?.dateSent != nil else { return }
                
                if self.messages.last!.dateSent != Date.now {
                    /* TODO: Request to save message history. */
                    /* TODO: Remove messages. */
                    /* TODO: Add support for showing chat history. */
                }
            }
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
    @Binding public var showTitle: Bool
    
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
                .padding(.top, prop.size.height / 2.5 > 300 ? 50 : 15)
                
                Spacer()
                
                if self.showTitle {
                    Text("TITLE!")
                    
                    Spacer()
                }
                
                //Spacer()
                
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
                .frame(maxWidth: 90, maxHeight: .infinity, alignment: .trailing)
                .padding(.top, prop.size.height / 2.5 > 300 ? 40 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2.5 > 300 ? 115 : 65, alignment: .top)
        .padding(.top, 5)
        .edgesIgnoringSafeArea(.top)
        .zIndex(1)
    }
}

struct TopNavUpload: View {
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @State private var showAccountPopup: Bool = false
    
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
            .padding([.bottom], 10)
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
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
    @Binding public var userHasSignedIn: Bool
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 10)
            .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
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
