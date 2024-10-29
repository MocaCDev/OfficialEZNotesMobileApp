//
//  RequestsAndResponses.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import Foundation
import SwiftUI

/* MARK: URLs used for requests. */
//let server = "https://www.eznotes.space"
//let server = "http://192.168.1.114:8088"
let server = "http://192.168.0.11:8088"//"http://192.168.1.114:8088"

/* MARK: Requestes structures for data to be given to the request header. */
/* Exists just in case we are performing a request that requires no data
 * to be sent to the endpoint.
 * */
struct ReqPlaceholder {}

struct LoginRequestData {
    let Username: String
    let Password: String
}

struct GetEmailData {
    let AccountId: String
}

struct StartAIChatData {
    let AccountId: String
}

struct SendAIChatMessageData {
    let AccountId: String
    let Message: String
}

struct SavePFPData {
    
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

/* MARK: All request actions. */
struct CSIARequest<T> {
    let url: String
    let method: String
    let reqData: T.Type
}

let check_server_active_req: CSIARequest = CSIARequest(
    url: "\(server)/EZNotes_Software_Network_Test",
    method: "get",
    reqData: ReqPlaceholder.self
)

let get_supported_states_req: CSIARequest = CSIARequest(
    url: "\(server)/get_supported_states",
    method: "get",
    reqData: ReqPlaceholder.self
)

let get_colleges_for_state_req: CSIARequest = CSIARequest(
    url: "\(server)/get_colleges_for_state",
    method: "get",
    reqData: GetCollegesRequest.self
)

let complete_login_req: CSIARequest = CSIARequest(
    url: "\(server)/mobile_cl",
    method: "post",
    reqData: LoginRequestData.self
)

let complete_signup1_req: CSIARequest = CSIARequest(
    url: "\(server)/csu",
    method: "post",
    reqData: SignUpRequestData.self
)

let complete_signup2_req: CSIARequest = CSIARequest(
    url: "\(server)/csu2",
    method: "post",
    reqData: SignUp2RequestData.self
)

let get_user_email_req: CSIARequest = CSIARequest(
    url: "\(server)/get_user_email",
    method: "get",
    reqData: GetEmailData.self
)

let start_ai_chat_req: CSIARequest = CSIARequest(
    url: "\(server)/mobile_start_aichat",
    method: "get",
    reqData: StartAIChatData.self
)

let send_ai_chat_message_req: CSIARequest = CSIARequest(
    url: "\(server)/mobile_send_aichat",
    method: "post",
    reqData: SendAIChatMessageData.self
)
