//
//  ShowNotesView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/14/24.
//
import SwiftUI

class FontConfiguration: ObservableObject {
    @Published public var fontPicked: String
    @Published public var fontSizePicked: CGFloat
    @Published public var fontAlignment: Alignment
    @Published public var fontTextAlignment: TextAlignment
    @Published public var fontColor: Color
    
    init(defaultFont: String, defaultFontSize: CGFloat) {
        fontPicked = defaultFont
        fontSizePicked = defaultFontSize
        fontColor = .white
        fontAlignment = .leading
        fontTextAlignment = .leading
    }
}

class NotesChatDetails: ObservableObject {
    @Published public var aiChatOverNotesChatID: UUID? = nil
    @Published public var aiChatOverNotes: Array<MessageDetails> = []
    @Published public var aiChatOverNotesIsLive: Bool = false
    
    func reset() {
        aiChatOverNotesChatID = nil
        aiChatOverNotes.removeAll()
        aiChatOverNotesIsLive = false
    }
}

struct EditableNotes: View {
    var prop: Properties
    /*var fontPicked: String
    var fontSizePicked: CGFloat*/
    @ObservedObject public var fontConfiguration: FontConfiguration
    var categoryName: String
    var setName: String
    
    @Binding public var notesContent: String
    @ObservedObject public var categoryData: CategoryData //@Binding public var setAndNotes: [String: Array<[String: String]>]
    
    @FocusState private var notePadFocus: Bool
    @State private var selectionText: TextSelection? = nil
    @State private var textEditorPaddingBottom: CGFloat = 150
    @State private var textHeight: CGFloat = 40 // Initial height
    @State private var keyboardHeight: CGFloat = 0
    
    /*private func updateHeight(proxy: GeometryProxy? = nil) {
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
    }*/
    
    private func textHeight(for text: String, width: CGFloat) -> CGFloat {
        /*let font = UIFont.systemFont(ofSize: 17)  // Customize this to match your font
         let constrainedSize = CGSize(width: width - 20, height: .infinity)  // Add padding to the width
         let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return boundingRect.height*/
        let textView = UITextView()
        textView.text = text + "\n\n\n"
        textView.font = UIFont.systemFont(ofSize: self.fontConfiguration.fontSizePicked)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        /* MARK: Configure the extra padding size in which will be added for each extra pixel past 16. */
        /* TODO: The below code can be tweaked a lot more. */
        let extraPaddingSize: CGFloat = self.fontConfiguration.fontSizePicked > 16 && self.fontConfiguration.fontSizePicked < 26
        ? 18
        : self.fontConfiguration.fontSizePicked > 26 && self.fontConfiguration.fontSizePicked < 36
            ? 28
            : self.fontConfiguration.fontSizePicked > 36 && self.fontConfiguration.fontSizePicked < 55
                ? 38
                : 44
        
        let extraPadding: CGFloat = extraPaddingSize * (self.fontConfiguration.fontSizePicked - 16) < 0 ? 0 :  extraPaddingSize * (self.fontConfiguration.fontSizePicked - 16)
        
        let fixedWidth = UIScreen.main.bounds.width//width - 16 // Account for padding
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        return max(size.height + self.textEditorPaddingBottom + extraPadding, 100) // Add a buffer and ensure a minimum height
    }
    
    /*@State private var aiChatOverNotesChatID: UUID? = nil
    @State private var aiChatOverNotes: Array<MessageDetails> = []
    @Binding public var aiChatOverNotesIsLive: Bool*/
    @ObservedObject public var noteChatDetails: NotesChatDetails
    @State private var aiIsTyping: Bool = false
    @State private var numberOfTheAnimationgBall = 3
    @State private var messageBoxTapped: Bool = false
    @State private var hideLeftsideContent: Bool = false
    @State private var messageInput: String = ""
    @State private var currentYPosOfMessageBox: CGFloat = 0
    
    // MAKR: - Drawing Constants
    let ballSize: CGFloat = 10
    let speed: Double = 0.3
    let chatUUID: UUID = UUID()
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height - 10
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { _ in
                self.keyboardHeight = 0
            }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var body: some View {
        ZStack {
            if self.noteChatDetails.aiChatOverNotesIsLive {
                VStack {
                    HStack {
                        Button(action: { self.noteChatDetails.aiChatOverNotesIsLive = false }) {
                            ZStack {
                                Image(systemName: "multiply")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.black)
                                    .padding(5.5)
                                    .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                    .clipShape(.circle)
                            }
                            .frame(width: 30, height: 30, alignment: .leading)
                            .padding([.leading, .top], 10)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    
                    VStack {
                        ZStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack {
                                        ForEach(self.noteChatDetails.aiChatOverNotes, id: \.self) { message in
                                            MessageView(message: message, aiIsTyping: $aiIsTyping)
                                                .id(message)
                                        }
                                        
                                        if self.aiIsTyping {
                                            HStack(alignment: .firstTextBaseline) {
                                                ForEach(0..<3) { i in
                                                    Capsule()
                                                        .foregroundColor((self.numberOfTheAnimationgBall == i) ? .blue : Color(UIColor.darkGray))
                                                        .frame(width: self.ballSize, height: self.ballSize)
                                                        .offset(y: (self.numberOfTheAnimationgBall == i) ? -5 : 0)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .animation(Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1).speed(2), value: UUID())
                                            .onAppear {
                                                Timer.scheduledTimer(withTimeInterval: self.speed, repeats: true) { _ in
                                                    var randomNumb: Int
                                                    repeat {
                                                        randomNumb = Int.random(in: 0...2)
                                                    } while randomNumb == self.numberOfTheAnimationgBall
                                                    self.numberOfTheAnimationgBall = randomNumb
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: self.noteChatDetails.aiChatOverNotes) {
                                        withAnimation {
                                            proxy.scrollTo(self.noteChatDetails.aiChatOverNotes.last)
                                        }
                                    }
                                    /*.onChange(of: self.aiIsTyping) {
                                     //if self.aiIsTyping {
                                     //    proxy.scrollTo(self.chatUUID)
                                     //}
                                     }*/
                                    .onChange(of: self.messageBoxTapped) {
                                        withAnimation {
                                            proxy.scrollTo(self.noteChatDetails.aiChatOverNotes.last)
                                        }
                                    }
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(self.noteChatDetails.aiChatOverNotes.last, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            self.messageBoxTapped = false
                        }
                        
                        Spacer()
                        
                        HStack {
                            if !self.hideLeftsideContent {
                                VStack {
                                    Button(action: { print("Upload File") }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .frame(width: 15, height: 20)
                                            .foregroundStyle(.white)//(Color.EZNotesOrange)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.bottom, 2.5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.leading, 10)
                                .padding(.top, 10)
                                .padding(.bottom, self.keyboardHeight == 0 ? 10 : 0)
                                
                                VStack {
                                    Button(action: { print("Take live picture to get instant feedback") }) {
                                        Image(systemName: "camera")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.top, 10)
                                .padding(.bottom, self.keyboardHeight == 0 ? 10 : 0)
                            }
                            
                            VStack {
                                TextField("Message...", text: $messageInput, axis: .vertical)
                                    .frame(maxWidth: prop.size.width - 40, minHeight: 30)
                                    .padding([.top, .bottom], 4)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 35)
                                    .cornerRadius(7.5)
                                    .padding(.horizontal, 5)
                                    .keyboardType(.alphabet)
                                    .background(
                                        self.hideLeftsideContent
                                        ? AnyView(RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .stroke(LinearGradient(gradient: Gradient(
                                                colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                            ), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
                                        : AnyView(RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .border(width: 1, edges: [.bottom], lcolor: LinearGradient(gradient: Gradient(
                                                colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                            ), startPoint: .leading, endPoint: .trailing)))
                                    )
                                    .foregroundStyle(.white)
                                    .overlay(
                                        HStack {
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .preference(key: ViewPositionKey.self, value: geometry.frame(in: .global).minY)
                                            }.frame(width: 0, height: 0)
                                            
                                            /* MARK: Exists to push the `x` button to the end of the textfield. */
                                            VStack { }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            
                                            if self.messageInput.count > 0 {
                                                Button(action: {
                                                    self.messageInput.removeAll()
                                                }) {
                                                    Image(systemName: "multiply.circle.fill")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing, 15)
                                                }
                                            }
                                        }
                                    )
                                    .padding(.top, 10)
                                    .padding(.bottom, self.keyboardHeight == 0 ? 10 : 0)
                                    .onChange(of: self.messageInput) {
                                        if self.messageInput.count > 0 { self.hideLeftsideContent = true }
                                        else { self.hideLeftsideContent = false }
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, !self.hideLeftsideContent ? 15 : 0)
                            .padding(.leading, !self.hideLeftsideContent ? 0 : 10)
                            .onPreferenceChange(ViewPositionKey.self) { value in
                                if value < self.currentYPosOfMessageBox {
                                    self.messageBoxTapped = true
                                }
                                
                                self.currentYPosOfMessageBox = value
                            }
                            
                            if self.hideLeftsideContent {
                                VStack {
                                    Button(action: {
                                        self.aiIsTyping = true
                                        
                                        self.noteChatDetails.aiChatOverNotes.append(MessageDetails(
                                            MessageID: UUID(),
                                            MessageContent: self.messageInput,
                                            userSent: true,
                                            dateSent: Date.now
                                        ))
                                        
                                        RequestAction<SendAIChatMessageData>(
                                            parameters: SendAIChatMessageData(
                                                ChatID: self.noteChatDetails.aiChatOverNotesChatID!,
                                                AccountId: getUDValue(key: "account_id"),
                                                Message: self.messageInput
                                            )
                                        ).perform(action: send_ai_chat_message_req) { statusCode, resp in
                                            self.aiIsTyping = false
                                            
                                            guard resp != nil && statusCode == 200 else {
                                                return
                                            }
                                            
                                            self.noteChatDetails.aiChatOverNotes.append(MessageDetails(
                                                MessageID: UUID(),
                                                MessageContent: resp!["AIResponse"] as! String,
                                                userSent: false,
                                                dateSent: Date.now
                                            ))
                                        }
                                        
                                        self.messageInput.removeAll()
                                    }) {
                                        Image(systemName: "arrow.up")
                                            .resizableImage(width: 15, height: 20)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.trailing, 10)
                                .padding(.leading, 5)
                                .padding(.top, 10)
                                .padding(.bottom, self.keyboardHeight == 0 ? 10 : 0)
                            }
                        }
                        .padding(.bottom, self.keyboardHeight == 0 ? 0 : self.keyboardHeight)
                        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Rectangle()
                        .fill(Color.EZNotesLightBlack.opacity(0.95))
                )
                .zIndex(1)
                .onAppear {
                    // Detect keyboard notifications when the view appears
                    addKeyboardObservers()
                }
                .onDisappear {
                    // Remove keyboard observers when the view disappears
                    removeKeyboardObservers()
                }
            }
            
            VStack {
                HStack {
                    HStack {
                        Text(self.fontConfiguration.fontPicked)
                            .frame(minWidth: 20, maxWidth: prop.isLargerScreen ? 120 : 80, alignment: .leading)
                            .foregroundStyle(.white)
                            .truncationMode(.tail)
                        
                        Divider()
                            .background(.white)
                            .frame(height: 15)
                        
                        Text("\(Int(self.fontConfiguration.fontSizePicked))px")
                            .frame(alignment: .leading)
                            .foregroundStyle(.white)
                    }
                    .frame(maxHeight: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    
                    HStack {
                        Button(action: {
                            if self.noteChatDetails.aiChatOverNotesChatID == nil {
                                RequestAction<StartAIChatOverNotesData>(parameters: StartAIChatOverNotesData(
                                    Notes: self.notesContent
                                ))
                                .perform(action: start_ai_chat_over_notes_req) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        if let resp = resp { print(resp) }
                                        /* TODO: handle errors. */
                                        return
                                    }
                                    
                                    self.noteChatDetails.aiChatOverNotesChatID = UUID(uuidString: resp!["ChatID"]! as! String)!
                                    self.noteChatDetails.aiChatOverNotesIsLive = true
                                }
                            } else { self.noteChatDetails.aiChatOverNotesIsLive = true }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .resizable()
                                    .frame(width: prop.isLargerScreen ? 15 : 10, height: prop.isLargerScreen ? 15 : 20)
                                    .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                                        .init(0, 0), .init(0.3, 0), .init(1, 0),
                                        .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                                    ], colors: [
                                        .indigo, .indigo, Color.EZNotesBlue,
                                        Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                        .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                    ]))
                                
                                Text("AI Chat")
                                    .frame(alignment: .center)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 10))
                                    .foregroundStyle(.white)
                                    .minimumScaleFactor(0.5)
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
                                    ]))
                            )
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        
                        Button(action: {
                            self.notePadFocus = false
                            
                            /* MARK: Just testing. */
                            for (index, value) in self.categoryData.setAndNotes[self.categoryName]!.enumerated() {
                                /* TODO: We need to make it to where the initial value (`[:]`), which gets assigned when initiating the variable, gets deleted. */
                                if value != [:] {
                                    for key in value.keys {
                                        if key == self.setName {
                                            /* MARK: Remove the data from the dictionary. */
                                            self.categoryData.setAndNotes[self.categoryName]!.remove(at: index)
                                            
                                            /* MARK: Append the new dictionary with the update text. */
                                            self.categoryData.setAndNotes[self.categoryName]!.append([key: self.notesContent])
                                        }
                                    }
                                }
                            }
                            
                            writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                        }) {
                            HStack {
                                Text("Stop Editing")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 10))
                                    .foregroundStyle(.black)
                                    .padding(5)
                                    .minimumScaleFactor(0.5)
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
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                
                EZNotesColoredDivider()
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        TextEditor(text: $notesContent)
                            .frame(height: textHeight(for: notesContent, width: UIScreen.main.bounds.width), alignment: self.fontConfiguration.fontAlignment) // Calculate height dynamically
                            .foregroundStyle(self.fontConfiguration.fontColor)
                            .padding(8.5)
                            .scrollDisabled(true)
                            .scrollContentBackground(.hidden)
                            .background(Color.EZNotesBlack)
                            .focused($notePadFocus)
                            .font(Font.custom(self.fontConfiguration.fontPicked, size: self.fontConfiguration.fontSizePicked))
                            .multilineTextAlignment(self.fontConfiguration.fontTextAlignment)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: self.notePadFocus) {
                        if self.notePadFocus {
                            withAnimation(.easeIn(duration: 0.5)) {
                                self.textEditorPaddingBottom += 300
                            }
                            return
                        }
                        
                        /* MARK: We can assume `notePadFocus` is hereby false. */
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.textEditorPaddingBottom -= 300
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(self.noteChatDetails.aiChatOverNotesIsLive ? [.bottom] : .init())
        /*.onAppear {
            self.textHeight = calculateHeight()
        }*/
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
    @State public var originalContent: String
    
    @Binding public var notesContent: String
    @Binding public var launchedSet: Bool
    @ObservedObject public var categoryData: CategoryData//@Binding public var setAndNotes: [String: Array<[String: String]>]
    
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
    //@State private var fontPicked: String = "Poppins-Regular"
    //@State private var fontAlignment: Alignment = .leading
    @State private var fontMenuTapped: Bool = false
    
    @StateObject private var fontConfiguration: FontConfiguration = FontConfiguration(
        defaultFont: "Poppins-Regular",
        defaultFontSize: 16
    )
    
    /* MARK: Variable for font size menu. */
    //@State private var fontSizePicked: CGFloat = 16
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
    
    @State private var aiGeneratedSummaryOfChanges: String = ""
    @State private var loadingAiGeneratedSummaryOfChanges: Bool = false
    @State private var showHelp: Bool = false
    @State private var aiGeneratedSummaryWidth: CGFloat = 0
    @State private var isVisible: Bool = false /* TODO: Change the name of this variable. */
    @State private var noteSelected: String = ""
    @State private var reWordedNotes: String = ""
    @State private var rewritingNotes: Bool = false
    @State private var rewritingNotesAnimation: Bool = false
    
    @State private var noteSelectedAnimation: Bool = false
    
    private func textHeight(for text: String, width: CGFloat) -> CGFloat {
        /*let font = UIFont.systemFont(ofSize: 17)  // Customize this to match your font
         let constrainedSize = CGSize(width: width - 20, height: .infinity)  // Add padding to the width
         let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return boundingRect.height*/
        let textView = UITextView()
        textView.text = text + "\n\n\n"
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        let fixedWidth = width - 16 // Account for padding
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return max(size.height + 60, 100) // Add a buffer and ensure a minimum height
    }
    
    @State private var targetX: CGFloat = 0
    @State private var targetY: CGFloat = 0
    
    //@State private var aiChatOverNotesIsLive: Bool = false
    @StateObject private var noteChatDetails: NotesChatDetails = NotesChatDetails()
    
    let EZNotesMG: MeshGradient = MeshGradient(width: 3, height: 3, points: [
        .init(0, 0), .init(0.3, 0), .init(1, 0),
        .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
        .init(0, 1), .init(0.5, 1), .init(1, 1)
    ], colors: [
        .indigo, .indigo, Color.EZNotesBlue,
        Color.EZNotesBlue, Color.EZNotesBlue, .purple,
        .indigo, Color.EZNotesGreen, Color.EZNotesBlue
    ])
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        /* MARK: When going back, check to see if the content in the TextEditor is the same as it was when the TextEditor loaded. If it is not, prompt an alert asking the user if they want to save. */
                        /*if self.notesContent != self.originalContent {
                            self.saveAlert = true
                        }*/
                        //self.notePadFocus = false
                        self.noteChatDetails.reset()
                        self.launchedSet = false
                    }) {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(maxWidth: 15, maxHeight: 15)
                            .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: 30, alignment: .leading)
                    .padding(.leading, 15)
                    
                    Text(self.setName)
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom], 4)
                        .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)//(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    ZStack {}.frame(maxWidth: 30, alignment: .trailing).padding(.trailing, 15)
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
                            
                            Button(action: {
                                self.showNotesSection = "save_changes"
                                
                                self.loadingAiGeneratedSummaryOfChanges = true
                                RequestAction<SummarizeNotesData>(parameters: SummarizeNotesData(
                                    OriginalNotes: self.originalContent, EditedNotes: self.notesContent
                                ))
                                .perform(action: summarize_notes_req) { statusCode, resp in
                                    self.loadingAiGeneratedSummaryOfChanges = false
                                    guard
                                        let resp = resp,
                                        resp.keys.contains("Summarization"),
                                        statusCode == 200
                                    else {
                                        if let resp = resp { print(resp) }
                                        
                                        self.aiGeneratedSummaryOfChanges = "I was unable to effectively perform my duties detecting changes :("
                                        return
                                    }
                                    
                                    self.aiGeneratedSummaryOfChanges = resp["Summarization"] as! String
                                }
                            }) {
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
                            .buttonStyle(NoLongPressButtonStyle())
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
                        fontConfiguration: self.fontConfiguration,
                        categoryName: self.categoryName,
                        setName: self.setName,
                        notesContent: $notesContent,
                        categoryData: self.categoryData,//setAndNotes: $setAndNotes,
                        noteChatDetails: self.noteChatDetails
                    )
                case "change_font":
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            HStack {
                                Text("Font Family:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 26, weight: .bold))
                                    .minimumScaleFactor(0.5)
                                
                                Menu {
                                    ForEach(self.fonts, id: \.self) { font in
                                        Button(action: { self.fontConfiguration.fontPicked = font }) { Text(font) }
                                    }
                                } label: {
                                    HStack {
                                        Text(self.fontConfiguration.fontPicked)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: 16))
                                            .padding([.top, .leading, .bottom], 10)
                                        
                                        VStack {
                                            Image(systemName: "arrowtriangle.up")
                                                .resizable()
                                                .frame(width: 6.5, height: 6.5)
                                                .foregroundStyle(.white)
                                                .padding(.bottom, -2)
                                            
                                            Image(systemName: "arrowtriangle.down")
                                                .resizable()
                                                .frame(width: 6.5, height: 6.5)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 2)
                                    .background(Color.EZNotesLightBlack)
                                    .cornerRadius(15)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .padding(.top, 20)
                            
                            Text("This text is displaying what it will look like in the notes. If you don't like it, change it.")
                                .frame(maxWidth: prop.size.width - 60, alignment: .leading) /* MARK: "Indent" the actual test text a bit. */
                                .foregroundStyle(.white)
                                .font(Font.custom(self.fontConfiguration.fontPicked, size: 16))
                                .minimumScaleFactor(0.5)
                                .padding(.top, 2)
                            
                            Divider()
                                .background(self.EZNotesMG)
                                .frame(width: prop.size.width - 40)
                            
                            HStack {
                                Text("Font Size:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 26, weight: .bold))
                                    .minimumScaleFactor(0.5)
                                
                                Menu {
                                    ForEach(8...60, id: \.self) { size in
                                        Button(action: { self.fontConfiguration.fontSizePicked = CGFloat(size) }) { Text("\(size)") }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(Int(self.fontConfiguration.fontSizePicked))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: 16))
                                            .padding([.top, .leading, .bottom], 10)
                                        
                                        VStack {
                                            Image(systemName: "arrowtriangle.up")
                                                .resizable()
                                                .frame(width: 6.5, height: 6.5)
                                                .foregroundStyle(.white)
                                                .padding(.bottom, -5)
                                            
                                            Image(systemName: "arrowtriangle.down")
                                                .resizable()
                                                .frame(width: 6.5, height: 6.5)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 2)
                                    .background(Color.EZNotesLightBlack)
                                    .cornerRadius(15)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .padding(.top, 15)
                            
                            Text("This text is displaying what it will look like in the notes. If you don't like it, change it.")
                                .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(Font.custom(self.fontConfiguration.fontPicked, size: self.fontConfiguration.fontSizePicked))
                                .minimumScaleFactor(0.5)
                                .padding([.top, .bottom], 8)
                            
                            Divider()
                                .background(self.EZNotesMG)
                                .frame(width: prop.size.width - 40)
                                .padding(.bottom, 15)
                            
                            VStack {
                                Text("Alignment:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 26, weight: .bold))
                                    .minimumScaleFactor(0.5)
                                
                                HStack {
                                    Button(action: {
                                        self.fontConfiguration.fontAlignment = .leading
                                        self.fontConfiguration.fontTextAlignment = .leading
                                    }) {
                                        VStack {
                                            Image(systemName: "align.horizontal.left")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundStyle(self.EZNotesMG)
                                            
                                            Text("Left")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Button(action: {
                                        self.fontConfiguration.fontAlignment = .center
                                        self.fontConfiguration.fontTextAlignment = .center
                                    }) {
                                        VStack {
                                            Image(systemName: "align.horizontal.center")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundStyle(self.EZNotesMG)
                                            
                                            Text("Center")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    
                                    Button(action: {
                                        self.fontConfiguration.fontAlignment = .trailing
                                        self.fontConfiguration.fontTextAlignment = .trailing
                                    }) {
                                        VStack {
                                            Image(systemName: "align.horizontal.right")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundStyle(self.EZNotesMG)
                                            
                                            Text("Right")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            Text("This text is displaying what it will look like in the notes. If you don't like it, change it.")
                                .frame(maxWidth: prop.size.width - 60, alignment: self.fontConfiguration.fontAlignment)
                                .foregroundStyle(.white)
                                .font(Font.custom(self.fontConfiguration.fontPicked, size: 16))
                                .minimumScaleFactor(0.5)
                                .padding([.top, .bottom], 8)
                                .multilineTextAlignment(self.fontConfiguration.fontTextAlignment)
                            
                            Divider()
                                .background(self.EZNotesMG)
                                .frame(width: prop.size.width - 40)
                                .padding(.bottom, 15)
                            
                            VStack {
                                HStack {
                                    Text("Text Color:")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 26, weight: .bold))
                                        .minimumScaleFactor(0.5)
                                    
                                    ZStack {
                                        ColorPicker("", selection: $fontConfiguration.fontColor)
                                            .frame(width: 38, height: 40)
                                            .padding(3.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity)
                                
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(self.fontConfiguration.fontColor)
                                    .frame(maxHeight: prop.isLargerScreen ? 100 : 80)
                                    .scaledToFit()
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            Text("This text is displaying what it will look like in the notes. If you don't like it, change it.")
                                .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                                .foregroundStyle(self.fontConfiguration.fontColor)
                                .font(Font.custom(self.fontConfiguration.fontPicked, size: 16))
                                .minimumScaleFactor(0.5)
                                .padding([.top, .bottom], 8)
                                .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                /* MARK: Obtain values of RGB from the picked font color. `ColorData` can be found in `JSONHandler.swift`. */
                                let components = self.fontConfiguration.fontColor.components()
                                let colorDataArray = ColorData(red: components.red, green: components.green, blue: components.blue)
                                
                                var fontConfigData: [String: [String: String]] = getFontConfiguration() != nil ? getFontConfiguration()! : [:]
                                
                                fontConfigData[self.setName] = [
                                    "Family": "\(self.fontConfiguration.fontPicked)",
                                    "Size": "\(Int(self.fontConfiguration.fontSizePicked))",
                                    "Alignment": self.fontConfiguration.fontAlignment == .leading
                                        ? "leading"
                                        : self.fontConfiguration.fontAlignment == .center
                                            ? "center"
                                            : "trailing",
                                    "TextAlignment": self.fontConfiguration.fontTextAlignment == .leading
                                        ? "leading"
                                        : self.fontConfiguration.fontTextAlignment == .center
                                            ? "center"
                                            : "trailing",
                                    "FontColorRed": "\(colorDataArray.red)",
                                    "FontColorGreen": "\(colorDataArray.green)",
                                    "FontColorBlue": "\(colorDataArray.blue)"
                                ]
                                
                                writeFontConfiguration(fontConfiguration: fontConfigData)
                            }) {
                                HStack {
                                    Text("Save")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding([.top, .bottom], 8)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: prop.size.width - 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                )
                                .cornerRadius(15)
                                
                                /* MARK: Ensure space between bottom of screen and end of the scrollview. */
                                VStack { }.frame(maxWidth: .infinity, maxHeight: 35)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(.bottom, 20) /* MARK: Ensure there is spacing between the bottom of the screen and the end of the content. */
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case "save_changes":
                    VStack {
                        //VStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.secondary)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                if self.loadingAiGeneratedSummaryOfChanges {
                                    ZStack {
                                        ProgressView()
                                            .tint(Color.EZNotesBlue)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(self.EZNotesMG)
                                        
                                        Text(self.aiGeneratedSummaryOfChanges)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(self.aiGeneratedSummaryOfChanges != "No Changes"
                                                             ? self.EZNotesMG
                                                             :MeshGradient(width: 3, height: 3, points: [
                                                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                             ], colors: [
                                                                .white, .white, .white,
                                                                .white, .white, .white,
                                                                .white, .white, .white
                                                                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                 Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                 Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                             ])
                                            )
                                            .padding(.leading, 10)
                                            .font(Font.custom("Poppins-SemiBold", size: 16))
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)
                                            .shadow(color: Color.white, radius: 2.5)
                                    )
                                    .padding(.top, 20)
                                    .padding([.leading, .trailing, .bottom], 10)
                                    .cornerRadius(15)
                                    .scaleEffect(x: 1.0, y: isVisible ? 1.0 : 0.0, anchor: .leading) // Animate width from left to right
                                    .animation(.easeOut(duration: 0.5), value: isVisible) // Apply animation
                                    .onAppear {
                                        isVisible = true
                                    }
                                    .onDisappear {
                                        isVisible = false
                                    }
                                }
                                
                                VStack {
                                    HStack {
                                        HStack {
                                            if self.noteSelected != "" {
                                                Button(action: {
                                                    self.noteSelected.removeAll()
                                                    self.noteSelectedAnimation = false
                                                }) {
                                                    Image(systemName: "arrow.backward")
                                                        .resizable()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(.white)
                                                        .padding(.trailing, 10)
                                                }
                                            }
                                            
                                            Text(self.noteSelected == "original"
                                                 ? "Original Version:"
                                                 : self.noteSelected == "edited"
                                                 ? "Edited Version:"
                                                 : "Notes:")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 26))
                                            .fontWeight(.bold)
                                            .minimumScaleFactor(0.5)
                                        }
                                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                    }
                                    
                                    if self.noteSelected == "" {
                                        VStack {
                                            HStack {
                                                Button(action: {
                                                    self.noteSelected = "original"
                                                    self.noteSelectedAnimation = true
                                                }) {
                                                    VStack {
                                                        Text(self.originalContent)
                                                            .frame(width: 105, height: 105)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: 8))
                                                            .padding(8)
                                                            .background(Color.EZNotesLightBlack.opacity(0.8))
                                                            .cornerRadius(15)
                                                        
                                                        Text("Original")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom("Poppins-Regular", size: 20))
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 10)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                
                                                Button(action: {
                                                    self.noteSelected = "edited"
                                                    self.noteSelectedAnimation = true
                                                }) {
                                                    VStack {
                                                        Text(self.notesContent)
                                                            .frame(width: 105, height: 105)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: 8))
                                                            .padding(8)
                                                            .background(Color.EZNotesLightBlack.opacity(0.8))
                                                            .cornerRadius(15)
                                                        
                                                        Text("Edited")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom("Poppins-Regular", size: 20))
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                
                                                Button(action: { print("Add Notes") }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "plus")
                                                                .resizable()
                                                                .frame(width: 30, height: 30)
                                                        }
                                                        .frame(width: 105, height: 105)
                                                        .foregroundStyle(.white)
                                                        .font(Font.custom(self.fontConfiguration.fontPicked, size: 10))
                                                        .padding(8)
                                                        .background(Color.EZNotesLightBlack.opacity(0.8))
                                                        .cornerRadius(15)
                                                        
                                                        Text("Add")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom("Poppins-Regular", size: 20))
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .padding(.trailing, 10)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            .frame(maxWidth: prop.size.width - 50)
                                        }
                                        .frame(maxWidth: .infinity)
                                    } else {
                                        switch(self.noteSelected) {
                                        case "original":
                                            VStack {
                                                VStack {
                                                    ScrollView(.vertical, showsIndicators: true) {
                                                        Text(self.notesContent)
                                                            .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: self.fontConfiguration.fontSizePicked))
                                                            .multilineTextAlignment(.leading)
                                                            /*.scaleEffect(self.rewritingNotes
                                                                         ? self.rewritingNotesAnimation
                                                                            ? 1.05 : 1.0
                                                                         : 1
                                                            )*/
                                                            .offset(x: self.rewritingNotes
                                                                    ? self.rewritingNotesAnimation
                                                                        ? CGFloat.random(in: -6...8)
                                                                        : 0
                                                                    : 0,
                                                                    y: self.rewritingNotes
                                                                    ? self.rewritingNotesAnimation
                                                                        ? CGFloat.random(in: -6...8)
                                                                        : 0
                                                                    : 0
                                                            )
                                                            .animation(
                                                                .easeInOut(duration: 1.0),
                                                                value: self.rewritingNotesAnimation
                                                            )
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2 - 60)
                                                    /*.frame(maxWidth: .infinity, maxHeight: textHeight(for: notesContent, width: UIScreen.main.bounds.width - 32))//prop.size.height / 2 - 60)
                                                    .scaleEffect(x: self.noteSelectedAnimation ? 1.0 : 0.0, y: self.noteSelectedAnimation ? 1.0 : 0.0, anchor: .leading) // Animate width from left to right
                                                    .animation(.easeOut(duration: 0.5), value: self.noteSelectedAnimation) // Apply animation*/
                                                }
                                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.EZNotesLightBlack)
                                                )
                                                .cornerRadius(15)
                                                
                                                Button(action: {
                                                    self.noteSelected = "edited"
                                                }) {
                                                    HStack {
                                                        Text("View Edited")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .foregroundStyle(.black)
                                                            .setFontSizeAndWeight(weight: .bold, size: 18)
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                    .padding([.top, .bottom], 8)
                                                    .background(.white)
                                                    .cornerRadius(15)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .padding(.top, 15)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        case "edited":
                                            VStack {
                                                VStack {
                                                    ScrollView(.vertical, showsIndicators: true) {
                                                        Text(self.notesContent)
                                                            .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                                                            .foregroundStyle(.white)
                                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: self.fontConfiguration.fontSizePicked))
                                                            .multilineTextAlignment(.leading)
                                                            /*.scaleEffect(self.rewritingNotes
                                                                         ? self.rewritingNotesAnimation
                                                                            ? 1.05 : 1.0
                                                                         : 1
                                                            )*/
                                                            .offset(x: self.rewritingNotes
                                                                    ? self.rewritingNotesAnimation
                                                                        ? CGFloat.random(in: -6...8)
                                                                        : 0
                                                                    : 0,
                                                                    y: self.rewritingNotes
                                                                    ? self.rewritingNotesAnimation
                                                                        ? CGFloat.random(in: -6...8)
                                                                        : 0
                                                                    : 0
                                                            )
                                                            .animation(
                                                                .easeInOut(duration: 1.0),
                                                                value: self.rewritingNotesAnimation
                                                            )
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2 - 60)
                                                }
                                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.EZNotesLightBlack)
                                                )
                                                .shadow(
                                                    color: Color.EZNotesBlue,
                                                    radius: self.rewritingNotes ? self.rewritingNotes ? 1.5 : 0 : 0,
                                                    x: self.rewritingNotes ? self.rewritingNotesAnimation ? CGFloat(Int.random(in: -4...4)) : 0 : 0,
                                                    y: self.rewritingNotes ? self.rewritingNotesAnimation ? CGFloat(Int.random(in: -4...4)) : 0 : 0
                                                )
                                                .animation(.easeInOut(duration: 0.5), value: self.rewritingNotes && self.rewritingNotesAnimation)
                                                .cornerRadius(15)
                                                
                                                if self.rewritingNotes {
                                                    VStack {
                                                        Text("Re-writing the notes...")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .foregroundStyle(self.EZNotesMG)
                                                            .font(.system(size: 14))
                                                            .fontWeight(.medium)
                                                        
                                                        ProgressView()
                                                            .tint(Color.EZNotesBlue)
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .padding()
                                                } else {
                                                    if self.reWordedNotes != "" {
                                                        VStack {
                                                            Text("Re-Written:")
                                                                .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 20))
                                                                .fontWeight(.bold)
                                                                .minimumScaleFactor(0.5)
                                                            
                                                            ZStack {
                                                                self.EZNotesMG
                                                                .blur(radius: 10)
                                                                /*.offset(
                                                                 x: self.moving ? CGFloat(Int.random(in: 0...6)) : 0,
                                                                 y: self.moving ? CGFloat(Int.random(in: 0...6)) : 0
                                                                 )
                                                                 .animation(.easeInOut(duration: 0.5).repeatForever(), value: self.moving)*/
                                                                .offset(x: targetX, y: targetY) // Offset controlled by targetX and targetY
                                                                .animation(
                                                                    .easeInOut(duration: 0.4), // Smooth animation
                                                                    value: targetX
                                                                )
                                                                .animation(
                                                                    .easeInOut(duration: 0.4), // Smooth animation
                                                                    value: targetY
                                                                )
                                                                //.animation(.easeOut(duration: 1.5), value: !self.moving)
                                                                .padding(5.5)
                                                                
                                                                HStack {
                                                                    Image(systemName: "sparkles")
                                                                        .frame(width: 20, height: 20)
                                                                        .foregroundStyle(self.EZNotesMG)
                                                                    
                                                                    ScrollView(.vertical, showsIndicators: true) {
                                                                        Text(self.reWordedNotes)
                                                                            .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                                                            .padding(4.5)
                                                                            .foregroundStyle(.white)
                                                                            .font(Font.custom(self.fontConfiguration.fontPicked, size: self.fontConfiguration.fontSizePicked))
                                                                            .multilineTextAlignment(.leading)
                                                                    }
                                                                    .frame(maxWidth: prop.size.width - 20, maxHeight: prop.size.height / 2 - 60)
                                                                }
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                .padding(4)
                                                                .background(Color.EZNotesBlack)
                                                                .cornerRadius(15)
                                                            }
                                                            .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2 - 60)
                                                            .padding([.top,.leading, .trailing], 20)
                                                            .padding(.bottom, 25)
                                                            .cornerRadius(15)
                                                            .onAppear {
                                                                self.moving = true
                                                                
                                                                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                                                                    if !self.moving {
                                                                        timer.invalidate() // Stop the timer when animation is off
                                                                    } else {
                                                                        targetX = CGFloat.random(in: -4...8) // Random X offset
                                                                        targetY = CGFloat.random(in: -4...8) // Random Y offset
                                                                    }
                                                                }
                                                                /*self.moving.toggle()
                                                                
                                                                self.animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                                                    self.moving.toggle()
                                                                }*/
                                                            }
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: (prop.size.height / 2) - 60)
                                                        .padding(.top, 20)
                                                        
                                                        VStack { }.frame(maxWidth: .infinity).padding([.top, .bottom]).background(.clear)
                                                        
                                                        HStack {
                                                            Button(action: {
                                                                self.notesContent = self.reWordedNotes
                                                                self.reWordedNotes.removeAll()
                                                            }) {
                                                                HStack {
                                                                    Text("Use re-written notes")
                                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                                        .foregroundStyle(.black)
                                                                        .setFontSizeAndWeight(weight: .bold, size: 15)
                                                                        .minimumScaleFactor(0.5)
                                                                }
                                                                .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                                                .padding([.top, .bottom], 4)
                                                                .background(.white)
                                                                .cornerRadius(15)
                                                            }
                                                            .buttonStyle(NoLongPressButtonStyle())
                                                            .cornerRadius(15)
                                                            
                                                            Button(action: {
                                                                self.reWordedNotes.removeAll()
                                                                self.moving = false
                                                            }) {
                                                                HStack {
                                                                    Text("Clear re-written notes")
                                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                                        .foregroundStyle(.black)
                                                                        .setFontSizeAndWeight(weight: .bold, size: 15)
                                                                        .minimumScaleFactor(0.5)
                                                                }
                                                                .frame(maxWidth: prop.size.width - 40, alignment: .trailing)
                                                                .padding([.top, .bottom], 4)
                                                                .background(Color.EZNotesRed)
                                                                .cornerRadius(15)
                                                            }
                                                            .buttonStyle(NoLongPressButtonStyle())
                                                            .cornerRadius(15)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 40)
                                                        
                                                        VStack { }
                                                            .frame(maxWidth: prop.size.width - 30, maxHeight: 0.5)
                                                            .padding([.top, .bottom], 0.4)
                                                            .background(.secondary)
                                                            .padding([.top, .bottom], 8)
                                                    }
                                                    
                                                    Button(action: {
                                                        self.rewritingNotes = true
                                                        
                                                        self.rewritingNotesAnimation = true
                                                        
                                                        self.animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                                            self.rewritingNotesAnimation.toggle()
                                                        }
                                                        
                                                        RequestAction<ReWordNotesData>(parameters: ReWordNotesData(
                                                            Notes: self.reWordedNotes == "" ? self.notesContent : self.reWordedNotes
                                                        ))
                                                        .perform(action: reword_notes_req) { statusCode, resp in
                                                            self.rewritingNotes = false
                                                            self.rewritingNotesAnimation = false
                                                            self.animationTimer = nil
                                                            
                                                            guard resp != nil && statusCode == 200 else {
                                                                return /* TODO: handle errors. */
                                                            }
                                                            
                                                            if resp!["Reworded"] as! String != "No Changes" {
                                                                self.reWordedNotes = resp!["Reworded"] as! String
                                                            }
                                                        }
                                                    }) {
                                                        HStack {
                                                            Image(systemName: "sparkles")
                                                                .foregroundStyle(self.EZNotesMG)
                                                            
                                                            Text(self.reWordedNotes != "" ? "Re-write again" : "Re-write for me")
                                                                .frame(alignment: .center)
                                                                .foregroundStyle(.white)
                                                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                                                .minimumScaleFactor(0.5)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                        .padding([.top, .bottom], 10)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .fill(.clear)
                                                                .strokeBorder(self.EZNotesMG)
                                                        )
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    .padding(.top, self.reWordedNotes != "" ? 0 : 15)
                                                    
                                                    Button(action: {
                                                        self.saveAlert = true
                                                        
                                                        /* MARK: Reset the "state" of the section. */
                                                        if self.noteSelected != "" { self.noteSelected.removeAll() }
                                                        
                                                        self.animationTimer = nil
                                                        self.rewritingNotesAnimation = false
                                                        self.reWordedNotes.removeAll()
                                                    }) {
                                                        HStack {
                                                            Text("Save Changes")
                                                                .frame(maxWidth: .infinity, alignment: .center)
                                                                .foregroundStyle(.black)
                                                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                                                .minimumScaleFactor(0.5)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .background(.white)
                                                        .cornerRadius(15)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    
                                                    Button(action: {
                                                        self.noteSelected = "original"
                                                    }) {
                                                        HStack {
                                                            Text("View Original")
                                                                .frame(maxWidth: .infinity, alignment: .center)
                                                                .foregroundStyle(.black)
                                                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                                                .minimumScaleFactor(0.5)
                                                        }
                                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .background(.white)
                                                        .cornerRadius(15)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    //.padding(.top, 15)
                                                    .padding(.bottom, 35)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        default:
                                            VStack { }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.aiGeneratedSummaryWidth = .infinity
                        }
                    }
                    .onDisappear {
                        self.aiGeneratedSummaryWidth = 0
                    }
                default:
                    EditableNotes(
                        prop: prop,
                        fontConfiguration: self.fontConfiguration,
                        /*fontPicked: self.fontPicked,
                        fontSizePicked: self.fontSizePicked,*/
                        categoryName: self.categoryName,
                        setName: self.setName,
                        notesContent: $notesContent,
                        categoryData: self.categoryData,//setAndNotes: $setAndNotes,
                        noteChatDetails: self.noteChatDetails//aiChatOverNotesIsLive: $aiChatOverNotesIsLive
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(self.noteChatDetails.aiChatOverNotesIsLive ? .init() : .bottom)
        //.ignoresSafeArea(edges: !self.aiChatOverNotesIsLive ? [.bottom] : .init())
        /*.onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                self.menuHeight = 60
            }
        }*/
        .background(Color.EZNotesBlack)
        .alert("Are you sure?", isPresented: $saveAlert) {
            Button(action: {
                /* MARK: Update the "original" notes with the content of the updated notes. */
                self.originalContent = self.notesContent
                
                /* MARK: Ensure that the content of the notes are updated accordingly. Then, write the changes to the appropriate cache file. */
                for (index, value) in self.categoryData.setAndNotes[self.categoryName]!.enumerated() {
                    /* TODO: We need to make it to where the initial value (`[:]`), which gets assigned when initiating the variable, gets deleted. */
                    if value != [:] {
                        for key in value.keys {
                            if key == self.setName {
                                /* MARK: Remove the data from the dictionary. */
                                self.categoryData.setAndNotes[self.categoryName]!.remove(at: index)
                                
                                /* MARK: Append the new dictionary with the update text. */
                                self.categoryData.setAndNotes[self.categoryName]!.append([key: self.notesContent])
                            }
                        }
                    }
                }
                
                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                
                /* MARK: Manually set the below variable to "No Changes", as once the user saves all changes are finalized. */
                self.aiGeneratedSummaryOfChanges = "No Changes"
            }) { Text("Yes") }
            
            Button("No", role: .cancel) { }
        } message: {
            Text("By continuing, your changes will be saved and you will not be able to undo them.")
        }
        .onAppear {
            guard
                let fontConfig = getFontConfiguration(),
                fontConfig != [:],
                fontConfig.keys.contains(self.setName)
            else {
                return
            }
            
            self.fontConfiguration.fontPicked = fontConfig[self.setName]!["Family"]!
            self.fontConfiguration.fontSizePicked = CGFloat(Double(fontConfig[self.setName]!["Size"]!)!)
            self.fontConfiguration.fontColor = Color(
                red: Double(fontConfig[self.setName]!["FontColorRed"]!)!,
                green: Double(fontConfig[self.setName]!["FontColorGreen"]!)!,
                blue: Double(fontConfig[self.setName]!["FontColorBlue"]!)!
            )
            self.fontConfiguration.fontAlignment = fontConfig[self.setName]!["Alignment"]! == "leading"
                ? .leading
                : fontConfig[self.setName]!["Alignment"]! == "center"
                    ? .center
                    : .trailing
            self.fontConfiguration.fontTextAlignment = fontConfig[self.setName]!["TextAlignment"]! == "leading"
                ? .leading
                : fontConfig[self.setName]!["TextAlignment"]! == "center"
                    ? .center
                    : .trailing
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
