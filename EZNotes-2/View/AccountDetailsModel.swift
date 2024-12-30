//
//  AccountDetailsModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/18/24.
//
import SwiftUI

struct FriendMessageDetails: Hashable, Encodable, Decodable {
    let MessageID: String
    let ContentType: String /* MARK: For now, the app only supports string-based messages. Image-based messages will be supported soon. */
    let MessageContent: String
    let From: String /* MARK: Will either be "client" or "<user>". This helps the app decipher how to display the messages. `<user>` will be the username of the client who sent the message to the current client. `<client>` tells the app that the content of the message is from the client. */
    let dateSent: Date
}

class AccountDetails: ObservableObject {
    @Published var username: String
    @Published var email: String
    @Published var college: String
    @Published var major: String
    @Published var major_field: String
    @Published var state: String
    @Published var accountID: String
    @Published var usage: String
    @Published var subID: String
    @Published var aiChatID: UUID
    @Published var accountDescription: String
    @Published var accountTags: Array<String>
    
    /* TODO: Mature the interface with friends. Perhaps make it to where the app (server) keeps track of how long the client has been friends with the given user. Perhaps we can make another class store specific information over the user so that the app doesn't have to consistently send requests to the server to obtain that data. */
    @Published var friends: [String: Image]
    @Published var friendRequests: [String: Image]
    @Published var pendingRequests: [String: Image]
    @Published var allChats: Array<[String: Image]> /* MARK: All chats that the client has with other users. */
    @Published var messages: [String: Array<FriendMessageDetails>]
    
    /* MARK: Used to manipulate the `messages` dictionary when the client sends an outgoing request. Method enables more efficient code in the actual UI part. */
    public final func addOutgoingMessages(to: String, messageID: String = UUID().uuidString, contentType: String, content: String, date: Date = .now) -> FriendMessageDetails {
        let messageDetails = FriendMessageDetails(
            MessageID: messageID,
            ContentType: contentType,
            MessageContent: content,
            From: "client",
            dateSent: date
        )
        
        if !self.messages.keys.contains(to) {
            self.messages[to] = [messageDetails]
        } else {
            self.messages[to]!.append(messageDetails)
        }
        
        return messageDetails
    }
    
    /* MARK: PFP - will be on top of `profileBackgroundImage`. */
    @Published var profilePicture: Image
    
    /* MARK: Background image for the top of the account popover. */
    @Published var profileBackgroundPicture: Image
    
    init() {
        username = ""
        email = ""
        college = ""
        major = ""
        major_field = ""
        state = ""
        accountID = ""
        usage = ""
        subID = ""
        aiChatID = UUID()
        accountDescription = ""
        accountTags = []
        friends = [:]
        friendRequests = [:]
        pendingRequests = [:]
        messages = [:]
        allChats = []
        profilePicture = Image(systemName: "person.crop.circle.fill") /* MARK: Default PFP icon. */
        profileBackgroundPicture = Image("Pfp-Default-Bg") /* MARK: Default PFP BG. */
    }
    
    public func getMessages(accountID: String, completion: @escaping (Int, [String: Any]?) -> Void) async {
        
    }
    
    public func getFriends(accountID: String, completion: @escaping (Int, [String: Any]?) -> Void) async {
        do {
            let req: RequestAction<GetClientsFriendsData> = RequestAction<GetClientsFriendsData>(
                parameters: GetClientsFriendsData(
                    AccountId: accountID
                )
            )
            
            let reqInit = req.initSession(withRequest: get_clients_friends_req)//, withDelegate: true, delegate: delegate)
            
            var request = reqInit.Request
            let session = reqInit.Session
            
            request.addValue(req.parameters.AccountId, forHTTPHeaderField: "Account-Id")
            
            let (data, response) = try await session.data(for: request)
            
            req.handleResponse(response: response, data: data, completion: completion)
        } catch {
            print(error)
        }
    }
    
    final public func reset() {
        username = ""
        email = ""
        college = ""
        major = ""
        major_field = ""
        state = ""
        accountID = ""
        usage = ""
        subID = ""
        aiChatID = UUID()
        accountDescription = ""
        accountTags = []
        friends = [:]
        friendRequests = [:]
        pendingRequests = [:]
        profilePicture = Image(systemName: "person.crop.circle.fill") /* MARK: Default PFP icon. */
        profileBackgroundPicture = Image("Pfp-Default-Bg") /* MARK: Default PFP BG. */
    }
    
    final public func setUsername(username: String) { self.username = username }
    final public func setEmail(email: String) { self.email = email }
    final public func setCollegeName(collegeName: String) { self.college = collegeName }
    final public func setMajorName(majorName: String) { self.major = majorName }
    final public func setMajorField(field: String) { self.major_field = field }
    final public func setAccountID(accountID: String) { self.accountID = accountID }
    final public func setUsage(usage: String) { self.usage = usage }
    final public func setClientSubID(subID: String) { self.subID = subID }
    final public func setAIChatID(chatID: UUID) { self.aiChatID = chatID }
    final public func setCollegeState(collegeState: String) { self.state = collegeState }
    
    final public func setProfilePicture(pfp: UIImage) { self.profilePicture = Image(uiImage: pfp) }
    final public func setProfilePicture(pfp: Image) { self.profilePicture = pfp }
    
    final public func setProfilePictureBackground(bg: UIImage) { self.profileBackgroundPicture = Image(uiImage: bg) }
    final public func setProfilePictureBackground(bg: Image) { self.profileBackgroundPicture = bg }
}
