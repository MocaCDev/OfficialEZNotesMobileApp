//
//  ChatView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

struct ChatView: View {
    @State private var friendSearch: String = ""
    
    @Binding public var section: String
    
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    
    @State private var showAccount: Bool = false
    
    var body: some View {
        if !self.showAccount {
            VStack {
                TopNavChat(
                    accountInfo: accountInfo,
                    showAccountPopup: $showAccount,
                    friendSearch: $friendSearch,
                    userHasSignedIn: $userHasSignedIn,
                    prop: prop,
                    backgroundColor: Color.EZNotesLightBlack
                )
                
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ButtomNavbar(
                    section: $section,
                    backgroundColor: Color.EZNotesLightBlack ,
                    prop: prop
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea([.bottom])
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .black,//Color.EZNotesBlack,
                            .black,//Color.EZNotesBlack,
                            .black,//Color.EZNotesBlack,
                            Color.EZNotesLightBlack//Color.EZNotesLightBlack
                            //Color.EZNotesOrange,
                            //Color.EZNotesOrange
                        ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width > 0 {
                        self.section = "upload"
                    }
                })
            )
        } else {
            Account(
                prop: self.prop,
                showAccount: $showAccount,
                userHasSignedIn: $userHasSignedIn,
                accountInfo: self.accountInfo
            )
        }
    }
}
