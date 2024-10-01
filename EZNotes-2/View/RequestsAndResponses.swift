//
//  RequestsAndResponses.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import Foundation
import SwiftUI

/* Exists just in case we are performing a request that requires no data
 * to be sent to the endpoint.
 * */
struct ReqPlaceholder {}

struct LoginRequestData {
    let Username: String
    let Password: String
}

struct SignUpRequestData {
    let Username: String
    let Email: String
    let Password: String
    let College: String
    let State: String
}

struct SignUp2RequestData {
    let AccountID: String
    let UserInputtedCode: String
}

struct GetCollegesRequest {
    let State: String
}

struct UploadImagesRequest {
    let Uploads: Array<UIImage>
}

struct UploadImagesData: Decodable {
    let category: String
    let set_name: String
    let image_content: String
    let brief_description: String
    let image_name: String
}

struct UploadImagesGoodResponse: Decodable {
    let Status: String
    let Data: Array<UploadImagesData>
}

struct GoodResponse: Decodable {
    let Status: String
    let Message: String
}

struct BadResponse: Decodable {
    let Status: String
    let ErrorCode: Int
    let Message: String
}

struct RequestResponse: Decodable {
    let Good: GoodResponse?
    let Bad: BadResponse?
}

struct ImageUploadRequestResponse: Decodable {
    let Good: UploadImagesGoodResponse?
    let Bad: BadResponse?
}
