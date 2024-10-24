//
//  AccountDetailsModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/18/24.
//
import SwiftUI

class AccountDetails: ObservableObject {
    @Published var username: String
    @Published var email: String
    @Published var college: String
    @Published var major: String
    @Published var planID: String
    
    /* MARK: PFP - will be on top of `profileBackgroundImage`. */
    @Published var profilePicture: Image
    
    /* MARK: Background image for the top of the account popover. */
    @Published var profileBackgroundPicture: Image
    
    init() {
        username = ""
        email = ""
        college = ""
        major = ""
        planID = ""
        profilePicture = Image(systemName: "person.crop.circle.fill")
        profileBackgroundPicture = Image("Pfp-Default-Bg")
    }
    
    final public func setUsername(username: String) { self.username = username }
    final public func setEmail(email: String) { self.email = email }
    
    final public func setProfilePicture(pfp: UIImage) { self.profilePicture = Image(uiImage: pfp) }
    final public func setProfilePicture(pfp: Image) { self.profilePicture = pfp }
    
    final public func setProfilePictureBackground(bg: UIImage) { self.profileBackgroundPicture = Image(uiImage: bg) }
    final public func setProfilePictureBackground(bg: Image) { self.profileBackgroundPicture = bg }
}
