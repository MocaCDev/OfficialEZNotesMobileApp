//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI
import Combine
import WebKit

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0
    
    func body(content: Content) -> some View {
        // 1.
        GeometryReader { geometry in
            content
                //.padding(.bottom, self.bottomPadding)
                // 2.
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    // 3.
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    // 4.
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    // 5.
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
            }
            // 6.
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct SignUpScreen : View, KeyboardReadable {
    @Environment(\.presentationMode) var presentationMode
    
    public var prop: Properties
    
    @State private var showPopup: Bool = false
    
    public var startupScreen: StartupScreen
    
    @Binding public var screen: String
    @Binding public var userHasSignedIn: Bool
    @Binding public var serverError: Bool
    @Binding public var supportedStates: Array<String>
    @State public var supportedColleges: Array<String> = []
    
    @State public var keyboardActivated: Bool = false
    
    @State public var planID: String = ""
    @State public var collegesPickerOpacity: Double  = 0.0
    @State public var accountID: String = ""
    @State public var userInputedCode: String = ""
    @State public var wrongCode: Bool = false
    @State public var userExists: Bool = false
    @State public var username: String = ""
    @State public var email: String = ""
    @State public var password: String = ""
    @State public var college: String = ""
    @State public var major: String = ""
    @State public var state: String = ""
    @State public var section: String = "select_plan"
    @State public var makeContentRed: Bool = false
    
    @State public var imageOpacity: Double = 1
    @FocusState public var passwordFieldInFocus: Bool
    
    @State private var isLargerScreen: Bool = false
    
    @State private var isPlanPicked: Bool = false
    @State private var planPicked: String = ""
    @State private var cardHolderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvc: String = ""
    @State private var lastCardNumberLength: Int = 0
    @State private var cardNumberIndex: Int = 0
    @State private var showPrivacyPolicy: Bool = false
    
    var borderBottomColor: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesBlue, Color.EZNotesOrange]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    var borderBottomColorError: LinearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color.EZNotesRed, Color.EZNotesRed]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func set_image_opacity(focused: Bool)
    {
        imageOpacity = focused ? 0.0 : 1.0;
    }
    
    private func setLoginStatus() -> Void {
        UserDefaults.standard.set(
            true,
            forKey: "logged_in"
        )
        UserDefaults.standard.set(
            self.accountID,
            forKey: "account_id"
        )
        self.userHasSignedIn = true
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // VStack with TextFields
                VStack {
                    Text(self.section != "select_plan" ? "Sign Up" : "Plans")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        .foregroundStyle(.white)
                        .font(
                            .system(
                                size: prop.isIpad
                                    ? 90
                                    : self.isLargerScreen
                                        ? 40
                                        : 30
                            )
                        )
                        .fontWeight(.bold)
                    
                    Text(
                        self.wrongCode
                            ? "Wrong code. Try again"
                            : self.userExists
                                ? "A user with the email and/or username you provided already exists"
                                : self.section == "main"
                                    ? "Sign up with a unique username, your email and a unique password"
                                    : self.section == "select_state_and_college"
                                        ? "Tell us about your college and your degree :)"
                                        : self.section == "code_input"
                                            ? "A code has been sent to your email. Input the code below"
                                            : "Select a plan that best suits you"
                    )
                    .frame(maxWidth: prop.size.width - 30, minHeight: 45, alignment: .center)
                    .foregroundStyle(self.wrongCode || self.userExists ? Color.red : Color.white)
                    .font(
                        .system(
                            size: prop.isIpad || self.isLargerScreen
                                ? 15
                                : 13
                        )
                    )
                    .multilineTextAlignment(.center)
                    
                    VStack {
                        if self.section == "main" {
                            Text("Username")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 10)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 22
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField("Username...", text: $username)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding()
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.alphabet)
                            
                            Text("Email")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 22
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField("Email...", text: $email)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                                ? self.userExists ? self.borderBottomColorError : self.borderBottomColor
                                                : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding()
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                            
                            Text("Password")
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(
                                    .system(
                                        size: self.isLargerScreen ? 25 : 22
                                    )
                                )
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            SecureField("Password...", text: $password)
                                .frame(
                                    width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                    : prop.size.width - 100,
                                    height: self.isLargerScreen ? 40 : 30
                                )
                                .padding([.leading], 15)
                                .background(
                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                        .border(
                                            width: 1,
                                            edges: [.bottom],
                                            lcolor: !self.makeContentRed
                                            ? self.borderBottomColor
                                            : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                        )
                                )
                                .foregroundStyle(Color.EZNotesBlue)
                                .padding()
                                .tint(Color.EZNotesBlue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .focused($passwordFieldInFocus)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else if self.section == "select_state_and_college" {
                            Text("State")
                                .frame(
                                    width: prop.isIpad
                                        ? prop.size.width - 450
                                        : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .padding([.top], 10)
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField(
                                "State name...",
                                text: $state,
                                onEditingChanged: set_image_opacity
                            )
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: self.isLargerScreen ? 40 : 30
                            )
                            .padding([.leading], 15)
                            .background(
                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                    .border(
                                        width: 1,
                                        edges: [.bottom],
                                        lcolor: !self.makeContentRed
                                            ? self.borderBottomColor
                                            : self.state == "" ? self.borderBottomColorError : self.borderBottomColor
                                    )
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .padding()
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            
                            Text("College Being Attended")
                                .frame(
                                    width: prop.isIpad
                                        ? prop.size.width - 450
                                        : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField(
                                "College name...",
                                text: $college,
                                onEditingChanged: set_image_opacity
                            )
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: self.isLargerScreen ? 40 : 30
                            )
                            .padding([.leading], 15)
                            .background(
                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                    .border(
                                        width: 1,
                                        edges: [.bottom],
                                        lcolor: !self.makeContentRed
                                            ? self.borderBottomColor
                                            : self.college == "" ? self.borderBottomColorError : self.borderBottomColor
                                    )
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .padding()
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            
                            Text("Major")
                                .frame(
                                    width: prop.isIpad
                                        ? prop.size.width - 450
                                        : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                                .fontWeight(.medium)
                            
                            TextField(
                                "Major...",
                                text: $major,
                                onEditingChanged: set_image_opacity
                            )
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: self.isLargerScreen ? 40 : 30
                            )
                            .padding([.leading], 15)
                            .background(
                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                    .border(
                                        width: 1,
                                        edges: [.bottom],
                                        lcolor: !self.makeContentRed
                                            ? self.borderBottomColor
                                            : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                    )
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .padding()
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        } else if self.section == "code_input" {
                            Text("Code")
                                .frame(
                                    width: prop.isIpad
                                        ? prop.size.width - 450
                                        : prop.size.width - 100,
                                    height: 5,
                                    alignment: .leading
                                )
                                .padding(.top, 15)
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                            
                            TextField(
                                "Code...",
                                text: $userInputedCode,
                                onEditingChanged: set_image_opacity
                            )
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: self.isLargerScreen ? 40 : 30
                            )
                            .padding([.leading], 15)
                            .background(
                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                    .border(
                                        width: 1,
                                        edges: [.bottom],
                                        lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                    )
                            )
                            .foregroundStyle(Color.EZNotesBlue)
                            .padding()
                            .tint(Color.EZNotesBlue)
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.numberPad)
                            .onChange(of: self.userInputedCode) {
                                /* Codes are 6-digits. */
                                if self.userInputedCode.count > 6 { self.userInputedCode = String(self.userInputedCode.prefix(6)) }
                            }
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                    VStack {
                                        VStack {
                                            Text("Basic Plan")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.black)
                                                .padding([.top, .bottom])
                                                .font(.system(size: 24))
                                                .fontWeight(.bold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                        
                                        VStack {
                                            VStack {
                                                Text("Description")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                /*Text("The Basic Plan includes all of the fundamental features that a user will need to automate the note taking process.")*/
                                                Text("The Basic Plan equips you with all the fundamentals that the app comes with.\nIt enables you to uploads roughly 100 images of notes at once and backup roughly 450K notes. You also get access to EZNotes Chatbot which can be your personal tutor through your note taking and studying adventures.")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding([.bottom, .leading], 10)
                                                    .font(.system(size: 14))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.light)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding(.leading)
                                            
                                            VStack {
                                                Text("Uploads:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• 1gb Upload Limit\n\t◦ 100 Image Upload Limit\n• 5gb Backup Limit\n\t◦ Roughly 450K notes can be backed up")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading])
                                            
                                            VStack {
                                                Text("AI Access:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• EZNotes LLM\n\t◦ Powers the automated note-curation\n• EZNotes Chatbot\n\t◦ Your personal tutor")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading])
                                            
                                            VStack {
                                                Text("Built-in Features:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• Essay Helper\n• Note Curation")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading, .bottom])
                                        }
                                        .padding()
                                        
                                        HStack {
                                            VStack {
                                                Button(action: {
                                                    self.isPlanPicked = true
                                                    self.planPicked = "basic_plan_monthly"
                                                }) {
                                                    Text("Select Monthly")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $10.50/month")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            VStack {
                                                Button(action: {
                                                    self.isPlanPicked = true
                                                    self.planPicked = "basic_plan_annually"
                                                }) {
                                                    Text("Select Annually")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $120/year")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                        .padding(.bottom)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .cornerRadius(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)
                                            .shadow(color: .black, radius: 2.5)
                                    )
                                    .padding(.bottom, 15)
                                    
                                    VStack {
                                        VStack {
                                            Text("Pro Plan")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.black)
                                                .padding([.top, .bottom])
                                                .font(.system(size: 24))
                                                .fontWeight(.bold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            MeshGradient(width: 3, height: 3, points: [
                                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                                            ], colors: [
                                                Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                                                Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                                                Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                                                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                            ])
                                        )
                                        
                                        VStack {
                                            VStack {
                                                Text("Description")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                /*Text("The Pro Plan is **coming soon**. The plan builds on top of the Basic Plan giving 2x upload and backup limits; further, the Pro Plan gives users access to a multitude of helpful features that allows for a more feasible experience when studying/doing homework. See the features to the right.")*/
                                                Text("The Pro Plan equips you with everything from the Basic Plan and more.\nWith the Pro Plan, you get 2x the limit on the uploads and backups enabling you to upload 200+ images of notes at once and enabling you to store roughly 1M curated sets of notes. Further, the Pro Plan equips you with a model of EZNotes AI that is capable of adapting to your handwriting and curating a essay in your handwriting.")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding([.bottom, .leading], 10)
                                                    .font(.system(size: 14))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.light)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding(.leading)
                                            
                                            VStack {
                                                Text("Uploads:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• 2gb Upload Limit\n\t◦ 200-250 Image Upload Limit\n• 10gb Backup Limit\n\t◦ Roughly 1M notes can be backed up")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading])
                                            
                                            VStack {
                                                Text("AI Access:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• EZNotes LLM\n\t◦ Powers the automated note-curation\n• EZNotes Chatbot\n\t◦ Your personal tutor")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading])
                                            
                                            VStack {
                                                Text("Built-in Features:")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 18))
                                                    .fontWeight(.semibold)
                                                
                                                Text("• Essay Helper\n• Handwritten Note Curation\n• Integrated Note-taking Styles\n• Note Curation")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .padding(.top, 5)
                                                    .padding(.leading, 10)
                                                    .font(.system(size: 15))
                                                    .minimumScaleFactor(0.5)
                                            }
                                            .padding([.top, .leading, .bottom])
                                        }
                                        .padding()
                                        
                                        HStack {
                                            VStack {
                                                Button(action: { print("Select Pro Plan") }) {
                                                    Text("Select Monthly")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $16/month")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            VStack {
                                                Button(action: { print("Select Pro Plan") }) {
                                                    Text("Select Annually")
                                                        .frame(maxWidth: (prop.size.width - 40) - 40, alignment: .center)
                                                        .foregroundStyle(.white)
                                                        .padding([.top, .bottom], 8)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 20, design: .rounded))
                                                        .fontWeight(.semibold)
                                                }
                                                .buttonStyle(NoLongPressButtonStyle())
                                                .background(
                                                    Rectangle()
                                                        .fill(Color.EZNotesBlue)
                                                )
                                                
                                                Text("From $160/year")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 12))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.thin)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                        .frame(maxWidth: prop.size.width - 80, alignment: .center)
                                        .padding(.bottom)
                                    }
                                    .frame(maxWidth: prop.size.width - 40)
                                    .cornerRadius(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.EZNotesBlack)
                                            .shadow(color: .black, radius: 2.5)
                                    )
                                    .padding(.bottom, 10)
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .popover(isPresented: $isPlanPicked) {
                                VStack {
                                    VStack {
                                        Text(self.planPicked == "basic_plan_monthly"
                                            ? "Monthly Basic Plan"
                                             : self.planPicked == "basic_plan_annually"
                                                ? "Annual Basic Plan"
                                                : "Pro Plan")
                                            .padding()
                                            .foregroundStyle(.white)
                                            .font(.system(size: 30, design: .rounded))
                                            .fontWeight(.heavy)
                                        
                                        Divider()
                                            .frame(maxWidth: prop.size.width - 40)
                                        
                                        VStack {
                                            Text("Card Details")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.bottom)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 22))
                                                .fontWeight(.medium)
                                            
                                            TextField("Card Holder Name", text: $cardHolderName)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: self.isLargerScreen ? 40 : 30
                                                )
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom], 5)
                                                .padding(.horizontal, 25)
                                                .background(
                                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .border(
                                                            width: 1,
                                                            edges: [.bottom],
                                                            lcolor: !self.makeContentRed
                                                                ? self.borderBottomColor
                                                                : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                        )
                                                )
                                                .tint(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .padding(.horizontal, 10)
                                                .overlay(
                                                    HStack {
                                                        Image(systemName: "person.crop.circle")
                                                            .foregroundColor(.gray)
                                                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                                                            .padding(.leading, 15)
                                                    }
                                                )
                                            
                                            TextField("Card Number", text: $cardNumber)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: self.isLargerScreen ? 40 : 30
                                                )
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom], 5)
                                                .padding(.horizontal, 25)
                                                .background(
                                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .border(
                                                            width: 1,
                                                            edges: [.bottom],
                                                            lcolor: !self.makeContentRed
                                                                ? self.borderBottomColor
                                                                : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                        )
                                                )
                                                .tint(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .padding(.horizontal, 10)
                                                .overlay(
                                                    HStack {
                                                        Image(systemName: "creditcard")
                                                            .foregroundColor(.gray)
                                                            .frame(
                                                                minWidth: 0, maxWidth: .infinity,
                                                                minHeight: 0, maxHeight: .infinity,
                                                                alignment: .leading
                                                            )
                                                            .padding(.leading, 15)
                                                    }
                                                )
                                                .textContentType(.creditCardNumber)
                                                .onChange(of: self.cardNumber) {
                                                    if self.cardNumber.count >= 16 {
                                                        self.cardNumber = String(self.cardNumber.prefix(16))
                                                    }
                                                }
                                            
                                            /*TextField("02/27", text: $expYear)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: self.isLargerScreen ? 40 : 30
                                                )
                                                .padding(.leading, 15)
                                                .padding([.top, .bottom], 5)
                                                .padding(.horizontal, 25)
                                                .background(
                                                    Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                        .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                        .border(
                                                            width: 1,
                                                            edges: [.bottom],
                                                            lcolor: !self.makeContentRed
                                                                ? self.borderBottomColor
                                                                : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                        )
                                                )
                                                .tint(Color.EZNotesBlue)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .autocapitalization(.words)
                                                .disableAutocorrection(true)
                                                .padding(.horizontal, 10)
                                                .overlay(
                                                    HStack {
                                                        Image(systemName: "calendar")
                                                            .foregroundColor(.gray)
                                                            .frame(
                                                                minWidth: 0, maxWidth: .infinity,
                                                                minHeight: 0, maxHeight: .infinity,
                                                                alignment: .leading
                                                            )
                                                            .padding(.leading, 15)
                                                    }
                                                )*/
                                            
                                            HStack {
                                                HStack {
                                                    VStack {
                                                        TextField("02", text: $expMonth)
                                                            .frame(
                                                                maxWidth: .infinity,
                                                                maxHeight: self.isLargerScreen ? 40 : 30,
                                                                alignment: .leading
                                                            )
                                                            .padding(.leading, 5)
                                                            .padding([.top], 5)
                                                        //.padding(.horizontal, 25)
                                                            .background(
                                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                                    .border(
                                                                        width: 1,
                                                                        edges: [.bottom],
                                                                        lcolor: !self.makeContentRed
                                                                        ? self.borderBottomColor
                                                                        : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                                    )
                                                            )
                                                            .tint(Color.EZNotesBlue)
                                                            .font(.system(size: 18))
                                                            .fontWeight(.medium)
                                                            .autocapitalization(.words)
                                                            .disableAutocorrection(true)
                                                            .padding(.horizontal, 10)
                                                        
                                                        Text("Month")
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .foregroundStyle(.secondary)
                                                            .padding(.leading, 15)
                                                            .font(.system(size: 12))
                                                            .fontWeight(.thin)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    VStack {
                                                        TextField("27", text: $expYear)
                                                            .frame(
                                                                maxWidth: .infinity,
                                                                maxHeight: self.isLargerScreen ? 40 : 30,
                                                                alignment: .trailing
                                                            )
                                                            .padding(.leading, 5)
                                                            .padding([.top], 5)
                                                            //.padding(.horizontal, 25)
                                                            .background(
                                                                Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                                    .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                                    .border(
                                                                        width: 1,
                                                                        edges: [.bottom],
                                                                        lcolor: !self.makeContentRed
                                                                        ? self.borderBottomColor
                                                                        : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                                    )
                                                            )
                                                            .tint(Color.EZNotesBlue)
                                                            .font(.system(size: 18))
                                                            .fontWeight(.medium)
                                                            .autocapitalization(.words)
                                                            .disableAutocorrection(true)
                                                            .padding(.horizontal, 10)
                                                        
                                                        Text("Year")
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .foregroundStyle(.secondary)
                                                            .padding(.leading, 15)
                                                            .font(.system(size: 12))
                                                            .fontWeight(.thin)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                HStack {
                                                    TextField("CVC", text: $expYear)
                                                        .frame(
                                                            maxWidth: .infinity,
                                                            maxHeight: self.isLargerScreen ? 40 : 30,
                                                            alignment: .leading
                                                        )
                                                        .padding(.leading, 15)
                                                        .padding([.top], 5)
                                                        .padding(.horizontal, 25)
                                                        .background(
                                                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                                                .fill(.clear)//(Color.EZNotesLightBlack.opacity(0.6))
                                                                .border(
                                                                    width: 1,
                                                                    edges: [.bottom],
                                                                    lcolor: !self.makeContentRed
                                                                    ? self.borderBottomColor
                                                                    : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                                                )
                                                        )
                                                        .tint(Color.EZNotesBlue)
                                                        .font(.system(size: 18))
                                                        .fontWeight(.medium)
                                                        .autocapitalization(.words)
                                                        .disableAutocorrection(true)
                                                        .padding(.horizontal, 10)
                                                        .overlay(
                                                            HStack {
                                                                Image(systemName: "key")
                                                                    .foregroundColor(.gray)
                                                                    .frame(
                                                                        minWidth: 0, maxWidth: .infinity,
                                                                        minHeight: 0, maxHeight: .infinity,
                                                                        alignment: .leading
                                                                    )
                                                                    .padding(.leading, 15)
                                                            }
                                                        )
                                                }
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                                .padding(.bottom, 18)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            
                                            Text("All purchases are handled securely by Stripe. Stripe is our partner for processing payments for subscriptions. If you have any questions, do not hesitate to contact us.\n\nBy clicking \"Submit Payment\" below, you agree to EZNotes Terms of Use and confirm you have read and understood our Privacy and Policy.")
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding(.top)
                                                .padding(.bottom, 2)
                                                .foregroundStyle(.secondary)
                                                .font(.system(size: 13))
                                                .minimumScaleFactor(0.5)
                                                .fontWeight(.light)
                                            
                                            Button(action: { self.showPrivacyPolicy.toggle() }) {
                                                Text("Privacy & Policy")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.blue)
                                                    .font(.system(size: 13))
                                                    .minimumScaleFactor(0.5)
                                                    .fontWeight(.light)
                                            }
                                            .buttonStyle(NoLongPressButtonStyle())
                                        }
                                        .frame(maxWidth: prop.size.width - 80, alignment: .top)
                                        .padding(.top, 20)
                                        .ignoresSafeArea(.keyboard, edges: .bottom)
                                    }
                                    .frame(maxWidth: prop.size.width - 80, alignment: .top)
                                    .ignoresSafeArea(.keyboard, edges: .bottom)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        print("Submit Payment!")
                                    }) {
                                        Text("Submit Payment")
                                            .frame(
                                                width: prop.isIpad
                                                ? UIDevice.current.orientation.isLandscape
                                                ? prop.size.width - 800
                                                : prop.size.width - 450
                                                : prop.size.width - 90,
                                                height: 10
                                            )
                                            .padding([.top, .bottom])
                                            .font(.system(size: 25, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.black)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                    .padding(.leading, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                    )
                                    .padding(.bottom, 20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.EZNotesBlack)
                                .popover(isPresented: $showPrivacyPolicy) {
                                    WebView(url: URL(string: "https://www.eznotes.space/privacy_policy")!)
                                        .navigationBarTitle("Privacy Policy", displayMode: .inline)
                                }
                            }
                        }
                    }
                    .padding(.top, self.isLargerScreen ? 25 : 20)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top) // Keep VStack aligned to the top
                .ignoresSafeArea(.keyboard, edges: .bottom) // Ignore keyboard safe area
                .onChange(of: prop.size.height) {
                    self.isLargerScreen = prop.size.height / 2.5 > 200
                }
                
                Spacer() // To push the TextFields to the top
                
                if self.section != "select_plan" {
                    VStack {
                        Button(action: {
                            if section == "main" {
                                if self.username == "" || self.email == "" || self.password == "" {
                                    self.makeContentRed = true
                                    return
                                }
                                
                                if self.userExists { self.userExists = false }
                                if self.makeContentRed { self.makeContentRed = false }
                                
                                self.section = "select_state_and_college"
                                UserDefaults.standard.set("select_state_and_college", forKey: "last_signup_section")
                            } else {
                                if self.section == "select_state_and_college" {
                                    if self.state == "" || self.college == "" || self.major == "" {
                                        self.makeContentRed = true
                                        return
                                    }
                                    
                                    RequestAction<SignUpRequestData>(
                                        parameters: SignUpRequestData(
                                            Username: username,
                                            Email: email,
                                            Password: password,
                                            College: college,
                                            State: state
                                        )
                                    ).perform(action: complete_signup1_req) { r in
                                        if r.Bad != nil {
                                            if r.Bad!.ErrorCode == 0x6970 {
                                                self.section = "main"
                                                self.userExists = true
                                                return
                                            }
                                            
                                            self.serverError = true
                                            return
                                        }
                                        else {
                                            if self.userExists { self.userExists = false }
                                            
                                            self.accountID = r.Good!.Message
                                            self.section = "code_input"
                                            UserDefaults.standard.set("code_input", forKey: "last_signup_section")
                                        }
                                    }
                                } else {
                                    if self.section == "code_input" {
                                        RequestAction<SignUp2RequestData>(
                                            parameters: SignUp2RequestData(
                                                AccountID: accountID,
                                                UserInputtedCode: userInputedCode
                                            )
                                        ).perform(action: complete_signup2_req) {r in
                                            if r.Bad != nil {
                                                self.wrongCode = true
                                                return
                                            }
                                            else {
                                                UserDefaults.standard.set(self.username, forKey: "username")
                                                UserDefaults.standard.set(self.email, forKey: "email")
                                                self.section = "select_plan"
                                            }
                                        }
                                        /* TODO: Add screen for the code to be put in.
                                         * TODO: After the screen is implemented, this else statement will take the code and send it to the server.*/
                                    } else {
                                        UserDefaults.standard.set(self.planID, forKey: "plan_id")
                                        
                                        /* TODO: The code in `setLoginStatus` is not needed. */
                                        setLoginStatus()
                                    }
                                }
                            }
                        }) {
                            Text(section == "main"
                                 ? "Continue"
                                 : section == "select_state_and_college"
                                 ? "Submit"
                                 : "Complete")
                            .frame(
                                width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                                : prop.size.width - 90,
                                height: 10
                            )
                            .padding([.top, .bottom])
                            .font(.system(size: 25, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        .padding(.leading, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                        )
                        
                        if !(self.section == "code_input") {
                            Button(action: {
                                if self.section == "main" { self.screen = "home" }
                                else { self.section = "main" }
                            }) {
                                Text("Go Back")
                                    .frame(
                                        width: prop.isIpad
                                        ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                        : prop.size.width - 90,
                                        height: 10
                                    )
                                    .padding([.top, .bottom])
                                    .font(.system(size: 25, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesLightBlack)
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .onAppear {
            self.isLargerScreen = prop.size.height / 2.5 > 300
            
            /*guard UserDefaults.standard.object(forKey: "last_signup_section") != nil else {
                UserDefaults.standard.set("main", forKey: "last_signup_section")
                return
            }
            
            self.section = UserDefaults.standard.string(forKey: "last_signup_section")!*/
        }
        /*VStack {
            Spacer()
            VStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.EZNotesOrange,
                            Color.EZNotesOrange,
                            prop.isIpad && (prop.isLandscape && !keyboardActivated)
                                ? Color.EZNotesBlue
                                : Color.EZNotesOrange,
                            prop.isIpad && (prop.isLandscape && !keyboardActivated)
                                ? Color.EZNotesBlue
                                : Color.EZNotesOrange,
                            //Color.EZNotesOrange,
                            //Color.EZNotesOrange
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                )
                .padding([.top], prop.isIpad && UIDevice.current.orientation.isLandscape ? -80 : 0)
                .frame(
                    width: prop.isIpad
                        ? 320
                        : 350,
                    height: prop.isIpad
                        ? 200
                        : 230
                )
                .mask(
                    Text("Sign Up")
                        .frame(alignment: .top)
                        .padding(
                            [.top],
                            prop.isIpad
                                ? -90
                                : prop.size.height / 2.5 > 300
                                    ? -115
                                    : imageOpacity == 0 || passwordFieldInFocus ? -100 : -120)
                        .padding([.bottom], -80)
                        .shadow(color: .white, radius: 2.5)
                        .font(
                            .system(
                                size: prop.isIpad
                                    ? 90
                                    : prop.size.width / 2.5 > 300
                                        ? 55
                                        : 45
                            )
                        )
                        .multilineTextAlignment(.center)
                        //.opacity(opacity2)
                )
                
                Text(
                    self.wrongCode
                        ? "Wrong code. Try again"
                        : self.section == "main"
                            ? "Sign up with a unique username, your email and a unique password"
                        : self.section == "select_state_and_college"
                                ? "Tell us about your college and your degree :)"
                                : "A code has been sent to your email. Input the code below"
                )
                .fontWeight(.bold)
                .padding([.top], prop.isIpad
                         ? UIDevice.current.orientation.isLandscape ? -140 : -80
                         : prop.size.width / 2.5 > 300
                            ? -170
                            : -180
                )
                .padding()
                .font(
                    .system(
                        size: prop.isIpad || prop.size.width / 2.5 > 300
                            ? 20
                            : 18
                    )
                )
                .multilineTextAlignment(.center)
                .frame(
                    maxWidth: prop.isIpad
                        ? prop.size.width - 480
                        : 350,
                    maxHeight: 50,
                    alignment: .top
                )
                .foregroundStyle(wrongCode ? Color.red : Color.white)
                    
            }
            .padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                            ? -330
                            : -180
                    : -120)
            .frame(
                width: prop.isIpad
                        ? 400
                        : nil,
                height: prop.isIpad
                        ? 850
                        : prop.size.height / 2.5 > 300
                            ? 750
                            : (prop.size.height / 2.5) + 200
            )
            
            VStack {
                VStack {
                    if section == "main" {
                        Text("Username")
                            .frame(
                                width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding(.top, 10)
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Username",
                            text: $username,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.username == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                        
                        Text("Email")
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Email",
                            text: $email,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.email == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        
                        Text("Password")
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(
                                .system(
                                    size: prop.size.width / 2.5 > 300 ? 25 : 22
                                )
                            )
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        SecureField(
                            "Password",
                            text: $password
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))//(Color.EZNotesLightBlack.opacity(0.6))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.password == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        //.cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .focused($passwordFieldInFocus)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    } else if section == "select_state_and_college"
                    {
                        Text("State")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding([.top], 10)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "College name...",
                            text: $state,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.state == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Text("College Being Attended")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "College name...",
                            text: $college,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.college == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Text("Major")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        
                        TextField(
                            "Major...",
                            text: $major,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                                ? UIDevice.current.orientation.isLandscape
                                    ? prop.size.width - 800
                                    : prop.size.width - 450
                                : prop.size.width - 100,
                            height: prop.size.height / 2.5 > 300 ? 40 : 30
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.makeContentRed
                                        ? self.borderBottomColor
                                        : self.major == "" ? self.borderBottomColorError : self.borderBottomColor
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        //Spacer()
                    } else
                    {
                        Text("Code")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding([.top], 40)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                        
                        TextField(
                            "Code",
                            text: $userInputedCode,
                            onEditingChanged: set_image_opacity
                        )
                        .frame(
                            width: prop.isIpad
                            ? prop.size.width - 450
                            : prop.size.width - 100,
                            height: 45
                        )
                        .padding([.leading], 15)
                        .background(
                            Rectangle()//RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.2))
                                .border(
                                    width: 1,
                                    edges: [.bottom],
                                    lcolor: !self.wrongCode
                                        ? self.borderBottomColor
                                        : self.borderBottomColorError
                                )
                        )
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.EZNotesBlue)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    
                    Button(action: {
                        if section == "main" {
                            if self.username == "" || self.email == "" || self.password == "" {
                                self.makeContentRed = true
                                return
                            }
                            
                            if self.makeContentRed { self.makeContentRed = false }
                            
                            section = "select_state_and_college"
                        } else {
                            if self.section == "select_state_and_college" {
                                if self.state == "" || self.college == "" || self.major == "" {
                                    self.makeContentRed = true
                                    return
                                }
                                RequestAction<SignUpRequestData>(
                                    parameters: SignUpRequestData(
                                        Username: username,
                                        Email: email,
                                        Password: password,
                                        College: college,
                                        State: state
                                    )
                                ).perform(action: complete_signup1_req) { r in
                                    if r.Bad != nil {
                                        print(r.Bad!)
                                        return
                                    }
                                    else {
                                        self.accountID = r.Good!.Message
                                        self.section = "code_input"
                                    }
                                }
                            }
                            else {
                                if self.section == "code_input" {
                                    RequestAction<SignUp2RequestData>(
                                        parameters: SignUp2RequestData(
                                            AccountID: accountID,
                                            UserInputtedCode: userInputedCode
                                        )
                                    ).perform(action: complete_signup2_req) {r in
                                        if r.Bad != nil {
                                            self.wrongCode = true
                                            return
                                        }
                                        else {
                                            UserDefaults.standard.set(username, forKey: "username")
                                            UserDefaults.standard.set(email, forKey: "email")
                                            
                                            self.showPopup = true
                                        }
                                    }
                                    /* TODO: Add screen for the code to be put in.
                                     * TODO: After the screen is implemented, this else statement will take the code and send it to the server.*/
                                }
                            }
                        }
                    }) {
                        Text(section == "main"
                             ? "Continue"
                             : section == "select_state_and_college"
                                 ? "Submit"
                                 : "Complete")
                            .frame(
                                width: prop.isIpad
                                    ? UIDevice.current.orientation.isLandscape
                                        ? prop.size.width - 800
                                        : prop.size.width - 450
                                    : prop.size.width - 90,
                                height: 10
                            )
                            .padding([.top, .bottom])
                            .font(.system(size: 25, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                    )
                    
                    /*startupScreen.createButton(
                        prop: prop,
                        text: "Go Back",
                        backgroundColor: Color.EZNotesBlue,
                        primaryGlow: false,
                        action: {
                            if section == "main" {
                                self.screen = "home"
                            } else if section == "select_state_and_college" {
                                section = "main"
                            } else {
                                section = "select_state_and_college"
                            }
                        }
                    )
                    .padding([.top], 5)*/
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(20)
                .padding(
                    [.top],
                        prop.isIpad
                            ? UIDevice.current.orientation.isLandscape && keyboardActivated
                                ? -450
                                : UIDevice.current.orientation.isLandscape ? -400 : -350
                            : prop.size.height / 2.5 > 300
                                ? -420
                                : -200
                )
                /*TextField("Username", text: $username)
                 .foregroundStyle(Color.white)
                 .padding([.top], -150)*/
                
                //Spacer()
            }
        }
        .alert("Enable FaceID?", isPresented: $showPopup) {
            Button("Enable") {
                UserDefaults.standard.set("enabled", forKey: "faceID_enabled")
                setLoginStatus()
            } //action: { self.allowFaceID = true }) { }
            Button("Disable", role: .cancel) {
                UserDefaults.standard.set("disabled", forKey: "faceID_enabled")
                setLoginStatus()
            }
        } message: {
            Text("Enabling FaceID will further secure your data")
        }*/
    }
}

struct SignUpScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
