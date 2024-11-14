//
//  ShowNotesView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/14/24.
//
import SwiftUI

struct ShowNotes: View {
    var prop: Properties
    var setName: String
    var categoryBackgroundColor: Color?
    var categoryTitleColor: Color?
    
    /* MARK: Needed for when "Undo Changed" is clicked we can just re-assign `notesContent` to its original state. */
    var originalContent: String
    
    @Binding public var notesContent: String
    @Binding public var launchedSet: Bool
    
    @FocusState private var notePadFocus: Bool
    
    @State private var showMenu: Bool = false
    
    var body: some View {
        ZStack {
            if self.showMenu {
                HStack {
                    VStack {
                        
                    }
                    .frame(maxWidth: prop.isLargerScreen ? 200 : 150, maxHeight: .infinity)
                    .background(.clear)
                    
                    VStack {
                        ZStack {
                            Text("Menu")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .font(Font.custom("Poppins-SemiBold", size: 28))
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 60 : 40)
                        .border(width: 0.5, edges: [.bottom], color: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesBlack)
                        
                        
                        Text("Actions:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .leading], 5)
                            .padding(.bottom, -5)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                            .minimumScaleFactor(0.5)
                        
                        Button(action: {
                            self.notesContent = self.originalContent
                        }) {
                            /*HStack {
                                Text("Undo Changes")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                                
                                ZStack {
                                    Image(systemName: "chevron.forward")
                                        .resizable()
                                        .frame(maxWidth: 10, maxHeight: 15)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: 15, alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom], 15)
                            .background(Color.EZNotesBlack.opacity(0.4))
                            .border(width: 0.5, edges: [.bottom], color: .gray)*/
                            HStack {
                                Text("Undo Changed")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(8)
                                    .foregroundStyle(.black)
                                    .setFontSizeAndWeight(weight: .medium, size: 16)
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing], 10)
                            .background(Color.white)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        
                        Button(action: {
                            print("Save Changes")
                        }) {
                            HStack {
                                Text("Save Changes")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                                
                                ZStack {
                                    Image(systemName: "chevron.forward")
                                        .resizable()
                                        .frame(maxWidth: 10, maxHeight: 15)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: 15, alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom], 15)
                            .background(Color.EZNotesBlack.opacity(0.4))
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        .padding(.top, -8)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .background(Color.EZNotesLightBlack)
                    
                    //Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
            }
            
            VStack {
                /*VStack {
                 HStack {
                 Button(action: {
                 self.notePadFocus = false
                 self.launchedSet = false
                 }) {
                 Image(systemName: "arrow.backward")
                 .resizable()
                 .frame(maxWidth: 15, maxHeight: 15)
                 .foregroundStyle(.white)
                 }
                 .buttonStyle(NoLongPressButtonStyle())
                 .frame(maxWidth: 80, alignment: .leading)
                 .padding(.leading, 15)
                 
                 Text(self.setName)
                 .frame(maxWidth: .infinity)
                 .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                 .font(Font.custom("Poppins-SemiBold", size: 22))
                 .minimumScaleFactor(0.5)
                 
                 ZStack {
                 
                 }
                 .frame(maxWidth: 80, alignment: .trailing)
                 .padding(.leading, 15)
                 }
                 
                 Divider()
                 .background(.white)
                 .frame(maxWidth: prop.size.width - 40)
                 
                 HStack {
                 Button(action: { print("Done") }) {
                 Text("Done")
                 .frame(maxWidth: .infinity, alignment: .center)
                 .foregroundStyle(.white)
                 .padding(8)
                 }
                 .buttonStyle(NoLongPressButtonStyle())
                 }
                 .frame(maxWidth: prop.size.width - 40)
                 }
                 .frame(maxWidth: .infinity, maxHeight: 80)
                 .background(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesBlack)*/
                
                HStack {
                    Button(action: {
                        self.notePadFocus = false
                        self.launchedSet = false
                    }) {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(maxWidth: 15, maxHeight: 15)
                            .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: 80, alignment: .leading)
                    .padding(.leading, 15)
                    
                    Text(self.setName)
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom], 4)
                        .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { self.showMenu = true }) {
                        ZStack {
                            Image("Menu")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .shadow(color: Color.black, radius: 1.5)
                        }
                        .frame(maxWidth: 80, alignment: .trailing)
                        .padding(.trailing, 15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 60 : 40)
                .background(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesBlack)
                
                if self.showMenu {
                    Text(self.notesContent)
                        .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity, alignment: .leading)
                        .padding(4.5)
                        .foregroundStyle(.white)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .onTapGesture {
                            self.showMenu = false
                        }
                } else {
                    TextEditor(text: $notesContent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(4.5)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .focused($notePadFocus)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
