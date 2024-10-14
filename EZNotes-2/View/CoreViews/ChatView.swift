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
    
    var body: some View {
        VStack {
            TopNavChat(friendSearch: $friendSearch, prop: prop, backgroundColor: Color.EZNotesLightBlack)
            
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
    }
}
