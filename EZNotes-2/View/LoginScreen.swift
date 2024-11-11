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
                HStack {
                    ZStack {
                        Button(action: { self.screen = "home" }) {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .frame(maxWidth: 20, alignment: .leading)
                    
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
                    
                    ZStack {
                        Menu {
                            Button(action: { print("Get Help") }) {
                                Label("I need help", systemImage: "questionmark")
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            //Button(action: { print("Restart") }) { Text("Restart Signup") }
                            //Button(action: { print("Get help") }) { Text("I need help") }
                        } label: {
                            Label("", systemImage: "ellipsis.circle")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: 20, alignment: .trailing)
                }
                
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
                        .padding([.top, .leading, .trailing], self.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                    
                    ZStack {
                        Button(action: { print("Forgot Username") }) {
                            Text("Forgot Username?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.EZNotesBlue)
                                .font(Font.custom("Poppins-ExtraLight", size: 12))
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .frame(maxWidth: prop.isIpad
                           ? UIDevice.current.orientation.isLandscape
                               ? prop.size.width - 800
                               : prop.size.width - 450
                           : prop.size.width - 80)
                    .padding(.bottom, 8)
                    
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
                        .padding([.top, .leading, .trailing], self.isLargerScreen ? 10 : 8)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .focused($passwordFieldInFocus)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    ZStack {
                        Button(action: { print("Forgot Password") }) {
                            Text("Forgot Password?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.EZNotesBlue)
                                .font(Font.custom("Poppins-ExtraLight", size: 12))
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .frame(maxWidth: prop.isIpad
                           ? UIDevice.current.orientation.isLandscape
                               ? prop.size.width - 800
                               : prop.size.width - 450
                           : prop.size.width - 80)
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
            
            Spacer()
            
            VStack {
                Button(action: {
                    if self.username == "" || self.password == "" { self.makeContentRed = true; return }
                    
                    if self.makeContentRed { self.makeContentRed = false }
                    
                    RequestAction<LoginRequestData>(
                        parameters: LoginRequestData(
                            Username: self.username,
                            Password: self.password
                        )
                    ).perform(action: complete_login_req) { statusCode, resp in
                        guard resp != nil && statusCode == 200 else {
                            self.loginError = true
                            return
                        }
                        
                        UserDefaults.standard.set(resp!["Username"] as? String, forKey: "username")
                        UserDefaults.standard.set(resp!["Email"] as? String, forKey: "email")
                        UserDefaults.standard.set(resp!["AccountID"] as? String, forKey: "account_id")
                        UserDefaults.standard.set(resp!["CustomerSubscriptionID"] as? String, forKey: "client_sub_id")
                        self.setLoginStatus()
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
                .padding(.leading, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .onAppear {
            self.isLargerScreen = prop.size.height / 2.5 > 300
            self.lastHeight = prop.size.height
        }
    }
}

struct LoginScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
