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

struct UploadImages {
    var imageUpload: Array<[String: UIImage]>
    
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
    
    func requestNativeImageUpload(completion: @escaping (ImageUploadRequestResponse) -> Void) {
        //let localServer1 = "http://10.185.51.126:8088"
        //let localServer1 = "http://192.168.1.114:8088"
        let localServer1 = "http://192.168.0.12:8088"
        //let localServer1 = "https://www.eznotes.space"
        
        let url = URL(string: "\(localServer1)/handle_uploads")
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url!)
        
        var mediaImages: Array<Media> = []
        
        for photo in imageUpload {
            for k in photo.keys {
                mediaImages.append(Media(withImage: photo[k]!, withName: k, forKey: "file")!)
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

        let dataBody = createDataBody(media: mediaImages, boundary: boundary)
        request.httpBody = dataBody

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
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
    
    func createDataBody(media: [Media]?, boundary: String) -> Data {

        let lineBreak = "\r\n"
        var body = Data()

        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }

        body.append("--\(boundary)--\(lineBreak)")

        return body
    }
}

struct RequestAction<T> {
    
    var parameters: T
    
    func perform(action: String, completion: @escaping (RequestResponse) -> Void) {
        
        let scheme: String = "https"
        let host: String = "www.eznotes.space"//"http://127.0.0.1:8088"//"www.eznotes.space"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        var request: URLRequest = URLRequest(url: URL(string: "n")!)
        let server = "http://192.168.0.12:8088"//"http://192.168.1.114:8088"
        
        switch(action)
        {
            case "check_server_is_active": request = URLRequest(url: URL(string: "\(server)/EZNotes_Software_Network_Test")!);break;
            case "get_supported_states": request = URLRequest(url: URL(string: "\(server)/get_supported_states")!);break;
            case "get_colleges_for_state": request = URLRequest(url: URL(string: "\(server)/get_colleges_for_state")!);break;
            case "complete_login":  request = URLRequest(url: URL(string: "\(server)/mobile_cl")!);break;
            case "complete_signup1": request = URLRequest(url: URL(string: "\(server)/csu")!);break;
            case "complete_signup2": request = URLRequest(url: URL(string: "\(server)/csu2")!);break;
            default: request = URLRequest(url: URL(string: "\(server)/\(action)")!);break;
        }
        
        if action == "get_supported_states" || action == "get_colleges_for_state" { request.httpMethod = "get" }
        else { request.httpMethod = "post" }
        
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html; charset=utf-8", forHTTPHeaderField: "Accept")
        
        /* `Fm` - From Mobile. */
        /* TODO: Update this. The endpoint `/get_supported_states` needs to become adherent to requests coming from
         * TODO: the mobile app.
         * */
        if action == "get_supported_states" { request.addValue("yes", forHTTPHeaderField: "Fm") }
        else if action == "get_colleges_for_state" {
            request.addValue("yes", forHTTPHeaderField: "Fm")
            
            guard let params: GetCollegesRequest = (parameters as? GetCollegesRequest) else { return }
            request.addValue(params.State, forHTTPHeaderField: "State")
        }
        else { request.addValue("yes", forHTTPHeaderField: "Fm") }
        
        switch(action)
        {
            case "complete_login":
                guard let params: LoginRequestData = (parameters as? LoginRequestData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "Un");
                request.addValue(params.Password, forHTTPHeaderField: "Pw");
                break;
            case "complete_signup1":
                guard let params: SignUpRequestData = (parameters as? SignUpRequestData) else { return }
                request.addValue(params.Username, forHTTPHeaderField: "N-Un")
                request.addValue(params.Password, forHTTPHeaderField: "N-Pw")
                request.addValue(params.Email, forHTTPHeaderField: "N-Em")
                request.addValue(params.State, forHTTPHeaderField: "N-St")
                request.addValue(params.College, forHTTPHeaderField: "N-Cl")
                request.addValue("", forHTTPHeaderField: "N-Bgimg")
                request.addValue("", forHTTPHeaderField: "N-Cip")
                break;
            case "complete_signup2":
                guard let params: SignUp2RequestData = (parameters as? SignUp2RequestData) else { return }
                request.addValue(params.AccountID, forHTTPHeaderField: "Account-Id")
                request.addValue(params.UserInputtedCode, forHTTPHeaderField: "Uic")
                break;
            default: break;
        }
        
        
        let _: Void = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
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
            }
        }
        .resume()
    }
}

struct PerformRequest_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
