//
//  ShowNotesView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/14/24.
//
import SwiftUI

struct EditableNotes: View {
    var prop: Properties
    var fontPicked: String
    var fontSizePicked: CGFloat
    
    @Binding public var notesContent: String
    
    @FocusState private var notePadFocus: Bool
    @State private var selectionText: TextSelection? = nil
    @State private var textEditorPaddingBottom: CGFloat = 0
    @State private var textHeight: CGFloat = 40 // Initial height
    
    private func updateHeight(proxy: GeometryProxy? = nil) {
        let uiTextView = UITextView()
        uiTextView.text = self.notesContent
        uiTextView.font = UIFont.systemFont(ofSize: 17)
        uiTextView.sizeToFit()
        uiTextView.layoutIfNeeded()
        let calculatedHeight = uiTextView.contentSize.height
        DispatchQueue.main.async {
            self.textHeight = max(calculatedHeight, 40) // Minimum height fallback
        }
    }
    
    private func calculateHeight() -> CGFloat {
        let textView = UITextView()
        
        // Match TextEditor's configuration
        textView.text = self.notesContent
        textView.font = UIFont.systemFont(ofSize: self.fontSizePicked)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4) // Match SwiftUI's TextEditor padding
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.sizeToFit()
        
        // Calculate height for the given content width
        let fixedWidth = UIScreen.main.bounds.width // Screen width minus padding (adjust as needed)
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.infinity))
        return max(size.height, 100) // Return height with a minimum fallback
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(self.fontPicked)
                        .frame(alignment: .leading)
                        .foregroundStyle(.white)
                    
                    Divider()
                        .background(.white)
                        .frame(height: 15)
                    
                    Text("\(Int(self.fontSizePicked))px")
                        .frame(alignment: .leading)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: (prop.size.width / 2) - 35, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 10)
                
                HStack {
                    HStack {
                        Image(systemName: "sparkles")
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
                        
                        Text("AI Chat")
                            .frame(alignment: .center)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.clear)
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
                    
                    Button(action: { self.notePadFocus = false }) {
                        HStack {
                            Text("Stop Editing")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .padding(5)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.EZNotesBlue)
                        )
                        .cornerRadius(15)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
                
                /*HStack {
                 Button(action: { self.notePadFocus = false }) {
                 HStack {
                 Text("Stop Editing")
                 .frame(maxWidth: .infinity, alignment: .center)
                 .foregroundStyle(.black)
                 .padding(5)
                 }
                 .background(
                 RoundedRectangle(cornerRadius: 15)
                 .fill(Color.EZNotesBlue)
                 )
                 .cornerRadius(15)
                 }
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                 .padding(.trailing, 10)*/
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            
            VStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.secondary)
            
            ScrollView(.vertical, showsIndicators: true) {
                TextEditor(text: $notesContent, selection: $selectionText).id(0)
                    .frame(height: self.textHeight)
                    .scrollDisabled(true)
                    .scrollContentBackground(.hidden)
                    .background(Color.EZNotesBlack)
                    .padding(4.5)
                    .font(Font.custom(self.fontPicked, size: self.fontSizePicked))
                    .focused($notePadFocus)
                    .padding(.bottom, self.textEditorPaddingBottom)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.onChange(of: self.notesContent) {
                                self.updateHeight(proxy: proxy)
                            }
                        }
                    )
            }
            .onChange(of: self.notePadFocus) {
                /* TODO: Are animations really needed? */
                if self.notePadFocus {
                    withAnimation(.easeIn(duration: 0.5)) {
                        self.textEditorPaddingBottom = 350
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.textEditorPaddingBottom = 100
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.textHeight = calculateHeight()
        }
    }
}

struct ShowNotes: View {
    var prop: Properties
    var categoryName: String
    var setName: String
    var categoryBackgroundColor: Color?
    var categoryTitleColor: Color?
    
    let activeBorderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesBlue, Color.EZNotesOrange]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    let inactiveBorderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [.gray, .gray]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /* MARK: Needed for when "Undo Changed" is clicked we can just re-assign `notesContent` to its original state. */
    var originalContent: String
    
    @Binding public var notesContent: String
    @Binding public var launchedSet: Bool
    @Binding public var setAndNotes: [String: Array<[String: String]>]
    
    //@FocusState private var notePadFocus: Bool
    
    //@State private var showMenu: Bool = false
    //@State private var selectionText: TextSelection? = nil
    //@State private var selectedTextPopover: Bool = false
    //@State private var menuHeight: CGFloat = 0
    //@State private var menuOpacity: CGFloat = 0
    @State private var saveAlert: Bool = false
    //@State private var textEditorPaddingBottom: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var moving: Bool = false
    
    /* TODO: Grow this list. */
    /* MARK: Variables for "change_font" section */
    let fonts = ["Poppins-Regular", "Poppins-SemiBold", "Poppins-ExtraLight"]
    @State private var fontPicked: String = "Poppins-Regular"
    @State private var fontMenuTapped: Bool = false
    
    /* MARK: Variable for font size menu. */
    @State private var fontSizePicked: CGFloat = 16
    @State private var fontSizeMenuTapped: Bool = false
    
    /* MARK: The section of the menu the user is in. */
    @State private var showNotesSection: String = "edit"
    
    @State private var keyboardHeight: CGFloat = 0
    private func setupKeyboardListeners() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
        
    private func removeKeyboardListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
                        //self.notePadFocus = false
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
                        .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)//(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    /*if self.notePadFocus {
                        Button(action: {
                            self.notePadFocus = false
                            
                            /*withAnimation(.easeIn(duration: 0.5)) {
                                self.menuHeight = 150
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    self.menuOpacity = 1
                                }
                            }*/
                            
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
                    else { ZStack { }.frame(maxWidth: 80, alignment: .trailing).padding(.trailing, 15) }*/
                    ZStack { }.frame(maxWidth: 80, alignment: .trailing).padding(.trailing, 15)
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 60 : 40)
                .background(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)//self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesBlack)
                
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button(action: { self.showNotesSection = "edit" }) {
                                HStack {
                                    Text("Edit")
                                        .frame(alignment: .center)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 8.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.showNotesSection == "edit" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.showNotesSection == "edit" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 12))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.showNotesSection = "save_changes" }) {
                                HStack {
                                    Text("View/Save Changes")
                                        .frame(alignment: .center)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 8.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.showNotesSection == "save_changes" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.showNotesSection == "save_changes" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 12))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.showNotesSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 8.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.showNotesSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.showNotesSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 12))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            /*Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }*/
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 15)
                .padding(.top, 5)
                
                switch(self.showNotesSection) {
                case "edit":
                    EditableNotes(
                        prop: prop,
                        fontPicked: self.fontPicked,
                        fontSizePicked: self.fontSizePicked,
                        notesContent: $notesContent
                    )
                case "save_changes":
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    EditableNotes(
                        prop: prop,
                        fontPicked: self.fontPicked,
                        fontSizePicked: self.fontSizePicked,
                        notesContent: $notesContent
                    )
                }
                
                /* MARK: The popup menu can be triggered by a swipe up or a tap. */
                /*VStack {
                    Button(action: {
                        /*if self.showMenu {
                            
                            /* MARK: Animate the menu down. */
                            withAnimation(.easeOut(duration: 0.5)) {
                                self.menuOpacity = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    self.menuHeight = 60
                                }
                                
                                /* MARK: Hide the menu after the above animation runs. */
                                self.showMenu = false
                            }
                            
                            return
                        }*/
                        
                        self.showMenu = true
                        
                        /*withAnimation(.easeIn(duration: 0.5)) {
                            self.menuHeight = 350
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                self.menuOpacity = 1
                            }
                        }*/
                    }) {
                        ZStack {
                            Image(systemName: "chevron.up")
                                .foregroundStyle(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, self.showMenu ? 10 : 0)
                        .padding(.bottom, self.showMenu ? 0 : 20)
                        .offset(y: self.moving ? 10 : 0)
                        .animation(.easeInOut(duration: 2), value: self.moving)
                        .onAppear {
                            self.moving.toggle()
                            self.animationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                                self.moving.toggle()
                            }
                        }
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding(.bottom)
                    
                    /*if self.showMenu {
                        VStack {
                            /*HStack {
                                VStack {
                                    Text("Text:")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .font(Font.custom("Poppins-SemiBold", size: 18))
                                        .foregroundStyle(.black)
                                    
                                    Button(action: { self.fontMenuTapped = true }) {
                                        ZStack {
                                            Text("Change Font")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                    
                                    Button(action: { self.fontSizeMenuTapped = true }) {
                                        ZStack {
                                            Text("Change Size")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                    
                                    Button(action: { UIPasteboard.general.setValue(self.notesContent, forPasteboardType: "public.plain-text") }) {
                                        ZStack {
                                            Text("Copy Notes")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.leading, 15)
                                
                                VStack {
                                    Text("Changes:")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                        .font(Font.custom("Poppins-SemiBold", size: 18))
                                        .foregroundStyle(.black)
                                    
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
                                .frame(maxWidth: .infinity, alignment: .topTrailing)
                                .padding(.trailing, 15)
                            }
                            .frame(maxWidth: prop.size.width - 40, alignment: .top)*/
                            
                            HStack {
                                ZStack {
                                    Text("Text:")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(Font.custom("Poppins-SemiBold", size: 18))
                                        .foregroundStyle(.black)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                //.padding(.leading, 20)
                                
                                ZStack {
                                    Text("Changes:")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(Font.custom("Poppins-SemiBold", size: 18))
                                        .foregroundStyle(.black)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                //.padding(.trailing, 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            
                            HStack {
                                /* MARK: `VStack` will show "under" `Text:`. */
                                VStack {
                                    Button(action: { self.fontMenuTapped = true }) {
                                        ZStack {
                                            Text("Change Font")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                    
                                    Button(action: { self.fontSizeMenuTapped = true }) {
                                        ZStack {
                                            Text("Change Size")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                    
                                    Button(action: { UIPasteboard.general.setValue(self.notesContent, forPasteboardType: "public.plain-text") }) {
                                        ZStack {
                                            Text("Copy Notes")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(4.5)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.white)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 25)
                                
                                /* MARK: `VStack` will show "under" `Changes:`.*/
                                VStack {
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
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(.trailing, 25)
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            
                            Spacer()
                            
                            Text("Other Action:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                                .font(Font.custom("Poppins-SemiBold", size: 18))
                                .foregroundStyle(.black)
                            
                            /*HStack {
                                Button(action: { self.fontMenuTapped = true }) {
                                    ZStack {
                                        Text("Change Font")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(4.5)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                }
                                
                                Button(action: { self.fontSizeMenuTapped = true }) {
                                    ZStack {
                                        Text("Change Size")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(4.5)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                }
                                
                                Button(action: { UIPasteboard.general.setValue(self.notesContent, forPasteboardType: "public.plain-text") }) {
                                    ZStack {
                                        Text("Copy Notes")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(4.5)
                                            .foregroundStyle(.black)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            Divider()
                                .background(Color.black)
                                .frame(maxWidth: prop.size.width - 40)
                            
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
                            .frame(maxWidth: prop.size.width - 40)*/
                            
                            //VStack {
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
                                .frame(maxWidth: prop.size.width - 40)
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
                            //}
                            //.frame(maxWidth: prop.size.width - 40)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(self.menuOpacity)
                    }*/
                }
                .frame(maxWidth: .infinity, maxHeight: self.menuHeight)//self.showMenu ? 150 : 60)
                .background(.clear)//(.white.gradient.opacity(0.8))
                .cornerRadius(15, corners: [.topLeft, .topRight])
                .gesture(DragGesture(minimumDistance: 0.2, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.height < 0.2 {
                            self.showMenu = true
                        }
                    })
                )*/
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: [.bottom])
        /*.onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                self.menuHeight = 60
            }
        }*/
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
        /*.popover(isPresented: $showMenu) {
            VStack {
                VStack {
                    Text(self.showNotesSection == "save_changes"
                         ? "Save Changes"
                         : self.showNotesSection == "edit_font"
                         ? "Edit Font"
                         : "Other Actions")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundStyle(.white)
                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 30 : 25))
                    .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .top)
                
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button(action: { self.menuSection = "save_changes" }) {
                                HStack {
                                    Text("View/Save Changes")
                                        .frame(alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "save_changes" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "save_changes" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            /*Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Button(action: { self.menuSection = "change_font" }) {
                                HStack {
                                    Text("Edit Font")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(self.menuSection == "change_font" ? Color.EZNotesBlue : .clear)
                                        )
                                        .foregroundStyle(self.menuSection == "change_font" ? .black : .secondary)
                                        .font(Font.custom("Poppins-SemiBold", size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }*/
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                .padding([.top, .bottom], 5)
                
                VStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.secondary)
                
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.EZNotesBlack)
            .onDisappear { self.showMenu = false }
        }*/
    }
}
