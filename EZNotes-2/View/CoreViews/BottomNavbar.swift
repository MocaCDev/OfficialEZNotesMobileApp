//
//  BottomNavbar.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/4/24.
//
import SwiftUI

struct ButtomNavbar: View {
    
    @Binding public var section: String
    var backgroundColor: Color
    var prop: Properties
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { self.section = "home" }) {
                VStack {
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 25, height: 20)
                        //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                        .foregroundStyle(self.section != "home" ? Color.EZNotesBlue : Color.white)
                    
                    Text("Categories")
                        .foregroundStyle(.white)
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 25)
                .padding(.bottom, prop.isLargerScreen ? 10 : 5)
            }
            .buttonStyle(NoLongPressButtonStyle())
            
            Spacer()
            //Spacer()
            
            Button(action: { self.section = "upload" }) {
                VStack {
                    if self.section != "upload" {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                            .foregroundStyle(Color.EZNotesBlue)
                    } else {
                        Image("History-Icon")
                            .resizable()
                            .frame(width: 25, height: 25)
                            //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                    }
                    
                    Text(self.section != "upload" ? "Upload" : "History")
                        .foregroundStyle(.white)
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, prop.isLargerScreen ? 10 : 5)
            }
            .buttonStyle(NoLongPressButtonStyle())
            
            Spacer()
            //Spacer()
            
            Button(action: { self.section = "chat" }) {
                VStack {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 20, height: 20)
                        //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                        .foregroundStyle(self.section != "chat" ? Color.EZNotesBlue : Color.white)
                    
                    Text("Chat")
                        .foregroundStyle(.white)
                        .font(.system(size: 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, 25)
                .padding(.bottom, prop.isLargerScreen ? 10 : 5)
            }
            .buttonStyle(NoLongPressButtonStyle())
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
        .background(
            self.section == "upload"
            ? AnyView(Rectangle()
                .fill(Color.EZNotesLightBlack.opacity(0.5))
                .shadow(color: Color.black, radius: 2.5, y: -2.5))
            : AnyView(Color.clear)
        )
    }
}
