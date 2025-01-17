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
let server = "http://192.168.1.109:8088"

/* MARK: Requestes structures for data to be given to the request header. */
/* Exists just in case we are performing a request that requires no data
 * to be sent to the endpoint.
 * */
struct ReqPlaceholder {}

struct GenerateFlashcardsData {
    let Topic: String
    let Notes: String
    let ScreenWidth: String
    let ScreenHeight: String
}

struct GenerateSlideshowData {
    let Topic: String
    let Notes: String
    let ScreenWidth: String
    let ScreenHeight: String
}

struct ReportProblemData {
    let AccountID: String
    let ContactEmail: String
    let ReportedProblem: String
}

struct GetClientsUsecaseReq {
    let AccountID: String
}

struct GetClientsMessagesData {
    let AccountId: String
}

struct SendMessageToFriendData {
    let AccountId: String
    let SendTo: String
    let MessageData: FriendMessageDetails
}

struct StartNewChatData {
    let AccountId: String
    let StartChatWith: String
}

struct SaveTagsData {
    let AccountId: String
    let Tags: String
}

struct RemoveTagData {
    let AccountId: String
    let TagToRemove: String
}

struct GetTagsData {
    let AccountId: String
}

struct GetAccountDescriptionData {
    let AccountId: String
}

struct SaveAccountDescriptionData {
    let AccountId: String
    let NewDescription: String
}

struct GetClientsUsernameData {
    let AccountId: String
}

struct GetUsersFriendsData {
    let ForUser: String
}

struct GetClientsFriendRequestsData {
    let AccountId: String
}

struct GetClientsPendingRequestsData {
    let AccountId: String
}

struct RemoveFriendRequest {
    let AccountId: String
    let CancelFor: String
}

struct RemoveFriendData {
    let AccountId: String
    let ToRemove: String
}

struct AcceptFriendRequestData {
    let AccountId: String
    let AcceptFrom: String
}

struct GetClientsFriendsData {
    let AccountId: String
}

struct GetUsersData {
    let AccountId: String
    let Filter: String
    let Usages: String
}

struct GetUsersAccountIdData {
    let Username: String
}

struct SearchUserData {
    let AccountId: String
    let Filter: String
    let Usages: String
    let Query: String
}

struct SendFriendRequestData {
    let AccountId: String
    let Username: String
    let RequestTo: String
}

struct IsFriendsOrHasSentFriendRequestData {
    let AccountId: String
    let Username: String
}

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
    let IP: String?
    let Usecase: String
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
    url: "\(server)/cl",
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

let get_user_req: CSIARequest = CSIARequest(
    url: "\(server)/get_users",
    method: "get",
    reqData: GetUsersData.self
)

let get_users_account_id_req: CSIARequest = CSIARequest(
    url: "\(server)/get_users_account_id",
    method: "get",
    reqData: GetUsersAccountIdData.self
)

let search_user_req: CSIARequest = CSIARequest(
    url: "\(server)/search_user",
    method: "get",
    reqData: SearchUserData.self
)

let send_friend_request_req: CSIARequest = CSIARequest(
    url: "\(server)/send_friend_request",
    method: "get",
    reqData: SendFriendRequestData.self
)

let is_friend_or_has_sent_friend_request_req: CSIARequest = CSIARequest(
    url: "\(server)/is_friend_or_has_sent_friend_request",
    method: "get",
    reqData: IsFriendsOrHasSentFriendRequestData.self
)

let get_clients_friend_requests_req: CSIARequest = CSIARequest(
    url: "\(server)/get_all_clients_friend_requestes",
    method: "get",
    reqData: GetClientsFriendRequestsData.self
)

let get_clients_pending_requests_req: CSIARequest = CSIARequest(
    url: "\(server)/get_all_clients_pending_requests",
    method: "get",
    reqData: GetClientsPendingRequestsData.self
)

let cancel_friend_request_req: CSIARequest = CSIARequest(
    url: "\(server)/cancel_friend_request",
    method: "get",
    reqData: RemoveFriendRequest.self
)

let accept_friend_request_req: CSIARequest = CSIARequest(
    url: "\(server)/accept_friend_request",
    method: "get",
    reqData: AcceptFriendRequestData.self
)

let get_clients_friends_req: CSIARequest = CSIARequest(
    url: "\(server)/get_all_clients_friends",
    method: "get",
    reqData: GetClientsFriendsData.self
)

let remove_friend_req: CSIARequest = CSIARequest(
    url: "\(server)/remove_friend",
    method: "get",
    reqData: RemoveFriendData.self
)

let get_clients_username_req: CSIARequest = CSIARequest(
    url: "\(server)/get_clients_username",
    method: "get",
    reqData: GetClientsUsernameData.self
)

let get_users_friends_req: CSIARequest = CSIARequest(
    url: "\(server)/get_all_users_friends",
    method: "get",
    reqData: GetUsersFriendsData.self
)

let get_account_description_req: CSIARequest = CSIARequest(
    url: "\(server)/get_account_description",
    method: "get",
    reqData: GetAccountDescriptionData.self
)

let save_account_description_req: CSIARequest = CSIARequest(
    url: "\(server)/save_account_description",
    method: "post",
    reqData: SaveAccountDescriptionData.self
)

let save_tags_req: CSIARequest = CSIARequest(
    url: "\(server)/add_tags",
    method: "get",
    reqData: SaveTagsData.self
)

let get_tags_req: CSIARequest = CSIARequest(
    url: "\(server)/get_tags",
    method: "get",
    reqData: GetTagsData.self
)

let start_chat_req: CSIARequest = CSIARequest(
    url: "\(server)/start_chat_with_user",
    method: "get",
    reqData: StartNewChatData.self
)

let send_message_req: CSIARequest = CSIARequest(
    url: "\(server)/send_message",
    method: "post",
    reqData: SendMessageToFriendData.self
)

let get_clients_messages_req: CSIARequest = CSIARequest(
    url: "\(server)/get_clients_messages",
    method: "get",
    reqData: GetClientsMessagesData.self
)

let get_clients_usecase_req: CSIARequest = CSIARequest(
    url: "\(server)/get_usecase",
    method: "get",
    reqData: GetClientsUsecaseReq.self
)

let remove_tag_req: CSIARequest = CSIARequest(
    url: "\(server)/remove_tag",
    method: "get",
    reqData: RemoveTagData.self
)

let feedback_req: CSIARequest = CSIARequest(
    url: "\(server)/feedback",
    method: "post", /* MARK: Sends data in JSON format. */
    reqData: ReportProblemData.self
)

let generate_flashcards_req: CSIARequest = CSIARequest(
    url: "\(server)/generate_flashcards",
    method: "post", /* MARK: Sends data in JSON format. */
    reqData: GenerateFlashcardsData.self
)

let generate_slideshow_req: CSIARequest = CSIARequest(
    url: "\(server)/generate_slideshow",
    method: "post", /* MARK: Sends data in JSON format. */
    reqData: GenerateSlideshowData.self
)
