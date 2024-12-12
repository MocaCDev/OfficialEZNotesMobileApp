//
//  TopNavView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import PhotosUI
import Combine
import WebKit

struct ProfileIconView: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.EZNotesBlue)
                
            Button(action: { self.showAccountPopup = true }) {
                /*Image(systemName: "person.crop.circle.fill")*/
                self.accountInfo.profilePicture
                    .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                    .scaledToFill()
                    .frame(maxWidth: 35, maxHeight: 35)
                    .clipShape(.circle)
                    
                    .foregroundStyle(.white)
            }
            .buttonStyle(NoLongPressButtonStyle())
        }
        .frame(width: 38, height: 38)
        .padding([.leading], 20)
    }
}

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TopNavHome: View {
    @EnvironmentObject private var messageModel: MessagesModel
    
    @ObservedObject public var accountInfo: AccountDetails
    @ObservedObject public var categoryData: CategoryData
    
    @Binding public var showAccountPopup: Bool
    @State private var aiChatPopover: Bool = false
    
    var prop: Properties
    var backgroundColor: Color
    //var categoriesAndSets: [String: Array<String>]
    
    @Binding public var changeNavbarColor: Bool
    @Binding public var navbarOpacity: Double
    @Binding public var categorySearch: String
    @Binding public var searchDone: Bool
    
    @State private var deleteAllMessagesConfirmAlert: Bool = false
    @State private var showSearchBar: Bool = false
    @FocusState private var categorySearchFocus: Bool
    /*@State private var userSentMessages: Array<String> = []//["Hi!", "What is 2+2?", "Yes"]
    @State private var systemResponses: Array<String> = []*///["Hello, how can I help you?", "2+2 is 4, would you like to know more?"]
    //@State private var messages: [String: String] = [:] /* MARK: Key is the user sent message, value is the AI response. */
    @State private var systemResponses: [String: String] = [:] /* MARK: Key will be the user sent message, value will be the AI response */
    @State private var waitingToSend: Array<String> = []
    @State private var processingMessage: Bool = false
    @State private var messageInput: String = ""
    @State private var hideLeftsideContent: Bool = false
    @State private var aiIsTyping: Bool = false
    @State private var messageBoxTapped: Bool = false
    @State private var currentYPosOfMessageBox: CGFloat = 0
    @State private var chatIsLive: Bool = false
    @State private var creatingNewChat: Bool = false
    @State private var errorGeneratingTopicsForMajor: Bool = false
    
    //@Binding public var messages: Array<MessageDetails>
    @Binding public var lookedUpCategoriesAndSets: [String: Array<String>]
    @Binding public var userHasSignedIn: Bool
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    
    @State private var numberOfTheAnimationgBall = 3
    
    // MAKR: - Drawing Constants
    let ballSize: CGFloat = 10
    let speed: Double = 0.3
    let chatUUID: UUID = UUID()
    
    let topicsColumns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    @State private var loadingTopics: Bool = false
    @State private var generatedTopics: Array<String> = []
    @State private var generatedTopicsImages: [String: Data] = [:]
    @State private var topicPicked: String = ""
    
    var body: some View {
        HStack {
            HStack {
                VStack {
                    ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
                }
                .frame(alignment: .leading)
                .padding(.bottom, 20)//.padding(.top, prop.size.height / 2.5 > 300 ? 50 : 15) /* MARK: Aligns icon for larger screens. */
                //.padding(.bottom, prop.size.height / 2.5 > 300 ? 0 : 10) /* MARK: Aligns icon for smaller screens. */
                //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
                
                if self.showSearchBar {
                    VStack {
                        TextField(
                            prop.size.height / 2.5 > 300 ? "Search Categories..." : "Search...",
                            text: $categorySearch
                        )
                        .frame(
                            maxWidth: .infinity,/*prop.isIpad
                                                 ? UIDevice.current.orientation.isLandscape
                                                 ? prop.size.width - 800
                                                 : prop.size.width - 450
                                                 : 150,*/
                            maxHeight: prop.isLargerScreen ? 20 : 15
                        )
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(7.5)
                        .padding(.horizontal, 10)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 15)
                                
                                //if self.categorySearchFocus || self.categorySearch != "" {
                                    Button(action: {
                                        self.categorySearch = ""
                                        self.lookedUpCategoriesAndSets.removeAll()
                                        self.searchDone = false
                                        self.showSearchBar = false
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 15)
                                    }
                                //}
                            }
                        )
                        .onSubmit {
                            if !(self.categorySearch == "") {
                                self.lookedUpCategoriesAndSets.removeAll()
                                
                                for (_, value) in self.categoryData.categoriesAndSets.keys.enumerated() {
                                    if value.lowercased() == self.categorySearch.lowercased() || value.lowercased().contains(self.categorySearch.lowercased()) {
                                        self.lookedUpCategoriesAndSets[value] = self.categoryData.categoriesAndSets[value]
                                        
                                        print(self.lookedUpCategoriesAndSets)
                                    }
                                }
                                
                                self.searchDone = true
                            } else {
                                self.lookedUpCategoriesAndSets.removeAll()
                                self.searchDone = false
                            }
                            
                            self.categorySearchFocus = false
                        }
                        .focused($categorySearchFocus)
                        .onChange(of: categorySearchFocus) {
                            if !self.categorySearchFocus && self.categorySearch == "" { self.showSearchBar = false }
                        }
                        .onTapGesture {
                            self.categorySearchFocus = true
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, prop.isLargerScreen ? 20 : 15)
                    .padding(.trailing, 10)
                    .padding(.leading, -10)
                    //.padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)//.padding(.top, 10)
                }
            }
            .frame(maxWidth: self.showSearchBar ? .infinity : 90, alignment: .leading)
            
            if !self.showSearchBar {
                Spacer()
            }
    
            if self.changeNavbarColor {
                VStack {
                    Text("View Categories")
                        .foregroundStyle(.primary)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text("Total: \(self.categoryData.categoriesAndSets.count)")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, design: .rounded))
                        .fontWeight(.thin)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, prop.isLargerScreen ? 20 : 15)
                //.padding(.top, prop.size.height / 2.5 > 300 ? 45 : 15)
            }
            
            Spacer()
            
            HStack {
                ZStack {
                    Button(action: {
                        if self.categoryData.categoriesAndSets.count > 0 {
                            if self.showSearchBar { self.showSearchBar = false; return }
                            self.showSearchBar = true
                        }
                    }) {
                        Image("SearchIcon")//(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.EZNotesOrange)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(width: 30, height: 30)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                
                ZStack {
                    Button(action: { self.aiChatPopover = true }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                                height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                            )
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(
                    width: 30,//prop.size.height / 2.5 > 300 ? 45 : 40,
                    height: 30//prop.size.height / 2.5 > 300 ? 45 : 40
                )
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                .padding([.trailing], 20)
            }
            .frame(maxWidth: 90, maxHeight: .infinity, alignment: .trailing)
            //.padding(.top, prop.size.height / 2.5 > 300 ? 40 : 0)
            .padding(.bottom, prop.isLargerScreen ? 20 : 15)
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
        .background(
            !self.changeNavbarColor
                ? AnyView(Color.clear)
                : AnyView(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).opacity(navbarOpacity))
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .zIndex(1) /* MARK: The navbar will always exist on top of content. This enables content under the navbar to scroll "under" it. */
        .onTapGesture {
            if self.showSearchBar { self.showSearchBar = false }
        }
        .onChange(of: self.aiChatPopover) {
            if !self.aiChatPopover {
                
                /* MARK: Don't do anything if there was no topic picked. */
                if self.topicPicked == "" {
                    /* MARK: Remove generated topics if none were picked (that way when the popover is initiated again, the user has to click "New Chat". */
                    self.generatedTopics.removeAll()
                    return
                }
                
                self.messageModel.tempStoredChats[self.topicPicked] = [self.accountInfo.aiChatID: self.messageModel.messages]
                writeTemporaryChatHistory(chatHistory: self.messageModel.tempStoredChats)
                
                self.topicPicked = ""
                self.generatedTopics.removeAll()
                self.chatIsLive = false
                self.messageModel.messages.removeAll()
            }
        }
        /* TODO: Change from popover to an actual view. */
        .popover(isPresented: $aiChatPopover) {
            AIChat(
                prop: self.prop,
                accountInfo: self.accountInfo
            )
            /*VStack {
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
                    .frame(maxWidth: prop.size.width - 100, maxHeight: .infinity, alignment: .center)
                    .padding()
                } else {
                    HStack {
                        if self.topicPicked != "" || self.chatIsLive {
                            Button(action: {
                                /* MARK: First, save the message history. */
                                self.tempChatHistory[self.topicPicked] = [self.accountInfo.aiChatID: self.messages]
                                writeTemporaryChatHistory(chatHistory: self.tempChatHistory)
                                
                                self.chatIsLive = false
                                
                                self.topicPicked = ""
                                self.generatedTopics.removeAll()
                                self.chatIsLive = false
                                self.messages.removeAll()
                            }) {
                                ZStack {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.EZNotesBlue)
                                }
                                .frame(maxWidth: 30, alignment: .leading)
                            }
                        }
                        
                        Text(self.topicPicked == ""
                             ? self.chatIsLive
                                ? "Unknown Topic"
                                : self.generatedTopics.count == 0
                                    ? "EZNotes AI Chat"
                                    : "Select Topic"
                             : self.topicPicked)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                            .font(.system(size: prop.size.height / 2.5 > 300 ? 30 : 26, design: .rounded))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.5)
                        
                        if self.topicPicked != "" || self.chatIsLive { ZStack{ }.frame(maxWidth: 30, alignment: .trailing) }
                    }
                    .frame(maxWidth: prop.size.width - 40, maxHeight: 50, alignment: .top)
                    .border(width: 0.5, edges: [.bottom], color: .gray)
                    
                    if !self.chatIsLive {
                        if !self.errorGeneratingTopicsForMajor {
                            HStack {
                                Button(action: {
                                    self.loadingTopics = true
                                    
                                    RequestAction<GetCustomTopicsData>(parameters: GetCustomTopicsData(Major: self.accountInfo.major))
                                        .perform(action: get_custom_topics_req) { statusCode, resp in
                                            self.loadingTopics = false
                                            guard resp != nil && statusCode == 200 else {
                                                if let resp = resp { print(resp) }
                                                self.errorGeneratingTopicsForMajor = true
                                                return
                                            }
                                            
                                            self.generatedTopics = resp!["Topics"] as! [String]
                                            /*let images = resp!["Images"] as! [String: Any]
                                            
                                            for (key, value) in images {
                                                self.generatedTopicsImages[key] = Data(base64Encoded: value as! String)
                                            }
                                            
                                            print(self.generatedTopics)*/
                                        }
                                }) {
                                    HStack {
                                        Text("New Chat")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.black)
                                            .font(.system(size: 20))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.medium)
                                    }
                                    .padding([.top, .bottom], 4)
                                    .padding([.leading, .trailing], 8)
                                    .background(Color.white.shadow(color: .black, radius: 2.5))
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding([.top, .bottom])
                                
                                Button(action: {
                                    self.deleteAllMessagesConfirmAlert = true
                                }) {
                                    HStack {
                                        Text("Delete All")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.medium)
                                    }
                                    .padding([.top, .bottom], 4)
                                    .padding([.leading, .trailing], 8)
                                    .background(Color.EZNotesRed.shadow(color: .black, radius: 2.5))
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding([.top, .bottom])
                                .alert("Are You Sure?", isPresented: $deleteAllMessagesConfirmAlert) {
                                    Button(action: {
                                        self.tempChatHistory.removeAll()
                                        writeTemporaryChatHistory(chatHistory: self.tempChatHistory)
                                    }) {
                                        Text("Yes")
                                    }
                                    
                                    Button("No", role: .cancel) { }
                                } message: {
                                    Text("By clicking Yes, you will effectively delete all of your \(self.tempChatHistory.count) chats.")
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        }
                    }
                    
                    if self.chatIsLive {
                        ZStack {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack {
                                        ForEach(messages, id: \.self) { message in
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
                                    .onChange(of: messages) {
                                        withAnimation {
                                            proxy.scrollTo(messages.last)
                                        }
                                    }
                                    /*.onChange(of: self.aiIsTyping) {
                                        //if self.aiIsTyping {
                                        //    proxy.scrollTo(self.chatUUID)
                                        //}
                                    }*/
                                    .onChange(of: self.messageBoxTapped) {
                                        withAnimation {
                                            proxy.scrollTo(messages.last)
                                        }
                                    }
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(messages.last, anchor: .bottom)
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
                                        
                                        self.messages.append(MessageDetails(
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
                                            
                                            self.messages.append(MessageDetails(
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
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 5)
                    } else {
                        if self.generatedTopics.count == 0 {
                            if !self.errorGeneratingTopicsForMajor {
                                VStack {
                                    Text("Chat History:")
                                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: 25))//.font(.system(size: 25))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.bold)
                                    
                                    if self.tempChatHistory == [:] {
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
                                                ForEach(Array(self.tempChatHistory.keys), id: \.self) { key in
                                                    Button(action: {
                                                        self.topicPicked = key
                                                        
                                                        for (key, value) in self.tempChatHistory[key]! {
                                                            self.accountInfo.setAIChatID(chatID: key)
                                                            
                                                            self.messages = value
                                                        }
                                                        
                                                        self.chatIsLive = true
                                                        
                                                        /*RequestAction<StartAIChatData>(
                                                            parameters: StartAIChatData(
                                                                AccountId: self.accountInfo.accountID,
                                                                Major: self.accountInfo.major,
                                                                Topic: key
                                                            )
                                                        )
                                                        .perform(action: start_ai_chat_req) { statusCode, resp in
                                                            guard resp != nil && statusCode == 200 else {
                                                                /* self.aiChatStartError = true*/
                                                                return
                                                            }
                                                            
                                                            //self.accountInfo.setAIChatID(chatID: resp!["ChatID"]! as! String)
                                                            //self.aiChatPopover = true
                                                            self.chatIsLive = true
                                                            //self.messages = self.tempChatHistory[key]!
                                                        }*/
                                                    }) {
                                                        HStack {
                                                            HStack {
                                                                VStack {
                                                                    Text(key)
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .foregroundStyle(.white)
                                                                        .padding(.leading, 10)
                                                                        .setFontSizeAndWeight(weight: .bold, size: 18, design: .rounded)
                                                                        .minimumScaleFactor(0.5)
                                                                        .multilineTextAlignment(.leading)
                                                                        .cornerRadius(8)
                                                                    
                                                                    if self.tempChatHistory[key]!.keys.count != 0 {
                                                                        ForEach(Array(self.tempChatHistory[key]!.keys), id: \.self) { chatID in
                                                                            if self.tempChatHistory[key]![chatID]!.count > 0 {
                                                                                Text("Last Message On: \(self.tempChatHistory[key]![chatID]![self.tempChatHistory[key]![chatID]!.count - 1].dateSent.formatted(date: .numeric, time: .omitted))")
                                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                                    .padding([.top, .bottom], 5)
                                                                                    .foregroundStyle(.white)
                                                                                    .padding(.leading, 10)
                                                                                    .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                    .minimumScaleFactor(0.5)
                                                                                    .multilineTextAlignment(.leading)
                                                                            } else {
                                                                                Text("No Messages")
                                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                                                    .padding([.top, .bottom], 5)
                                                                                    .foregroundStyle(.white)
                                                                                    .padding(.leading, 10)
                                                                                    .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                    .minimumScaleFactor(0.5)
                                                                                    .multilineTextAlignment(.leading)
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    //ForEach(self.tempChatHistory[key!]!.keys, id: \.self) { key2 in
                                                                        /*if self.tempChatHistory[key!]![key2].count > 0 {
                                                                            Text("Last Message On: \(self.tempChatHistory[key!]![key2]![self.tempChatHistory[key!]![key2]!.count - 1].dateSent.formatted(date: .numeric, time: .omitted))")
                                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                                .padding([.top, .bottom], 5)
                                                                                .foregroundStyle(.white)
                                                                                .padding(.leading, 10)
                                                                                .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                .minimumScaleFactor(0.5)
                                                                                .multilineTextAlignment(.leading)
                                                                        } else {
                                                                            Text("No Messages")
                                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                                .padding([.top, .bottom], 5)
                                                                                .foregroundStyle(.white)
                                                                                .padding(.leading, 10)
                                                                                .setFontSizeAndWeight(weight: .light, size: 12)
                                                                                .minimumScaleFactor(0.5)
                                                                                .multilineTextAlignment(.leading)
                                                                        }*/
                                                                        //Text(key2)
                                                                    //}
                                                                    
                                                                    HStack {
                                                                        Button(action: {
                                                                            self.tempChatHistory.removeValue(forKey: key)
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
                                                                
                                                                ZStack {
                                                                    Image(systemName: "chevron.right")
                                                                        .resizableImage(width: 10, height: 15)
                                                                        .foregroundStyle(Color.EZNotesBlue)
                                                                }
                                                                .frame(maxWidth: 15, alignment: .trailing)
                                                                .padding(.trailing, 25)
                                                            }
                                                            .frame(maxWidth: prop.size.width - 80)
                                                            .padding(12)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .fill(Color.EZNotesLightBlack.opacity(0.3))
                                                                    .shadow(color: Color.black, radius: 2.5)
                                                            )
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                    }
                                                }
                                            }
                                            .padding(.top, 10)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            } else {
                                VStack {
                                    Image(systemName: "exclamationmark.warninglight.fill")
                                        .resizable()
                                        .frame(width: 65, height: 60)
                                        .padding([.top, .bottom], 15)
                                        .foregroundStyle(Color.EZNotesRed)
                                    
                                    Text("Error generating topics for \(self.accountInfo.major)")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 25, design: .rounded))
                                        .minimumScaleFactor(0.5)
                                        .fontWeight(.medium)
                                    
                                    Button(action: {
                                        self.errorGeneratingTopicsForMajor = false
                                        
                                        /* MARK: Precautionary measure. */
                                        if self.chatIsLive { self.chatIsLive = false }
                                    }) {
                                        Text("Go Back")
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 90,
                                                height: 10
                                            )
                                            .padding([.top, .bottom])
                                            .font(.system(size: 25, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack)
                                    )
                                }
                                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .top)
                            }
                        } else {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    ForEach(self.generatedTopics, id: \.self) { topic in
                                        Button(action: {
                                            self.topicPicked = topic
                                            var topicNumber = 0
                                            
                                            for (topic, _) in self.tempChatHistory {
                                                if topic.contains(self.topicPicked) { topicNumber += 1 }
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
                                                self.tempChatHistory[topic] = [UUID(uuidString: resp!["ChatID"]! as! String)!: []]
                                                self.chatIsLive = true
                                            }
                                        }) {
                                            HStack {
                                                Text("\(topic)")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.leading, 10)
                                                    .setFontSizeAndWeight(weight: .bold, size: 22, design: .rounded)
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
                                            .frame(maxWidth: prop.size.width - 40)
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.EZNotesLightBlack)
                                                    .shadow(color: Color.black, radius: 2.5)
                                            )
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    
                                    Button(action: {
                                        self.topicPicked = "Other"
                                        
                                        RequestAction<StartAIChatData>(
                                            parameters: StartAIChatData(
                                                AccountId: self.accountInfo.accountID,
                                                Major: self.accountInfo.major,
                                                Topic: "Other"
                                            )
                                        )
                                        .perform(action: start_ai_chat_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                /* self.aiChatStartError = true*/
                                                return
                                            }
                                            
                                            //self.accountInfo.setAIChatID(chatID: resp!["ChatID"]! as! String)
                                            //self.aiChatPopover = true
                                            self.chatIsLive = true
                                        }
                                    }) {
                                        HStack {
                                            Text("Other Topic")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 10)
                                                .setFontSizeAndWeight(weight: .bold, size: 22, design: .rounded)
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
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack)
                                                .shadow(color: Color.black, radius: 2.5)
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: prop.size.width - 60, maxHeight: .infinity)
                            .padding(.top, 15)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.EZNotesLightBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesBlack,
                            Color.EZNotesBlack
                        ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                //guard self.tempChatHistory.count > 0 && self.tempChatHistory[self.tempChatHistory.count - 1].dateSent != nil else { return }
                /*for(chatTitle, value) in self.tempChatHistory {
                    
                    /*RequestAction<SaveChatHistoryData>(parameters: SaveChatHistoryData(
                        AccountID: self.accountInfo.accountID, ChatTitle: chatTitle, ChatHistory: []
                    ))
                    .perform(action: save_chat_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            return
                        }
                        
                        print(resp!)
                    }*/
                    /* MARK: If the most recent message date is not the current date, save it to the server. */
                    if value[value.count - 1].dateSent.formatted(date: .numeric, time: .omitted) != Date.now.formatted(date: .numeric, time: .omitted) {
                    }
                }*/
                //guard self.tempChatHistory != [:] && self.tempChatHistory.
                
                /*if self.tempChatHistory.last!.dateSent != Date.now {
                    /* TODO: Request to save message history. */
                    /* TODO: Remove messages. */
                    /* TODO: Add support for showing chat history. */
                } else {
                    print("NAH")
                }*/
            }*/
        }
        /*VStack {
            HStack {
                VStack {
                    ProfileIconView(prop: prop, showAccountPopup: $showAccountPopup)
                }
                .frame(maxWidth: 50, alignment: .leading)
                .padding([.top], 50)
                .popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo) }
                
                Spacer()
                
                /* TODO: Change the below `Text` to a search bar (`TextField`) where user can search for specific categories.
                 * */
                if self.showSearchBar {
                    VStack {
                        TextField(
                            "Search Categories...",
                            text: $categorySearch
                        )
                        .frame(
                            maxWidth: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                            ? prop.size.width - 800
                            : prop.size.width - 450
                            : 150,
                            maxHeight: prop.size.height / 2.5 > 300 ? 20 : 20
                        )
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(7.5)
                        .padding(.horizontal, 10)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 15)
                                
                                if self.categorySearchFocus || self.categorySearch != "" {
                                    Button(action: {
                                        self.categorySearch = ""
                                        self.lookedUpCategoriesAndSets.removeAll()
                                        self.searchDone = false
                                        self.showSearchBar = false
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 15)
                                    }
                                }
                            }
                        )
                        .onSubmit {
                            if !(self.categorySearch == "") {
                                self.lookedUpCategoriesAndSets.removeAll()
                                
                                for (_, value) in self.categoriesAndSets.keys.enumerated() {
                                    if value.lowercased() == self.categorySearch.lowercased() || value.lowercased().contains(self.categorySearch.lowercased()) {
                                        self.lookedUpCategoriesAndSets[value] = self.categoriesAndSets[value]
                                        
                                        print(self.lookedUpCategoriesAndSets)
                                    }
                                }
                                
                                self.searchDone = true
                            } else {
                                self.lookedUpCategoriesAndSets.removeAll()
                                self.searchDone = false
                            }
                            
                            self.categorySearchFocus = false
                        }
                        .focused($categorySearchFocus)
                        .onChange(of: categorySearchFocus) {
                            if !self.categorySearchFocus && self.categorySearch == "" { self.showSearchBar = false }
                        }
                        .onTapGesture {
                            self.categorySearchFocus = true
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top], prop.size.height > 340 ? 55 : 45)
                } else {
                    if self.changeNavbarColor {
                        VStack {
                            Text("View Categories")
                                .foregroundStyle(.primary)
                                .font(.system(size: 18, design: .rounded))
                                .fontWeight(.semibold)
                            
                            Text("Total: \(self.categoriesAndSets.count)")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.thin)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, prop.size.height > 340 ? 55 : 50)
                    }
                }
                /*} else {
                    if self.categoriesAndSets.count > 0 {
                        VStack {
                            TextField(
                                "Search Categories...",
                                text: $categorySearch
                            )
                            .frame(
                                maxWidth: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                                : 200,
                                maxHeight: prop.size.height / 2.5 > 300 ? 30 : 20
                            )
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                            .cornerRadius(7.5)
                            .padding(.horizontal, 10)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 15)
                                    
                                    if self.categorySearchFocus {
                                        Button(action: {
                                            self.categorySearch = ""
                                            self.lookedUpCategoriesAndSets.removeAll()
                                            self.searchDone = false
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 15)
                                        }
                                    }
                                }
                            )
                            .onSubmit {
                                if !(self.categorySearch == "") {
                                    self.lookedUpCategoriesAndSets.removeAll()
                                    
                                    for (_, value) in self.categoriesAndSets.keys.enumerated() {
                                        if value.lowercased() == self.categorySearch.lowercased() || value.lowercased().contains(self.categorySearch.lowercased()) {
                                            self.lookedUpCategoriesAndSets[value] = self.categoriesAndSets[value]
                                            
                                            print(self.lookedUpCategoriesAndSets)
                                        }
                                    }
                                    
                                    self.searchDone = true
                                } else {
                                    self.lookedUpCategoriesAndSets.removeAll()
                                    self.searchDone = false
                                }
                                
                                self.categorySearchFocus = false
                            }
                            .focused($categorySearchFocus)
                            .onTapGesture {
                                self.categorySearchFocus = true
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 25, alignment: .center)
                        .padding([.top], 55)//prop.size.height > 340 ? 55 : 50)
                    }
                }*/
                
                Spacer()
                
                VStack {
                    HStack {
                        //if self.changeNavbarColor && !self.showSearchBar {
                            Button(action: { self.showSearchBar = true }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color.EZNotesOrange)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding([.top], 5)
                        //}
                        Button(action: { self.aiChatPopover = true }) {
                            Image("AI-Chat-Icon")
                                .resizable()
                                .frame(
                                    width: prop.size.height / 2.5 > 300 ? 45 : 40,
                                    height: prop.size.height / 2.5 > 300 ? 45 : 40
                                )
                                .padding([.trailing], 20)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                }
                .frame(maxWidth: 50, alignment: .trailing)
                .padding([.top], 50)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
            .background(!self.changeNavbarColor
                        ? AnyView(Color.black)
                        : AnyView(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).opacity(navbarOpacity))
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard)
        .zIndex(1)
        .popover(isPresented: $aiChatPopover) {
            VStack {
                VStack {
                    Text("EZNotes AI Chat")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .font(.system(size: 30, design: .rounded))
                        .shadow(color: .white, radius: 2)
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: 90, alignment: .top)
                .border(width: 0.5, edges: [.bottom], color: .gray)
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }*/
    }
}

struct TopNavCategoryView: View {
    @EnvironmentObject private var messageModel: MessagesModel
    
    var prop: Properties
    var categoryName: String
    var categoryBackground: Image
    var categoryBackgroundColor: Color
    var totalSets: Int
    
    @Binding public var launchCategory: Bool
    @Binding public var showTitle: Bool
    //@Binding public var tempChatHistory: [String: [UUID: Array<MessageDetails>]]
    //@Binding public var messages: Array<MessageDetails>
    @ObservedObject public var accountInfo: AccountDetails
    @Binding public var topBanner: [String: TopBanner]
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @State private var aiChat: Bool = false
    
    var body: some View {
        ZStack {
            ZStack {
                self.categoryBackground
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 125)
                //.aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay(Color.EZNotesBlack.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: 135)
            .background(
                Rectangle()
                    .shadow(color: self.categoryBackgroundColor, radius: 2.5, y: 2.5)
            )
            
            HStack {
                VStack {
                    Button(action: { self.launchCategory = false }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color.EZNotesBlue)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding([.leading], 20)
                }
                .frame(maxWidth: 50, maxHeight: .infinity, alignment: .leading)
                .padding(.top, prop.isLargerScreen ? 25 : -10)
                
                if self.topBanner.keys.contains(self.categoryName) && self.topBanner[self.categoryName]! != .None {
                    switch(self.topBanner[self.categoryName]!) {
                    case .LoadingUploads:
                        HStack {
                            Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                .padding(.trailing, 5)
                            
                            ProgressView()
                                .controlSize(.mini)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.trailing, 10)
                        .padding(.top, prop.isLargerScreen ? 25 : -10)
                    default: VStack { }.onAppear { self.topBanner[self.categoryName] = .None }
                    }
                } else { Spacer() }
                
                //Spacer()
                
                VStack {
                    Button(action: { self.aiChat = true }) {
                        Image("AI-Chat-Icon")
                            .resizable()
                            .frame(
                                width: prop.isLargerScreen ? 35 : 30,
                                height: prop.isLargerScreen ? 35 : 30
                            )
                            .padding([.trailing], 20)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: 50, maxHeight: .infinity, alignment: .trailing)
                .padding(.top, prop.isLargerScreen ? 25 : -10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .top)
        //.padding([.top], 5)//.background(Color.EZNotesBlack.opacity(0.95))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .popover(isPresented: $aiChat) {
            AIChat(
                prop: self.prop,
                accountInfo: self.accountInfo
            )
        }
        //.zIndex(1)
    }
}

struct TopNavUpload: View {
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var settings: SettingsConfigManager
    
    @Binding public var topBanner: TopBanner
    @ObservedObject public var categoryData: CategoryData
    @ObservedObject public var imagesToUpload: ImagesUploads
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    @Binding public var section: String
    @Binding public var lastSection: String
    @Binding public var userHasSignedIn: Bool
    
    @ObservedObject public var images_to_upload: ImagesUploads
    
    var prop: Properties
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 20)
            //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
            if self.topBanner != .None || self.networkMonitor.needsNoWifiBanner {
                if self.networkMonitor.needsNoWifiBanner {
                    HStack {
                        HStack {
                            Button(action: { self.topBanner = .None }) {
                                ZStack {
                                    Image(systemName: "multiply")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(.white)
                                }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            
                            Text("No WiFi Connection")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(Color.EZNotesRed)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            /* TODO: Is this really needed since the `NetworkMonitor` class is consistently checking? */
                            self.networkMonitor.manualRetryCheckConnection()
                        }) {
                            ZStack {
                                Text("Retry")
                                    .frame(alignment: .trailing)
                                    .padding([.top, .bottom], 2.5)
                                    .padding([.leading, .trailing], 6.5)
                                    .background(.white)
                                    .cornerRadius(15)
                                    .foregroundStyle(.black)
                                    .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                            }
                            .frame(alignment: .trailing)
                            .padding(.trailing, 10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                    .background(Color.EZNotesLightBlack.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.bottom, 20)
                    .padding(.trailing, 10)
                } else {
                    switch(self.topBanner) {
                    case .LoadingUploads:
                        HStack {
                            Text("Uploading \(self.images_to_upload.images_to_upload.count) \(self.images_to_upload.images_to_upload.count > 1 ? "images" : "image")...")
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 16 : 13))
                                .padding(.trailing, 5)
                            
                            ProgressView()
                                .controlSize(.mini)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, !self.settings.justNotes ? 10 : 0)
                    case .ErrorUploading:
                        HStack {
                            HStack {
                                Button(action: { self.topBanner = .None }) {
                                    ZStack {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.white)
                                    }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Text("Error Uploading. Try Again")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(Color.EZNotesRed)
                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                print("Report Issue")
                            }) {
                                ZStack {
                                    Text("Report")
                                        .frame(alignment: .trailing)
                                        .padding([.top, .bottom], 2.5)
                                        .padding([.leading, .trailing], 6.5)
                                        .background(.white)
                                        .cornerRadius(15)
                                        .foregroundStyle(.black)
                                        .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, !self.settings.justNotes ? 10 : 0)
                    case .UploadsReadyToReview:
                        HStack {
                            HStack {
                                Button(action: {
                                    self.categoryData.saveNewCategories()
                                    self.imagesToUpload.images_to_upload.removeAll()
                                    self.topBanner = .None
                                }) {
                                    ZStack {
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.white)
                                    }.frame(maxWidth: 10, alignment: .leading).padding(.leading, 10)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Text("Uploading Finished")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(Color.EZNotesGreen)
                                    .font(.system(size: prop.isLargerScreen ? 16 : 13))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                self.lastSection = self.section
                                self.section = "review_new_categories"
                                
                                self.topBanner = .None
                            }) {
                                ZStack {
                                    Text("Review")
                                        .frame(alignment: .trailing)
                                        .padding([.top, .bottom], 2.5)
                                        .padding([.leading, .trailing], 6.5)
                                        .background(.white)
                                        .cornerRadius(15)
                                        .foregroundStyle(.black)
                                        .font(.system(size: prop.isLargerScreen ? 13.5 : 10))
                                }
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .padding([.top, .bottom], 6)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                        .padding(.trailing, !self.settings.justNotes ? 10 : 0)
                    default:
                        VStack { }.onAppear { self.topBanner = .None }
                    }
                }
            } else {
                Spacer()
            }
            
            if self.settings.justNotes {
                Menu {
                    Button(action: {
                        self.settings.justNotes = false
                        self.settings.saveSettings()
                    }) {
                        HStack {
                            Image(systemName: "lightswitch.off")
                                .resizable()
                                .frame(width: 15, height: 20)
                                .foregroundStyle(.white)
                            
                            Text("Turn Off JustNotes")
                        }
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    
                } label: {
                    ZStack {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: 38, alignment: .trailing)
                    .padding(.trailing, 20)
                    .padding([.bottom], 20)
                }
            }
            
            /*VStack {
                VStack {
                    Button(action: {
                        self.lastSection = self.section
                        self.section = "upload_review"
                    }) {
                        Text("Review")
                            .padding(5)
                            .foregroundStyle(.white)
                            .frame(width: 75, height: 20)
                    }
                    .tint(Color.EZNotesBlue)
                    .opacity(!self.images_to_upload.images_to_upload.isEmpty ? 1 : 0)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 5 : 0)
                    .padding([.trailing], 20)
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(width: 200, height: 40, alignment: .topTrailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .background(.clear)*/
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
        .background(.clear)
    }
}

struct YouTubeVideoView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true // Enable inline media playback
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            return webView
        }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0?autoplay=1&mute=0") else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct TopNavChat: View {
    
    @ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    @Binding public var friendSearch: String
    @Binding public var userHasSignedIn: Bool
    
    var prop: Properties
    var backgroundColor: Color
    
    @State private var rickRoll: Bool = false
    @State private var userSearched: String = ""
    @FocusState private var userSearchBarFocused: Bool
    @State private var usersSearched: [String: Image] = [:]
    @State private var launchUserPreview: Bool = false
    @State private var launchedForUser: String = ""
    @State private var usersPfpBg: Image = Image("Pfp-Default-Bg")
    @State private var usersPfp: Image = Image(systemName: "person.crop.circle.fill")
    
    var body: some View {
        HStack {
            VStack {
                ProfileIconView(prop: prop, accountInfo: accountInfo, showAccountPopup: $showAccountPopup)
            }
            .padding([.bottom], 20)
            //.popover(isPresented: $showAccountPopup) { AccountPopup(prop: prop, accountInfo: accountInfo, userHasSignedIn: $userHasSignedIn) }
            
            Spacer()
            
            HStack {
                ZStack {
                    Button(action: { self.rickRoll = true }) {
                        Image(systemName: "person.badge.plus")//Image("Add-Friend-Icon")
                            .resizable()
                            .frame(maxWidth: 25, maxHeight: 25)
                            .foregroundStyle(Color.EZNotesBlue)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .padding(.leading, 5)
                }
                .frame(width: 30, height: 30, alignment: .center)
                .padding(6)
                .background(
                    Circle()
                        .fill(Color.EZNotesLightBlack.opacity(0.5))
                )
                .padding(.trailing, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 20)
            .popover(isPresented: $rickRoll) {
                VStack {
                    HStack {
                        Button(action: { self.rickRoll = false }) {
                            ZStack {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .frame(width: 18, height: 10)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: 30, alignment: .leading)
                            .padding(.leading, 15)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        
                        Text("Add Friend")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.system(size: prop.isLargerScreen ? 24 : 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        ZStack { }.frame(maxWidth: 30, alignment: .trailing).padding(.trailing, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .padding([.leading, .top, .trailing], 8)
                    
                    HStack {
                        TextField(
                            "",
                            text: $userSearched
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .padding(8)
                        .padding(.horizontal, 25)
                        .background(Color.EZNotesLightBlack)//(Color(.systemGray5))
                        .foregroundStyle(.white)
                        .cornerRadius(15)
                        .padding(.horizontal, 10)
                        .focused($userSearchBarFocused)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, alignment: .leading)
                                    .padding(.leading, 20)
                                
                                if self.userSearched.isEmpty && !self.userSearchBarFocused {
                                    Text("Search...")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                } else {
                                    Spacer()
                                }
                                
                                if !self.userSearched.isEmpty {
                                    Button(action: {
                                        self.userSearched = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 25)
                                    }
                                }
                            }
                        )
                        .onSubmit {
                            print(self.userSearched)
                        }
                        
                        ZStack {
                            Image(systemName: "line.3.horizontal.decrease")
                                .resizable()
                                .frame(width: 20, height: 15)
                                .foregroundStyle(.white)
                        }
                        .padding(.leading, 5)
                    }
                    .frame(maxWidth: prop.size.width - 20)
                    .padding(.top, 15)
                    
                    Divider()
                        .background(.white)
                        .padding(.top)
                        .padding(.bottom, -5)
                    
                    ZStack {
                        if self.launchUserPreview {
                            VStack {
                                Spacer()
                                
                                VStack {
                                    ZStack {
                                        self.usersPfpBg
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxHeight: prop.isLargerScreen ? 135 : 115)
                                        //.aspectRatio(contentMode: .fill)
                                            .clipped()
                                            .overlay(Color.EZNotesBlack.opacity(0.3))
                                            .cornerRadius(15, corners: [.topLeft, .topRight])
                                    }
                                    .frame(maxWidth: prop.size.width, maxHeight: 100)
                                    
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(colors: [Color.EZNotesBlue, Color.EZNotesBlack], startPoint: .top, endPoint: .bottom))
                                            
                                            self.usersPfp
                                                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                .scaledToFill()
                                                .frame(maxWidth: 70, maxHeight: 70)
                                                .clipShape(.circle)
                                        }
                                        .frame(width: 75, height: 75, alignment: .leading)
                                        .padding(.leading, 20)
                                        .zIndex(1)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, -20)
                                    
                                    HStack {
                                        Text(launchedForUser)
                                            .frame(alignment: .leading)
                                            .padding(.leading, 20)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 30 : 24))//(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 28 : 22))
                                        
                                        Divider()
                                            .background(.white)
                                        
                                        Text("0 Friends")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: prop.isLargerScreen ? 20 : 16, weight: .light))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 20)
                                    .padding(.top, 10)
                                    
                                    Text("TODO: Add description details for users being looked up.")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 20)
                                        .padding(.top, 10)
                                        .foregroundStyle(.gray)
                                        .font(Font.custom("Poppins-Regular", size: 12))
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Tags:")
                                        .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                        .foregroundStyle(.white)
                                        .padding(.leading, 20)
                                        .padding(.top, 10)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            HStack {
                                                Text("Support Coming Soon")
                                                    .frame(alignment: .center)
                                                    .padding([.top, .bottom], 4)
                                                    .padding([.leading, .trailing], 8.5)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(Color.EZNotesLightBlack.opacity(0.8))
                                                        //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                                                    )
                                                    .font(Font.custom("Poppins-SemiBold", size: 14))
                                                    .foregroundStyle(.white)
                                                    .padding([.top, .bottom], 1.5)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            HStack {
                                                Text("Stay Tuned")
                                                    .frame(alignment: .center)
                                                    .padding([.top, .bottom], 4)
                                                    .padding([.leading, .trailing], 8.5)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(Color.EZNotesLightBlack.opacity(0.8))
                                                        //.stroke(Color.EZNotesBlue, lineWidth: 0.5)
                                                    )
                                                    .font(Font.custom("Poppins-SemiBold", size: 14))
                                                    .foregroundStyle(.white)
                                                    .padding([.top, .bottom], 1.5)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.trailing, 10)
                                        .padding(.leading, 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.leading, 20)
                                    
                                    /* TODO: Remove this after releasing build tonight. */
                                    Text("The rest of this view, alongside the entire **\"Chat\"** view, is in development. Stay tuned for the next build 🤝")
                                        .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                        .font(Font.custom("Poppins-Regular", size: 13))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                        .padding([.top, .bottom], 40) /* MARK: Temporary. Will get removed when this entire feature is actually implemented for use. */
                                }
                                .frame(maxWidth: prop.size.width - 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.black)
                                        .shadow(color: Color.EZNotesLightBlack, radius: 4.5)
                                )
                                .cornerRadius(15)
                                .padding(4.5) /* MARK: Ensure the shadow can be seen. */
                                
                                Button(action: { self.launchUserPreview = false }) {
                                    HStack {
                                        ZStack { }.frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundStyle(.black)
                                            
                                            Text("Add User")
                                                .frame(alignment: .center)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        ZStack { }.frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .padding(8)
                                    .background(Color.EZNotesBlue)
                                    .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Button(action: { self.launchUserPreview = false }) {
                                    Text("Go Back")
                                        .frame(alignment: .center)
                                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                        .padding(8)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.black)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.EZNotesBlack.opacity(0.9))
                            .zIndex(1)
                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                ForEach(Array(self.usersSearched.keys), id: \.self) { user in
                                    Button(action: {
                                        RequestAction<GetUsersAccountIdData>(parameters: GetUsersAccountIdData(
                                            Username: user
                                        )).perform(action: get_users_account_id_req) { statusCode, resp in
                                            guard resp != nil && statusCode == 200 else {
                                                print("ERROR!")
                                                return
                                            }
                                            
                                            /*guard resp!.keys.contains("AccountId") else {
                                                print("Missing `AccountId` in response.")
                                                return
                                            }*/
                                            
                                            if let accountId: String = resp!["AccountId"] as? String {
                                                PFP(accountID: accountId)
                                                    .requestGetPFPBg() { statusCode, pfp_bg in
                                                        guard pfp_bg != nil && statusCode == 200 else { return }
                                                        
                                                        self.usersPfpBg = Image(uiImage: UIImage(data: pfp_bg!)!)
                                                    }
                                            }
                                        }
                                        
                                        self.launchUserPreview = true
                                        self.usersPfp = self.usersSearched[user]!
                                        self.launchedForUser = user
                                    }) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.EZNotesBlue)
                                                
                                                /*Image(systemName: "person.crop.circle.fill")*/
                                                self.usersSearched[user]!
                                                    .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                    .scaledToFill()
                                                    .frame(maxWidth: 35, maxHeight: 35)
                                                    .clipShape(.circle)
                                                    .foregroundStyle(.white)
                                            }
                                            .frame(width: 38, height: 38)
                                            .padding([.leading], 10)
                                            
                                            Text(user)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 16 : 14))
                                                .foregroundStyle(.white)
                                            
                                            Button(action: { print("Add User") }) {
                                                HStack {
                                                    Image(systemName: "plus")
                                                        .resizable()
                                                        .frame(width: 10, height: 10)
                                                        .foregroundStyle(.black)
                                                    
                                                    Text("Add")
                                                        .frame(alignment: .center)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundStyle(.black)
                                                }
                                                .padding([.top, .bottom], 2)
                                                .padding([.leading, .trailing], 8)
                                                .background(Color.EZNotesBlue)
                                                .cornerRadius(15)
                                                .padding(.trailing, 10)
                                            }
                                        }
                                        .padding(8)
                                        .background(Color.EZNotesLightBlack)
                                        .cornerRadius(15)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 30) /* MARK: Ensure space between bottom of screen and content at end of scrollview. */
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.EZNotesBlack)
                .onAppear {
                    RequestAction<ReqPlaceholder>(
                        parameters: ReqPlaceholder()
                    )
                    .perform(action: get_user_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            print("Error!")
                            return
                        }
                        
                        if let resp = resp as? [String: [String: Any]] {
                            for user in resp.keys {
                                guard resp[user] != nil else { continue }
                                
                                if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                    if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                        self.usersSearched[user] = Image(
                                            uiImage: UIImage(
                                                data: userPFPData
                                            )!
                                        )
                                    } else {
                                        self.usersSearched[user] = Image(systemName: "person.crop.circle.fill")
                                    }
                                } else {
                                    self.usersSearched[user] = Image(systemName: "person.crop.circle.fill")
                                }
                            }
                        } else {
                            print("Error")
                        }
                    }
                }
                /*WebView(url: URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0")!)
                    .navigationBarTitle("Get Rick Rolled, Boi", displayMode: .inline)*/
                /*YouTubeVideoView() // Replace with your YouTube video ID
                    .frame(maxWidth: .infinity, maxHeight: .infinity)//: 300) // Set height for the video player
                    .cornerRadius(10)
                    .padding()*/
            }
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}

#Preview {
    ContentView()
}
