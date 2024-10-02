//
//  HomeView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

struct HomeView: View {
    @Binding public var section: String
    
    @State private var home_section: String = "main"
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(maxWidth: 30, maxHeight: 30)
                    .padding([.leading], 20)
                    .padding([.top], 30)
                
                Spacer()
                
                Image("AI-Chat-Icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding([.trailing], 20)
                    .padding([.top], 30)
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .background(Color.EZNotesLightBlack.opacity(0.4).blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)
            
            VStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    self.section = "upload"
                }
            })
        )
    }
}
