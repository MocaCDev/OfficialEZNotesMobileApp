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

    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
                    .opacity(!prop.isIpad
                            ? passwordFieldInFocus
                                ? 0
                                : imageOpacity
                            : 1
                    )
                    .padding([.top], -20)
                
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
                        .contrast(0)
                        .shadow(color: .white, radius: 2.5)
                        .opacity(prop.isIpad && UIDevice.current.orientation.isLandscape
                                 ? passwordFieldInFocus
                                    ? 0
                                    : imageOpacity
                                 : 1/*prop.size.width / 2.5 < 300
                                 ? passwordFieldInFocus
                                    ? 0
                                    : imageOpacity
                                 : 1*/
                        )
                        .padding(
                            [.top],
                            prop.isIpad
                                ? -90
                                : prop.size.height / 2.5 > 300
                                    ? -125
                                    : imageOpacity == 0 || passwordFieldInFocus ? -100 : -120)
                        .padding([.bottom], -80)
                        .frame(alignment: .top)
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
                .opacity(prop.isIpad && UIDevice.current.orientation.isLandscape
                         ? passwordFieldInFocus
                            ? !loginError ? 0 : 1
                            : !loginError ? imageOpacity : 1
                         : prop.size.width / 2.5 < 300
                            ? passwordFieldInFocus
                                ? !loginError ? 0 : 1
                                : !loginError ? imageOpacity : 1
                            : 1
                )
                .fontWeight(.bold)
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
                .multilineTextAlignment(.center)
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
                
                //Spacer()
            }
            .padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                            ? -330
                            : -280
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
            
            //Spacer()
            
            VStack {
                VStack {
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
                        .padding([.top], 10)
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
                    /*.onReceive(keyboardPublisher) { newIsKeyboardVisible in
                        self.keyboardActivated = newIsKeyboardVisible
                    }*/
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(
                        width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                            : prop.size.width - 100,
                        height: prop.size.height / 2.5 > 300 ? 45 : 35
                    )
                    .padding([.leading], 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray)
                            .opacity(0.6)
                    )
                    .cornerRadius(15)
                    /*.overlay(
                     RoundedRectangle(cornerRadius: 15)
                     .stroke(Color.EZNotesBlue, lineWidth: 2)
                     )*/
                    .padding()
                    .tint(Color.EZNotesBlue)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.EZNotesBlue)
                    
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
                    .focused($passwordFieldInFocus)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(
                        width: prop.isIpad
                            ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                            : prop.size.width - 100,
                        height: prop.size.height / 2.5 > 300 ? 45 : 35
                    )
                    .padding([.leading], 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray)
                            .opacity(0.6)
                    )
                    .cornerRadius(15)
                    /*.overlay(
                     RoundedRectangle(cornerRadius: 15)
                     .stroke(Color.EZNotesBlue, lineWidth: 2)
                     )*/
                    .padding()
                    .tint(Color.EZNotesBlue)
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.EZNotesBlue)
                    
                    startupScreen.createButton(
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
                    .padding([.top], 5)
                    
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
            
            //Spacer()
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
        }
    }
}

struct LoginScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
