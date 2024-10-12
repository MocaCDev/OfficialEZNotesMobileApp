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
            
            VStack {
                Button(action: { self.section = "home" }) {
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                        .foregroundStyle(self.section != "home" ? Color.EZNotesBlue : Color.white)
                }
                .buttonStyle(.borderless)
                Text("Categories")
                    .foregroundStyle(.white)
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading], 15)
            
            Spacer()
            //Spacer()
            
            VStack {
                Button(action: { self.section = "upload" }) {
                    if self.section != "upload" {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                            .foregroundStyle(Color.EZNotesBlue)
                    } else {
                        Image("History-Icon")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding([.top], prop.size.height / 2.5 > 300 ? 15 : 5)
                    }
                }
                .buttonStyle(.borderless)
                
                Text(self.section != "upload" ? "Upload" : "History")
                    .foregroundStyle(.white)
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            //Spacer()
            
            VStack {
                Button(action: { self.section = "chat" }) {
                    Image(systemName: "message")//self.section != "chat" ? "Chat" : "Chat-Active")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 20 : 5)
                        .foregroundStyle(self.section != "chat" ? Color.EZNotesBlue : Color.white)
                }
                .buttonStyle(.borderless)
                Text("Chat")
                    .foregroundStyle(.white)
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding([.trailing], 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(Rectangle()
            .fill(self.section == "upload" ? backgroundColor : .clear)
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: .infinity, maxHeight: 40)
            .border(width: 0.2, edges: [.top], color: self.section == "home" || self.section == "chat" ? .clear : .white))
    }
}

struct BottomNavbar_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
