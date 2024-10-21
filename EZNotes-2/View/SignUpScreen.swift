//
//  SignUpScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/25/24.
//
import SwiftUI

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
    @State public var state: String = "Select"
    @State public var section: String = "main"
    
    @State public var imageOpacity: Double = 1
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
        UserDefaults.standard.set(
            self.accountID,
            forKey: "account_id"
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
                    .padding([.top], 10)
                
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
                    wrongCode
                        ? "Wrong code. Try again"
                        : section == "main"
                            ? "Sign up with a unique username, your email and a unique password"
                            : section == "select_state_and_college"
                                ? "Select your State and College"
                                : "A code has been sent to your email. Input the code below"
                )
                .opacity(prop.isIpad && UIDevice.current.orientation.isLandscape
                         ? passwordFieldInFocus
                            ? 0
                            : imageOpacity
                         : prop.size.width / 2.5 < 300
                            ? passwordFieldInFocus
                                ? 0
                                : imageOpacity
                            : 1
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
                            : -310
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
                        .padding(prop.size.width / 2.5 > 300 ? 10 : 5)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.EZNotesBlue)
                        /*.onReceive(keyboardPublisher) { newIsKeyboardVisible in
                            self.keyboardActivated = newIsKeyboardVisible
                        }*/
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
                            .padding([.top], 10)
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
                            height: prop.size.height / 2.5 > 300 ? 45 : 35
                        )
                        .padding([.leading], 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray)
                                .opacity(0.6)
                        )
                        .cornerRadius(15)
                        .padding(prop.size.width / 2.5 > 300 ? 10 : 5)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.EZNotesBlue)
                        /*.onReceive(keyboardPublisher) { newIsKeyboardVisible in
                            print("Is keyboard visible? ", newIsKeyboardVisible)
                            self.keyboardActivated = newIsKeyboardVisible
                        }*/
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
                            .padding([.top], 10)
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
                        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                            print("Is keyboard visible? ", newIsKeyboardVisible)
                            self.keyboardActivated = newIsKeyboardVisible
                        }
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
                        .padding(prop.size.width / 2.5 > 300 ? 10 : 5)
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.EZNotesBlue)
                    } else if section == "select_state_and_college"
                    {
                        
                        Text("Select State")
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding()
                            .padding([.top], 0)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        Picker(
                            "Select State",
                            selection: $state
                        ) {
                            ForEach(supportedStates, id: \.self) { value in
                                Text(value).tag(value)
                            }
                        }
                        .onChange(of: state, {
                            self.supportedColleges = []
                            RequestAction<GetCollegesRequest>(parameters: GetCollegesRequest(
                                    State: state
                            ))
                            .perform(action: get_colleges_for_state_req) { r in
                                if r.Bad != nil {
                                    self.serverError = true
                                } else {
                                    let colleges = r.Good?.Message.components(separatedBy: "\n")
                                    
                                    colleges!.forEach { value in
                                        self.supportedColleges.append(value)
                                    }
                                    
                                    self.collegesPickerOpacity = 1;
                                }
                            }
                        })
                        .frame(
                            width: prop.isIpad
                                ? prop.size.width - 450
                                : prop.size.width - 100
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray)
                                .opacity(0.6)
                        )
                        .pickerStyle(.segmented)
                        
                        Text("Select College")
                            .opacity(collegesPickerOpacity)
                            .frame(
                                width: prop.isIpad
                                    ? prop.size.width - 450
                                    : prop.size.width - 100,
                                height: 5,
                                alignment: .leading
                            )
                            .padding()
                            .padding([.top], 10)
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        Picker(
                            "Select College",
                            selection: $college
                        ) {
                            ForEach(supportedColleges, id: \.self) { value in
                                Text(value).tag(value)
                            }
                        }
                        .opacity(collegesPickerOpacity)
                        .frame(
                            width: prop.isIpad
                                ? prop.size.width - 450
                                : prop.size.width - 100
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray)
                                .opacity(
                                    collegesPickerOpacity == 0
                                        ? 0
                                        : 0.6
                                )
                        )
                        .pickerStyle(.segmented)
                        .padding([.bottom], 30)
                        
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
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray)
                                .opacity(0.6)
                        )
                        .cornerRadius(15)
                        .padding()
                        .tint(Color.EZNotesBlue)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.EZNotesBlue)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    
                    startupScreen.createButton(
                        prop: prop,
                        text: section == "main"
                            ? "Continue"
                            : section == "select_state_and_college"
                                ? "Submit"
                                : "Complete",
                        primaryGlow: false,
                        action: {
                            if section == "main" {
                                if self.username == "" || self.email == "" || self.password == "" { return }
                                
                                section = "select_state_and_college"
                            } else {
                                if section == "select_state_and_college" {
                                    RequestAction<SignUpRequestData>(
                                        parameters: SignUpRequestData(
                                            Username: username,
                                            Email: email,
                                            Password: password,
                                            College: college,
                                            State: state
                                        )
                                    ).perform(action: complete_signup1_req) { r in
                                        if r.Bad != nil { self.serverError = true }
                                        else {
                                            self.accountID = r.Good!.Message
                                            self.section = "code_input"
                                        }
                                    }
                                } else if self.section == "code_input" {
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
                    )
                    .padding([.top], 10)
                    
                    startupScreen.createButton(
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
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SignUpScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
