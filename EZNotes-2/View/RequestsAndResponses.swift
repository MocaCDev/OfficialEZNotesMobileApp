//
//  RequestsAndResponses.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import Foundation
import SwiftUI

/* MARK: URLs used for requests. */
let server = "https://www.eznotes.space"
//let server = "http://192.168.1.109:8088"

/* MARK: Requestes structures for data to be given to the request header. */
/* Exists just in case we are performing a request that requires no data
 * to be sent to the endpoint.
 * */
struct ReqPlaceholder {}

struct SummarizeNotesData {
    let OriginalNotes: String
    let EditedNotes: String
}

struct ReWordNotesData {
    let Notes: String
}

struct DetectPossibleSimilarCategories {
    let NewCategories: Array<String>
    let ExistingCategories: Array<String>
}

struct CheckStateHasCollege {
    let State: String
    let College: String
}

struct UpdateCollegeNameData {
    let NewCollegeName: String
    let AccountID: String
}

struct UpdateMajorFieldData {
    let NewMajorField: String
    let AccountID: String
}

struct UpdateMajorData {
    let NewMajor: String
    let AccountID: String
}

struct UpdateStateData {
    let NewState: String
    let AccountID: String
}

struct UpdateUsernameData {
    let NewUsername: String
    let AccountID: String
}

struct UpdatePasswordData {
    let OldPassword: String
    let NewPassword: String
    let AccountID: String
}

struct CheckUsernameRequestData {
    let Username: String
}

struct CheckEmailRequestData {
    let Email: String
}

struct LoginRequestData {
    let Username: String
    let Password: String
}

struct GetEmailData {
    let AccountId: String
}

struct StartAIChatData {
    let AccountId: String
    let Major: String
    let Topic: String
}

struct StartAIChatOverNotesData {
    let Notes: String
}

struct SendAIChatMessageData {
    let ChatID: UUID
    let AccountId: String
    let Message: String
}

struct DeleteSignupProcessData {
    let AccountID: String
}

struct SignUpRequestData {
    let Username: String
    let Email: String
    let Password: String
    let College: String
    let State: String
    let Field: String
    let Major: String
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

struct GetSubscriptionInfoData {
    let AccountID: String
}

struct UploadImagesData: Decodable {
    let category: String
    let set_name: String
    let image_content: String
    let brief_description: String
    let image_name: String
    let notes: String
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

struct GenerateDescRequestData {
    let Subject: String
}

struct GetCollegesRequestData {
    let State: String
}

struct GetMajorsRequestData {
    let College: String
    let MajorField: String
}

struct GetCustomMajorsRequestData {
    let CMajorField: String /* MARK: `CMajorField` stands for Custom Major Field. This is if the user puts in a custom field for their major. */
}

struct GetCustomTopicsData {
    let Major: String
}

struct GetCustomCollegeFieldsData {
    let State: String
    let College: String
}

struct SaveChatHistoryData {
    let AccountID: String
    let ChatTitle: String
    let ChatHistory: Array<MessageDetails>
}

/* MARK: All request actions. */
struct CSIARequest<T> {
    let url: String
    let method: String
    let reqData: T.Type
}

let check_username_req: CSIARequest = CSIARequest(
    url: "\(server)/cu",
    method: "get",
    reqData: CheckUsernameRequestData.self
)

let check_email_req: CSIARequest = CSIARequest(
    url: "\(server)/ce",
    method: "get",
    reqData: CheckEmailRequestData.self
)

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

let start_ai_chat_over_notes_req: CSIARequest = CSIARequest(
    url: "\(server)/mobile_start_aichat_over_notes",
    method: "post",
    reqData: StartAIChatOverNotesData.self
)

let send_ai_chat_message_req: CSIARequest = CSIARequest(
    url: "\(server)/mobile_send_aichat",
    method: "post",
    reqData: SendAIChatMessageData.self
)

let generate_desc_req: CSIARequest = CSIARequest(
    url: "\(server)/get_description_for_subject",
    method: "get",
    reqData: GenerateDescRequestData.self
)

let get_colleges: CSIARequest = CSIARequest(
    url: "\(server)/get_colleges",
    method: "get",
    reqData: GetCollegesRequestData.self
)

let get_major_fields_req: CSIARequest = CSIARequest(
    url: "\(server)/get_major_categories",
    method: "get",
    reqData: ReqPlaceholder.self
)

let get_majors_req: CSIARequest = CSIARequest(
    url: "\(server)/get_majors",
    method: "get",
    reqData: GetMajorsRequestData.self
)

let get_custom_majors_req: CSIARequest = CSIARequest(
    url: "\(server)/generate_majors_for_custom_major_field",
    method: "get",
    reqData: GetCustomMajorsRequestData.self
)

let get_custom_college_fields_req: CSIARequest = CSIARequest(
    url: "\(server)/generate_fields_for_custom_college",
    method: "get",
    reqData: GetCustomCollegeFieldsData.self
)

let check_college_exists_in_state_req: CSIARequest = CSIARequest(
    url: "\(server)/check_college_exists_in_state",
    method: "get",
    reqData: CheckStateHasCollege.self
)

let get_custom_topics_req: CSIARequest = CSIARequest(
    url: "\(server)/generate_topics",
    method: "get",
    reqData: GetCustomTopicsData.self
)

let save_chat_req: CSIARequest = CSIARequest(
    url: "\(server)/save_chat_history",
    method: "post",
    reqData: SaveChatHistoryData.self
)

let delete_signup_process_req: CSIARequest = CSIARequest(
    url: "\(server)/delete_temp_account_data",
    method: "post",
    reqData: DeleteSignupProcessData.self
)

let get_subscription_info_req: CSIARequest = CSIARequest(
    url: "\(server)/get_subscription_information",
    method: "get",
    reqData: GetSubscriptionInfoData.self
)

let update_college_name_req: CSIARequest = CSIARequest(
    url: "\(server)/update_users_college_name",
    method: "post",
    reqData: UpdateCollegeNameData.self
)

let update_major_field_req: CSIARequest = CSIARequest(
    url: "\(server)/update_users_major_field",
    method: "post",
    reqData: UpdateMajorFieldData.self
)

let update_major_req: CSIARequest = CSIARequest(
    url: "\(server)/update_users_major",
    method: "post",
    reqData: UpdateMajorData.self
)

let update_state_req: CSIARequest = CSIARequest(
    url: "\(server)/update_users_state",
    method: "post",
    reqData: UpdateStateData.self
)

let update_username_req: CSIARequest = CSIARequest(
    url: "\(server)/update_username",
    method: "post",
    reqData: UpdateUsernameData.self
)

let update_password_req: CSIARequest = CSIARequest(
    url: "\(server)/update_password",
    method: "post",
    reqData: UpdatePasswordData.self
)

let summarize_notes_req: CSIARequest = CSIARequest(
    url: "\(server)/summarize_changes_to_notes",
    method: "post",
    reqData: SummarizeNotesData.self
)

let reword_notes_req: CSIARequest = CSIARequest(
    url: "\(server)/reword_edited_notes",
    method: "post",
    reqData: ReWordNotesData.self
)

let detect_possible_similar_categories_req: CSIARequest = CSIARequest(
    url: "\(server)/detect_possible_similar_categories",
    method: "post",
    reqData: DetectPossibleSimilarCategories.self
)
