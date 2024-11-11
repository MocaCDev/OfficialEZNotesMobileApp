//
//  ChangeUsernameView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/11/24.
//
import SwiftUI

struct ChangeUsername: View {
    /* TODO: Add loading screen for when "Update" is pressed. */
    var prop: Properties
    var borderBottomColor: LinearGradient
    
    @ObservedObject public var accountInfo: AccountDetails
    @Binding public var accountPopupSection: String
    @Binding public var isLargerScreen: Bool
    
    @State private var newUsername: String = ""
    @State private var errorUpdatingUsername: Bool = false
    @State private var usernameExistsError: Bool = false
    @State private var errorUpdatingUseranme: Bool = false
    @State private var usernameUpdated: Bool = false
    @State private var changeUsernameAlert: Bool = false
    
    var body: some View {
        VStack {
            if self.errorUpdatingUseranme || self.usernameExistsError {
                Text(self.errorUpdatingUseranme
                     ? "Error updating username. Try again."
                     : "The username you provided already exists. Try again")
                .frame(maxWidth: prop.size.width - 30, alignment: .center)
                .foregroundStyle(Color.EZNotesRed)
                .font(
                    .system(
                        size: prop.isIpad || self.isLargerScreen
                        ? 15
                        : 13
                    )
                )
                .multilineTextAlignment(.center)
            }
            
            if !self.usernameUpdated {
                Text("New Username")
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
                            size: self.isLargerScreen ? 18 : 13
                        )
                    )
                    .foregroundStyle(.white)
                    .fontWeight(.medium)
                
                TextField("New Username...", text: $newUsername)
                    .frame(
                        width: prop.isIpad
                        ? UIDevice.current.orientation.isLandscape
                        ? prop.size.width - 800
                        : prop.size.width - 450
                        : prop.size.width - 100,
                        height: self.isLargerScreen ? 40 : 30
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
                    .padding(self.isLargerScreen ? 10 : 8)
                    .tint(Color.EZNotesBlue)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.alphabet)
                
                Button(action: {
                    if self.usernameExistsError { self.usernameExistsError = false }
                    if self.errorUpdatingUseranme { self.errorUpdatingUseranme = false }
                    
                    self.changeUsernameAlert = true
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
                    
                    Text("Username Updated")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .font(Font.custom("Poppins-SemiBold", size: 18))
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.accountPopupSection = "main"
                        
                        self.usernameUpdated = false
                        
                        /* MARK: Just to ensure no sort of error message shows. */
                        self.errorUpdatingUseranme = false
                        self.usernameExistsError = false
                        
                        /* MARK: Remove all the content in the variable `newUsername` to ensure there is no content to be shown next time the user comes back. */
                        self.newUsername.removeAll()
                    }
                }
            }
        }
        .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
        .alert("Are you sure?", isPresented: $changeUsernameAlert) {
            Button(action: {
                RequestAction<UpdateUsernameData>(parameters: UpdateUsernameData(
                    NewUsername: self.newUsername, AccountID: self.accountInfo.accountID
                ))
                .perform(action: update_username_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        if let resp = resp {
                            if resp.keys.contains("Message") {
                                if resp["Message"] as! String == "username_exists" {
                                    self.usernameExistsError = true
                                    return
                                }
                            }
                        }
                        self.errorUpdatingUseranme = true
                        return
                    }
                    
                    self.accountInfo.setUsername(username: self.newUsername)
                    UserDefaults.standard.set(self.newUsername, forKey: "username")
                    self.newUsername.removeAll()
                    
                    self.usernameUpdated = true
                }
            }) { Text("Yes") }
            
            Button("No", role: .cancel) { }
        } message: {
            Text("By proceeding, your username will change to \(self.newUsername). Are you sure?")
        }
    }
}
