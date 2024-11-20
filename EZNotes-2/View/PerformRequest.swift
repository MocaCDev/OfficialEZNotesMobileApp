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

struct PFP {
    var pfp: Image?
    var pfpBg: Image?
    var accountID: String?
    
    private func perform(request: URLRequest, completion: @escaping (Int, [String: Any]?) -> Void) {
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
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()
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
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()
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
            
            DispatchQueue.main.async { completion(response.statusCode, resp) }
        }.resume()
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

struct UploadImages {
    var imageUpload: Array<[String: UIImage]>
    
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

struct RequestAction<T> {
    
    var parameters: T
    
    func perform(action: CSIARequest<T>, completion: @escaping (Int, [String: Any]?) -> Void) {
        
        let scheme: String = "https"
        let host: String = "www.eznotes.space"//"http://127.0.0.1:8088"//"www.eznotes.space"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        var request: URLRequest = URLRequest(url: URL(string: action.url)!)//URLRequest(url: URL(string: "n")!)
        
        request.httpMethod = action.method
        request.addValue("yes", forHTTPHeaderField: "Fm") /* `Fm` - From Mobile. */
        
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
        
        switch(action.reqData.self)
        {
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
                request.addValue("", forHTTPHeaderField: "N-Cip")
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
            default: break
        }
        
        
        let _: Void = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                let data = data,
                let resp = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                DispatchQueue.main.async {
                    completion(500, nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(response.statusCode, resp)
            }
            
            /*if let data = data {
                /* Attempt to get a good response. */
                let response = try? JSONDecoder().decode(GoodResponse.self, from: data)
                
                /* Attempt to get a bad response*/
                let bresponse = try? JSONDecoder().decode(BadResponse.self, from: data)
                
                /* Complete accordingly. */
                if let bresponse = bresponse {
                    DispatchQueue.main.async {
                        completion(RequestResponse(Good: nil, Bad: bresponse))
                    }
                    return
                }
                
                if let response = response {
                    DispatchQueue.main.async {
                        completion(RequestResponse(Good: response, Bad: nil))
                    }
                    return
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(RequestResponse(
                        Good: nil,
                        Bad: BadResponse(
                            Status: "404",
                            ErrorCode: 0x1,
                            Message: "(Internal) Request Failed"
                        )
                    ))
                }
            }*/
        }
        .resume()
    }
}

struct PerformRequest_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
