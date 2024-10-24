//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI
import Combine

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

struct SignUpScreen : View, KeyboardReadable {
    public var prop: Properties
    
    @State private var showPopup: Bool = false
    
    public var startupScreen: StartupScreen
    
    @Binding public var screen: String
    @Binding public var userHasSignedIn: Bool
    @Binding public var serverError: Bool
    @Binding public var supportedStates: Array<String>
    @State public var supportedColleges: Array<String> = []
    
    @State public var keyboardActivated: Bool = false
    
    @State public var collegesPickerOpacity: Double  = 0.0
    @State public var accountID: String = ""
    @State public var userInputedCode: String = ""
    @State public var wrongCode: Bool = false
    @State public var username: String = ""
    @State public var email: String = ""
    @State public var password: String = ""
    @State public var college: String = ""
    @State public var major: String = ""
    @State public var state: String = ""
    @State public var section: String = "main"
    @State public var makeContentRed: Bool = false
    
    @State public var imageOpacity: Double = 1
    @FocusState public var passwordFieldInFocus: Bool
    
    @State private var isLargerScreen: Bool = false
    
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
                    Text("Sign Up")
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
                            : self.section == "main"
                                ? "Sign up with a unique username, your email and a unique password"
                            : self.section == "select_state_and_college"
                                    ? "Tell us about your college and your degree :)"
                                    : "A code has been sent to your email. Input the code below"
                    )
                    .frame(maxWidth: .infinity, minHeight: 45, alignment: .center)
                    .foregroundStyle(wrongCode ? Color.red : Color.white)
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
                                            ? self.borderBottomColor
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
                                            ? self.borderBottomColor
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
                        } else {
                            
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
                
                VStack {
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
                    
                    Button(action: {
                        if self.section == "main" { self.screen = "home" }
                        else {
                            switch(self.section) {
                                case "select_state_and_college": self.section = "main";break
                                case "code_input": self.section = "select_state_and_college";break
                                default: self.screen = "home"
                            }
                        }
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
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            self.isLargerScreen = prop.size.height / 2.5 > 300
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
