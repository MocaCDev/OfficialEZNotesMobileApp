//
//  LoginViewModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import Foundation
import SwiftUI

/*class RequestAction1: ObservableObject {
    @Published public var response: RequestResponse = RequestResponse(Good: nil, Bad: nil)
}*/

extension Data {
    mutating public func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
/*public extension Data {
    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}*/
extension NSMutableData {
  func appendString(_ string: String) {
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
    
    func postApiDataWithMultipartForm<T:Decodable>(requestUrl: URL, request: ImageRequest, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void)
    {
        var urlRequest = URLRequest(url: requestUrl)
        let lineBreak = "\r\n"
        
        urlRequest.httpMethod = "post"
        let boundary = "---------------------------------\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
        
        var requestData = Data()
        
        requestData.append("--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"attachment\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append(request.attachment .data(using: .utf8)!)
        
        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
        requestData.append("content-disposition: form-data; name=\"file\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
        requestData.append("\(request.fileName + lineBreak)" .data(using: .utf8)!)
        
        requestData.append("--\(boundary)--\(lineBreak)" .data(using: .utf8)!)
        
        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
        urlRequest.httpBody = requestData
        
        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
            if(error == nil && data != nil && data?.count != 0)
            {
                // let dataStr = String(decoding: requestData, as: UTF8.self) //to view the data you receive from the API
                do {
                    let response = try JSONDecoder().decode(T.self, from: data!)
                    _=completionHandler(response)
                }
                catch let decodingError {
                    debugPrint(decodingError)
                }
            }
            
        }.resume()
        
    }
    
    func requestNativeImageUpload(completion: @escaping (ImageUploadRequestResponse) -> Void) {
        //let localServer1 = "http://10.185.51.126:8088"
        //let localServer1 = "http://192.168.1.114:8088"
        //let localServer1 = "http://192.168.0.8:8088"
        let localServer1 = "https://www.eznotes.space"
        
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
    
    func multiImageUpload(completion: @escaping (Array<ImageUploadRequestResponse>) -> Void) {
        let localServer1 = "https://www.eznotes.space"//"http://192.168.0.8:8088"
        //let localServer1 = "http://192.168.1.114:8088"
        
        let url = URL(string: "\(localServer1)/handle_uploads")
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"

        request.allHTTPHeaderFields = [
                    "X-User-Agent": "ios",
                    "Accept-Language": "en",
                    "Accept": "application/json",
                    "Content-Type": "multipart/form-data; boundary=\(boundary)",
                ]
        
        var mediaImages: Array<Media> = []
        
        var i = 0
        var responses: Array<ImageUploadRequestResponse> = []
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 400
        
        var total = 0
        
        /* MARK: Estimate the amount of responses expected. Since there are more than 5 uploads, each request will consist of, max, 5 uploads. So, if there are 11 uploads there will be 3 responses. 2 requests carrying 5 uploads, the last one carrying only 1.
         * MARK: We want to round up regardless the decimal value. If the value of `requestsBeingSent` is not a rounded decimal, that means that the last request won't carry the max of 5 images.
         * MARK: Example: If there are 11 images uploaded, that will result in 3 requests. 2 with 5 uploads the last having 1 upload. This will prompt the server to send back 3 responses. 11 / 5 = 2.2, with `.rounded(.up)` this will result in 3.
         * */
        let requestsBeingSent: Float = Float(imageUpload.count) / 5
        let totalResponsesExpected = Int(requestsBeingSent.rounded(.up))
        var totalResponses = 0
        var uploads = imageUpload
        
        while true {
            if total >= imageUpload.count || uploads.count == 0 { break }
            
            if mediaImages.count > 0 { mediaImages.removeAll() }
            
            for photo in uploads {
                if i >= 5 { /*totalResponsesExpected += 1;*/ break }
                
                mediaImages.append(Media(withImage: photo.first!.value, withName: photo.keys.first!, forKey: "file")!)
                
                uploads.remove(at: 0)
                
                i += 1
                total += 1
                
                /*for k in photo.keys {
                    mediaImages.append(Media(withImage: photo[k]!, withName: k, forKey: "file")!)
                }*/
            }
            
            i = 0
            
            let dataBody = createDataBody(media: mediaImages, boundary: boundary)
            request.httpBody = dataBody
            
            session.dataTask(with: request) { (data, response, error) in
                totalResponses += 1
                
                if let data = data {
                    /* Attempt to get a good response. */
                    let response = try? JSONDecoder().decode(UploadImagesGoodResponse.self, from: data)
                    
                    /* Attempt to get a bad response*/
                    let bresponse = try? JSONDecoder().decode(BadResponse.self, from: data)
                    
                    if let response = response {
                        /*DispatchQueue.main.async {
                            completion(ImageUploadRequestResponse(Good: response, Bad: nil))
                        }
                        return*/
                        responses.append(ImageUploadRequestResponse(Good: response, Bad: nil))
                        
                        if totalResponses == totalResponsesExpected {
                            //responses.append(ImageUploadRequestResponse(Good: response, Bad: nil))
                            DispatchQueue.main.async {
                                completion(responses)
                            }
                        }
                        return
                    }
                    
                    if let bresponse = bresponse {
                        responses.append(ImageUploadRequestResponse(Good: nil, Bad: bresponse))
                        
                        if totalResponses == totalResponsesExpected {
                            DispatchQueue.main.async {
                                completion(responses)
                            }
                        }
                        return
                    }
                } else {
                    responses.append(ImageUploadRequestResponse(
                        Good: nil,
                        Bad: BadResponse(
                            Status: "404",
                            ErrorCode: 0x1,
                            Message: "(Internal) Request Failed"
                        )
                    ))
                    
                    if totalResponses == totalResponsesExpected {
                        DispatchQueue.main.async {
                            completion(responses)
                        }
                    }
                    
                    return
                }
            }.resume()
        }
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
    
    /*func uploadImage(c: @escaping (ImageUploadRequestResponse) -> Void) {
        let boundary = "Boundary-\(UUID().uuidString)"
        let lineBreak = "\r\n"
        var urlRequest = URLRequest(
            url: URL(
                string: "http://192.168.1.114:8088/handle_uploads"
            )!
        )
        urlRequest.httpMethod = "post"
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(String(imageUpload.pngData()!.count), forHTTPHeaderField: "Content-Length")
    
        var requestData = Data()
        requestData.append("--\(boundary)")
        requestData.append("Content-Disposition: form-data; name=\"file\"; filename=\"mobileUpload.png\"\(lineBreak)")
        requestData.append("Content-Type: image/png\(lineBreak)")
        requestData.append(imageUpload.pngData()!)
        requestData.append("--\(boundary)--\(lineBreak)")
        
        let session = URLSession.shared
        
        /*session.uploadTask(with: urlRequest, from: requestData, completionHandler: { data, response, error in
            if error != nil {
                print("Error!")
                return
            }
            
            print(response!)
        }).resume()*/
        urlRequest.httpBody = requestData
        session.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print("ERROR")
                return
            }
            
            print(response!)
        }.resume()
    }*/
    
    /*func perform_upload2(completion: @escaping (ImageUploadRequestResponse) -> Void) {
        let boundary: String = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://www.eznotes.space/handle_uploads")!)
        
        request.httpMethod = "post"
        request.httpBody = makeMultipart(boundary)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if error == nil {
                let response1 = try? JSONDecoder().decode(GoodResponse.self, from: data!)
                print(response1!)
            }
            
            if let data = data {
                /* Attempt to get a good response. */
                let response = try? JSONDecoder().decode(UploadImagesGoodResponse.self, from: data)
                
                /* Attempt to get a bad response*/
                let bresponse = try? JSONDecoder().decode(BadResponse.self, from: data)
                
                /* Complete accordingly. */
                if let bresponse = bresponse {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: nil, Bad: bresponse))
                    }
                    return
                }
                
                if let response = response {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: response, Bad: nil))
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
    }*/
    
    /*func perform_upload(completion: @escaping (ImageUploadRequestResponse) -> Void) {
        let url = URL(string: "https://www.eznotes.space/handle_uploads")
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession.shared
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "post"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Accept")
        
        var data = Data()
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"mobile_upload.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(imageUpload.pngData()!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
        /*let _ = URLSession.shared.dataTask(with: urlRequest) { data, _, error in*/
            if error == nil {
                /* Attempt to get a good response. */
                let response = try? JSONDecoder().decode(UploadImagesGoodResponse.self, from: data)
                
                /* Attempt to get a bad response*/
                let bresponse = try? JSONDecoder().decode(BadResponse.self, from: data)

                print(response as Any, bresponse as Any)
                
                /* Complete accordingly. */
                if let bresponse = bresponse {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: nil, Bad: bresponse))
                    }
                    return
                }
                
                if let response = response {
                    DispatchQueue.main.async {
                        completion(ImageUploadRequestResponse(Good: response, Bad: nil))
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
        }).resume()
    }*/
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
        let server = "https://www.eznotes.space"//"http://192.168.0.8:8088"
        
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
        
        //let url = URL(string: "http://192.168.0.8:8088")//guard let url = components.url else { print("NO"); return }
        //var request = URLRequest(url: url!)
        
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
