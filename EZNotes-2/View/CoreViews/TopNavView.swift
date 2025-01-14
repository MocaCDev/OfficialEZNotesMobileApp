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
    @EnvironmentObject private var accountInfo: AccountDetails
    
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
    var numberOfSets: Int
    var creationDate: String
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
                    .frame(maxHeight: prop.isLargerScreen ? 125 : prop.isMediumScreen ? 110 : 100)
                //.aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay(Color.EZNotesBlack.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 125 : prop.isMediumScreen ? 110 : 100)
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
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.EZNotesBlack)
                    )
                    .padding([.leading], 20)
                }
                .frame(maxWidth: 50, maxHeight: .infinity, alignment: .leading)
                .padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 25 : 10)
                
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
                        .padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 25 : 10)
                    default: VStack { }.onAppear { self.topBanner[self.categoryName] = .None }
                    }
                } else {
                    VStack {
                        Text(self.categoryName)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? self.categoryName.count < 22 ? 22 : 18 : self.categoryName.count < 22 ? 18 : 16))
                            .foregroundStyle(.white)
                            .lineLimit(1...2)
                            .multilineTextAlignment(.center)
                            .truncationMode(.tail)
                        
                        HStack {
                            Text("\(self.numberOfSets) \(self.numberOfSets > 1 ? "Sets" : self.numberOfSets == 0 ? "Sets" : "Set")")
                                .frame(alignment: .leading)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                            
                            Divider()
                                .background(.white)
                            
                            Text("Created \(self.creationDate)")
                                .frame(alignment: .trailing)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                        }
                        .frame(maxHeight: 13)
                        .padding(.top, -8)
                    }
                    .padding(.top, prop.isLargerScreen ? self.categoryName.count < 22 ? 35 : 38 : prop.isMediumScreen ? 25 : 10)
                    .padding(.horizontal, 8)
                }
                
                //Spacer()
                
                VStack {
                    ZStack {
                        Button(action: { self.aiChat = true }) {
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
                            .fill(Color.EZNotesBlack)
                    )
                    .padding([.trailing], 20)
                    .padding(.top, prop.isLargerScreen || prop.isMediumScreen ? 25 : 10)//-10)
                }
                .frame(maxWidth: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 125 : prop.isMediumScreen ? 110 : 100, alignment: .top)
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

struct CheckBox: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        })
        .buttonStyle(NoLongPressButtonStyle())
    }
}

enum TopNavChatErrors {
    case None
    case ErrorAcceptingFriendRequest
    case CannotAddYourself
    case ErrorSendingFriendRequest
}

struct TopNavChat: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    //@ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var showAccountPopup: Bool
    
    @Binding public var friendSearch: String
    @Binding public var userHasSignedIn: Bool
    
    var prop: Properties
    var backgroundColor: Color
    
    /* MARK: States for the overall "Add Friend" popup. */
    @Binding public var showUserProfilePreview: Bool
    @State private var rickRoll: Bool = false
    @State private var userSearched: String = ""
    @FocusState private var userSearchBarFocused: Bool
    
    @State private var error: TopNavChatErrors = .None
    @State private var errorPopupYOffset: CGFloat = 0
    
    /* MARK: Friends/friend requests/pending states. */
    @State private var defaultUsers: [String: Image] = [:] /* MARK: Stores users that show in the "Add" section without the user searching. */
    @State private var usersSearched: [String: Image] = [:] /* MARK: Stores users that match the users search. */
    
    @State private var launchUserPreview: Bool = false
    @State private var launchedForUser: String = ""
    @State private var usersFriendCount: Int = 0
    @State private var usersPfpBg: Image = Image("Pfp-Default-Bg")
    @State private var usersPfp: Image = Image(systemName: "person.crop.circle.fill")
    @State private var usersDescrition: String = "No Description"
    @State private var usersTags: Array<String> = []
    @State private var noUsersToShow: Bool = false
    @State private var noSearchResults: Bool = false
    @State private var performingSearch: Bool = false
    @State private var addingFriend: Bool = false
    @State private var removingFriendRequest: Bool = false
    @State private var acceptingFriendRequest: Bool = false
    @State private var usersBeingAccepted: Array<String> = []
    @State private var usersBeingRemoved: Array<String> = []

    @State private var sendingFriendRequestsTo: Array<String> = []
    @State private var selectedView: String = "add"
    @State private var loadingView: Bool = false
    
    /* MARK: States for filters. */
    @State private var showFilters: Bool = false
    @State private var showAnyUser: Bool = true /* MARK: Default filter. */
    @State private var showUsersFromSameState: Bool = false
    @State private var showUsersFromSameCollege: Bool = false
    @State private var showUsersWithSameMajor: Bool = false
    @State private var showUsersWithSchoolUsageOnly: Bool = false
    @State private var showUsersWithWorkUsageOnly: Bool = false
    @State private var showUsersWithGeneralUsageOnly: Bool = false
    @State private var numberOfResults: Int = 30
    @State private var usersNumberOfFriends: Int = 1
    
    private func getFilter() -> (Filters: String, Usages: String) { /* MARK: Checks all of the filter toggle states and returns which one is toggled on. */
        let filters: [String] = [
            self.showUsersFromSameState ? "same_state" : nil,
            self.showUsersFromSameCollege ? "same_college" : nil,
            self.showUsersWithSameMajor ? "same_major" : nil
        ].compactMap { $0 } // Remove nil entries
        
        let usages: [String] = [
            self.showUsersWithSchoolUsageOnly ? "school_usage" : nil,
            self.showUsersWithWorkUsageOnly ? "work_usage" : nil,
            self.showUsersWithGeneralUsageOnly ? "general_usage" : nil
        ].compactMap { $0 }
        
        return (
            Filters: filters.isEmpty ? "show_any" : filters.joined(separator: "_and_"),
            Usages: usages.isEmpty ? "" : usages.joined(separator: ",")
        )
    }
    
    private func endignAction() -> Void {
        if self.loadingView { self.loadingView = false }
    }
    
    private func returnNilAction() -> Void {
        self.noUsersToShow = true
    }
    
    private func getUsers() {
        RequestAction<GetUsersData>(
            parameters: GetUsersData(
                AccountId: self.accountInfo.accountID,
                Filter: self.getFilter().Filters,
                Usages: self.getFilter().Usages
            )
        )
        .perform(action: get_user_req) { statusCode, resp in
            guard resp != nil && statusCode == 200 else {
                self.noUsersToShow = true
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                if let resp = resp {
                    guard
                        let usersData = ResponseHelper(
                            endingAction: self.endignAction,
                            returnNilAction: self.returnNilAction
                        ).populateUsers(resp: resp)
                    else {
                        return /* MARK: `noUsersToShow` gets set if `populateUsers` returns `nil`. */
                    }
                    
                    self.defaultUsers = usersData
                    
                    /* MARK: In the background, send requests to the server to check the friend status of the users being shown. */
                    /*for user in self.defaultUsers.keys {
                        /* MARK: Check to see if the client is friends with the user, or the user has sent a request to be friends with the client. */
                        RequestAction<IsFriendsOrHasSentFriendRequestData>(parameters: IsFriendsOrHasSentFriendRequestData(
                            AccountId: self.accountInfo.accountID,
                            Username: user
                        )).perform(action: is_friend_or_has_sent_friend_request_req) { statusCode, r in
                            guard r != nil && statusCode == 200 else {
                                return
                            }
                            
                            if let r = r {
                                if r["Pending"]! as! Bool {
                                    DispatchQueue.main.async { self.defaultUsersPendingRequests.append(user) }
                                    //self.defaultUsersPendingRequests.append(user)
                                }
                                else {
                                    if r["Friends"]! as! Bool {
                                        DispatchQueue.main.async { self.defaultUsersFriends.append(user) }
                                        //self.defaultUsersFriends.append(user)
                                    }
                                }
                            }
                        }
                    }*/
                }
                else { self.noUsersToShow = true }
            }
        }
    }
    
    /* MARK: If the search is empty, the function will repopulate the `defaultUsers` dictionary. */
    private func checkIfSearchIsEmpty() {
        self.userSearched.removeAll()
        
        if self.noUsersToShow { self.noUsersToShow = false }
        if self.noSearchResults { self.noSearchResults = false }
        
        self.usersSearched.removeAll()
        self.defaultUsers.removeAll()
        
        self.getUsers()
    }
    
    @FocusState private var searchFieldFocus: Bool
    
    @State private var constantlyUpdateIncomingFriendRequests: Bool = false
    
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
                    Button(action: { self.showUserProfilePreview = true }) {
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
            .popover(isPresented: $showUserProfilePreview) {
                VStack {
                    HStack {
                        if self.showFilters {
                            Button(action: { self.showFilters = false }) {
                                ZStack {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: 30, alignment: .leading)
                                .padding(.leading, 15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        } else {
                            Button(action: { self.showUserProfilePreview = false }) {
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
                        }
                        
                        Text(!self.showFilters ? "Add Friend" : "Filters")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.system(size: prop.isLargerScreen ? 24 : 22, weight: .bold))
                            .foregroundStyle(.white)
                        
                        ZStack { }.frame(maxWidth: 30, alignment: .trailing).padding(.trailing, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .padding([.leading, .top, .trailing], 8)
                    .padding(.top, 10)
                    
                    if !self.showFilters {
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
                            .autocorrectionDisabled(true)
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
                                            self.userSearched.removeAll()
                                            
                                            if self.noUsersToShow { self.noUsersToShow = false }
                                            if self.noSearchResults { self.noSearchResults = false }
                                            
                                            self.usersSearched.removeAll()
                                            self.defaultUsers.removeAll()
                                            //self.pendingRequests.removeAll()
                                            //self.friends.removeAll()
                                            
                                            self.getUsers()
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 25)
                                        }
                                    }
                                }
                            )
                            .onChange(of: self.userSearched) {
                                if self.userSearched.isEmpty {
                                    self.userSearched.removeAll()
                                    
                                    if self.noUsersToShow { self.noUsersToShow = false }
                                    if self.noSearchResults { self.noSearchResults = false }
                                    
                                    self.usersSearched.removeAll()
                                    self.defaultUsers.removeAll()
                                    
                                    self.getUsers()
                                } else {
                                    /* MARK: Default back to the "add" view if the user starts searching something. */
                                    if self.selectedView != "add" { self.selectedView = "add" }
                                    
                                    /* MARK: Ensure both of these states are false to allow the view for `performingSearch` to show. */
                                    if self.noUsersToShow { self.noUsersToShow = false }
                                    if self.noSearchResults { self.noSearchResults = false }
                                    
                                    /* MARK: Do nothing if `userSearched` is empty. */
                                    if self.userSearched.isEmpty { return }
                                    
                                    self.performingSearch = true
                                    
                                    RequestAction<SearchUserData>(parameters: SearchUserData(
                                        AccountId: self.accountInfo.accountID,
                                        Filter: self.getFilter().Filters,
                                        Usages: self.getFilter().Usages,
                                        Query: self.userSearched
                                    )).perform(action: search_user_req) { statusCode, resp in
                                        self.performingSearch = false
                                        
                                        guard resp != nil && statusCode == 200 else {
                                            self.noSearchResults = true
                                            return
                                        }
                                        
                                        self.usersSearched.removeAll()
                                        
                                        if let resp = resp {
                                            guard
                                                let searchResults = ResponseHelper(
                                                    endingAction: self.endignAction,
                                                    returnNilAction: self.returnNilAction
                                                ).populateUsers(resp: resp)
                                            else {
                                                self.noSearchResults = true
                                                self.noUsersToShow = false
                                                return
                                            }
                                            
                                            self.usersSearched = searchResults
                                            
                                            //self.defaultUsersPendingRequests.removeAll()
                                            //self.defaultUsersFriends.removeAll()
                                            
                                            /*for user in self.usersSearched.keys {
                                                /* MARK: Continue to check the search. If at any point during this iteration it becomes empty, hault the loop, repopulate the `defaultUsers` dictionary and exit. */
                                                if self.userSearched.isEmpty {
                                                    self.performingSearch = false
                                                    self.userSearched.removeAll()
                                                    
                                                    if self.noUsersToShow { self.noUsersToShow = false }
                                                    if self.noSearchResults { self.noSearchResults = false }
                                                    
                                                    self.usersSearched.removeAll()
                                                    self.defaultUsers.removeAll()
                                                    self.pendingRequests.removeAll()
                                                    self.friends.removeAll()
                                                    
                                                    self.loadingView = true
                                                    self.getUsers()
                                                    
                                                    return
                                                }
                                                
                                                RequestAction<IsFriendsOrHasSentFriendRequestData>(parameters: IsFriendsOrHasSentFriendRequestData(
                                                    AccountId: self.accountInfo.accountID,
                                                    Username: user
                                                )).perform(action: is_friend_or_has_sent_friend_request_req) { statusCode, r in
                                                    /* MARK: Ensure that the search is still not empty after the request has been performed. */
                                                    if self.userSearched.isEmpty {
                                                        self.performingSearch = false
                                                        self.userSearched.removeAll()
                                                        
                                                        if self.noUsersToShow { self.noUsersToShow = false }
                                                        if self.noSearchResults { self.noSearchResults = false }
                                                        
                                                        self.usersSearched.removeAll()
                                                        self.defaultUsers.removeAll()
                                                        self.pendingRequests.removeAll()
                                                        self.friends.removeAll()
                                                        
                                                        self.loadingView = true
                                                        self.getUsers()
                                                        
                                                        return
                                                    }
                                                    
                                                    guard r != nil && statusCode == 200 else {
                                                        return
                                                    }
                                                    
                                                    if let r = r {
                                                        if r["Pending"]! as! Bool {
                                                            //DispatchQueue.main.async { self.defaultUsersPendingRequests.append(user) }
                                                            self.defaultUsersPendingRequests.append(user)
                                                        }
                                                        else {
                                                            if r["Friends"]! as! Bool {
                                                                //DispatchQueue.main.async { self.defaultUsersFriends.append(user) }
                                                                self.defaultUsersFriends.append(user)
                                                            }
                                                        }
                                                    }
                                                }
                                            }*/
                                            
                                            if self.noUsersToShow {
                                                self.noSearchResults = true
                                                self.noUsersToShow = false
                                                return
                                            }
                                        }
                                        else { self.noSearchResults = true }
                                    }
                                }
                            }
                            .onSubmit {
                                if self.userSearched.isEmpty { return }
                                
                                /* MARK: Default back to the "add" view if the user starts searching something. */
                                if self.selectedView != "add" { self.selectedView = "add" }
                                
                                /* MARK: Ensure both of these states are false to allow the view for `performingSearch` to show. */
                                if self.noUsersToShow { self.noUsersToShow = false }
                                if self.noSearchResults { self.noSearchResults = false }
                                
                                /* MARK: Do nothing if `userSearched` is empty. */
                                if self.defaultUsers.isEmpty {
                                    /*self.defaultUsers.removeAll()
                                    
                                    if self.noUsersToShow { self.noUsersToShow = false }
                                    if self.noSearchResults { self.noSearchResults = false }
                                    
                                    self.usersSearched.removeAll()
                                    self.pendingRequests.removeAll()
                                    self.friends.removeAll()
                                    
                                    self.getUsers()*/
                                    return
                                }
                                
                                self.performingSearch = true
                                
                                RequestAction<SearchUserData>(parameters: SearchUserData(
                                    AccountId: self.accountInfo.accountID,
                                    Filter: self.getFilter().Filters,
                                    Usages: self.getFilter().Usages,
                                    Query: self.userSearched
                                )).perform(action: search_user_req) { statusCode, resp in
                                    self.performingSearch = false
                                    
                                    guard resp != nil && statusCode == 200 else {
                                        self.noSearchResults = true
                                        return
                                    }
                                    
                                    self.usersSearched.removeAll()
                                    
                                    if let resp = resp {
                                        guard
                                            let searchResults = ResponseHelper(
                                                endingAction: self.endignAction,
                                                returnNilAction: self.returnNilAction
                                            ).populateUsers(resp: resp)
                                        else {
                                            self.noSearchResults = true
                                            self.noUsersToShow = false
                                            
                                            return
                                        }
                                        
                                        self.usersSearched = searchResults
                                        
                                        if self.noUsersToShow {
                                            self.noSearchResults = true
                                            self.noUsersToShow = false
                                            return
                                        }
                                    }
                                    else { self.noSearchResults = true }
                                }
                            }
                            
                            /* MARK: Filters for searching for friends will come for users who are using the app for work/general purposes later. For now, filters only apply to those using the app for school as the app was initially being built for only those using it for school. */
                            //if self.accountInfo.usage == "school" {
                                Button(action: { self.showFilters = true }) {
                                    ZStack {
                                        Image(systemName: "line.3.horizontal.decrease")
                                            .resizable()
                                            .frame(width: 20, height: 15)
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.leading, 5)
                                }
                            //}
                        }
                        .frame(maxWidth: prop.size.width - 20)
                        .padding(.top, 15)
                        
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: { self.selectedView = "add" }) {
                                        HStack {
                                            Text("Add")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "add" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "add" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { self.selectedView = "friends" }) {
                                        HStack {
                                            Text("Friends")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "friends" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "friends" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { self.selectedView = "requests" }) {
                                        HStack {
                                            Text("Requests")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.selectedView == "requests" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.selectedView == "requests" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { self.selectedView = "pending" }) {
                                        HStack {
                                            ZStack {
                                                HStack {
                                                    Spacer()
                                                    
                                                    VStack {
                                                        Text("\(self.accountInfo.pendingRequests.count)")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .font(.system(size: 10, weight: .medium))
                                                            .foregroundStyle(self.accountInfo.pendingRequests.count >= 1 ? Color.EZNotesGreen : .secondary)
                                                        
                                                        Spacer()
                                                    }
                                                    .frame(width: 20, height: 20)
                                                    .clipShape(.circle)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .zIndex(1)
                                                
                                                Text("Pending")
                                                    .frame(alignment: .center)
                                                    .padding([.top, .bottom], 4)
                                                    .padding(.leading, 8.5)
                                                    .padding(.trailing, 15.5)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(self.selectedView == "pending" ? Color.EZNotesBlue : .clear)
                                                    )
                                                    .foregroundStyle(self.selectedView == "pending" ? .black : .secondary)
                                                    .font(Font.custom("Poppins-SemiBold", size: 12))
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 25)
                                            
                                            /*Text("+ \(self.accountInfo.pendingRequests.count)")
                                                .frame(alignment: .leading)
                                                .padding([.top, .bottom], 4)
                                                .foregroundStyle(self.accountInfo.pendingRequests.count > 1 ? Color.EZNotesGreen : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))*/
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
                        .padding(.top)
                        
                        Divider()
                            .background(.white)
                            .padding(.bottom, -5)
                        
                        switch(self.selectedView) {
                        case "add":
                            ZStack {
                                if self.error == .CannotAddYourself || self.error == .ErrorSendingFriendRequest {
                                    VStack {
                                        Spacer()
                                        
                                        HStack {
                                            Text(self.error == .ErrorSendingFriendRequest
                                                 ? "Failed to send friend request. Try again"
                                                 : "You cannot add yourself as a friend")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(Color.EZNotesRed)
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen ? 18 : 16,
                                                    weight: .medium
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                            .padding(.leading, 10)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.black)//(Color.EZNotesLightBlack.opacity(0.7))
                                                .shadow(color: Color.EZNotesLightBlack, radius: 12.5)//.stroke(Color.white, lineWidth: 1)
                                        )
                                        .padding(4)
                                        //.clipShape(RoundedRectangle(cornerRadius: 15))
                                        .padding(.horizontal)
                                        .offset(y: self.errorPopupYOffset)
                                        .animation(.easeIn(duration: 3), value: self.errorPopupYOffset)
                                    }
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            //withAnimation(.easeIn(duration: 3)) {
                                                self.errorPopupYOffset = prop.size.height // Animate to desired position
                                            //}
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                self.error = .None
                                                self.errorPopupYOffset = 0
                                            }
                                        }
                                    }
                                }
                                
                                if self.performingSearch {
                                    VStack { /* MARK: `VStack` needing to ensure the content in `LoadingView` does not sit on top of each other. */
                                        LoadingView(message: "Searching...")
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    if self.launchUserPreview {
                                        VStack {
                                            Spacer()
                                            
                                            VStack {
                                                UsersProfile(
                                                    prop: self.prop,
                                                    username: self.launchedForUser,
                                                    usersPfpBg: self.usersPfpBg,
                                                    usersPfp: self.usersPfp,
                                                    usersDescription: self.usersDescrition,
                                                    usersTags: self.usersTags.isEmpty ? ["No Tags"] : self.usersTags,
                                                    usersFriends: self.usersFriendCount,
                                                    accountPopupSection: $launchedForUser, /* TODO: Figure something out with this, this is bad. */
                                                    showAccount: $launchUserPreview, /* TODO: Figure something out with this, this is bad. */
                                                    addMoreTags: $launchUserPreview,
                                                    accountViewY: $errorPopupYOffset,
                                                    accountViewOpacity: $errorPopupYOffset
                                                )
                                                .padding(.top, 8)
                                                .padding(.bottom, 20)
                                                
                                                /* TODO: Remove this after releasing build tonight. */
                                                /*Text("The rest of this view, alongside the entire **\"Chat\"** view, is in development. Stay tuned for the next build 🤝")
                                                    .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                                    .font(Font.custom("Poppins-Regular", size: 13))
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding([.top, .bottom], 40) /* MARK: Temporary. Will get removed when this entire feature is actually implemented for use. */*/
                                            }
                                            .frame(maxWidth: prop.size.width - 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(.black)
                                                    .shadow(color: /*Color.EZNotesLightBlack*/Color.white, radius: 2.5)
                                            )
                                            .padding(2.5)
                                            .cornerRadius(15)
                                            //.padding(4.5) /* MARK: Ensure the shadow can be seen. */
                                            
                                            if !self.accountInfo.friends.keys.contains(self.launchedForUser) && !self.accountInfo.friendRequests.keys.contains(self.launchedForUser) {
                                                if !self.sendingFriendRequestsTo.contains(self.launchedForUser) {
                                                    Button(action: {
                                                        self.sendingFriendRequestsTo.append(self.launchedForUser)
                                                        self.addingFriend = true
                                                        
                                                        RequestAction<SendFriendRequestData>(parameters: SendFriendRequestData(
                                                            AccountId: self.accountInfo.accountID,
                                                            Username: self.accountInfo.username,
                                                            RequestTo: self.launchedForUser
                                                        )).perform(action: send_friend_request_req) { statusCode, resp in
                                                            self.addingFriend = false
                                                            self.sendingFriendRequestsTo.removeAll(where: { $0 == self.launchedForUser })
                                                            
                                                            guard resp != nil && statusCode == 200 else {
                                                                print("Error")
                                                                return
                                                            }
                                                            
                                                            self.accountInfo.friendRequests[self.launchedForUser] = self.defaultUsers[self.launchedForUser]
                                                        }
                                                    }) {
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
                                                } else {
                                                    if self.usersBeingRemoved.contains(self.launchedForUser) {
                                                        VStack {
                                                            LoadingView(message: "Removing...")
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                    } else if self.sendingFriendRequestsTo.contains(self.launchedForUser) {
                                                        VStack {
                                                            LoadingView(message: "Adding...")
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                    }
                                                }
                                            } else {
                                                if !self.usersBeingRemoved.contains(self.launchedForUser) {
                                                    if self.accountInfo.friends.keys.contains(self.launchedForUser) {
                                                        Text("Friends")
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))
                                                            .foregroundStyle(.white)
                                                        
                                                        Button(action: {
                                                            self.usersBeingRemoved.append(self.launchedForUser)
                                                            
                                                            RequestAction<RemoveFriendData>(parameters: RemoveFriendData(
                                                                AccountId: self.accountInfo.accountID,
                                                                ToRemove: self.launchedForUser
                                                            )).perform(action: remove_friend_req) { statusCode, resp in
                                                                self.usersBeingRemoved.removeAll(where: { $0 == self.launchedForUser })
                                                                
                                                                guard resp != nil && statusCode == 200 else {
                                                                    return
                                                                }
                                                                
                                                                self.accountInfo.friends.removeValue(forKey: self.launchedForUser)
                                                            }
                                                        }) {
                                                            Text("Remove Friend")
                                                                .frame(alignment: .center)
                                                                .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                                .padding(8)
                                                                .font(.system(size: 14, weight: .medium))
                                                                .foregroundStyle(.black)
                                                                .background(Color.white)
                                                                .cornerRadius(15)
                                                        }
                                                    } else {
                                                        if self.accountInfo.pendingRequests.keys.contains(self.launchedForUser) {
                                                            HStack {
                                                                Image(systemName: "paperplane")
                                                                    .resizable()
                                                                    .frame(width: 10, height: 10)
                                                                    .foregroundStyle(.gray)
                                                                
                                                                Text("Pending")
                                                                    .frame(alignment: .center)
                                                                    .font(.system(size: 14, weight: .medium))
                                                                    .foregroundStyle(.gray)
                                                            }
                                                            .frame(maxWidth: .infinity)
                                                            .cornerRadius(15)
                                                            
                                                            Button(action: {
                                                                self.removingFriendRequest = true
                                                                
                                                                self.usersBeingRemoved.append(self.launchedForUser)
                                                                
                                                                RequestAction<RemoveFriendRequest>(parameters: RemoveFriendRequest(
                                                                    AccountId: self.accountInfo.accountID,
                                                                    CancelFor: self.launchedForUser
                                                                )).perform(action: cancel_friend_request_req) { statusCode, resp in
                                                                    self.removingFriendRequest = false
                                                                    
                                                                    guard resp != nil && statusCode == 200 else {
                                                                        return /* TODO: Handle error. */
                                                                    }
                                                                    
                                                                    /* MARK: Ensure that the dictionary is updated with the current manipulation. */
                                                                    self.accountInfo.friendRequests.removeValue(forKey: self.launchedForUser)
                                                                    
                                                                    //self.usersBeingRemoved.removeAll(where: { $0 == self.launchedForUser })
                                                                }
                                                            }) {
                                                                Text("Cancel Friend Request")
                                                                    .frame(alignment: .center)
                                                                    .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                                                    .padding(8)
                                                                    .font(.system(size: 14, weight: .medium))
                                                                    .foregroundStyle(.black)
                                                                    .background(Color.white)
                                                                    .cornerRadius(15)
                                                            }
                                                            .buttonStyle(NoLongPressButtonStyle())
                                                        }
                                                    }
                                                } else {
                                                    LoadingView(message: "Removing...")
                                                }
                                            }
                                            
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
                                        .background(.black.opacity(0.9))
                                        .onTapGesture {
                                            self.launchUserPreview = false
                                        }
                                        .onDisappear {
                                            /* MARK: Reset all of the user information after the preview closes. */
                                            self.usersFriendCount = 0
                                            self.usersPfp = Image(systemName: "person.crop.circle.fill")
                                            self.usersPfpBg = Image("Pfp-Default-Bg")
                                            self.launchedForUser.removeAll()
                                        }
                                        .zIndex(1)
                                    }
                                    
                                    if !self.noUsersToShow && !self.noSearchResults {
                                        if !self.loadingView {
                                            ScrollView(.vertical, showsIndicators: false) {
                                                VStack {
                                                    if self.usersSearched.isEmpty {
                                                        ForEach(Array(self.defaultUsers.enumerated()), id: \.offset) { index, value in
                                                            Button(action: {
                                                                RequestAction<GetUsersAccountIdData>(parameters: GetUsersAccountIdData(
                                                                    Username: value.key
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
                                                                        
                                                                        RequestAction<GetClientsFriendsData>(parameters: GetClientsFriendsData(
                                                                            AccountId: accountId
                                                                        )).perform(action: get_clients_friends_req) { statusCode, resp in
                                                                            guard resp != nil && statusCode == 200 else {
                                                                                return
                                                                            }
                                                                            
                                                                            if let resp = resp {
                                                                                self.usersFriendCount = resp.keys.count
                                                                            }
                                                                        }
                                                                        
                                                                        RequestAction<GetAccountDescriptionData>(parameters: GetAccountDescriptionData(
                                                                            AccountId: accountId
                                                                        )).perform(action: get_account_description_req) { statusCode, resp in
                                                                            guard resp != nil && statusCode == 200 else {
                                                                                self.usersDescrition = "No Description"
                                                                                return
                                                                            }
                                                                            
                                                                            if let resp = resp {
                                                                                guard
                                                                                    let desc = resp["AccountDescription"] as? String,
                                                                                    desc != ""
                                                                                else {
                                                                                    self.usersDescrition = "No Description"
                                                                                    return
                                                                                }
                                                                                
                                                                                self.usersDescrition = desc
                                                                            } else {
                                                                                self.usersDescrition = "No Description"
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                self.launchUserPreview = true
                                                                self.usersPfp = self.defaultUsers[value.key]!
                                                                self.launchedForUser = value.key
                                                                
                                                                if self.userSearchBarFocused {
                                                                    print("YES")
                                                                }
                                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                            }) {
                                                                HStack {
                                                                    ZStack {
                                                                        Circle()
                                                                            .fill(Color.EZNotesBlue)
                                                                        
                                                                        /*Image(systemName: "person.crop.circle.fill")*/
                                                                        self.defaultUsers[value.key]!
                                                                            .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                                            .scaledToFill()
                                                                            .frame(maxWidth: 35, maxHeight: 35)
                                                                            .clipShape(.circle)
                                                                            .foregroundStyle(.white)
                                                                    }
                                                                    .frame(width: 38, height: 38)
                                                                    .padding([.leading], 10)
                                                                    
                                                                    Text(value.key)
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                                        .foregroundStyle(.white)
                                                                    
                                                                    if self.usersBeingRemoved.contains(value.key) {
                                                                        HStack {
                                                                            Text("Removing...")
                                                                                .frame(alignment: .center)
                                                                                .font(.system(size: 16, weight: .medium))
                                                                                .foregroundStyle(.black)
                                                                        }
                                                                        .padding(4)
                                                                        //.padding([.top, .bottom], 2)
                                                                        .padding([.leading, .trailing], 12)
                                                                        .background(Color.EZNotesRed)
                                                                        .cornerRadius(15)
                                                                        .padding(.trailing, 10)
                                                                    } else {
                                                                        if !self.accountInfo.friendRequests.keys.contains(value.key) && !self.accountInfo.friends.keys.contains(value.key) {
                                                                            Button(action: {
                                                                                self.sendingFriendRequestsTo.append(value.key)
                                                                                self.addingFriend = true
                                                                                
                                                                                RequestAction<SendFriendRequestData>(parameters: SendFriendRequestData(
                                                                                    AccountId: self.accountInfo.accountID,
                                                                                    Username: self.accountInfo.username,
                                                                                    RequestTo: value.key
                                                                                )).perform(action: send_friend_request_req) { statusCode, resp in
                                                                                    self.addingFriend = false
                                                                                    self.sendingFriendRequestsTo.removeAll(where: { $0 == value.key })
                                                                                    
                                                                                    guard
                                                                                        resp != nil,
                                                                                        statusCode == 200
                                                                                    else {
                                                                                        if let resp = resp {
                                                                                            if let errorCode = resp["ErrorCode"] as? Int {
                                                                                                if errorCode == 0x7779 {
                                                                                                    self.error = .CannotAddYourself
                                                                                                    return
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        
                                                                                        self.error = .ErrorSendingFriendRequest
                                                                                        return
                                                                                    }
                                                                                    
                                                                                    self.accountInfo.friendRequests[value.key] = self.defaultUsers[value.key]
                                                                                }
                                                                            }) {
                                                                                if !self.sendingFriendRequestsTo.contains(value.key) {
                                                                                    HStack {
                                                                                        Image(systemName: "plus")
                                                                                            .resizable()
                                                                                            .frame(width: 12, height: 12)
                                                                                            .foregroundStyle(.black)
                                                                                        
                                                                                        Text("Add")
                                                                                            .frame(alignment: .center)
                                                                                            .font(.system(size: 16, weight: .medium))
                                                                                            .foregroundStyle(.black)
                                                                                    }
                                                                                    .padding(4)
                                                                                    //.padding([.top, .bottom], 2)
                                                                                    .padding([.leading, .trailing], 12)
                                                                                    .background(Color.EZNotesBlue)
                                                                                    .cornerRadius(15)
                                                                                    .padding(.trailing, 10)
                                                                                } else {
                                                                                    LoadingView(message: "")
                                                                                }
                                                                            }
                                                                        } else {
                                                                            if self.accountInfo.friendRequests.keys.contains(value.key) {
                                                                                HStack {
                                                                                    Image(systemName: "paperplane")
                                                                                        .resizable()
                                                                                        .frame(width: 10, height: 10)
                                                                                        .foregroundStyle(.gray)
                                                                                    
                                                                                    Text("Pending")
                                                                                        .frame(alignment: .center)
                                                                                        .font(.system(size: 14, weight: .medium))
                                                                                        .foregroundStyle(.gray)
                                                                                    
                                                                                    Button(action: {
                                                                                        self.removingFriendRequest = true
                                                                                        
                                                                                        self.usersBeingRemoved.append(value.key)
                                                                                        
                                                                                        RequestAction<RemoveFriendRequest>(parameters: RemoveFriendRequest(
                                                                                            AccountId: self.accountInfo.accountID,
                                                                                            CancelFor: value.key
                                                                                        )).perform(action: cancel_friend_request_req) { statusCode, resp in
                                                                                            self.removingFriendRequest = false
                                                                                            
                                                                                            guard resp != nil && statusCode == 200 else {
                                                                                                return /* TODO: Handle error. */
                                                                                            }
                                                                                            
                                                                                            /* MARK: Ensure that the dictionary is updated with the current manipulation. */
                                                                                            self.accountInfo.friendRequests.removeValue(forKey: value.key)
                                                                                            
                                                                                            //self.usersBeingRemoved.removeAll(where: { $0 == value.key })
                                                                                        }
                                                                                    }) {
                                                                                        Image(systemName: "multiply")
                                                                                            .resizable()
                                                                                            .frame(width: 10, height: 10)
                                                                                            .foregroundStyle(.white)
                                                                                            .padding(8) /* MARK: Ensure the button can be clicked on feasibly. */
                                                                                    }
                                                                                    .buttonStyle(NoLongPressButtonStyle())
                                                                                }
                                                                                .padding([.top, .bottom], 2)
                                                                                .padding([.leading, .trailing], 8)
                                                                                .cornerRadius(15)
                                                                            } else {
                                                                                Button(action: {
                                                                                    RequestAction<RemoveFriendData>(parameters: RemoveFriendData(
                                                                                        AccountId: self.accountInfo.accountID,
                                                                                        ToRemove: value.key
                                                                                    )).perform(action: remove_friend_req) { statusCode, resp in
                                                                                        guard resp != nil && statusCode == 200 else {
                                                                                            return
                                                                                        }
                                                                                        
                                                                                        self.accountInfo.friends.removeValue(forKey: value.key)
                                                                                        
                                                                                        for chat in self.accountInfo.allChats {
                                                                                            if chat.keys.contains(value.key) {
                                                                                                self.accountInfo.allChats.removeAll(where: { $0 == chat })
                                                                                                break
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        self.accountInfo.messages.removeValue(forKey: value.key)
                                                                                        
                                                                                        for chat in self.accountInfo.allChats {
                                                                                            if chat.keys.contains(value.key) {
                                                                                                self.accountInfo.allChats.removeAll(where: { $0 == chat })
                                                                                                break
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        if self.accountInfo.messages.keys.contains(value.key) {
                                                                                            self.accountInfo.messages.removeValue(forKey: value.key)
                                                                                        }
                                                                                    }
                                                                                }) {
                                                                                    HStack {
                                                                                        Image(systemName: "person.badge.minus")
                                                                                            .resizable()
                                                                                            .frame(width: 13.5, height: 13.5)
                                                                                            .foregroundStyle(.black)
                                                                                        
                                                                                        Text("Remove")
                                                                                            .frame(alignment: .center)
                                                                                            .font(.system(size: 16, weight: .medium))
                                                                                            .foregroundStyle(.black)
                                                                                    }
                                                                                    .padding(4)
                                                                                    //.padding([.top, .bottom], 2)
                                                                                    .padding([.leading, .trailing], 12)
                                                                                    .background(Color.EZNotesRed)
                                                                                    .cornerRadius(15)
                                                                                    .padding(.trailing, 10)
                                                                                }
                                                                                .buttonStyle(NoLongPressButtonStyle())
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                .padding(8)
                                                                //.background(Color.EZNotesLightBlack)
                                                                //.cornerRadius(15)
                                                            }
                                                            .buttonStyle(NoLongPressButtonStyle())
                                                            
                                                            if !(index == self.defaultUsers.count - 1) {
                                                                Divider()
                                                                    .background(.white)
                                                                    .frame(height: 0.5)
                                                            }
                                                        }
                                                    } else {
                                                        ForEach(Array(self.usersSearched.enumerated()), id: \.offset) { index, value in
                                                            Button(action: {
                                                                RequestAction<GetUsersAccountIdData>(parameters: GetUsersAccountIdData(
                                                                    Username: value.key
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
                                                                        
                                                                        RequestAction<GetClientsFriendsData>(parameters: GetClientsFriendsData(
                                                                            AccountId: accountId
                                                                        )).perform(action: get_clients_friends_req) { statusCode, resp in
                                                                            guard resp != nil && statusCode == 200 else {
                                                                                return
                                                                            }
                                                                            
                                                                            if let resp = resp {
                                                                                self.usersFriendCount = resp.keys.count
                                                                            }
                                                                        }
                                                                        
                                                                        RequestAction<GetAccountDescriptionData>(parameters: GetAccountDescriptionData(
                                                                            AccountId: accountId
                                                                        )).perform(action: get_account_description_req) { statusCode, resp in
                                                                            guard resp != nil && statusCode == 200 else {
                                                                                self.usersDescrition = "No Description"
                                                                                return
                                                                            }
                                                                            
                                                                            if let resp = resp {
                                                                                guard
                                                                                    let desc = resp["AccountDescription"] as? String,
                                                                                    desc != ""
                                                                                else {
                                                                                    self.usersDescrition = "No Description"
                                                                                    return
                                                                                }
                                                                                
                                                                                self.usersDescrition = desc
                                                                            } else {
                                                                                self.usersDescrition = "No Description"
                                                                            }
                                                                        }
                                                                        
                                                                        RequestAction<GetTagsData>(parameters: GetTagsData(
                                                                            AccountId: accountId
                                                                        )).perform(action: get_tags_req) { statusCode, resp in
                                                                            guard resp != nil && statusCode == 200 else {
                                                                                return
                                                                            }
                                                                            
                                                                            if let resp = resp as? [String: Array<String>] {
                                                                                guard resp.keys.contains("Tags") else { return }
                                                                                
                                                                                self.usersTags = resp["Tags"]!
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                self.launchUserPreview = true
                                                                self.usersPfp = self.usersSearched[value.key]!
                                                                self.launchedForUser = value.key
                                                                
                                                                /* MARK: Make keyboard go away, if it's active. */
                                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                            }) {
                                                                HStack {
                                                                    ZStack {
                                                                        Circle()
                                                                            .fill(Color.EZNotesBlue)
                                                                        
                                                                        /*Image(systemName: "person.crop.circle.fill")*/
                                                                        self.usersSearched[value.key]!
                                                                            .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                                            .scaledToFill()
                                                                            .frame(maxWidth: 35, maxHeight: 35)
                                                                            .clipShape(.circle)
                                                                            .foregroundStyle(.white)
                                                                    }
                                                                    .frame(width: 38, height: 38)
                                                                    //.padding([.leading], 10)
                                                                    
                                                                    Text(value.key)
                                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                                        .foregroundStyle(.white)
                                                                    
                                                                    if !self.accountInfo.friends.keys.contains(value.key) {
                                                                        if !self.accountInfo.friendRequests.keys.contains(value.key) {
                                                                            Button(action: {
                                                                                self.sendingFriendRequestsTo.append(value.key)
                                                                                self.addingFriend = true
                                                                                
                                                                                RequestAction<SendFriendRequestData>(parameters: SendFriendRequestData(
                                                                                    AccountId: self.accountInfo.accountID,
                                                                                    Username: self.accountInfo.username,
                                                                                    RequestTo: value.key
                                                                                )).perform(action: send_friend_request_req) { statusCode, resp in
                                                                                    self.addingFriend = false
                                                                                    self.sendingFriendRequestsTo.removeAll(where: { $0 == value.key })
                                                                                    
                                                                                    guard
                                                                                        resp != nil,
                                                                                        statusCode == 200
                                                                                    else {
                                                                                        if let resp = resp {
                                                                                            if let errorCode = resp["ErrorCode"] as? Int {
                                                                                                if errorCode == 0x7779 {
                                                                                                    self.error = .CannotAddYourself
                                                                                                    return
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        self.error = .ErrorSendingFriendRequest
                                                                                        return
                                                                                    }
                                                                                    
                                                                                    self.accountInfo.friendRequests[value.key] = self.usersSearched[value.key]//.append(value.key)
                                                                                }
                                                                            }) {
                                                                                if !self.sendingFriendRequestsTo.contains(value.key) {
                                                                                    HStack {
                                                                                        Image(systemName: "plus")
                                                                                            .resizable()
                                                                                            .frame(width: 10, height: 10)
                                                                                            .foregroundStyle(.black)
                                                                                        
                                                                                        Text("Add")
                                                                                            .frame(alignment: .center)
                                                                                            .font(.system(size: 16, weight: .medium))
                                                                                            .foregroundStyle(.black)
                                                                                    }
                                                                                    .padding(4)
                                                                                    //.padding([.top, .bottom], 2)
                                                                                    .padding([.leading, .trailing], 12)
                                                                                    .background(Color.EZNotesBlue)
                                                                                    .cornerRadius(15)
                                                                                    .padding(.trailing, 10)
                                                                                } else {
                                                                                    LoadingView(message: "")
                                                                                }
                                                                            }
                                                                        } else {
                                                                            if self.accountInfo.friendRequests.keys.contains(value.key) {
                                                                                HStack {
                                                                                    Image(systemName: "paperplane")
                                                                                        .resizable()
                                                                                        .frame(width: 10, height: 10)
                                                                                        .foregroundStyle(.gray)
                                                                                    
                                                                                    Text("Pending")
                                                                                        .frame(alignment: .center)
                                                                                        .font(.system(size: 14, weight: .medium))
                                                                                        .foregroundStyle(.gray)
                                                                                    
                                                                                    Button(action: {
                                                                                        self.removingFriendRequest = true
                                                                                        
                                                                                        self.usersBeingRemoved.append(value.key)
                                                                                        
                                                                                        RequestAction<RemoveFriendRequest>(parameters: RemoveFriendRequest(
                                                                                            AccountId: self.accountInfo.accountID,
                                                                                            CancelFor: value.key
                                                                                        )).perform(action: cancel_friend_request_req) { statusCode, resp in
                                                                                            self.removingFriendRequest = false
                                                                                            
                                                                                            guard resp != nil && statusCode == 200 else {
                                                                                                return /* TODO: Handle error. */
                                                                                            }
                                                                                            
                                                                                            /* MARK: Ensure that the dictionary is updated with the current manipulation. */
                                                                                            self.accountInfo.friendRequests.removeValue(forKey: value.key)
                                                                                            
                                                                                            //self.usersBeingRemoved.removeAll(where: { $0 == value.key })
                                                                                        }
                                                                                    }) {
                                                                                        Image(systemName: "multiply")
                                                                                            .resizable()
                                                                                            .frame(width: 10, height: 10)
                                                                                            .foregroundStyle(.white)
                                                                                            .padding(8) /* MARK: Ensure the button can be clicked on feasibly. */
                                                                                    }
                                                                                    .buttonStyle(NoLongPressButtonStyle())
                                                                                }
                                                                                .padding([.top, .bottom], 2)
                                                                                .padding([.leading, .trailing], 8)
                                                                                .cornerRadius(15)
                                                                            } else {
                                                                                HStack {
                                                                                    Image(systemName: "person.badge.minus")
                                                                                        .resizable()
                                                                                        .frame(width: 13.5, height: 13.5)
                                                                                        .foregroundStyle(.black)
                                                                                    
                                                                                    Text("Remove")
                                                                                        .frame(alignment: .center)
                                                                                        .font(.system(size: 16, weight: .medium))
                                                                                        .foregroundStyle(.black)
                                                                                }
                                                                                .padding(4)
                                                                                //.padding([.top, .bottom], 2)
                                                                                .padding([.leading, .trailing], 12)
                                                                                .background(Color.EZNotesRed)
                                                                                .cornerRadius(15)
                                                                                .padding(.trailing, 10)
                                                                            }
                                                                        }
                                                                    } else {
                                                                        Button(action: {
                                                                            RequestAction<RemoveFriendData>(parameters: RemoveFriendData(
                                                                                AccountId: self.accountInfo.accountID,
                                                                                ToRemove: value.key
                                                                            )).perform(action: remove_friend_req) { statusCode, resp in
                                                                                guard resp != nil && statusCode == 200 else {
                                                                                    return
                                                                                }
                                                                                
                                                                                self.accountInfo.friends.removeValue(forKey: value.key)
                                                                                
                                                                                for chat in self.accountInfo.allChats {
                                                                                    if chat.keys.contains(value.key) {
                                                                                        self.accountInfo.allChats.removeAll(where: { $0 == chat })
                                                                                        break
                                                                                    }
                                                                                }
                                                                                
                                                                                if self.accountInfo.messages.keys.contains(value.key) {
                                                                                    self.accountInfo.messages.removeValue(forKey: value.key)
                                                                                }
                                                                            }
                                                                        }) {
                                                                            HStack {
                                                                                Image(systemName: "person.badge.minus")
                                                                                    .resizable()
                                                                                    .frame(width: 13.5, height: 13.5)
                                                                                    .foregroundStyle(.black)
                                                                                
                                                                                Text("Remove")
                                                                                    .frame(alignment: .center)
                                                                                    .font(.system(size: 16, weight: .medium))
                                                                                    .foregroundStyle(.black)
                                                                            }
                                                                            .padding(4)
                                                                            //.padding([.top, .bottom], 2)
                                                                            .padding([.leading, .trailing], 12)
                                                                            .background(Color.EZNotesRed)
                                                                            .cornerRadius(15)
                                                                            .padding(.trailing, 10)
                                                                        }
                                                                        .buttonStyle(NoLongPressButtonStyle())
                                                                    }
                                                                }
                                                                .padding(8)
                                                                //.background(Color.EZNotesLightBlack)
                                                                //.cornerRadius(15)
                                                            }
                                                            .buttonStyle(NoLongPressButtonStyle())
                                                            
                                                            if !(index == self.usersSearched.count - 1) {
                                                                Divider()
                                                                    .background(.white)
                                                                    .frame(height: 0.5)
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.EZNotesLightBlack.opacity(0.4))//(Color.EZNotesBlack.opacity(0.6))
                                                )
                                                .cornerRadius(15)
                                                .padding(.top, 10)
                                                .padding(.bottom, 30) /* MARK: Ensure space between bottom of screen and content at end of scrollview. */
                                            }
                                            .frame(maxWidth: prop.size.width - 20, maxHeight: .infinity)
                                        } else {
                                            LoadingView(message: "")
                                        }
                                    } else {
                                        if self.noUsersToShow {
                                            Text("Something Went Wrong :(")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .minimumScaleFactor(0.5)
                                        } else {
                                            Text("No results for: **\(self.userSearched)**")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-Regular", size: 16))
                                                .minimumScaleFactor(0.5)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                self.loadingView = true
                                self.performingSearch = false
                                
                                self.noUsersToShow = false
                                self.noSearchResults = false
                                
                                self.defaultUsers.removeAll()
                                //self.defaultUsersPendingRequests.removeAll()
                                //self.defaultUsersFriends.removeAll()
                                
                                self.getUsers()
                            }
                        case "friends":
                            VStack {
                                if self.accountInfo.friends.isEmpty {
                                        Text("No Friends")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                } else {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ForEach(Array(self.accountInfo.friends.enumerated()), id: \.offset) { index, value in
                                            HStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.EZNotesBlue)
                                                    
                                                    /*Image(systemName: "person.crop.circle.fill")*/
                                                    self.accountInfo.friends[value.key]!
                                                        .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                        .scaledToFill()
                                                        .frame(maxWidth: 35, maxHeight: 35)
                                                        .clipShape(.circle)
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(width: 38, height: 38)
                                                .padding([.leading], 10)
                                                
                                                Text(value.key)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                    .foregroundStyle(.white)
                                                
                                                Button(action: {
                                                    RequestAction<RemoveFriendData>(parameters: RemoveFriendData(
                                                        AccountId: self.accountInfo.accountID,
                                                        ToRemove: value.key
                                                    )).perform(action: remove_friend_req) { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            return
                                                        }
                                                        
                                                        self.accountInfo.friends.removeValue(forKey: value.key)
                                                        
                                                        for chat in self.accountInfo.allChats {
                                                            if chat.keys.contains(value.key) {
                                                                self.accountInfo.allChats.removeAll(where: { $0 == chat })
                                                                break
                                                            }
                                                        }
                                                        
                                                        if self.accountInfo.messages.keys.contains(value.key) {
                                                            self.accountInfo.messages.removeValue(forKey: value.key)
                                                        }
                                                    }
                                                }) {
                                                    HStack {
                                                        Image(systemName: "person.badge.minus")
                                                            .resizable()
                                                            .frame(width: 13.5, height: 13.5)
                                                            .foregroundStyle(.black)
                                                        
                                                        Text("Remove")
                                                            .frame(alignment: .center)
                                                            .font(.system(size: 16, weight: .medium))
                                                            .foregroundStyle(.black)
                                                    }
                                                    .padding(4)
                                                    //.padding([.top, .bottom], 2)
                                                    .padding([.leading, .trailing], 12)
                                                    .background(Color.EZNotesRed)
                                                    .cornerRadius(15)
                                                    .padding(.trailing, 10)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case "requests":
                            VStack {
                                if !self.noUsersToShow {
                                    if self.loadingView {
                                        LoadingView(message: "Loading requests")
                                    } else {
                                        ScrollView(.vertical, showsIndicators: false) {
                                            ForEach(Array(self.accountInfo.friendRequests.enumerated()), id: \.offset) { index, value in
                                                if !self.usersBeingRemoved.contains(value.key) {
                                                    HStack {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color.EZNotesBlue)
                                                            
                                                            /*Image(systemName: "person.crop.circle.fill")*/
                                                            self.accountInfo.friendRequests[value.key]!
                                                                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                                .scaledToFill()
                                                                .frame(maxWidth: 35, maxHeight: 35)
                                                                .clipShape(.circle)
                                                                .foregroundStyle(.white)
                                                        }
                                                        .frame(width: 38, height: 38)
                                                        .padding([.leading], 10)
                                                        
                                                        Text(value.key)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                            .foregroundStyle(.white)
                                                        
                                                        HStack {
                                                            if !self.usersBeingRemoved.contains(value.key) {
                                                                Image(systemName: "paperplane")
                                                                    .resizable()
                                                                    .frame(width: 10, height: 10)
                                                                    .foregroundStyle(.gray)
                                                                
                                                                Text("Pending")
                                                                    .frame(alignment: .center)
                                                                    .font(.system(size: 14, weight: .medium))
                                                                    .foregroundStyle(.gray)
                                                                
                                                                Button(action: {
                                                                    self.removingFriendRequest = true
                                                                    
                                                                    self.usersBeingRemoved.append(value.key)
                                                                    
                                                                    RequestAction<RemoveFriendRequest>(parameters: RemoveFriendRequest(
                                                                        AccountId: self.accountInfo.accountID,
                                                                        CancelFor: value.key
                                                                    )).perform(action: cancel_friend_request_req) { statusCode, resp in
                                                                        self.removingFriendRequest = false
                                                                        
                                                                        guard resp != nil && statusCode == 200 else {
                                                                            return /* TODO: Handle error. */
                                                                        }
                                                                        
                                                                        /* MARK: Ensure that the dictionary is updated with the current manipulation. */
                                                                        //self.accountInfo.friendRequests.removeValue(forKey: value.key)
                                                                    }
                                                                }) {
                                                                    Image(systemName: "multiply")
                                                                        .resizable()
                                                                        .frame(width: 10, height: 10)
                                                                        .foregroundStyle(.white)
                                                                        .padding(8) /* MARK: Ensure the button can be clicked on feasibly. */
                                                                }
                                                                .buttonStyle(NoLongPressButtonStyle())
                                                            } else {
                                                                LoadingView(message: "")
                                                            }
                                                        }
                                                        .padding([.top, .bottom], 2)
                                                        .padding([.leading, .trailing], 8)
                                                        .cornerRadius(15)
                                                    }
                                                    .padding(8)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Text("Nothing to see here")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            /*.onAppear {
                                self.accountInfo.friendRequests.removeAll()
                                
                                if self.noUsersToShow { self.noUsersToShow = false }
                                
                                self.loadingView = true
                                RequestAction<GetClientsFriendRequestsData>(parameters: GetClientsFriendRequestsData(
                                    AccountId: self.accountInfo.accountID
                                )).perform(action: get_clients_friend_requests_req) { statusCode, resp in
                                    self.loadingView = false
                                    
                                    guard resp != nil && statusCode == 200 else {
                                        self.noUsersToShow = true
                                        return
                                    }
                                    
                                    if let resp = resp {
                                        /* MARK: `CFR` - Clients Friend Requests. */
                                        guard
                                            let CFR = ResponseHelper(
                                                endingAction: self.endignAction,
                                                returnNilAction: self.returnNilAction
                                            ).populateUsers(resp: resp)
                                        else {
                                            //self.noUsersToShow = true
                                            return
                                        }
                                        
                                        self.accountInfo.friendRequests = CFR
                                    } else {
                                        self.noUsersToShow = true
                                    }
                                }
                                /* MARK: Reset all error states/user data states. */
                                /*self.usersSearched.removeAll()
                                self.noUsersToShow = false
                                self.noSearchResults = false
                                
                                if self.pendingRequests.isEmpty { self.noUsersToShow = true; return }
                                
                                self.loadingView = true
                                for user in self.pendingRequests {
                                    RequestAction<SearchUserData>(parameters: SearchUserData(
                                        AccountId: self.accountInfo.accountID,
                                        Filter: "",
                                        Usages: "",
                                        Query: user
                                    )).perform(action: search_user_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            self.usersSearched[user] = Image(systemName: "person.crop.circle.fill")
                                            if user == self.pendingRequests.last { self.loadingView = false }
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
                                            self.noUsersToShow = true
                                        }
                                        
                                        if user == self.pendingRequests.last { self.loadingView = false }
                                    }
                                }*/
                                //self.noUsersToShow = true
                            }*/
                        case "pending":
                            ZStack {
                                if self.error == .ErrorAcceptingFriendRequest {
                                    VStack {
                                        Spacer()
                                        
                                        HStack {
                                            Text(self.error == .ErrorAcceptingFriendRequest
                                                 ? "Failed to accept friend request. Try again"
                                                 : "Something went wrong. Try again")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(Color.EZNotesRed)
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen ? 18 : 16,
                                                    weight: .medium
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                            .padding(.leading, 10)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.black)//(Color.EZNotesLightBlack.opacity(0.7))
                                                .shadow(color: Color.EZNotesLightBlack, radius: 12.5)//.stroke(Color.white, lineWidth: 1)
                                        )
                                        .padding(4) /* MARK: Ensure there are "bright" spots to the shadow applie to the above `RoundedRectangle`. */
                                        //.clipShape(RoundedRectangle(cornerRadius: 15))
                                        .padding(.horizontal)
                                        .offset(y: self.errorPopupYOffset)
                                        .animation(.easeIn(duration: 3), value: self.errorPopupYOffset)
                                    }
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                            //withAnimation(.easeIn(duration: 3)) {
                                                self.errorPopupYOffset = prop.size.height // Animate to desired position
                                            //}
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                self.error = .None
                                                self.errorPopupYOffset = 0
                                            }
                                        }
                                    }
                                }
                                
                                VStack {
                                    if !self.accountInfo.pendingRequests.isEmpty {
                                        ScrollView(.vertical, showsIndicators: false) {
                                            ForEach(Array(self.accountInfo.pendingRequests.enumerated()), id: \.offset) { index, value in
                                                if !self.accountInfo.friends.keys.contains(value.key) { /* MARK: Precautionary check to ensure we don't show a pending user after they are accepted. */
                                                    HStack {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color.EZNotesBlue)
                                                            
                                                            /*Image(systemName: "person.crop.circle.fill")*/
                                                            self.accountInfo.pendingRequests[value.key]!
                                                                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                                .scaledToFill()
                                                                .frame(maxWidth: 35, maxHeight: 35)
                                                                .clipShape(.circle)
                                                                .foregroundStyle(.white)
                                                        }
                                                        .frame(width: 38, height: 38)
                                                        .padding([.leading], 10)
                                                        
                                                        Text(value.key)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                            .foregroundStyle(.white)
                                                        
                                                        Button(action: {
                                                            self.acceptingFriendRequest = true
                                                            self.usersBeingAccepted.append(value.key)
                                                            
                                                            RequestAction<AcceptFriendRequestData>(parameters: AcceptFriendRequestData(
                                                                AccountId: self.accountInfo.accountID,
                                                                AcceptFrom: value.key
                                                            )).perform(action: accept_friend_request_req) { statusCode, resp in
                                                                self.usersBeingAccepted.removeAll(where: { $0 == value.key })
                                                                self.acceptingFriendRequest = false
                                                                
                                                                guard resp != nil && statusCode == 200 else {
                                                                    self.error = .ErrorAcceptingFriendRequest
                                                                    //self.accountInfo.friends[value.key] = Image(systemName: "person.crop.circle.fill")
                                                                    return /* TODO: Handle errors. */
                                                                }
                                                                
                                                                self.accountInfo.pendingRequests.removeValue(forKey: value.key)
                                                                
                                                                if let resp = resp {
                                                                    guard
                                                                        let f = ResponseHelper().populateUsers(resp: resp)
                                                                    else {
                                                                        self.accountInfo.friends[value.key] = Image(systemName: "person.crop.circle.fill")
                                                                        return
                                                                    }
                                                                    
                                                                    self.accountInfo.friends[value.key] = f[value.key]
                                                                }
                                                            }
                                                        }) {
                                                            if self.acceptingFriendRequest && self.usersBeingAccepted.contains(value.key) {
                                                                LoadingView(message: "")
                                                            } else {
                                                                HStack {
                                                                    Text("Accept")
                                                                        .frame(alignment: .center)
                                                                        .font(.system(size: 16, weight: .medium))
                                                                        .foregroundStyle(.black)
                                                                }
                                                                .padding(4) /* MARK: Add a bit more padding. I don't know why, but it looks off compared to the "+ Add". */
                                                                //.padding([.top, .bottom], 2)
                                                                .padding([.leading, .trailing], 12)
                                                                .background(Color.EZNotesBlue)
                                                                .cornerRadius(15)
                                                                .padding(.trailing, 10)
                                                            }
                                                        }
                                                        .buttonStyle(NoLongPressButtonStyle())
                                                    }
                                                    .padding(8)
                                                }
                                            }
                                        }
                                    } else {
                                        Text("Nothing to see here")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 16))
                                            .minimumScaleFactor(0.5)
                                    }
                                    /*if !self.loadingView {
                                     if !self.noUsersToShow {
                                     ScrollView(.vertical, showsIndicators: false) {
                                     ForEach(Array(self.clientsPendingRequests.enumerated()), id: \.offset) { index, value in
                                     HStack {
                                     ZStack {
                                     Circle()
                                     .fill(Color.EZNotesBlue)
                                     
                                     /*Image(systemName: "person.crop.circle.fill")*/
                                     self.clientsPendingRequests[value.key]!
                                     .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                     .scaledToFill()
                                     .frame(maxWidth: 35, maxHeight: 35)
                                     .clipShape(.circle)
                                     .foregroundStyle(.white)
                                     }
                                     .frame(width: 38, height: 38)
                                     .padding([.leading], 10)
                                     
                                     Text(value.key)
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                     .foregroundStyle(.white)
                                     
                                     Button(action: {
                                     self.acceptingFriendRequest = true
                                     self.usersBeingAccepted.append(value.key)
                                     
                                     RequestAction<AcceptFriendRequestData>(parameters: AcceptFriendRequestData(
                                     AccountId: self.accountInfo.accountID,
                                     AcceptFrom: value.key
                                     )).perform(action: accept_friend_request_req) { statusCode, resp in
                                     guard resp != nil && statusCode == 200 else {
                                     //self.accountInfo.friends[value.key] = Image(systemName: "person.crop.circle.fill")
                                     return /* TODO: Handle errors. */
                                     }
                                     
                                     self.clientsPendingRequests.removeValue(forKey: value.key)
                                     
                                     if let resp = resp {
                                     guard let f = ResponseHelper.populateUsers(resp: resp) else {
                                     self.accountInfo.friends[value.key] = Image(systemName: "person.crop.circle.fill")
                                     return
                                     }
                                     
                                     self.accountInfo.friends[value.key] = f[value.key]
                                     }
                                     }
                                     }) {
                                     if self.acceptingFriendRequest && self.usersBeingAccepted.contains(value.key) {
                                     LoadingView(message: "")
                                     } else {
                                     HStack {
                                     Text("Accept")
                                     .frame(alignment: .center)
                                     .font(.system(size: 14, weight: .medium))
                                     .foregroundStyle(.black)
                                     }
                                     .padding([.top, .bottom], 4) /* MARK: Add a bit more padding. I don't know why, but it looks off compared to the "+ Add". */
                                     .padding([.leading, .trailing], 8)
                                     .background(Color.EZNotesBlue)
                                     .cornerRadius(15)
                                     .padding(.trailing, 10)
                                     }
                                     }
                                     .buttonStyle(NoLongPressButtonStyle())
                                     }
                                     .padding(8)
                                     }
                                     }
                                     } else {
                                     Text("Nothing to see here")
                                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                     .foregroundStyle(.white)
                                     .font(Font.custom("Poppins-Regular", size: 16))
                                     .minimumScaleFactor(0.5)
                                     }
                                     } else {
                                     LoadingView(message: "Loading pending requests...")
                                     }*/
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            /*.onAppear {
                                self.accountInfo.pendingRequests.removeAll()
                                
                                self.noUsersToShow = false
                                self.noSearchResults = false
                                
                                self.loadingView = true
                                
                                RequestAction<GetClientsPendingRequestsData>(parameters: GetClientsPendingRequestsData(
                                    AccountId: self.accountInfo.accountID
                                )).perform(action: get_clients_pending_requests_req) { statusCode, resp in
                                    guard resp != nil && statusCode == 200 else {
                                        self.loadingView = false
                                        
                                        self.noUsersToShow = true
                                        return
                                    }
                                    
                                    if let resp = resp {
                                        /* MARK: `CPR` - Clients Pending Requests. */
                                        guard let CPR = ResponseHelper.populateUsers(resp: resp) else {
                                            self.loadingView = false
                                            
                                            self.noUsersToShow = true
                                            return
                                        }
                                        
                                        self.accountInfo.pendingRequests = CPR
                                    } else {
                                        self.noUsersToShow = true
                                    }
                                    
                                    self.loadingView = false
                                }
                            }*/
                        default:
                            VStack { }.onAppear { self.selectedView = "add" }
                        }
                    } else {
                        HStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.white)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            /*Text("Search Filters:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                                .padding(.top)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)*/
                            
                            HStack {
                                Text("Filter")
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 16))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text("Description")
                                    .frame(maxWidth: prop.size.width / 2.2, alignment: .leading)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 16))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: prop.size.width - 30)
                            .padding(.top) /* MARK: Ensure space between divider before scrollview and content in the scrollview. */
                            
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {//[GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                                VStack {
                                    HStack {
                                        Toggle(isOn: $showAnyUser) {
                                            Text("Show Any")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .toggleStyle(CheckBox())
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .onChange(of: self.showAnyUser) {
                                            
                                            if !self.showUsersFromSameCollege
                                                && !self.showUsersWithSameMajor
                                                && !self.showUsersFromSameState
                                                && !self.showUsersWithSchoolUsageOnly
                                                && !self.showUsersWithWorkUsageOnly
                                                && !self.showUsersWithGeneralUsageOnly { self.showAnyUser = true }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(self.accountInfo.usage == "school"
                                             ? "Show users regardless their state, college, or major."
                                             : "Show any user, regardless their usage of the app or career.")
                                            .frame(maxWidth: prop.size.width / 2.2, alignment: .center)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    if self.accountInfo.usage == "school" {
                                        HStack {
                                            Toggle(isOn: $showUsersFromSameState) {
                                                Text("Same State")
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .toggleStyle(CheckBox())
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .onChange(of: self.showUsersFromSameState) { /* MARK: If another filter gets toggled on, ensure `showAny` is off. */
                                                if self.showUsersFromSameState { self.showAnyUser = false; return }
                                                
                                                /* MARK: We can assume that upon the below if statement being reached, the above filter is not set. If the below filter is toggled off as well, force `showAnyUser` to be on. */
                                                if !self.showUsersFromSameCollege
                                                    && !self.showUsersWithSameMajor
                                                    && !self.showUsersWithSchoolUsageOnly
                                                    && !self.showUsersWithWorkUsageOnly
                                                    && !self.showUsersWithGeneralUsageOnly { self.showAnyUser = true }
                                            }
                                            Spacer()
                                            
                                            Text("Show users who reside in the same state as you.")
                                                .frame(maxWidth: prop.size.width / 2.3, alignment: .center)
                                                .padding(.leading, 10)
                                                .font(Font.custom("Poppins-Regular", size: 12))
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(.bottom, 8)
                                        
                                        HStack {
                                            Toggle(isOn: $showUsersFromSameCollege) {
                                                Text("Same College")
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .toggleStyle(CheckBox())
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .onChange(of: self.showUsersFromSameCollege) { /* MARK: If another filter gets toggled on, ensure `showAny` is off. */
                                                if self.showUsersFromSameCollege { self.showAnyUser = false; return }
                                                
                                                /* MARK: We can assume that upon the below if statement being reached, the above filter is not set. If the below filter is toggled off as well, force `showAnyUser` to be on. */
                                                if !self.showUsersFromSameState
                                                    && !self.showUsersWithSameMajor
                                                    && !self.showUsersWithSchoolUsageOnly
                                                    && !self.showUsersWithWorkUsageOnly
                                                    && !self.showUsersWithGeneralUsageOnly { self.showAnyUser = true }
                                            }
                                            
                                            Spacer()
                                            
                                            Text("Show users who attend the same college as you.")
                                                .frame(maxWidth: prop.size.width / 2.2, alignment: .center)
                                                .font(Font.custom("Poppins-Regular", size: 12))
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(.bottom, 8)
                                    }
                                    
                                    HStack {
                                        Toggle(isOn: $showUsersWithSchoolUsageOnly) {
                                            Text("School Usage Only")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .toggleStyle(CheckBox())
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .onChange(of: self.showUsersWithSchoolUsageOnly) {
                                            if self.showUsersWithSchoolUsageOnly { self.showAnyUser = false; return }
                                            
                                            /* MARK: We can assume that upon the below if statement being reached, the above filter is not set. If the below filter is toggled off as well, force `showAnyUser` to be on. */
                                            if !self.showUsersFromSameState
                                                && !self.showUsersFromSameCollege
                                                && !self.showUsersWithSameMajor
                                                && !self.showUsersWithWorkUsageOnly
                                                && !self.showUsersWithGeneralUsageOnly { self.showAnyUser = true }
                                        }
                                        
                                        Spacer()
                                        
                                        Text("Show users that use the app for **school** purposes.")
                                            .frame(maxWidth: prop.size.width / 2.35, alignment: .leading)
                                            //.padding(.leading, 20)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    HStack {
                                        Toggle(isOn: $showUsersWithWorkUsageOnly) {
                                            Text("Work Usage Only")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .toggleStyle(CheckBox())
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .onChange(of: self.showUsersWithWorkUsageOnly) {
                                            if self.showUsersWithWorkUsageOnly { self.showAnyUser = false; return }
                                            
                                            /* MARK: We can assume that upon the below if statement being reached, the above filter is not set. If the below filter is toggled off as well, force `showAnyUser` to be on. */
                                            if !self.showUsersFromSameState
                                                && !self.showUsersFromSameCollege
                                                && !self.showUsersWithSameMajor
                                                && !self.showUsersWithSchoolUsageOnly
                                                && !self.showUsersWithGeneralUsageOnly { self.showAnyUser = true }
                                        }
                                        
                                        Spacer()
                                        
                                        Text("Show users that use the app for **work** purposes.")
                                            .frame(maxWidth: prop.size.width / 2.35, alignment: .leading)
                                            //.padding(.leading, 20)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    HStack {
                                        Toggle(isOn: $showUsersWithGeneralUsageOnly) {
                                            Text("General Usage Only")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .toggleStyle(CheckBox())
                                        .foregroundStyle(Color.EZNotesBlue)
                                        .onChange(of: self.showUsersWithGeneralUsageOnly) {
                                            if self.showUsersWithGeneralUsageOnly { self.showAnyUser = false; return }
                                            
                                            /* MARK: We can assume that upon the below if statement being reached, the above filter is not set. If the below filter is toggled off as well, force `showAnyUser` to be on. */
                                            if !self.showUsersFromSameState
                                                && !self.showUsersFromSameCollege
                                                && !self.showUsersWithSameMajor
                                                && !self.showUsersWithSchoolUsageOnly
                                                && !self.showUsersWithWorkUsageOnly { self.showAnyUser = true }
                                        }
                                        
                                        Spacer()
                                        
                                        Text("Show users that use the app for **general** purposes.")
                                            .frame(maxWidth: prop.size.width / 2.35, alignment: .leading)
                                            //.padding(.leading, 20)
                                            .font(Font.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.bottom, 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .padding(.trailing, 10)
                            
                            Divider()
                                .background(.gray)
                                .frame(width: prop.size.width - 40)
                                .padding([.top, .bottom])
                            
                            Text("Filter Results:")
                                .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                                .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 16))
                                .foregroundStyle(.white)
                            
                            HStack {
                                Text("Number Of Results")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(Font.custom("Poppins-SemiBold", size: 14))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(1...50, id: \.self) { resultNumber in
                                        Button(action: { self.numberOfResults = resultNumber }) { Text("\(resultNumber)") }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(Int(self.numberOfResults))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 14))
                                            .padding(.leading, 10)
                                        
                                        VStack {
                                            Image(systemName: "arrowtriangle.up")
                                                .resizable()
                                                .frame(width: 5.5, height: 5.5)
                                                .foregroundStyle(.white)
                                                .padding(.bottom, -5)
                                            
                                            Image(systemName: "arrowtriangle.down")
                                                .resizable()
                                                .frame(width: 5.5, height: 5.5)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    //.frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 2)
                                    .background(Color.EZNotesLightBlack)
                                    .cornerRadius(15)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            HStack {
                                Text("Number Of Friends")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(Font.custom("Poppins-SemiBold", size: 14))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(1...200, id: \.self) { resultNumber in
                                        Button(action: { self.usersNumberOfFriends = resultNumber }) { Text("\(resultNumber)") }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(Int(self.usersNumberOfFriends))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 14))
                                            .padding(.leading, 10)
                                        
                                        VStack {
                                            Image(systemName: "arrowtriangle.up")
                                                .resizable()
                                                .frame(width: 5.5, height: 5.5)
                                                .foregroundStyle(.white)
                                                .padding(.bottom, -5)
                                            
                                            Image(systemName: "arrowtriangle.down")
                                                .resizable()
                                                .frame(width: 5.5, height: 5.5)
                                                .foregroundStyle(.white)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    //.frame(maxWidth: .infinity)
                                    .padding([.top, .bottom], 2)
                                    .background(Color.EZNotesLightBlack)
                                    .cornerRadius(15)
                                }
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        }
                        .padding(.top, -6) /* MARK: Make it look like the scrollview scrolls "under" the header. */
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onAppear {
                    self.constantlyUpdateIncomingFriendRequests = true
                    
                    if self.error != .None { self.error = .None }
                    
                    DispatchQueue.global(qos: .background).async {
                        while self.constantlyUpdateIncomingFriendRequests {
                            RequestAction<GetClientsFriendRequestsData>(parameters: GetClientsFriendRequestsData(
                                AccountId: self.accountInfo.accountID
                            )).perform(action: get_clients_friend_requests_req) { statusCode, resp in
                                guard resp != nil && statusCode == 200 else {
                                    DispatchQueue.main.async {
                                        self.accountInfo.friendRequests.removeAll()
                                        self.usersBeingRemoved.removeAll()
                                    }
                                    return
                                }
                                
                                if let resp = resp {
                                    /* MARK: `CFR` - Clients Friend Requests. */
                                    guard var CFR = ResponseHelper().populateUsers(resp: resp) else {
                                        return
                                    }
                                    
                                    for user in self.accountInfo.friendRequests.keys {
                                        if !CFR.keys.contains(user) {
                                            DispatchQueue.main.async {
                                                self.accountInfo.friendRequests.removeValue(forKey: user)
                                            }
                                        }
                                    }
                                    
                                    for user in self.usersBeingRemoved {
                                        if CFR.keys.contains(user) { CFR.removeValue(forKey: user) }
                                        else {
                                            self.usersBeingRemoved.removeAll(where: { $0 == user })
                                        }
                                    }
                                    
                                    for user in CFR.keys {
                                        if !self.accountInfo.friendRequests.keys.contains(user) {
                                            DispatchQueue.main.async {
                                                self.accountInfo.friendRequests[user] = CFR[user]!
                                            }
                                        }
                                    }
                                    
                                    /*if !self.usersBeingRemoved.isEmpty {
                                        for user in self.usersBeingRemoved {
                                            /* MARK: Check to see if `CFR` still has `user`. If it doesn't, remove `user` from `usersBeingRemoved` array. `usersBeingRemoved` array continues to store the user being removed until the server has updated. Updates happen every 1.5 seconds, so users being removed should only exist in the `usersBeingRemoved` array for max 2 seconds. */
                                            if self.accountInfo.friendRequests.keys.contains(user) { continue }
                                            
                                            self.usersBeingRemoved.removeAll(where: { $0 == user })
                                        }
                                    }*/
                                }
                            }
                            
                            RequestAction<GetClientsPendingRequestsData>(parameters: GetClientsPendingRequestsData(
                                AccountId: self.accountInfo.accountID
                            )).perform(action: get_clients_pending_requests_req) { statusCode, resp in
                                guard resp != nil && statusCode == 200 else {
                                    guard
                                        let resp = resp,
                                        resp.keys.contains("ErrorCode")
                                    else { return }
                                    
                                    if resp["ErrorCode"] as! Int == 0x2238 { /* MARK: If `0x2238` is the error code, that means there are no pending requests. If that is the case, clear out `pendingRequests`. */
                                        self.accountInfo.pendingRequests.removeAll()
                                    }
                                    
                                    return
                                }
                                
                                if let resp = resp {
                                    /* MARK: `CPR` - Clients Pending Requests. */
                                    guard let CPR = ResponseHelper().populateUsers(resp: resp) else {
                                        return
                                    }
                                    
                                    /* MARK: Ensure if there is a user in `pendingRequests` that is not in `CPR` that we remove that data. */
                                    for user in self.accountInfo.pendingRequests.keys {
                                        if !CPR.keys.contains(user) {
                                            self.accountInfo.pendingRequests.removeValue(forKey: user)
                                        }
                                    }
                                    
                                    for user in CPR.keys {
                                        if !self.accountInfo.pendingRequests.keys.contains(user) {
                                            DispatchQueue.main.async { self.accountInfo.pendingRequests[user] = CPR[user]! }
                                        }
                                    }
                                }
                            }
                            
                            /* MARK: Every 1.5 seconds, send a new request to the server seeing if there are any new incoming friend requests for the user. This timeout aligns with the one in `ChatView.swift`. */
                            Thread.sleep(forTimeInterval: 1.5)
                        }
                    }
                }
                .onDisappear {
                    self.constantlyUpdateIncomingFriendRequests = false
                }
                /*.onAppear {
                    if self.accountInfo.friends.isEmpty {
                        DispatchQueue.global(qos: .background).async {
                            RequestAction<GetClientsFriendsData>(parameters: GetClientsFriendsData(
                                AccountId: self.accountInfo.accountID
                            )).perform(action: get_clients_friends_req) { statusCode, resp in
                                guard resp != nil && statusCode == 200 else {
                                    return
                                }
                                
                                if let resp = resp {
                                    guard let clientsFriends = ResponseHelper.populateUsers(resp: resp) else {
                                        return
                                    }
                                    
                                    self.accountInfo.friends = clientsFriends
                                }
                            }
                        }
                    }
                }*/
                .popover(isPresented: $rickRoll) {
                    /*WebView(url: URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0")!)
                     .navigationBarTitle("Get Rick Rolled, Boi", displayMode: .inline)*/
                    YouTubeVideoView() // Replace with your YouTube video ID
                        .frame(maxWidth: .infinity, maxHeight: .infinity)//: 300) // Set height for the video player
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .topNavSettings(prop: prop, backgroundColor: .clear)
        .padding([.top], 5)
    }
}
