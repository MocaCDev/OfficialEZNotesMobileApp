//
//  AIChatView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/26/24.
//
import SwiftUI

private enum aiChatError {
    case None
    case ErrorLoadingTopics
}

private struct mainView: View {
    @StateObject public var messageModel: MessagesModel
    
    var prop: Properties
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var aiChatSection: String
    @Binding public var generatedTopics: Array<String>
    @Binding public var error: aiChatError
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    //@Binding public var messages: Array<MessageDetails>
    @Binding public var topicPicked: String
    
    @State private var loadingTopics: Bool = false
    
    var body: some View {
        VStack {
            if self.loadingTopics {
                VStack {
                    Text("Loading Topics")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .setFontSizeAndWeight(weight: .medium, size: 20)
                        .minimumScaleFactor(0.5)
                    
                    ProgressView()
                        .tint(Color.EZNotesBlue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    Button(action: {
                        self.loadingTopics = true
                        
                        RequestAction<GetCustomTopicsData>(parameters: GetCustomTopicsData(Major: self.accountInfo.major))
                            .perform(action: get_custom_topics_req) { statusCode, resp in
                                self.loadingTopics = false
                                guard resp != nil && statusCode == 200 else {
                                    if let resp = resp { print(resp) }
                                    self.error = .ErrorLoadingTopics
                                    return
                                }
                                
                                self.generatedTopics = resp!["Topics"] as! [String]
                                
                                /* MARK: This will make `mainView` dissapear and make the view that shows all the generated topics show. This is controlled view `AIChat` view. */
                                self.aiChatSection = "select_topic"
                                /*let images = resp!["Images"] as! [String: Any]
                                 
                                 for (key, value) in images {
                                 self.generatedTopicsImages[key] = Data(base64Encoded: value as! String)
                                 }
                                 
                                 print(self.generatedTopics)*/
                            }
                    }) {
                        HStack {
                            Spacer()
                            
                            HStack {
                                ZStack {
                                    Image(systemName: "plus.message.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.EZNotesBlack)
                                }
                                .frame(maxWidth: 20, alignment: .center)
                                
                                Text("Create Chat")
                                    .frame(alignment: .center)
                                    .foregroundStyle(Color.EZNotesBlack)
                                    .font(.system(size: prop.isLargerScreen ? 20 : 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Spacer()
                        }
                        .frame(maxWidth: prop.size.width - 80)
                        .padding(10)
                        .background(Color.EZNotesBlue.opacity(0.7))
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                VStack {
                    Text("Chat History:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                        .foregroundStyle(.white)
                        .font(.system(size: prop.isLargerScreen ? 26 : 22, weight: .medium))
                    
                    if self.messageModel.tempStoredChats.count == 0 {
                        Text("No Chat History")
                            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .center)
                            .padding(.top)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-ExtraLight", size: 15))//.font(.system(size: 15, design: .rounded))
                            .minimumScaleFactor(0.5)
                            .fontWeight(.light)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(Array(self.messageModel.tempStoredChats.keys), id: \.self) { key in
                                        Button(action: {
                                            self.topicPicked = key
                                            
                                            for (key, value) in self.messageModel.tempStoredChats[key]! {
                                                self.accountInfo.setAIChatID(chatID: key)
                                                
                                                self.messageModel.messages = value
                                            }
                                            
                                            self.aiChatSection = "chat"
                                        }) {
                                            HStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(MeshGradient(width: 3, height: 3, points: [
                                                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                        ], colors: [
                                                            .indigo, .indigo, Color.EZNotesBlue,
                                                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                                        ]))
                                                        .blur(radius: 6)
                                                    
                                                    HStack {
                                                        VStack {
                                                            Text(key)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .foregroundStyle(.white)
                                                                .padding(.leading, 10)
                                                                .setFontSizeAndWeight(weight: .bold, size: 18, design: .rounded)
                                                                //.minimumScaleFactor(0.5)
                                                                .multilineTextAlignment(.leading)
                                                                .cornerRadius(8)
                                                        
                                                            if self.messageModel.tempStoredChats[key]!.keys.count != 0 {
                                                                Spacer()
                                                                
                                                                ForEach(Array(self.messageModel.tempStoredChats[key]!.keys), id: \.self) { chatID in
                                                                    if self.messageModel.tempStoredChats[key]![chatID]!.count > 0 {
                                                                        Text("Last Message On: \(self.messageModel.tempStoredChats[key]![chatID]![self.messageModel.tempStoredChats[key]![chatID]!.count - 1].dateSent.formatted(date: .numeric, time: .omitted))")
                                                                            /*.frame(maxWidth: .infinity, alignment: .leading)
                                                                            .padding([.top, .bottom], 5)
                                                                            .foregroundStyle(.white)
                                                                            .padding(.leading, 10)
                                                                            .setFontSizeAndWeight(weight: .light, size: 12)
                                                                            .minimumScaleFactor(0.5)
                                                                            .multilineTextAlignment(.leading)*/
                                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                                            .font(Font.custom("Poppins-ExtraLight", size: 12))
                                                                            .padding([.top, .bottom], 5)
                                                                            .foregroundStyle(.white)
                                                                            .padding(.leading, 10)
                                                                            .multilineTextAlignment(.leading)
                                                                    } else {
                                                                        Text("No Messages")
                                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                                            .font(Font.custom("Poppins-ExtraLight", size: 12))
                                                                            .padding([.top, .bottom], 5)
                                                                            .foregroundStyle(.white)
                                                                            .padding(.leading, 10)
                                                                            .multilineTextAlignment(.leading)
                                                                    }
                                                                }
                                                                
                                                                Spacer()
                                                            }
                                                            
                                                            HStack {
                                                                Button(action: {
                                                                    self.messageModel.tempStoredChats.removeValue(forKey: key)
                                                                }) {
                                                                    Image(systemName: "trash")
                                                                        .resizable()
                                                                        .frame(width: 14.5, height: 14.5)
                                                                        .foregroundStyle(.red)
                                                                        .padding([.trailing, .top, .bottom], 10)
                                                                    
                                                                    Text("Delete")
                                                                        .foregroundStyle(.white)
                                                                        .font(.system(size: 13))
                                                                        .fontWeight(.medium)
                                                                        .padding([.leading], -10)
                                                                }
                                                                .padding([.leading], 10)
                                                                
                                                                Button(action: { print("Share") }) {
                                                                    Image(systemName: "square.and.arrow.up")
                                                                        .resizable()
                                                                        .frame(width: 14.5, height: 19.5)
                                                                        .foregroundStyle(Color.EZNotesBlue)
                                                                        .padding([.trailing, .bottom], 10)
                                                                        .padding([.top], 5)
                                                                    
                                                                    Text("Share")
                                                                        .foregroundStyle(.white)
                                                                        .font(.system(size: 13))
                                                                        .fontWeight(.medium)
                                                                        .padding([.leading], -10)
                                                                }
                                                                .padding(.leading, 10)
                                                            }
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                    }
                                                    .frame(maxHeight: .infinity)//.frame(maxWidth: prop.size.width - 80)
                                                    .padding([.leading, .trailing], 8)
                                                    .padding([.top, .bottom], 12)
                                                    .background(.black)
                                                    .cornerRadius(15)
                                                }
                                                .frame(maxHeight: .infinity)//.frame(maxWidth: prop.size.width - 75)
                                                .padding(2.5)
                                            }
                                            .frame(minHeight: 160, maxHeight: 360)//.frame(height: 160)//.frame(maxWidth: .infinity)
                                            //.padding(.bottom, 10)
                                        }
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AIChat: View {
    @EnvironmentObject private var messageModel: MessagesModel
    
    var prop: Properties
    @ObservedObject public var accountInfo: AccountDetails
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    //@Binding public var messages: Array<MessageDetails>
    
    @State private var aiChatSection: String = "main"
    @State private var error: aiChatError = .None
    
    /* MARK: "States" for loading topics (when "Create Chat" button is tapped). */
    @State private var errorGeneratingTopicsForMajor: Bool = false
    @State private var generatedTopics: Array<String> = []
    @State private var topicPicked: String = ""
    @State private var messageBoxTapped: Bool = false
    @State private var aiIsTyping: Bool = false
    @State private var hideLeftsideContent: Bool = false
    @State private var messageInput: String = ""
    @State private var currentYPosOfMessageBox: CGFloat = 0
    
    @State private var numberOfTheAnimationgBall = 3
    let ballSize: CGFloat = 10
    let speed: Double = 0.3
    let chatUUID: UUID = UUID()
    
    @State private var keyboardHeight: CGFloat = 0
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height - 20
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
    
    private func textHeight(for text: String, width: CGFloat) -> CGFloat {
        /*let font = UIFont.systemFont(ofSize: 17)  // Customize this to match your font
         let constrainedSize = CGSize(width: width - 20, height: .infinity)  // Add padding to the width
         let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return boundingRect.height*/
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        let fixedWidth = width - 16 // Account for padding
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return max(size.height, 100) // Add a buffer and ensure a minimum height
    }
    
    var body: some View {
        VStack {
            HStack {
                if self.aiChatSection != "main" {
                    Button(action: {
                        if self.aiChatSection == "chat" {
                            /* MARK: Save the chat history before going back to the "main" section. */
                            self.messageModel.tempStoredChats[self.topicPicked] = [self.accountInfo.aiChatID: self.messageModel.messages]
                            writeTemporaryChatHistory(chatHistory: self.messageModel.tempStoredChats)
                            
                            self.messageModel.messages.removeAll()
                        }
                        
                        self.aiChatSection = "main"
                    }) {
                        ZStack {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 20, alignment: .leading)
                        .padding(.leading, 25)
                    }
                } else { ZStack { }.frame(maxWidth: 20, alignment: .leading).padding(.leading, 25) }
                
                /* TODO: Format the code to look better and perhaps add better code to determine the height of the text? */
                Text(self.aiChatSection == "main"
                     ? "EZNotes AI Chat"
                     : self.aiChatSection == "select_topic"
                        ? "Select Topic"
                        : self.aiChatSection == "chat"
                             ? self.topicPicked
                             :"EZNotes AI Chat")
                .frame(maxWidth: .infinity, minHeight: 20, maxHeight: textHeight(for: self.aiChatSection == "main"
                                                                  ? "EZNotes AI Chat"
                                                                  : self.aiChatSection == "select_topic"
                                                                     ? "Select Topic"
                                                                     : self.aiChatSection == "chat"
                                                                          ? self.topicPicked
                                                                          :"EZNotes AI Chat", width: UIScreen.main.bounds.width), alignment: .center)
                .foregroundStyle(.white)
                .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 24))
                .multilineTextAlignment(.center)
                
                ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
            }
            .frame(maxWidth: .infinity, minHeight: 20, maxHeight: textHeight(for: self.aiChatSection == "main"
                                                              ? "EZNotes AI Chat"
                                                              : self.aiChatSection == "select_topic"
                                                                 ? "Select Topic"
                                                                 : self.aiChatSection == "chat"
                                                                      ? self.topicPicked
                                                                      :"EZNotes AI Chat", width: UIScreen.main.bounds.width), alignment: .center)
            .padding(.top, 10)
            .background(
                self.aiChatSection != "chat"
                ? AnyView(Image("AIChatBg2")
                    .resizable()
                    .scaledToFill()
                    .overlay(.black.opacity(0.4)))
                : AnyView(Color.clear)
            )
            
            if self.error == .None {
                switch(self.aiChatSection) {
                case "main":
                    mainView(
                        messageModel: self.messageModel,
                        prop: self.prop,
                        accountInfo: self.accountInfo,
                        aiChatSection: $aiChatSection,
                        generatedTopics: $generatedTopics,
                        error: $error,
                        topicPicked: $topicPicked
                    )
                case "select_topic":
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                ForEach(self.generatedTopics, id: \.self) { topic in
                                    Button(action: {
                                        self.topicPicked = topic
                                        
                                        var topicNumber = 0
                                        
                                        for (t, _) in self.messageModel.tempStoredChats {
                                            if t.contains(self.topicPicked) { topicNumber += 1 }
                                        }
                                        
                                        if topicNumber > 0 {
                                            self.topicPicked = "\(self.topicPicked) \(topicNumber)"
                                        }
                                        
                                        RequestAction<StartAIChatData>(
                                            parameters: StartAIChatData(
                                                AccountId: self.accountInfo.accountID,
                                                Major: self.accountInfo.major,
                                                Topic: topic
                                            )
                                        )
                                        .perform(action: start_ai_chat_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                /* self.aiChatStartError = true*/
                                                return
                                            }
                                            
                                            //print(UUID(uuidString: resp!["ChatID"]! as! String)!)
                                            self.accountInfo.setAIChatID(chatID: UUID(uuidString: resp!["ChatID"]! as! String)!)
                                            //self.aiChatPopover = true
                                            self.messageModel.tempStoredChats[self.topicPicked] = [UUID(uuidString: resp!["ChatID"]! as! String)!: []]
                                            
                                            self.aiChatSection = "chat"
                                        }
                                    }) {
                                        HStack {
                                            Text("\(topic)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 10)
                                                .setFontSizeAndWeight(weight: .medium, size: prop.isLargerScreen ? 18 : 15)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.leading)
                                                .cornerRadius(8)
                                                .foregroundColor(.white)
                                            
                                            ZStack {
                                                Image(systemName: "chevron.right")
                                                    .resizableImage(width: 10, height: 15)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(maxWidth: 15, alignment: .trailing)
                                            .padding(.trailing, 25)
                                        }
                                        .frame(maxWidth: prop.size.width - 80)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                                .shadow(color: Color.black, radius: 2.5)
                                        )
                                    }
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 10)
                case "chat":
                    VStack {
                        ZStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack {
                                        ForEach(self.messageModel.messages, id: \.self) { message in
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
                                                Timer.scheduledTimer(withTimeInterval: self.speed, repeats: true) { timer in
                                                    if !self.aiIsTyping {
                                                        timer.invalidate()
                                                        return
                                                    }
                                                    
                                                    var randomNumb: Int
                                                    repeat {
                                                        randomNumb = Int.random(in: 0...2)
                                                    } while randomNumb == self.numberOfTheAnimationgBall
                                                    self.numberOfTheAnimationgBall = randomNumb
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: self.messageModel.messages) {
                                        withAnimation {
                                            proxy.scrollTo(self.messageModel.messages.last)
                                        }
                                    }
                                    /*.onChange(of: self.aiIsTyping) {
                                        //if self.aiIsTyping {
                                        //    proxy.scrollTo(self.chatUUID)
                                        //}
                                    }*/
                                    .onChange(of: self.messageBoxTapped) {
                                        withAnimation {
                                            proxy.scrollTo(self.messageModel.messages.last)
                                        }
                                    }
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(self.messageModel.messages.last, anchor: .bottom)
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
                        .padding(.top, -7)
                        
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
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.leading, 10)
                                
                                VStack {
                                    Button(action: { print("Take live picture to get instant feedback") }) {
                                        Image(systemName: "camera")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                
                                VStack {
                                    Button(action: { print("Select category to talk to the AI chat about") }) {
                                        Image("Categories-Icon")
                                            .resizableImage(width: 15, height: 15)
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.trailing, 5)
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
                                    .padding([.top, .bottom], 10)
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
                                        
                                        self.messageModel.messages.append(MessageDetails(
                                            MessageID: UUID(),
                                            MessageContent: self.messageInput,
                                            userSent: true,
                                            dateSent: Date.now
                                        ))
                                        
                                        RequestAction<SendAIChatMessageData>(
                                            parameters: SendAIChatMessageData(
                                                ChatID: self.accountInfo.aiChatID,
                                                AccountId: self.accountInfo.accountID,
                                                Message: self.messageInput
                                            )
                                        ).perform(action: send_ai_chat_message_req) { statusCode, resp in
                                            self.aiIsTyping = false
                                            
                                            guard resp != nil && statusCode == 200 else {
                                                return
                                            }
                                            
                                            self.messageModel.messages.append(MessageDetails(
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
                                            .foregroundStyle(.white)/*(
                                                                     MeshGradient(width: 3, height: 3, points: [
                                                                     .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                                     .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                                     .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                                     ], colors: [
                                                                     Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                                     Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                                     Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                                     /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                                      Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                                      Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                                     ])
                                                                     )*/
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    //.padding(.top, 5)
                                }
                                .frame(minWidth: 10, alignment: .leading)
                                .padding(12.5)
                                .background(Color.EZNotesLightBlack.opacity(0.65))
                                .clipShape(.circle)
                                .padding(.trailing, 10)
                                .padding(.leading, 5)
                            }
                        }
                        .padding(.bottom, self.keyboardHeight == 0 ? 0 : self.keyboardHeight)
                        .animation(.easeOut(duration: 0.3), value: keyboardHeight)
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Image("AIChatBg3")
                            .resizable()
                            .scaledToFill()
                    )
                    .onAppear {
                        // Detect keyboard notifications when the view appears
                        addKeyboardObservers()
                    }
                    .onDisappear {
                        // Remove keyboard observers when the view disappears
                        removeKeyboardObservers()
                    }
                default:
                    mainView(
                        messageModel: self.messageModel,
                        prop: self.prop,
                        accountInfo: self.accountInfo,
                        aiChatSection: $aiChatSection,
                        generatedTopics: $generatedTopics,
                        error: $error,
                        topicPicked: $topicPicked
                    )
                }
            } else {
                /* MARK: Error handling. Provides views to display error messages to the user when something went wrong. */
                switch(self.error) {
                case .ErrorLoadingTopics:
                    VStack {
                        ErrorMessage(prop: self.prop, placement: .center, message: "Error loading topics")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    VStack { }.onAppear { self.error = .None; self.aiChatSection = "main" }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .edgesIgnoringSafeArea([.bottom])
        .onDisappear {
            /* TODO: I don't know if this is needed, but just in case. */
            self.aiChatSection = "main"
        }
    }
}
