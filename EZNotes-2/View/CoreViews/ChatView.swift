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
    @ObservedObject public var images_to_upload: ImagesUploads
    
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
        .background(Color.EZNotesBlack)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width > 0 {
                    self.section = "upload"
                }
            })
        )
    }
}
