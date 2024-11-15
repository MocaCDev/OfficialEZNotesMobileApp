//
//  ShowNotesView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/14/24.
//
import SwiftUI

struct ShowNotes: View {
    var prop: Properties
    var categoryName: String
    var setName: String
    var categoryBackgroundColor: Color?
    var categoryTitleColor: Color?
    
    /* MARK: Needed for when "Undo Changed" is clicked we can just re-assign `notesContent` to its original state. */
    var originalContent: String
    
    @Binding public var notesContent: String
    @Binding public var launchedSet: Bool
    @Binding public var setAndNotes: [String: Array<[String: String]>]
    
    @FocusState private var notePadFocus: Bool
    
    @State private var showMenu: Bool = false
    @State private var selectionText: TextSelection? = nil
    @State private var selectedTextPopover: Bool = false
    @State private var menuHeight: CGFloat = 0
    @State private var menuOpacity: CGFloat = 0
    @State private var saveAlert: Bool = false
    
    var body: some View {
        ZStack {
            /*if self.showMenu {
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
                                Text("Undo Changes")
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
            }*/
            
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
                        /* MARK: When going back, check to see if the content in the TextEditor is the same as it was when the TextEditor loaded. If it is not, prompt an alert asking the user if they want to save. */
                        /*if self.notesContent != self.originalContent {
                            self.saveAlert = true
                        }*/
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
                        .padding([.top, .bottom], 4)
                        .foregroundStyle(.white)//(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    if self.notePadFocus {
                        Button(action: {
                            self.notePadFocus = false
                            
                            withAnimation(.easeIn(duration: 0.5)) {
                                self.menuHeight = 150
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    self.menuOpacity = 1
                                }
                            }
                            
                            self.showMenu = true
                        }) {
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
                    else { ZStack { }.frame(maxWidth: 80, alignment: .trailing).padding(.trailing, 15) }
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 60 : 40)
                .background(.black)//self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesBlack)
                
                if self.showMenu {
                    ScrollView(.vertical, showsIndicators: true) {
                        Text(self.notesContent)
                            .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity, alignment: .leading)
                            .padding(4.5)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)
                            .onTapGesture {
                                self.showMenu = false
                                
                                withAnimation(.easeOut(duration: 0.5)) {
                                    self.menuHeight = 60
                                    self.menuOpacity = 0
                                }
                            }
                    }
                } else {
                    TextEditor(text: $notesContent, selection: $selectionText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .background(Color.EZNotesBlack)
                        .padding(4.5)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .focused($notePadFocus)
                }
                
                VStack {
                    Button(action: {
                        if self.showMenu {
                            self.showMenu = false
                            
                            /* MARK: Animate the menu down. */
                            withAnimation(.easeOut(duration: 0.5)) {
                                self.menuHeight = 60
                                self.menuOpacity = 0
                            }
                            
                            return
                        }
                        
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.menuHeight = 150
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                self.menuOpacity = 1
                            }
                        }
                        
                        self.showMenu = true
                    }) {
                        ZStack {
                            Image(systemName: !self.showMenu ? "chevron.up" : "chevron.down")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, self.showMenu ? 10 : 0)
                        .padding(.bottom, self.showMenu ? 0 : 20)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding(.bottom)
                    
                    if self.showMenu {
                        VStack {
                            HStack {
                                Button(action: {
                                    self.saveAlert = true
                                    //self.setAndNotes[self.categoryName]!.removeValue(forKey: self.setName)
                                }) {
                                    ZStack {
                                        Text("Save Changes")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(4.5)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                    .cornerRadius(15)
                                }
                                
                                ZStack {
                                    Text("Undo Changes")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(4.5)
                                        .foregroundStyle(.black)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                )
                                .cornerRadius(15)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            VStack {
                                HStack {
                                    HStack {
                                        ZStack {
                                            Image(systemName: "sparkles")
                                                .resizable()
                                                .frame(width: 20, height: 25)
                                                .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                                                    .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                    .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                ], colors: [
                                                    .indigo, .indigo, Color.EZNotesBlue,
                                                    Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                                    .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                                    /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                     Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                     Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                ]))
                                        }
                                        .frame(maxWidth: 20, alignment: .leading)
                                        
                                        Text("Get AI Help")
                                            .frame(alignment: .center)
                                            .padding(4.5)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: 200, alignment: .center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding([.top, .bottom], 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                        .strokeBorder(MeshGradient(width: 3, height: 3, points: [
                                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                                        ], colors: [
                                            .indigo, .indigo, Color.EZNotesBlue,
                                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                            /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                             Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                             Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                        ]))
                                )
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(self.menuOpacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: self.menuHeight)//self.showMenu ? 150 : 60)
                .background(self.categoryBackgroundColor != nil
                            ? self.categoryBackgroundColor!.opacity(0.8)
                            : .black.opacity(0.8)
                )
                .cornerRadius(15, corners: [.topLeft, .topRight])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: [.bottom])
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                self.menuHeight = 60
            }
        }
        .background(Color.EZNotesBlack)
        .alert("Are you sure?", isPresented: $saveAlert) {
            Button(action: {
                for (index, value) in self.setAndNotes[self.categoryName]!.enumerated() {
                    /* TODO: We need to make it to where the initial value (`[:]`), which gets assigned when initiating the variable, gets deleted. */
                    if value != [:] {
                        for key in value.keys {
                            if key == self.setName {
                                /* MARK: Remove the data from the dictionary. */
                                self.setAndNotes[self.categoryName]!.remove(at: index)
                                
                                /* MARK: Append the new dictionary with the update text. */
                                self.setAndNotes[self.categoryName]!.append([key: self.notesContent])
                            }
                        }
                    }
                }
                
                writeSetsAndNotes(setsAndNotes: self.setAndNotes)
            }) { Text("Yes") }
            
            Button("No", role: .cancel) { }
        } message: {
            Text("By continuing, your changes will be saved and you will not be able to undo them.")
        }
    }
}
