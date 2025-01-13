//
//  ChatView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI
import Combine

/* MARK: The below class handles the showing of when the message was sent. */
class MessageSentHandler: ObservableObject {
    private var timer: AnyCancellable?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.cancel()
    }
    
    public final func stopTimer() { timer?.cancel() }
    public final func startTimer() {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send() // Trigger UI updates every minute
            }
    }
    
    public final func relativeTime(for message: FriendMessageDetails) -> String {
        let now = Date()
        let interval = Int(now.timeIntervalSince(message.dateSent))
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(interval / 60) min ago"
        } else if interval < 86400 {
            return "\(interval / 3600) hr ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: message.dateSent)
        }
    }
}

struct ChatView: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var messageSentHandler: MessageSentHandler = MessageSentHandler()
    
    @State private var friendSearch: String = ""
    
    @Binding public var section: String
    
    //var prop: Properties
    
    //@ObservedObject public var accountInfo: AccountDetails
    
    @Binding public var userHasSignedIn: Bool
    
    @State private var showAccount: Bool = false
    @State private var newChatPopup: Bool = false
    @State private var newChatSearch: String = ""
    @State private var newChatSearchResults: [String: Image] = [:]
    @State private var showAllClientsFriends: Bool = true /* MARK: If `newChatSearch` is empty, this will be true. */
    @State private var chatSearchResults: [String: Image] = [:] /* MARK: The dictionary will get mutated depending on the friends that are found in `accountInfo.friends`. */
    @State private var chatSelected: Bool = false
    @State private var chattingWith: String = "" /* MARK: Gets set if the user clicks on an existing chat, or if they start a chat. */
    @State private var usersBeingChattedWithPfp: Image = Image(systemName: "person.crop.circle.fill")
    @State private var chatMessages: Array<FriendMessageDetails> = [] /* MARK: Gets set to the value of the clients message history with the given user upon an existing chat being tapped or a new chat being started (if it's a new chat, the array will stay empty until a new message is sent. */
    @State private var messageInput: String = ""
    
    /* MARK: State needed to ensure the textfield for sending messages is not hidden by the keyboard. */
    @State private var keyboardHeight: CGFloat = 0
    
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
    
    @State private var fetchData: Bool = true
    @State private var loadingAllMessages: Bool = false
    @State private var launchUserPreview: Bool = false
    @State private var launchedForUser: String = ""
    @State private var usersPfp: Image = Image(systemName: "person.crop.circle.fill")
    @State private var usersPfpBg: Image = Image("Pfp-Default-Bg")
    @State private var usersDescrition: String = ""
    @State private var usersTags: Array<String> = []
    @State private var usersFriendCount: Int = 0
    @State private var showUserProfilePreview: Bool = false
    
    private func fetchClientsFriendData() -> Void {
        DispatchQueue.global(qos: .background).async { /* TODO: Is the below code being in a background thread needed? I think it just enables a more feasible user experience so for now, keep it. But, nonetheless, figure out if it is really useful or not. */
            while(self.fetchData) {
                /* MARK: We want to consistenly update the outgoing requests for the user. In the case the end user accepts, we want to ensure that the apps data is up to date. */
                RequestAction<GetClientsFriendRequestsData>(parameters: GetClientsFriendRequestsData(
                    AccountId: self.accountInfo.accountID
                )).perform(action: get_clients_friend_requests_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        DispatchQueue.main.async { self.accountInfo.friendRequests.removeAll() }
                        return
                    }
                    
                    if let resp = resp {
                        /* MARK: `CFR` - Clients Friend Requests. */
                        guard let CFR = ResponseHelper().populateUsers(resp: resp) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            /* MARK: Iterate through the users in `CFR`. Make sure `friendRequests` doesn't already contain the user. Only add to `friendRequests` upon there being a new friend request. */
                            for user in CFR.keys {
                                if !self.accountInfo.friendRequests.keys.contains(user) {
                                    self.accountInfo.friendRequests[user] = CFR[user]!
                                }
                            }
                        }
                    }
                }
                
                /* MARK: Ensure the `friends` dictionary is up to day in regards to the updated `friendRequests`. */
                Task {
                    await self.accountInfo.getFriends(accountID: self.accountInfo.accountID) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            return
                        }
                        
                        if let resp = resp as? [String: [String: Any]] {
                            for user in resp.keys {
                                guard resp[user] != nil else { continue }
                                
                                if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                                    if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                                        DispatchQueue.main.async { /* MARK: Needed to ensure `accountInfo` is being used on the main thread.. otherwise it is error prone. */
                                            if !self.accountInfo.friends.keys.contains(user) {
                                                self.accountInfo.friends[user] = Image(
                                                    uiImage: UIImage(
                                                        data: userPFPData
                                                    )!
                                                )
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            if !self.accountInfo.friends.keys.contains(user) {
                                                self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                            }
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        if !self.accountInfo.friends.keys.contains(user) {
                                            self.accountInfo.friends[user] = Image(systemName: "person.crop.circle.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                RequestAction<GetClientsMessagesData>(parameters: GetClientsMessagesData(
                    AccountId: self.accountInfo.accountID
                )).perform(action: get_clients_messages_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        return
                    }
                    
                    if let resp = resp as? [String: Array<[String: String]>] {
                        resp.keys.forEach { user in
                            if !self.accountInfo.friends.keys.contains(user) {
                                for chat in self.accountInfo.allChats {
                                    print(chat)
                                    if chat.keys.contains(user) {
                                        self.accountInfo.allChats.removeAll(where: { $0 == chat })
                                        break
                                    }
                                }
                                
                                self.accountInfo.messages.removeValue(forKey: user)
                            } else {
                                if !self.accountInfo.allChats.contains(where: { $0.first?.key == user }) {
                                    if let friendImage = self.accountInfo.friends[user] {
                                        self.accountInfo.allChats.append([user: friendImage])
                                    } else {
                                        self.accountInfo.allChats.append([user: Image(systemName: "person.crop.circle.fill")])
                                    }
                                }
                                
                                /* MARK: Automatically assume there is no chat history with `user`. */
                                if !self.accountInfo.messages.keys.contains(user) {
                                    self.accountInfo.messages[user] = []
                                }
                                
                                if !resp[user]!.isEmpty {
                                    resp[user]!.forEach { message in
                                        let messageData = FriendMessageDetails(
                                            MessageID: message["MessageID"]!,
                                            ContentType: message["ContentType"]!,
                                            MessageContent: message["MessageContent"]!,
                                            From: message["From"]!,
                                            dateSent: ISO8601DateFormatter().date(from: message["dateSent"]!)!
                                        )
                                        
                                        if !self.accountInfo.messages[user]!.contains(where: { $0 == messageData }) && messageData.From != "client" {
                                            self.accountInfo.messages[user]!.append(messageData)
                                        }
                                    }
                                    
                                    /*if let messageHistoryWithUser = resp[user]! as? Array<FriendMessageDetails> {
                                     print(messageHistoryWithUser)
                                     /*messageHistoryWithUser.forEach { message in
                                      self.accountInfo.messages[user]!.append(message)
                                      }*/
                                     }*/
                                }
                            }
                        }
                    }
                }
                
                Thread.sleep(forTimeInterval: 1.5)
            }
        }
    }
    
    @State private var chatViewX: CGFloat = UIScreen.main.bounds.width
    @State private var chatViewOpacity: CGFloat = 0
    
    var body: some View {
        if !self.showAccount {
            ResponsiveView { prop in
                ZStack {
                    //ZStack {
                    if self.launchUserPreview {
                        VStack {
                            Spacer()
                            
                            VStack {
                                UsersProfile(
                                    prop: prop,
                                    username: self.launchedForUser,
                                    usersPfpBg: self.usersPfpBg,
                                    usersPfp: self.usersPfp,
                                    usersDescription: self.usersDescrition,
                                    usersTags: self.usersTags.isEmpty ? ["No Tags"] : self.usersTags,
                                    usersFriends: self.usersFriendCount,
                                    accountPopupSection: $launchedForUser, /* TODO: Figure something out with this, this is bad. */
                                    showAccount: $launchUserPreview, /* TODO: Figure something out with this, this is bad. */
                                    addMoreTags: $launchUserPreview,
                                    accountViewY: $keyboardHeight,
                                    accountViewOpacity: $keyboardHeight
                                )
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            .onTapGesture {
                                return /* MARK: Capture tap events on the above `VStack` to override `.onTapGesture` over the overarching `VStack`. If this doesn't exist, the overarching `.onTapGesture` will close out the view. */
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesBlack)
                                    .shadow(color: /*Color.EZNotesLightBlack*/Color.white, radius: 2.5)
                            )
                            .padding(2.5)
                            .cornerRadius(15)
                            
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
                    
                    if !self.chatSelected {
                        VStack {
                            TopNavChat(
                                showAccountPopup: $showAccount,
                                friendSearch: $friendSearch,
                                userHasSignedIn: $userHasSignedIn,
                                prop: prop,
                                backgroundColor: Color.EZNotesLightBlack,
                                showUserProfilePreview: $showUserProfilePreview
                            )
                            
                            if self.accountInfo.allChats.isEmpty {
                                if !self.loadingAllMessages {
                                    Text("No Chats")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .minimumScaleFactor(0.5)
                                } else {
                                    Spacer()
                                    
                                    LoadingView(message: "Loading...")
                                    
                                    Spacer()
                                }
                            } else {
                                if !self.loadingAllMessages {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ForEach(Array(self.accountInfo.allChats.enumerated()), id: \.offset) { index, value in
                                            Button(action: {
                                                self.chattingWith = value.keys.first!
                                                self.usersBeingChattedWithPfp = value.values.first!
                                                self.chatSelected = true
                                            }) {
                                                HStack {
                                                    Button(action: {
                                                        RequestAction<GetUsersAccountIdData>(parameters: GetUsersAccountIdData(
                                                            Username: value.keys.first!
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
                                                        self.usersPfp = self.accountInfo.friends[value.keys.first!]!//self.defaultUsers[value.keys.first!]!
                                                        self.launchedForUser = value.keys.first!
                                                    }) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color.EZNotesBlue)
                                                            
                                                            /*Image(systemName: "person.crop.circle.fill")*/
                                                            value.values.first!
                                                                .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                                                .scaledToFill()
                                                                .frame(maxWidth: 35, maxHeight: 35)
                                                                .clipShape(.circle)
                                                                .foregroundStyle(.white)
                                                        }
                                                        .frame(width: 38, height: 38)
                                                        .padding([.leading], 10)
                                                    }
                                                    .buttonStyle(NoLongPressButtonStyle())
                                                    
                                                    VStack {
                                                        Text(value.keys.first!)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                            .foregroundStyle(.white)
                                                        
                                                        Text(self.accountInfo.messages.keys.contains(value.keys.first!)
                                                             ? !self.accountInfo.messages[value.keys.first!]!.isEmpty
                                                             ? "\(self.accountInfo.messages[value.keys.first!]!.last!.From == "client" ? "You" : value.keys.first!): \(self.accountInfo.messages[value.keys.first!]!.last!.MessageContent)"
                                                             : "No Messages"
                                                             : "No Messages")
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .lineLimit(2)
                                                        .truncationMode(.tail)
                                                        .font(Font.custom("Poppins-Regular", size: 12))
                                                        .foregroundStyle(.gray)
                                                        .multilineTextAlignment(.leading)
                                                    }
                                                    
                                                    VStack {
                                                        Text(self.accountInfo.messages.keys.contains(value.keys.first!)
                                                             ? !self.accountInfo.messages[value.keys.first!]!.isEmpty
                                                             ? self.messageSentHandler.relativeTime(for: self.accountInfo.messages[value.keys.first!]!.last!)
                                                             : "---"
                                                             : "---")
                                                        .frame(alignment: .center)
                                                        .font(Font.custom("Poppins-SemiBold", size: 14))
                                                        .foregroundStyle(.white)
                                                    }
                                                    .frame(alignment: .trailing)
                                                    .padding([.leading, .trailing], 10)
                                                }
                                                .frame(maxWidth: prop.size.width - 20)
                                                .padding(8)
                                            }
                                            
                                            if index < self.accountInfo.allChats.count - 1 {
                                                Divider()
                                                    .background(.white)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    Spacer()
                                    
                                    LoadingView(message: "Loading Messages...")
                                    
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                            
                            ButtomNavbar(
                                section: $section,
                                backgroundColor: Color.EZNotesLightBlack ,
                                prop: prop
                            )
                        }
                        .offset(x: self.chatViewX)
                        .animation(.smooth(duration: 0.55), value: self.chatViewX)
                        .opacity(self.chatViewOpacity)
                        .animation(.smooth(duration: 0.6), value: self.chatViewOpacity)
                        .onAppear {
                            withAnimation(.smooth(duration: 0.55)) {
                                self.chatViewX = 0
                                self.chatViewOpacity = 1
                             }
                        }
                        .zIndex(self.launchUserPreview ? 0 : 1)
                    } else {
                        VStack {
                            HStack {
                                Button(action: { self.chatSelected = false }) {
                                    Image(systemName: "arrow.left")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.EZNotesBlue)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding(.leading, 10)
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.EZNotesBlue)
                                    
                                    /*Image(systemName: "person.crop.circle.fill")*/
                                    self.usersBeingChattedWithPfp
                                        .resizable()//.resizableImageFill(maxWidth: 35, maxHeight: 35)
                                        .scaledToFill()
                                        .frame(maxWidth: 35, maxHeight: 35)
                                        .clipShape(.circle)
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 38, height: 38)
                                .padding([.leading], 10)
                                
                                Text(self.chattingWith)
                                    .frame(alignment: .center)
                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 22 : 20))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            
                            Divider()
                                .background(.white)
                                .frame(maxWidth: .infinity)
                            
                            if !self.accountInfo.messages[self.chattingWith]!.isEmpty {
                                ScrollView(.vertical, showsIndicators: false) {
                                    ForEach(self.accountInfo.messages[self.chattingWith]!, id: \.self) { value in
                                        FriendMessageView(message: value)
                                    }
                                }
                                .frame(maxWidth: prop.size.width - 20)
                            } else { Spacer() /* MARK: Ensure content is moved down if the above `ScrollView` will not be shown. */ }
                            
                            HStack {
                                TextField("Message...", text: $messageInput, axis: .vertical)
                                    .frame(maxWidth: prop.size.width - 40, minHeight: 30)
                                    .padding([.top, .bottom], 4)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 35)
                                    .cornerRadius(7.5)
                                    .padding(.horizontal, 5)
                                    .keyboardType(.alphabet)
                                    .background(
                                        AnyView(RoundedRectangle(cornerRadius: 15)
                                            .fill(.clear)
                                            .stroke(LinearGradient(gradient: Gradient(
                                                colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                            ), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
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
                                    .padding(.bottom, self.keyboardHeight == 0 ? 25 : self.keyboardHeight + 5)
                                /*.onChange(of: self.messageInput) {
                                 if self.messageInput.count > 0 { self.hideLeftsideContent = true }
                                 else { self.hideLeftsideContent = false }
                                 }*/
                                
                                Button(action: {
                                    let data = self.accountInfo.addOutgoingMessages(
                                        to: self.chattingWith,
                                        contentType: "text",
                                        content: self.messageInput
                                    )
                                    
                                    self.messageInput.removeAll()
                                    
                                    RequestAction<SendMessageToFriendData>(parameters: SendMessageToFriendData(
                                        AccountId: self.accountInfo.accountID,
                                        SendTo: self.chattingWith,
                                        MessageData: data
                                    )).perform(action: send_message_req) { statusCode, resp in
                                        guard resp != nil && statusCode == 200 else {
                                            /* MARK: For now, remove the most up to date outgoing message. */
                                            self.accountInfo.messages[self.chattingWith]!.removeAll(where: { $0 == data })
                                            
                                            return /* TODO: Handle error*/
                                        }
                                        
                                        /* MARK: Do nothing else*/
                                    }
                                    
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(Color.EZNotesBlue)
                                        
                                        Image(systemName: "arrow.up")
                                            .resizableImage(width: 15, height: 20)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                                .padding([.top, .bottom], 10)
                                .padding([.leading, .trailing], 6)
                                .padding(.bottom, self.keyboardHeight == 0 ? 25 : self.keyboardHeight + 5)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                        }
                        .onAppear {
                            // Detect keyboard notifications when the view appears
                            addKeyboardObservers()
                        }
                        .onDisappear {
                            // Remove keyboard observers when the view disappears
                            removeKeyboardObservers()
                        }
                        .zIndex(self.launchUserPreview ? 0 : 1)
                    }
                    
                    if !self.chatSelected {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Button(action: { self.newChatPopup = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.EZNotesBlue.opacity(0.8))
                                            .scaledToFit()
                                            .shadow(color: Color.black, radius: 4.5)
                                        /*.overlay(
                                         /*self.testPopup
                                          ? Circle().fill(Color.EZNotesLightBlack.opacity(0.6))
                                          : Circle().fill(.clear)*/
                                         Circle().fill(Color.EZNotesLightBlack.opacity(0.6))
                                         )*/
                                        
                                        Image(systemName: "plus.message.fill")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundStyle(Color.EZNotesBlack)
                                    }
                                    .frame(width: 50, height: 50)
                                    .padding(.trailing, 25)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .padding(.bottom, prop.isLargerScreen ? 90 : 70)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                        //}
                        //.frame(maxWidth: .infinity, maxHeight: .infinity)
                        //.zIndex(1)
                        
                        VStack {
                            Spacer()
                            
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                            .background(
                                Image("DefaultThemeBg2")
                                    .resizable()
                                    .scaledToFill()
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea([.bottom])
                .background(.black)
                .gesture(DragGesture(minimumDistance: 0.5, coordinateSpace: .local)
                    .onEnded({ value in
                        if self.chatSelected { return }
                        
                        if value.translation.width > 0 {
                            withAnimation(.smooth(duration: 0.55)) {
                                self.chatViewX = UIScreen.main.bounds.width
                                self.chatViewOpacity = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                self.section = "upload"
                                //self.uploadViewX = 0
                                //self.uploadViewOpacity = 1
                            }
                        }
                    })
                )
                .onChange(of: self.scenePhase) { /* MARK: Ensure consistent requests stop being sent to the user when the user leaves the app. */
                    if self.scenePhase == .background {
                        self.fetchData = false
                    }
                    
                    if self.scenePhase == .active {
                        if !self.fetchData {
                            self.fetchData = true
                            
                            /* MARK: Restart the process where the app gets the users friend requests/friends/incoming friend requests and messages. */
                            self.fetchClientsFriendData()
                        }
                    }
                }
                .onAppear {
                    if self.accountInfo.friends.isEmpty {
                        //self.loadingAllMessages = true
                        
                    } else {
                        RequestAction<GetClientsMessagesData>(parameters: GetClientsMessagesData(
                            AccountId: self.accountInfo.accountID
                        )).perform(action: get_clients_messages_req) { statusCode, resp in
                            guard resp != nil && statusCode == 200 else {
                                if let resp = resp { print(resp, "\tLOL2!") }
                                return
                            }
                            
                            if let resp = resp as? [String: Array<[String: String]>] {
                                resp.keys.forEach { user in
                                    if !self.accountInfo.allChats.contains(where: { $0.first?.key == user }) {
                                        if let friendImage = self.accountInfo.friends[user] {
                                            //if !self.accountInfo.allChats.contains(where: { $0.first?.key == user }) {//if !self.accountInfo.allChats.contains(where: { $0 == [user: friendImage] }) {
                                            self.accountInfo.allChats.append([user: friendImage])
                                            //}
                                        } else {
                                            //if !self.accountInfo.allChats.contains(where: { $0.first?.key == user }) {//[user: Image(systemName: "person.crop.circle.fill")] }) {
                                            self.accountInfo.allChats.append([user: Image(systemName: "person.crop.circle.fill")])
                                            //}
                                        }
                                    }
                                    
                                    /* MARK: Automatically assume there is no chat history with `user`. */
                                    if !self.accountInfo.messages.keys.contains(user) {
                                        self.accountInfo.messages[user] = []
                                    }
                                    
                                    if !resp[user]!.isEmpty {
                                        
                                        resp[user]!.forEach { message in
                                            let messageData = FriendMessageDetails(
                                                MessageID: message["MessageID"]!,
                                                ContentType: message["ContentType"]!,
                                                MessageContent: message["MessageContent"]!,
                                                From: message["From"]!,
                                                dateSent: ISO8601DateFormatter().date(from: message["dateSent"]!)!
                                            )
                                            
                                            if !self.accountInfo.messages[user]!.contains(where: { $0.MessageID == messageData.MessageID }) {
                                                self.accountInfo.messages[user]!.append(messageData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    /* MARK: This will run each time the view appears. However, if the user exits the app it will end due to the scene change. After the user comes back to the app, the scene will change to `active` and the `.onChange` above will handle restarting this process. */
                    self.fetchClientsFriendData()
                }
                .onDisappear {
                    self.fetchData = false
                }
                .popover(isPresented: $newChatPopup) {
                    VStack {
                        HStack {
                            Button(action: { self.newChatPopup = false }) {
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
                            
                            Text("New Chat")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.system(size: prop.isLargerScreen ? 24 : 22, weight: .bold))
                                .foregroundStyle(.white)
                            
                            ZStack { }.frame(maxWidth: 30, alignment: .trailing).padding(.trailing, 15)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .padding([.leading, .top, .trailing], 8)
                        .padding(.top, 10)
                        
                        HStack {
                            TextField(
                                "",
                                text: $newChatSearch
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
                            //.focused($userSearchBarFocused)
                            .autocorrectionDisabled(true)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .frame(minWidth: 0, alignment: .leading)
                                        .padding(.leading, 20)
                                    
                                    if self.newChatSearch.isEmpty {// && !self.userSearchBarFocused {
                                        Text("Search...")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                    } else {
                                        Spacer()
                                    }
                                    
                                    if !self.newChatSearch.isEmpty {
                                        Button(action: {
                                            self.newChatSearch.removeAll()
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 25)
                                        }
                                    }
                                }
                            )
                            .onChange(of: self.newChatSearch) {
                                self.newChatSearchResults.removeAll()
                                
                                if self.newChatSearch.isEmpty || self.newChatSearch == "" {
                                    self.showAllClientsFriends = true
                                    return
                                }
                                
                                if self.showAllClientsFriends { self.showAllClientsFriends = false }
                                
                                for user in self.accountInfo.friends.keys {
                                    if user.contains(self.newChatSearch) {
                                        self.newChatSearchResults[user] = self.accountInfo.friends[user]!
                                    }
                                }
                                
                                print(self.newChatSearchResults)
                            }
                            .padding([.top, .bottom])
                        }
                        .frame(maxWidth: prop.size.width - 20)
                        
                        /*Divider()
                            .background(.white)
                            .padding(.bottom, -5)*/
                        
                        Text(self.showAllClientsFriends ? "Friends" : "Search Results")
                            .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .foregroundStyle(.white)
                        
                        if !self.accountInfo.friends.isEmpty {
                            if !self.showAllClientsFriends && self.newChatSearchResults.isEmpty {
                                Text("No Results")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundStyle(.white)
                            } else {
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack {
                                        if self.showAllClientsFriends {
                                            ForEach(Array(self.accountInfo.friends.enumerated()), id: \.offset) { index, value in
                                                Button(action: {
                                                    RequestAction<StartNewChatData>(parameters: StartNewChatData(
                                                        AccountId: self.accountInfo.accountID,
                                                        StartChatWith: value.key
                                                    )).perform(action: start_chat_req) { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            guard let resp = resp, resp.keys.contains("ErrorCode") else { return }
                                                            
                                                            if resp["ErrorCode"]! as! Int == 0x4545 {
                                                                /* MARK: The chat exists.. launch it. */
                                                                self.chattingWith = value.key
                                                                self.usersBeingChattedWithPfp = self.accountInfo.friends[value.key]!
                                                                self.chatSelected = true
                                                                self.newChatPopup = false
                                                                return
                                                            }
                                                            
                                                            return /* TODO: Handle error*/
                                                        }
                                                        
                                                        self.accountInfo.allChats.append([value.key: self.accountInfo.friends[value.key]!])
                                                        self.accountInfo.messages[value.key] = []
                                                        
                                                        self.chattingWith = value.key
                                                        self.usersBeingChattedWithPfp = self.accountInfo.friends[value.key]!
                                                        self.chatSelected = true
                                                        self.newChatPopup = false
                                                    }
                                                }) {
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
                                                        
                                                        Text(value.key)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                            .foregroundStyle(.white)
                                                    }
                                                    .padding(8)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                        } else {
                                            ForEach(Array(self.newChatSearchResults.enumerated()), id: \.offset) { index, value in
                                                Button(action: {
                                                    RequestAction<StartNewChatData>(parameters: StartNewChatData(
                                                        AccountId: self.accountInfo.accountID,
                                                        StartChatWith: value.key
                                                    )).perform(action: start_chat_req) { statusCode, resp in
                                                        guard resp != nil && statusCode == 200 else {
                                                            guard let resp = resp, resp.keys.contains("ErrorCode") else { return }
                                                            
                                                            if resp["ErrorCode"]! as! Int == 0x4545 {
                                                                /* MARK: The chat exists.. launch it. */
                                                                self.chattingWith = value.key
                                                                self.usersBeingChattedWithPfp = self.accountInfo.friends[value.key]!
                                                                self.chatSelected = true
                                                                self.newChatPopup = false
                                                                return
                                                            }
                                                            
                                                            return /* TODO: Handle error*/
                                                        }
                                                        
                                                        self.accountInfo.allChats.append([value.key: self.accountInfo.friends[value.key]!])
                                                        self.accountInfo.messages[value.key] = []
                                                        
                                                        self.chattingWith = value.key
                                                        self.usersBeingChattedWithPfp = self.accountInfo.friends[value.key]!
                                                        self.chatSelected = true
                                                        self.newChatPopup = false
                                                    }
                                                }) {
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
                                                        
                                                        Text(value.key)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 16 : 14))
                                                            .foregroundStyle(.white)
                                                    }
                                                    .padding(8)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesLightBlack.opacity(0.4))//(Color.EZNotesBlack.opacity(0.6))
                                    )
                                    .cornerRadius(15)
                                    .padding(.bottom, 30)
                                }
                                .frame(maxWidth: prop.size.width - 40)
                            }
                        } else {
                            Text("No Friends")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .foregroundStyle(.white)
                            
                            Button(action: {
                                self.showUserProfilePreview = true
                                self.newChatPopup = false
                            }) {
                                HStack {
                                    Text("Add Friend")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding([.top, .bottom], 8)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                        .minimumScaleFactor(0.5)
                                }
                                /*.frame(maxWidth: prop.size.width - 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white)
                                )
                                .cornerRadius(15)*/
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .frame(maxWidth: prop.size.width - 180)
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding(prop.isLargerScreen || prop.isMediumScreen ? 12 : 10)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                                    .shadow(color: Color.white, radius: 6.5)//, x: 3, y: -6.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 25))//.cornerRadius(25)
                            .padding(3)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
                    .onTapGesture {
                        /* MARK: Ensure there is a way for the user to exit the focus of the search bar. This `.onTapGesture` ensures that if the user taps anywhere (with the exception of the searchbar itself), the keyboard will go away. */
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        } else {
            ResponsiveView { prop in
                Account(
                    prop: prop,
                    showAccount: $showAccount,
                    userHasSignedIn: $userHasSignedIn
                )
            }
        }
    }
}
