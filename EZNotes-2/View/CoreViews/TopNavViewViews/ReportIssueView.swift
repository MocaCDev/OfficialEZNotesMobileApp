//
//  ReportIssueView.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/7/24.
//
import SwiftUI

enum ReportIssueStatus {
    case None
    case UnableToAcceptError
    case MissingDataError
    case Success
}

struct ReportIssue: View {
    @EnvironmentObject private var accountInfo: AccountDetails
    
    var prop: Properties
    
    @Binding public var accountPopupSection: String
    
    @State private var name: String = ""
    @FocusState private var nameFieldInFocus: Bool
    @State private var nameTextOpacity: CGFloat = 0
    
    @State private var emailToContact: String = ""
    @FocusState private var emailFieldInFocus: Bool
    @State private var emailTextOpacity: CGFloat = 0
    @State private var useEmailLinkedToAccount: Bool = false
    
    @State private var reportedProblem: String = ""
    @FocusState private var reportedProblemFieldInFocus: Bool
    @State private var reportedProblemTextOpacity: CGFloat = 0
    
    @State private var keyboardHeight: CGFloat = 0
    private func setupKeyboardListeners() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                /*if self.isLoggingIn {
                    keyboardHeight = keyboardFrame.height - 86
                } else {
                    if keyboardFrame.height > keyboardHeight && keyboardHeight != 0 {
                        let difference = keyboardFrame.height - keyboardHeight
                        keyboardHeight = keyboardFrame.height - difference
                        return
                    }
                    
                    keyboardHeight = keyboardFrame.height
                }*/
                if keyboardFrame.height > keyboardHeight && keyboardHeight != 0 {
                    let difference = keyboardFrame.height - keyboardHeight
                    keyboardHeight = keyboardFrame.height - difference
                    return
                }
                
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
        
    private func removeKeyboardListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @State private var submittingFeedback: Bool = false
    @State private var submitFeedbackStatus: ReportIssueStatus = .None
    @State private var successOpacity: CGFloat = 1
    
    @State private var feedbackFormOpacity: CGFloat = 1
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                .background(
                    Image("DefaultThemeBg3")
                        .resizable()
                        .scaledToFill()
                )
                .padding(.top, 70)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)
            
            VStack {
                HStack {
                    Button(action: {
                        self.accountPopupSection = "main"
                        self.removeKeyboardListeners()
                    }) {
                        ZStack {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 20, alignment: .leading)
                        .padding(.top, 15)
                        .padding(.leading, 25)
                    }
                    
                    Text("Report Issue")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding([.top], 15)
                        .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                        
                    /* MARK: "spacing" to ensure above Text stays in the middle. */
                    ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(.top, prop.isLargerScreen ? 55 : prop.isMediumScreen ? 45 : 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if self.submitFeedbackStatus == .Success {
                VStack {
                    Spacer()
                    
                    Image(systemName: "envelope.badge")
                        .resizable()
                        .frame(width: 65, height: 50)
                        .foregroundStyle(Color.EZNotesGreen)
                        .padding(.bottom)
                    
                    Text("Your feedback has been recieved.")
                        .frame(maxWidth: prop.size.width - 40, alignment: .center)
                        .font(.system(size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))//(Font.custom("Poppins-Regular", size: prop.isLargerScreen || prop.isMediumScreen ? 16 : 14))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .opacity(self.successOpacity)
                .animation(.easeOut(duration: 0.8), value: self.successOpacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeOut(duration: 0.8)) { self.successOpacity = 0 }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            self.submitFeedbackStatus = .None
                            
                            withAnimation(.smooth(duration: 0.8)) { self.feedbackFormOpacity = 1 }
                        }
                    }
                }
            } else {
                VStack {
                    /*Text("Name")
                        .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                        .foregroundStyle(.white)
                        .opacity(self.nameTextOpacity)
                        .animation(self.nameTextOpacity == 1 ? .smooth(duration: 0.8) : .easeOut(duration: 0.8), value: self.nameTextOpacity)
                        .padding(.top, self.nameTextOpacity == 1 ? 8 : 0)
                    
                    TextField("", text: $name)
                        .frame(maxWidth: prop.size.width - 70)
                        .padding(.bottom, 6.5)
                    //.padding(.horizontal, 12)
                        .font(.system(size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                        .foregroundStyle(.white)
                    /*.padding(8)
                     .padding(.horizontal, 6)
                     .background(Color(.systemGray6))
                     .cornerRadius(15)*/
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .borderBottomWLMutableByFocus(
                                    isError: false,
                                    inFocus: self.nameFieldInFocus,
                                    width: 0.5
                                )//.borderBottomWLColor(isError: self.loginError == .InvalidUserError || self.loginError == .EmptyUsername, width: 0.5)
                        )
                        .overlay(
                            HStack {
                                if self.name.isEmpty && !self.nameFieldInFocus {
                                    Text("Name...")
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 15,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(Color(.systemGray2))
                                        .padding(.leading, 5)//18)
                                        .padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                        .onTapGesture { self.nameFieldInFocus = true }
                                    
                                    Spacer()
                                } else {
                                    if self.name.isEmpty {
                                        Text("Name...")
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 15,
                                                    weight: .medium
                                                )
                                            )
                                            .foregroundStyle(Color(.systemGray2))
                                            .padding(.leading, 5)//18)
                                            .padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                            .onTapGesture { self.nameFieldInFocus = true }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .padding(.bottom, self.emailTextOpacity == 0 ? -26 : 8)
                        .padding(.top, self.nameTextOpacity == 1 ? -4 : 0)
                        .focused($nameFieldInFocus)
                        .onChange(of: self.name) {
                            if !self.name.isEmpty {
                                withAnimation(.smooth(duration: 0.8)) { self.nameTextOpacity = 1 }
                            } else {
                                withAnimation(.easeOut(duration: 0.8)) { self.nameTextOpacity = 0 }
                            }
                        }*/
                    
                    Text("Contact Email")
                        .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                        .foregroundStyle(.white)
                        .opacity(self.emailTextOpacity)
                        .animation(self.emailTextOpacity == 1 ? .smooth(duration: 0.8) : .easeOut(duration: 0.8), value: self.emailTextOpacity)
                        .padding(.top, self.emailTextOpacity == 1 ? 16 : 0)
                    
                    TextField("", text: $emailToContact)
                        .frame(maxWidth: prop.size.width - 70)
                        .padding(.bottom, 6.5)
                    //.padding(.horizontal, 12)
                        .font(.system(size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                        .foregroundStyle(.white)
                    /*.padding(8)
                     .padding(.horizontal, 6)
                     .background(Color(.systemGray6))
                     .cornerRadius(15)*/
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.clear)
                                .borderBottomWLMutableByFocus(
                                    isError: false,
                                    inFocus: self.emailFieldInFocus,
                                    width: 0.5
                                )//.borderBottomWLColor(isError: self.loginError == .InvalidUserError || self.loginError == .EmptyUsername, width: 0.5)
                        )
                        .overlay(
                            HStack {
                                if self.emailToContact.isEmpty && !self.emailFieldInFocus {
                                    Text("Email we can contact...")
                                        .font(
                                            .system(
                                                size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 15,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(Color(.systemGray2))
                                        .padding(.leading, 5)//18)
                                        .padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                        .onTapGesture { self.emailFieldInFocus = true }
                                    
                                    Spacer()
                                } else {
                                    if self.emailToContact.isEmpty {
                                        Text("Email we can contact...")
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 15,
                                                    weight: .medium
                                                )
                                            )
                                            .foregroundStyle(Color(.systemGray2))
                                            .padding(.leading, 5)//18)
                                            .padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                            .onTapGesture { self.emailFieldInFocus = true }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        )
                        .padding(.bottom, 8)
                        .padding(.top, self.emailTextOpacity == 1 ? -4 : 0)
                        .focused($emailFieldInFocus)
                        .onChange(of: self.emailToContact) {
                            if !self.emailToContact.isEmpty {
                                withAnimation(.smooth(duration: 0.8)) { self.emailTextOpacity = 1 }
                            } else {
                                withAnimation(.easeOut(duration: 0.8)) { self.emailTextOpacity = 0 }
                            }
                        }
                    
                    Toggle(isOn: $useEmailLinkedToAccount) {
                        Text("Use email linked with account")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: prop.size.width - 70, alignment: .leading)
                    .toggleStyle(CheckBox())
                    .foregroundStyle(Color.EZNotesBlue)
                    .padding(.bottom, 20)
                    .onChange(of: self.useEmailLinkedToAccount) {
                        if self.useEmailLinkedToAccount {
                            self.emailToContact = self.accountInfo.email
                        } else {
                            if self.emailToContact == self.accountInfo.email { self.emailToContact.removeAll() }
                        }
                    }
                    
                    Text("Briefly explain your issue")
                        .frame(maxWidth: prop.size.width - 60, alignment: .leading)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                        .foregroundStyle(.white)
                        .overlay(
                            self.emailToContact.isEmpty ? AnyView(Color.black.opacity(0.8)) : AnyView(Color.clear)
                        )
                    
                    TextField("", text: $reportedProblem, axis: .vertical)
                        .frame(maxWidth: prop.size.width - 70)
                        .lineLimit(prop.isLargerScreen || prop.isMediumScreen ? 5...10 : 4...7) /* MARK: This is not adherent to smaller screens. Change it. */
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                    /*.padding(.horizontal, 12)
                     .font(.system(size: prop.isLargerScreen || prop.isMediumScreen ? 18 : 16))
                     .foregroundStyle(.white)
                     .padding(8)
                     .padding(.horizontal, 6)*/
                        .padding(12)
                        .background(Color.EZNotesLightBlack)
                        .cornerRadius(15)
                        .focused($reportedProblemFieldInFocus)
                        .overlay(
                            VStack {
                                HStack {
                                    if self.reportedProblem.isEmpty && !self.reportedProblemFieldInFocus {
                                        Text("I am having issues with...")
                                            .font(
                                                .system(
                                                    size: prop.isLargerScreen || prop.isMediumScreen ? 16 : 14
                                                )
                                            )
                                            .foregroundStyle(Color(.systemGray2))
                                            .padding([.top, .leading], 12)
                                        //.padding(.leading)
                                        //.padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                            .onTapGesture { self.reportedProblemFieldInFocus = true }
                                        
                                        Spacer()
                                    } else {
                                        if self.reportedProblem.isEmpty {
                                            Text("I am having issues with...")
                                                .font(
                                                    .system(
                                                        size: prop.isLargerScreen || prop.isMediumScreen ? 16 : 14
                                                    )
                                                )
                                                .foregroundStyle(Color(.systemGray2))
                                                .padding([.top, .leading], 12)
                                            //.padding(.leading, 16)
                                            //.padding(.bottom, 6.5) /* MARK: Exists to follow the padding on the actual textfield. */
                                                .onTapGesture { self.reportedProblemFieldInFocus = true }
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                Spacer()
                            }
                        )
                        .overlay(
                            self.emailToContact.isEmpty ? AnyView(Color.black.opacity(0.8)) : AnyView(Color.clear)
                        )
                    
                    Spacer()
                    
                    //Spacer()
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                .padding(.top, prop.isLargerScreen ? 110 : prop.isMediumScreen ? 100 : 90)
                .opacity(self.feedbackFormOpacity)
                .animation(.smooth(duration: 0.8), value: self.feedbackFormOpacity)
                .onAppear {
                    self.nameFieldInFocus = true /* MARK: Automatically force focus on the name textfield. */
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        //if self.emailToContact.isEmpty || self.reportedProblem.isEmpty { return }
                        
                        /* TODO: Add request to server to save the report. */
                        self.submittingFeedback = true
                        RequestAction<ReportProblemData>(parameters: ReportProblemData(
                            AccountID: self.accountInfo.accountID,
                            ContactEmail: self.emailToContact,
                            ReportedProblem: self.reportedProblem
                        )).perform(action: feedback_req) { statusCode, resp in
                            self.submittingFeedback = false
                            guard
                                resp != nil,
                                statusCode == 200
                            else {
                                if let resp = resp { print(resp) }
                                return /* TODO: Add ability to display error, if any occurr. */
                            }
                            
                            /* MARK: Remove all the content from the form. */
                            self.name.removeAll()
                            self.emailToContact.removeAll()
                            self.reportedProblem.removeAll()
                            
                            self.submitFeedbackStatus = .Success
                            self.feedbackFormOpacity = 0
                        }
                    }) {
                        HStack {
                            if !self.submittingFeedback {
                                Text("Submit")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.black)
                                    .setFontSizeAndWeight(weight: .bold, size: 18)
                                    .minimumScaleFactor(0.5)
                            } else {
                                LoadingView(tint: Color.EZNotesBlack)
                            }
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        .padding([.top, .bottom], 8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                        )
                        .cornerRadius(15)
                        .overlay(
                            self.emailToContact.isEmpty || self.reportedProblem.isEmpty ? AnyView(Color.black.opacity(0.8)) : AnyView(Color.clear)
                        )
                        .padding(.bottom, self.keyboardHeight == 0 ? 30 : self.keyboardHeight + 15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { self.setupKeyboardListeners() }
        .onDisappear { self.removeKeyboardListeners() }
    }
}
