//
//  UpdatePasswordView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/11/24.
//
import SwiftUI

struct UpdatePassword: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    /* TODO: Add loading screen for when "Update" is pressed. */
    
    var prop: Properties
    var borderBottomColor: LinearGradient
    
    @Binding public var accountPopupSection: String
    
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
                    
                    Text("Update Password")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding([.top], 15)
                        .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                        
                    /* MARK: "spacing" to ensure above Text stays in the middle. */
                    ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(.top, prop.isLargerScreen ? 55 : 0)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                if self.newPasswordTooShort || self.oldPasswordTooShort || self.errorUpdatingPassword || self.wrongOldPassword || self.oldAndNewPasswordsAreTheSame {
                    Text(self.newPasswordTooShort
                         ? "New password too short. Password must be 8 characters or more."
                         : self.oldPasswordTooShort
                         ? "Current password is too short. Passwords require 8 or more characters."
                         : self.errorUpdatingPassword
                         ? "Error updating password. Try again."
                         : self.wrongOldPassword
                         ? "The current password you provided is incorrect. Please try again."
                         : "Current password cannot be the same as the new password.")
                    .frame(maxWidth: prop.size.width - 30, alignment: .center)
                    .foregroundStyle(Color.EZNotesRed)
                    .font(
                        .system(
                            size: prop.isIpad || prop.isLargerScreen
                            ? 15
                            : 13
                        )
                    )
                    .multilineTextAlignment(.center)
                } else {
                    HStack {
                        ZStack { }.frame(maxWidth: 10, alignment: .leading)
                        
                        ZStack {
                            Text("Enter a new password below. The new password cannot be the same as your current password.")
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
                }
                
                if !self.passwordUpdated {
                    Text("Current Password")
                        .frame(
                            width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                            ? prop.size.width - 800
                            : prop.size.width - 450
                            : prop.size.width - 80,
                            height: 5,
                            alignment: .leading
                        )
                        .padding(.top, 10)
                        .font(
                            .system(
                                size: prop.isLargerScreen ? 18 : 13
                            )
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                    
                    TextField("Old Password...", text: $oldPassword)
                        .frame(
                            width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                            ? prop.size.width - 800
                            : prop.size.width - 450
                            : prop.size.width - 100,
                            height: prop.isLargerScreen ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .borderBottomWLColor(isError: false)
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding(prop.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                    
                    Text("New Password")
                        .frame(
                            width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                            ? prop.size.width - 800
                            : prop.size.width - 450
                            : prop.size.width - 80,
                            height: 5,
                            alignment: .leading
                        )
                        .padding(.top, 10)
                        .font(
                            .system(
                                size: prop.isLargerScreen ? 18 : 13
                            )
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                    
                    TextField("New Password...", text: $newPassword)
                        .frame(
                            width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                            ? prop.size.width - 800
                            : prop.size.width - 450
                            : prop.size.width - 100,
                            height: prop.isLargerScreen ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding(prop.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                    
                    Button(action: {
                        if self.oldPassword.count < 8 { self.oldPasswordTooShort = true; return }
                        if self.oldPasswordTooShort { self.oldPasswordTooShort = false }
                        
                        if self.newPassword.count < 8 { self.newPasswordTooShort = true; return }
                        if self.newPasswordTooShort { self.newPasswordTooShort = false }
                        
                        self.errorUpdatingPassword = false
                        self.wrongOldPassword = false
                        
                        if self.oldPassword == self.newPassword { self.oldAndNewPasswordsAreTheSame = true; return }
                        if self.oldAndNewPasswordsAreTheSame { self.oldAndNewPasswordsAreTheSame = false }
                        
                        self.changePasswordAlert = true
                    }) {
                        HStack {
                            Text("Update")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 8)
                                .foregroundStyle(.black)
                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: prop.isIpad
                               ? UIDevice.current.orientation.isLandscape
                               ? prop.size.width - 800
                               : prop.size.width - 450
                               : prop.size.width - 80)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                        )
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    
                    Spacer()
                } else {
                    VStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.EZNotesGreen)
                        
                        Text("Password Updated")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.accountPopupSection = "main"
                            
                            self.passwordUpdated = false
                            
                            /* MARK: Just to ensure no sort of error message shows. */
                            self.oldPasswordTooShort = false
                            self.newPasswordTooShort = false
                            self.errorUpdatingPassword = false
                            self.wrongOldPassword = false
                            
                            /* MARK: Ensure the old/new textfields will have no text in them if the user comes back. */
                            self.oldPassword.removeAll()
                            self.newPassword.removeAll()
                        }
                    }
                }
            }
            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            .padding(.top, prop.isLargerScreen ? 90 : 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Are you sure?", isPresented: $changePasswordAlert) {
            Button(action: {
                RequestAction<UpdatePasswordData>(parameters: UpdatePasswordData(
                    OldPassword: self.oldPassword, NewPassword: self.newPassword, AccountID: self.accountInfo.accountID
                ))
                .perform(action: update_password_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        if let resp = resp {
                            if !resp.keys.contains("Message") { self.errorUpdatingPassword = true }
                            else {
                                if resp["Message"] as! String == "wrong_old_password" {
                                    self.wrongOldPassword = true
                                    return
                                }
                            }
                        }
                        
                        self.errorUpdatingPassword = true
                        return
                    }
                    
                    self.passwordUpdated = true
                }
            }) { Text("Yes") }
            Button("No", role: .cancel) { }
        } message: {
            Text("If you change your password, your old one will no longer be eligible to be used to login. Are you sure?")
        }
    }
}
