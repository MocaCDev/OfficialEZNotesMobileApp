//
//  LoginScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI

struct LoginScreen: View, KeyboardReadable {
    public var prop: Properties
    
    @State private var showPopup: Bool = false
    
    public var startupScreen: StartupScreen
    @Binding public var screen: String
    @Binding public var userHasSignedIn: Bool
    
    @State public var keyboardActivated: Bool = false
    
    @State public var makeContentRed: Bool = false
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
    
    @State public var username: String = ""
    @State public var password: String = ""
    @State public var imageOpacity: Double = 1
    @State public var loginError: Bool = false
    @FocusState public var passwordFieldInFocus: Bool
    
    func set_image_opacity(focused: Bool)
    {
        imageOpacity = focused ? 0.0 : 1.0;
    }
    
    private func setLoginStatus() -> Void {
        UserDefaults.standard.set(
            true,
            forKey: "logged_in"
        )
        self.userHasSignedIn = true
    }
    
    /* TODO: Create a observed object for this. The below variables can be found in `SignUpScreen.swift` as well. */
    @State private var isLargerScreen: Bool = false
    @State private var lastHeight: CGFloat = 0.0

    var body: some View {
        VStack {
            VStack {
                Text("Login")
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
                    !self.loginError
                    ? "Use your Email or Username to login to your account"
                    : "Email, Username or Password is incorrect"
                )
                .frame(maxWidth: prop.size.width - 30, minHeight: 45, alignment: .center)
                .foregroundStyle(self.loginError ? Color.red : Color.white)
                .font(
                    .system(
                        size: prop.isIpad || self.isLargerScreen
                        ? 15
                        : 13
                    )
                )
                .multilineTextAlignment(.center)
                
                VStack {
                    Text("Username or Email")
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
                                size: self.isLargerScreen ? 25 : 20
                            )
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                    
                    TextField("Username or Email...", text: $username)
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
                                    lcolor: self.loginError || self.makeContentRed ? self.borderBottomColorError : self.borderBottomColor
                                        /*!self.makeContentRed
                                        ? self.loginError ? self.borderBottomColorError : self.borderBottomColor
                                        : self.username == "" ? self.borderBottomColorError : self.borderBottomColor*/
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding(self.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                    
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
                        .padding(.top, 10)
                        .font(
                            .system(
                                size: self.isLargerScreen ? 25 : 20
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
                                    lcolor: self.loginError || self.makeContentRed ? self.borderBottomColorError : self.borderBottomColor
                                        /*!self.makeContentRed
                                    ? self.borderBottomColor
                                    : self.password == "" ? self.borderBottomColorError : self.borderBottomColor*/
                                )
                        )
                        .foregroundStyle(Color.EZNotesBlue)
                        .padding(self.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .focused($passwordFieldInFocus)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.top, self.isLargerScreen ? 25 : 20)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .top) // Keep VStack aligned to the top
            .ignoresSafeArea(.keyboard, edges: .bottom) // Ignore keyboard safe area
            .onChange(of: prop.size.height) {
                if prop.size.height < self.lastHeight { self.isLargerScreen = prop.size.height / 2.5 > 200 }
                else { self.isLargerScreen = prop.size.height / 2.5 > 300 }
                
                self.lastHeight = prop.size.height
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        /*VStack {
            VStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.EZNotesOrange,
                            Color.EZNotesOrange,
                            Color.EZNotesOrange,
                            Color.EZNotesOrange,
                            //Color.EZNotesOrange,
                            //Color.EZNotesOrange
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                )
                .frame(
                    width: prop.isIpad
                        ? 320
                        : 350,
                    height: prop.isIpad
                        ? 200
                        : 230
                )
                .mask(
                    Text("Login")
                        .frame(alignment: .top)
                        .padding(
                            [.top],
                            prop.isIpad
                                ? -90
                                : prop.size.height / 2.5 > 300
                                    ? -125
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
                    !loginError
                        ? "Use your Email or Username to login to your account"
                        : "Email, Username or Password is incorrect"
                )
                .frame(
                    maxWidth: prop.isIpad
                        ? prop.size.width - 520
                        : 320,
                    maxHeight: 50,
                    alignment: .top
                )
                .foregroundStyle(!loginError
                    ? Color.white
                    : Color.red)
                .padding([.top], prop.isIpad
                         ? -80
                         : prop.size.width / 2.5 > 300
                            ? !loginError ? -170 : -150
                            : !loginError ? -180 : -160
                )
                .padding()
                .font(
                    .system(
                        size: prop.isIpad || prop.size.width / 2.5 > 300
                            ? 20
                            : 18
                    )
                )
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                
                //Spacer()
            }
            /*.padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                            ? -330
                            : -180
                    : -120)*/
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
                /*width: prop.isIpad
                        ? 400
                        : nil,
                height: prop.isIpad
                        ? 850
                        : prop.size.height / 2.5 > 300
                            ? 750
                            : (prop.size.height / 2.5) + 200*/
            )
            .ignoresSafeArea(.keyboard)
            
            //Spacer()
            
            //VStack {
                VStack {
                    VStack { }.frame(maxWidth: .infinity, maxHeight: 25)
                    
                    Text("Username/Email")
                        .frame(
                            width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                            : prop.size.width - 100,
                            height: 5,
                            alignment: .leading
                        )
                        .padding([.top], 10)
                        .font(
                        .system(
                            size: prop.size.width / 2.5 > 300 ? 25 : 22
                            )
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                    
                    TextField(
                        "Username or Email...",
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
                    .padding()
                    .tint(Color.EZNotesBlue)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
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
                            .fill(.gray.opacity(0.2))
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
                    
                    Button(action: {
                        if username == "" || password == "" { self.makeContentRed = true; return }
                        
                        if self.makeContentRed { self.makeContentRed = false }
                        
                        RequestAction<LoginRequestData>(
                            parameters: LoginRequestData(
                                Username: username,
                                Password: password
                            )
                        ).perform(action: complete_login_req) { r in
                            if r.Good == nil {
                                self.loginError = true
                                return
                            } else {
                                UserDefaults.standard.set(username, forKey: "username")
                                
                                if UserDefaults.standard.object(forKey: "email") == nil || UserDefaults.standard.string(forKey: "email") == "" {
                                    RequestAction<GetEmailData>(
                                        parameters: GetEmailData(
                                            AccountId: r.Good!.Message
                                        )
                                    ).perform(action: get_user_email_req) { resp in
                                        print(resp)
                                        if resp.Good == nil {
                                            self.loginError = true
                                            return
                                        } else {
                                            UserDefaults.standard.set(resp.Good!.Message, forKey: "email")
                                        }
                                    }
                                }
                                
                                if UserDefaults.standard.string(forKey: "faceID_enabled") == "not_enabled" {
                                    self.showPopup = true
                                } else {
                                    UserDefaults.standard.set(true, forKey: "logged_in")
                                    self.userHasSignedIn = true
                                    self.startupScreen.goBackToLogin = false
                                    self.startupScreen.faceIDAuthenticated = true
                                }
                                
                                return
                            }
                        }
                    }) {
                        Text("Login")
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
                    
                    Button(action: { self.screen = "home" }) {
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
                    /*.background(.gray.opacity(0.6))
                    .overlay(
                        Capsule()
                          .glow(
                            fill: .angularGradient(
                              stops: [
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.0
                                ),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.2),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.4
                                ),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.5
                                ),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.7
                                ),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 0.9
                                ),
                                .init(
                                    color: Color.EZNotesBlue,
                                    location: 1.0
                                ),
                              ],
                              center: .center,
                              startAngle: Angle(radians: .zero),
                              endAngle: Angle(radians: .pi * 2)
                            ),
                            lineWidth: 2.5
                          )
                    )*/
                    
                    /*startupScreen.createButton(
                        prop: prop,
                        text: "Login",
                        primaryGlow: false,
                        action: {
                            if username == "" || password == "" { self.loginError = true; return }
                            
                            RequestAction<LoginRequestData>(
                                parameters: LoginRequestData(
                                    Username: username,
                                    Password: password
                                )
                            ).perform(action: complete_login_req) { r in
                                /* MARK: Temporary. Bug in server needs fixed. */
                                /*if r.Good!.Status != "200" {
                                    self.loginError = true
                                    return
                                }
                                
                                UserDefaults.standard.set(true, forKey: "logged_in")
                                self.userHasSignedIn = true
                                print("LOGGED IN!")
                                return*/
                                
                                if r.Good == nil {
                                    self.loginError = true
                                    return
                                } else {
                                    UserDefaults.standard.set(username, forKey: "username")
                                    
                                    if UserDefaults.standard.object(forKey: "email") == nil || UserDefaults.standard.string(forKey: "email") == "" {
                                        RequestAction<GetEmailData>(
                                            parameters: GetEmailData(
                                                AccountId: r.Good!.Message
                                            )
                                        ).perform(action: get_user_email_req) { resp in
                                            print(resp)
                                            if resp.Good == nil {
                                                self.loginError = true
                                                return
                                            } else {
                                                UserDefaults.standard.set(resp.Good!.Message, forKey: "email")
                                            }
                                        }
                                    }
                                    
                                    if UserDefaults.standard.string(forKey: "faceID_enabled") == "not_enabled" {
                                        self.showPopup = true
                                    } else {
                                        UserDefaults.standard.set(true, forKey: "logged_in")
                                        self.userHasSignedIn = true
                                        self.startupScreen.goBackToLogin = false
                                        self.startupScreen.faceIDAuthenticated = true
                                    }
                                    
                                    return
                                }
                                /*if r.Bad != nil
                                {
                                    self.loginError = true
                                    return
                                } else {
                                    UserDefaults.standard.set(true, forKey: "logged_in")
                                    self.userHasSignedIn = true
                                }*/
                            }
                        }
                    )
                    .padding([.top], 10)
                    
                    startupScreen.createButton(
                        prop: prop,
                        text: "Go Back",
                        backgroundColor: Color.EZNotesBlue,
                        primaryGlow: false,
                        action: { self.screen = "home" }
                    )
                    .padding([.top], 5)*/
                    
                    Spacer()
                }
                .frame(maxWidth: prop.size.width - 30, maxHeight: (prop.size.height / 2) - 100)
                .cornerRadius(15)
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
            //}
            //.frame(maxWidth: prop.size.width - 100, maxHeight: 50)
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
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

struct LoginScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
