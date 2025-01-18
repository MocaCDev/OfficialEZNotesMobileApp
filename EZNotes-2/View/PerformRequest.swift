//
//  LoginViewModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import Foundation
import SwiftUI

extension Data {
    mutating public func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

class CompletionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    var completion: ((Int, [String: Any]?) -> Void)?
    
    var accumulatedData = Data()

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        accumulatedData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error: \(error)")
            DispatchQueue.main.async {
                self.completion?(500, nil)
            }
        } else {
            if let taskResponse = task.response as? HTTPURLResponse {
                if let response = try? JSONSerialization.jsonObject(with: accumulatedData, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.completion?(taskResponse.statusCode, response)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.completion?(500, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.completion?(500, nil)
                }
            }
        }
    }
}

struct ImageRequest : Encodable
{
    let attachment : String
    let fileName : String
}

/* TODO: Make a better image upload client API. */
struct MediaUpload {
    struct Media {
        let key: String
        let fileName: String
        let data: Data
        let mimeType: String
        
        init?(withImage image: UIImage, withName name: String, forKey key: String) {
            self.key = key
            self.mimeType = "image/jpg"
            self.fileName = name
            
            guard let data = image.jpegData(compressionQuality: 0.99) else { return nil }
            self.data = data
        }
    }
    
    public func createDataBody(media: [Media]?, boundary: String) -> Data {

        let lineBreak = "\r\n"
        var body = Data()

        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }

        body.append("--\(boundary)--\(lineBreak)")

        return body
    }
}

class PFP {
    var pfp: Image?
    var pfpBg: Image?
    var accountID: String?
    
    init(pfp: Image? = nil, pfpBg: Image? = nil, accountID: String? = nil) {
        self.pfp = pfp
        self.pfpBg = pfpBg
        self.accountID = accountID
    }
    
    private func perform(request: URLRequest, completion: @escaping (Int, [String: Any]?) -> Void) {
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 10000
        sessionConfig.timeoutIntervalForResource = 10000
        
        let sessionDelegate: CompletionDelegate = CompletionDelegate()
        sessionDelegate.completion = completion
        
        let dataTask = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil).dataTask(with: request)
        dataTask.resume()
        
        /*URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                200..<300~=response.statusCode,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async { completion(500, nil) }
                return
            }
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()*/
    }
    
    @MainActor public func requestSavePFPBg(completion: @escaping (Int, [String: Any]?) -> Void) {
        let url = URL(string: "\(server)/save_user_pfp_bg")
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url!)
        
        request.addValue("yes", forHTTPHeaderField: "Fm")
        request.addValue(accountID!, forHTTPHeaderField: "Account-Id")
        
        request.httpMethod = "POST"

        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        
        let pfp = ImageRenderer(content: self.pfpBg).uiImage!
        let pfpImage: MediaUpload.Media = MediaUpload.Media(withImage: pfp, withName: "\(arc4random()).jpeg", forKey: "pfp_image_bg")!
        
        let dataBody = MediaUpload().createDataBody(media: [pfpImage], boundary: boundary)
        request.httpBody = dataBody
        
        let sessionDelegate: CompletionDelegate = CompletionDelegate()
        sessionDelegate.completion = completion
        
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 10000
        sessionConfig.timeoutIntervalForResource = 10000
        
        let dataTask = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil).dataTask(with: request)
        dataTask.resume()
        
        /*URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                200..<300~=response.statusCode,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async { completion(500, nil) }
                return
            }
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()*/
    }
    
    @MainActor public func requestSavePFP(completion: @escaping (Int, [String: Any]?) -> Void) {
        let url = URL(string: "\(server)/save_user_pfp")
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url!)
        
        request.addValue("yes", forHTTPHeaderField: "Fm")
        request.addValue(accountID!, forHTTPHeaderField: "Account-Id")
        
        request.httpMethod = "POST"

        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        
        let pfp = ImageRenderer(content: self.pfp).uiImage!
        let pfpImage: MediaUpload.Media = MediaUpload.Media(withImage: pfp, withName: "\(arc4random()).jpeg", forKey: "pfp_image")!
        
        let dataBody = MediaUpload().createDataBody(media: [pfpImage], boundary: boundary)
        request.httpBody = dataBody
        
        let sessionDelegate: CompletionDelegate = CompletionDelegate()
        sessionDelegate.completion = completion
        
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 10000
        sessionConfig.timeoutIntervalForResource = 10000
        
        let dataTask = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil).dataTask(with: request)
        dataTask.resume()
        
        /*URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                200..<300~=response.statusCode,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async { completion(500, nil) }
                return
            }
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()*/
    }
    
    public func requestGetPFP(completion: @escaping (Int, Data?, [String: Any]?) -> Void) {
        var request = URLRequest(url: URL(string: "\(server)/get_user_pfp")!)
        
        request.addValue("yes", forHTTPHeaderField: "Fm")
        request.addValue(accountID!, forHTTPHeaderField: "Account-Id")
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async { completion(500, nil, nil) }
                return
            }
            
            guard
                200..<300~=response.statusCode
            else {
                DispatchQueue.main.async { completion(response.statusCode, nil, resp) }
                return
            }
            
            DispatchQueue.main.async { completion(response.statusCode, Data(base64Encoded: resp["PFP"] as! String), resp) }
        }.resume()
    }
    
    public func requestGetPFPBg(completion: @escaping (Int, Data?) -> Void) {
        var request = URLRequest(url: URL(string: "\(server)/get_user_pfp_bg")!)
        
        request.addValue("yes", forHTTPHeaderField: "Fm")
        request.addValue(accountID!, forHTTPHeaderField: "Account-Id")
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                200..<300~=response.statusCode,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async { completion(500, nil) }
                return
            }
            
            DispatchQueue.main.async { completion(response.statusCode, Data(base64Encoded: resp["PFP_BG"] as! String)) }
        }.resume()
    }
}

class UploadImages {
    var imageUpload: Array<[String: UIImage]>
    
    init(imageUpload: Array<[String: UIImage]>) {
        self.imageUpload = imageUpload
    }
    
    public func requestNativeImageUpload(completion: @escaping (ImageUploadRequestResponse) -> Void) {
        //let localServer1 = "http://10.185.51.126:8088"
        //let localServer1 = "http://192.168.1.114:8088"
        //let localServer1 = "http://192.168.0.12:8088"
        //let localServer1 = "https://www.eznotes.space"
        
        let url = URL(string: "\(server)/handle_uploads")
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url!)
        
        var mediaImages: Array<MediaUpload.Media> = []
        
        for photo in imageUpload {
            for k in photo.keys {
                mediaImages.append(MediaUpload.Media(withImage: photo[k]!, withName: k, forKey: "file")!)
            }
        }
        
        //guard let mediaImage = Media(withImage: imageUpload, forKey: "file") else { return }

        request.httpMethod = "POST"

        request.allHTTPHeaderFields = [
                    "X-User-Agent": "ios",
                    "Accept-Language": "en",
                    "Accept": "application/json",
                    "Content-Type": "multipart/form-data; boundary=\(boundary)",
                ]

        let dataBody = MediaUpload().createDataBody(media: mediaImages, boundary: boundary)
        request.httpBody = dataBody
        
        request.timeoutInterval = 50000

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                /* Attempt to get a good response. */
                let response = try? JSONDecoder().decode(UploadImagesGoodResponse.self, from: data)
                
                /* Attempt to get a bad response*/
                let bresponse = try? JSONDecoder().decode(BadResponse.self, from: data)
                
                if let response = response {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: response, Bad: nil))
                    }
                    return
                }
                
                if let bresponse = bresponse {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: nil, Bad: bresponse))
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    completion(ImageUploadRequestResponse(
                        Good: nil,
                        Bad: BadResponse(
                            Status: "404",
                            ErrorCode: 0x1,
                            Message: "(Internal) Request Failed"
                        )
                    ))
                }
            }
        }.resume()
    }
}

class RequestAction<T>: ObservableObject {
    
    var parameters: T
    
    init(parameters: T) {
        self.parameters = parameters
    }
    
    final public func initSession(withRequest: CSIARequest<T>, withDelegate: Bool = false, delegate: CompletionDelegate? = nil) -> (Session: URLSession, Request: URLRequest) {
        var request = URLRequest(url: URL(string: withRequest.url)!)
        request.httpMethod = withRequest.method
        
        request.addValue("yes", forHTTPHeaderField: "Fm") /* `Fm` - From Mobile. */
        
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Configure the session
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        
        /* MARK: Allow 15 minutes for requests. This is way more than what is needed, but it's okay during beta testing. */
        sessionConfig.timeoutIntervalForRequest = 900
        sessionConfig.timeoutIntervalForResource = 900
        
        if withDelegate && delegate != nil {
            let session = URLSession(configuration: sessionConfig, delegate: delegate!, delegateQueue: nil)
            
            return (session, request)
        }
        
        let session = URLSession(configuration: sessionConfig)
        return (session, request)
    }
    
    final public func handleResponse(response: Any, data: Data, completion: @escaping (Int, [String: Any]?) -> Void) -> Void {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        completion(httpResponse.statusCode, json)
                    }//return (httpResponse.statusCode, json)
                    return
                } else {
                    DispatchQueue.main.async {
                        completion(500, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(500, nil)
                }
            }
        }
    }
    
    func perform(action: CSIARequest<T>, completion: @escaping (Int, [String: Any]?) -> Void) {
        
        /*let scheme: String = "https"
        let host: String = "www.eznotes.space"//"http://127.0.0.1:8088"//"www.eznotes.space"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        var request: URLRequest = URLRequest(url: URL(string: action.url)!)//URLRequest(url: URL(string: "n")!)
        
        request.httpMethod = action.method
        request.addValue("yes", forHTTPHeaderField: "Fm") /* `Fm` - From Mobile. */
        
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
        
        request.timeoutInterval = 50000*/
        
        let delegate = CompletionDelegate()
        delegate.completion = completion
        
        let reqInit = self.initSession(withRequest: action, withDelegate: true, delegate: delegate)
        
        var request = reqInit.Request
        let session = reqInit.Session
        
        switch(action.reqData.self)
        {
            case is GetClientsMessagesData.Type:
                guard let params: GetClientsMessagesData = (parameters as? GetClientsMessagesData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is StartNewChatData.Type:
                guard let params: StartNewChatData = (parameters as? StartNewChatData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.StartChatWith, forHTTPHeaderField: "Start-Chat-With")
                break
            case is SendMessageToFriendData.Type:
                guard let params: SendMessageToFriendData = (parameters as? SendMessageToFriendData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.SendTo, forHTTPHeaderField: "Send-To")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                request.httpBody = try? encoder.encode(params.MessageData)//try? JSONSerialization.data(withJSONObject: params.MessageData)
                break
            case is SaveTagsData.Type:
                guard let params: SaveTagsData = (parameters as? SaveTagsData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.Tags, forHTTPHeaderField: "Tags")
                break
            case is RemoveTagData.Type:
                guard let params: RemoveTagData = (parameters as? RemoveTagData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.TagToRemove, forHTTPHeaderField: "Tag-To-Remove")
                break
            case is GetTagsData.Type:
                guard let params: GetTagsData = (parameters as? GetTagsData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is GetAccountDescriptionData.Type:
                guard let params: GetAccountDescriptionData = (parameters as? GetAccountDescriptionData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is SaveAccountDescriptionData.Type:
                guard let params: SaveAccountDescriptionData = (parameters as? SaveAccountDescriptionData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                //request.addValue(params.NewDescription, forHTTPHeaderField: "New-Description")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
                let jsonData: [String: String] = ["NewDescription": params.NewDescription]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is GetUsersFriendsData.Type:
                guard let params: GetUsersFriendsData = (parameters as? GetUsersFriendsData) else { return }
                request.addValue(params.ForUser, forHTTPHeaderField: "For-User")
                break
            case is GetClientsUsernameData.Type:
                guard let params: GetClientsUsernameData = (parameters as? GetClientsUsernameData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is RemoveFriendRequest.Type:
                guard let params: RemoveFriendRequest = (parameters as? RemoveFriendRequest) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.CancelFor, forHTTPHeaderField: "Cancel-For")
                break
            case is RemoveFriendData.Type:
                guard let params: RemoveFriendData = (parameters as? RemoveFriendData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.ToRemove, forHTTPHeaderField: "To-Remove")
                break
            case is AcceptFriendRequestData.Type:
                guard let params: AcceptFriendRequestData = (parameters as? AcceptFriendRequestData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.AcceptFrom, forHTTPHeaderField: "Accept-From")
                break
            case is GetClientsFriendsData.Type:
                guard let params: GetClientsFriendsData = (parameters as? GetClientsFriendsData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is GetClientsFriendRequestsData.Type:
                guard let params: GetClientsFriendRequestsData = (parameters as? GetClientsFriendRequestsData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is GetClientsPendingRequestsData.Type:
                guard let params: GetClientsPendingRequestsData = (parameters as? GetClientsPendingRequestsData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is SendFriendRequestData.Type:
                guard let params: SendFriendRequestData = (parameters as? SendFriendRequestData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.Username, forHTTPHeaderField: "Username")
                request.addValue(params.RequestTo, forHTTPHeaderField: "Request-To")
                break
            case is IsFriendsOrHasSentFriendRequestData.Type:
                guard let params: IsFriendsOrHasSentFriendRequestData = (parameters as? IsFriendsOrHasSentFriendRequestData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id");
                request.addValue(params.Username, forHTTPHeaderField: "Username")
                break
            case is SearchUserData.Type:
                guard let params: SearchUserData = (parameters as? SearchUserData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id");
                request.addValue(params.Filter, forHTTPHeaderField: "Filter")
                request.addValue(params.Usages, forHTTPHeaderField: "Usages")
                request.addValue(params.Query, forHTTPHeaderField: "Query")
                break
            case is GetUsersData.Type:
                guard let params: GetUsersData = (parameters as? GetUsersData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id");
                request.addValue(params.Filter, forHTTPHeaderField: "Filter")
                request.addValue(params.Usages, forHTTPHeaderField: "Usages")
                break
            case is GetUsersAccountIdData.Type:
                guard let params: GetUsersAccountIdData = (parameters as? GetUsersAccountIdData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "Username");
                break
            case is CheckUsernameRequestData.Type://"complete_login":
                guard let params: CheckUsernameRequestData = (parameters as? CheckUsernameRequestData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "Username");
                break
            case is CheckEmailRequestData.Type://"complete_login":
                guard let params: CheckEmailRequestData = (parameters as? CheckEmailRequestData) else { return }
                request.addValue(params.Email, forHTTPHeaderField: "Email");
                break
            case is LoginRequestData.Type://"complete_login":
                guard let params: LoginRequestData = (parameters as? LoginRequestData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "Un");
                request.addValue(params.Password, forHTTPHeaderField: "Pw");
                break
            case is SignUpRequestData.Type:
                guard let params: SignUpRequestData = (parameters as? SignUpRequestData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "N-Un")
                request.addValue(params.Password, forHTTPHeaderField: "N-Pw")
                request.addValue(params.Email, forHTTPHeaderField: "N-Em")
                request.addValue(params.State, forHTTPHeaderField: "N-St")
                request.addValue(params.College, forHTTPHeaderField: "N-Cl")
                request.addValue(params.Field, forHTTPHeaderField: "N-Field")
                request.addValue(params.Major, forHTTPHeaderField: "N-Major")
                request.addValue("", forHTTPHeaderField: "N-Bgimg")
                request.addValue(params.IP != nil ? params.IP! : "::1", forHTTPHeaderField: "N-Cip") /* MARK: `::1` is localhost, essentially. */
                request.addValue(params.Usecase, forHTTPHeaderField: "Usage")
                break
            case is SignUp2RequestData.Type:
                guard let params: SignUp2RequestData = (parameters as? SignUp2RequestData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.UserInputtedCode, forHTTPHeaderField: "Uic")
                break
            case is GetEmailData.Type:
                guard let params: GetEmailData = (parameters as? GetEmailData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                break
            case is StartAIChatData.Type:
                guard let params: StartAIChatData = (parameters as? StartAIChatData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.Major, forHTTPHeaderField: "Major")
                request.addValue(params.Topic, forHTTPHeaderField: "Topic")
                break
            case is StartAIChatOverNotesData.Type:
                guard let params: StartAIChatOverNotesData = (parameters as? StartAIChatOverNotesData) else { return }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData: [String: String] = ["Notes": params.Notes]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is SendAIChatMessageData.Type:
                guard let params: SendAIChatMessageData = (parameters as? SendAIChatMessageData) else { return }
                request.addValue(params.AccountId, forHTTPHeaderField: "Account-Id")
                request.addValue(params.ChatID.uuidString, forHTTPHeaderField: "Chat-Id")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData: [String: String] = ["Message": params.Message]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                //request.addValue(params.Message, forHTTPHeaderField: "Message")
                break
            case is SummarizeNotesData.Type:
                guard let params: SummarizeNotesData = (parameters as? SummarizeNotesData) else { return }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData: [String: String] = ["OriginalNotes": params.OriginalNotes, "EditedNotes": params.EditedNotes]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is ReWordNotesData.Type:
                guard let params: ReWordNotesData = (parameters as? ReWordNotesData) else { return }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData: [String: String] = ["EditedNotes": params.Notes]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is DetectPossibleSimilarCategories.Type:
                guard let params: DetectPossibleSimilarCategories = (parameters as? DetectPossibleSimilarCategories) else { return }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let jsonData: [String: Array<String>] = ["Existing": params.ExistingCategories, "New": params.NewCategories]
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is GenerateDescRequestData.Type:
                print("YES")
                guard let params: GenerateDescRequestData = (parameters as? GenerateDescRequestData) else { return }
                request.addValue(params.Subject, forHTTPHeaderField: "Subject")
                break
            case is GetCollegesRequestData.Type:
                guard let params: GetCollegesRequestData = (parameters as? GetCollegesRequestData) else { return }
                request.addValue(params.State, forHTTPHeaderField: "State")
                break
            case is GetMajorsRequestData.Type:
                guard let params: GetMajorsRequestData = (parameters as? GetMajorsRequestData) else { return }
                request.addValue(params.College, forHTTPHeaderField: "College")
                request.addValue(params.MajorField, forHTTPHeaderField: "Major-Field")
                break
            case is GetCustomMajorsRequestData.Type:
                guard let params: GetCustomMajorsRequestData = (parameters as? GetCustomMajorsRequestData) else { return }
                request.addValue(params.CMajorField, forHTTPHeaderField: "CMajor-Field")
                break
            case is GetCustomCollegeFieldsData.Type:
                guard let params: GetCustomCollegeFieldsData = (parameters as? GetCustomCollegeFieldsData) else { return }
                request.addValue(params.State, forHTTPHeaderField: "State")
                request.addValue(params.College, forHTTPHeaderField: "CCollege")
                break
            case is GetCustomTopicsData.Type:
                guard let params: GetCustomTopicsData = (parameters as? GetCustomTopicsData) else { return }
                request.addValue(params.Major, forHTTPHeaderField: "Major")
                break
            case is SaveChatHistoryData.Type:
                guard let params: SaveChatHistoryData = (parameters as? SaveChatHistoryData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var jsonData: [String: Array<[String: Any]>] = [params.ChatTitle: []]
                    
                for value in params.ChatHistory {
                    jsonData[params.ChatTitle]!.append([
                        "MessageID": value.MessageID.uuidString,
                        "MessageContent": value.MessageContent,
                        "userSent": value.userSent,
                        "dateSent": ISO8601DateFormatter().string(from: value.dateSent)
                    ])
                }
            
                print(jsonData)
            
                request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
                break
            case is DeleteSignupProcessData.Type:
                guard let params: DeleteSignupProcessData = (parameters as? DeleteSignupProcessData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                break
            case is GetSubscriptionInfoData.Type:
                guard let params: GetSubscriptionInfoData = (parameters as? GetSubscriptionInfoData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                break
            case is UpdateCollegeNameData.Type:
                guard let params: UpdateCollegeNameData = (parameters as? UpdateCollegeNameData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.NewCollegeName, forHTTPHeaderField: "New-College-Name")
                break
            case is UpdateMajorFieldData.Type:
                guard let params: UpdateMajorFieldData = (parameters as? UpdateMajorFieldData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.NewMajorField, forHTTPHeaderField: "New-Major-Field")
                break
            case is CheckStateHasCollege.Type:
                guard let params: CheckStateHasCollege = (parameters as? CheckStateHasCollege) else { return }
                request.addValue(params.State, forHTTPHeaderField: "State")
                request.addValue(params.College, forHTTPHeaderField: "College")
                break
            case is UpdateMajorData.Type:
                guard let params: UpdateMajorData = (parameters as? UpdateMajorData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.NewMajor, forHTTPHeaderField: "New-Major")
                break
            case is UpdateStateData.Type:
                guard let params: UpdateStateData = (parameters as? UpdateStateData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.NewState, forHTTPHeaderField: "New-State")
                break
            case is UpdateUsernameData.Type:
                guard let params: UpdateUsernameData = (parameters as? UpdateUsernameData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.NewUsername, forHTTPHeaderField: "New-Username")
                break
            case is UpdatePasswordData.Type:
                guard let params: UpdatePasswordData = (parameters as? UpdatePasswordData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.OldPassword, forHTTPHeaderField: "Old-Password")
                request.addValue(params.NewPassword, forHTTPHeaderField: "New-Password")
                break
            case is GetClientsUsecaseReq.Type:
                guard let params: GetClientsUsecaseReq = (parameters as? GetClientsUsecaseReq) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                break
            case is ReportProblemData.Type:
                guard let params: ReportProblemData = (parameters as? ReportProblemData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.ContactEmail, forHTTPHeaderField: "Contact-Email")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let feedback: [String: String] = [
                    "Feedback": params.ReportedProblem
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: feedback)
                break
            case is GenerateFlashcardsData.Type:
                guard let params: GenerateFlashcardsData = (parameters as? GenerateFlashcardsData) else { return }
                request.addValue(params.Topic, forHTTPHeaderField: "Topic")
                request.addValue(params.ScreenWidth, forHTTPHeaderField: "Screen-Width")
                request.addValue(params.ScreenHeight, forHTTPHeaderField: "Screen-Height")
            
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
                let data: [String: String] = [
                    "Notes": params.Notes
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: data)
            
                break
            case is GenerateSlideshowData.Type:
                guard let params: GenerateSlideshowData = (parameters as? GenerateSlideshowData) else { return }
                request.addValue(params.Topic, forHTTPHeaderField: "Topic")
                request.addValue(params.ScreenWidth, forHTTPHeaderField: "Screen-Width")
                request.addValue(params.ScreenHeight, forHTTPHeaderField: "Screen-Height")
            
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
                let data: [String: String] = [
                    "Notes": params.Notes
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: data)
            
                break
            default: break
        }
        
        //let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        
        let requestTask = session.dataTask(with: request)
        requestTask.resume()
    }
}

struct ResponseHelper {
    var endingAction: (() -> Void)? = nil
    var returnNilAction: (() -> Void)? = nil
    
    public func populateUsers(resp: [String: Any]) -> [String: Image]? {
        if let resp = resp as? [String: [String: Any]] {
            var usersData: [String: Image] = [:]
            
            for user in resp.keys {
                guard resp[user] != nil else { continue }
                
                if let pfpEncodedData: String = resp[user]!["PFP"] as? String {
                    if let userPFPData: Data = Data(base64Encoded: pfpEncodedData) {
                        usersData[user] = Image(
                            uiImage: UIImage(
                                data: userPFPData
                            )!
                        )
                    } else {
                        usersData[user] = Image(systemName: "person.crop.circle.fill")
                    }
                } else {
                    usersData[user] = Image(systemName: "person.crop.circle.fill")
                }
                
                /*if setLoadingViewToFalse {
                    if user == Array(resp.keys).last && self.loadingView { self.loadingView = false }
                }*/
                if user == Array(resp.keys).last && self.endingAction != nil {
                    self.endingAction!()
                }
            }
            
            return usersData
        } else {
            if self.returnNilAction != nil { self.returnNilAction!() } //self.noUsersToShow = true
        }
        
        return nil
    }
}
