//
//  HomeScreen.swift
//      MARK: `HomeScreen.swift` is the source code file of the initial screen that launches after app is downloaded, or after a user logs out.
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI
import Foundation
import Network

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View
    {
      configuration.label
        .background(
            configuration.isPressed
                ? Color(
                    red: 255/255,
                    green: 145/255,
                    blue: 77/255
                ) : Color.clear
        )
      /*.background(
        Circle()
            .fill(configuration.isPressed
                  ? fillColor : Color.clear
            )
      )*/
    }
    
    func pressed(configuration: Self.Configuration) -> Bool
    {
        configuration.isPressed
    }
}

extension Image {
    func logoImageModifier(prop: Properties) -> some View {
        self.resizable()
            .font(.callout)
            .frame(
                maxWidth: prop.isIpad
                    ? prop.isLandscape
                        ? 150
                        : 200
                    : prop.size.width / 2.5 > 300
                        ? 150
                        : 120,
                maxHeight: prop.isIpad
                    ? prop.isLandscape
                        ? 150
                        : 200
                    : prop.size.width / 2.5 > 300
                        ? 150
                        : 120
            )
            .padding(
                [.top],
                prop.isIpad
                    ? 80/*prop.size.height / 2.5 > 500
                        ? 80
                        : -15*/
                    : prop.size.height / 2.5 > 300
                        ? 0
                        : 50)
    }
}

extension Color {
    static var EZNotesBlue: Color = Color(
        red: 12 / 255,
        green: 192 / 255,
        blue: 223 / 255
    )
    
    static var EZNotesOrange: Color = Color(
        red: 255/255,
        green: 145/255,
        blue: 77/255
    )
    
    static var EZNotesBlack: Color = Color(
        red: 24/255,
        green: 24/255,
        blue: 24/255
        /*red: 18/255,
        green: 18/255,
        blue: 18/255*/
    )
    
    static var EZNotesLightBlack: Color = Color (
        red: 50/255,
        green: 50/255,
        blue: 50/255
        /*red: 40/255,
        green: 40/255,
        blue: 40/255*/
    )
    
    static var EZNotesGreen: Color = Color (
        red: 98/255,
        green: 252/255,
        blue: 175/255
    )
    
    static var EZNotesRed: Color = Color (
        red: 255/255,
        green: 68/255,
        blue: 51/255
    )
}

struct StartupScreen: View {
    @State public var screen: String = "home"
    
    @Binding public var userHasSignedIn: Bool
    @Binding public var goBackToLogin: Bool
    @Binding public var faceIDAuthenticated: Bool
    
    @State public var serverError: Bool = false
    @State public var supportedStates: Array<String> = []
    
    private let rotationChangePublisher = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
    
    @ViewBuilder
    public func createButton(
        prop: Properties,
        text: String,
        backgroundColor: Color = Color.clear,
        textColor: Color = Color.white,
        primaryGlow: Bool = true,
        isError: Bool = false,
        action: @escaping () -> Void
    ) -> some View
    {
        Button(action: { action(); })
        {
            Text(text)
                .fontWeight(.bold)
                .frame(
                    width: prop.isIpad
                        ? 345//prop.size.width - 500
                        : prop.size.width - 100,
                    height: 10)
                .padding()
                .font(.system(size: 24))
                .foregroundStyle(textColor)
                .contentShape(Rectangle())
        }
        .buttonStyle(MyButtonStyle())
        .background(backgroundColor)
        .cornerRadius(25)
        .overlay(
            /*RoundedRectangle(cornerRadius: 20)
                .stroke(
                    /*Color(
                        red: 12 / 255,
                        green: 192 / 255,
                        blue: 223 / 255
                     )*/Color.clear,
                    lineWidth: 2
                )*/
            Capsule()
              .glow(
                fill: .angularGradient(
                  stops: [
                    .init(
                        color: isError
                            ? Color.yellow
                            : primaryGlow
                                ? Color.EZNotesOrange
                                : Color.EZNotesBlue,
                        location: 0.0
                    ),
                    .init(
                        color: isError
                            ? Color.yellow
                            : primaryGlow
                                ? Color.EZNotesOrange
                                : Color.EZNotesBlue,
                        location: 0.2),
                    .init(
                        color: isError
                            ? Color.yellow
                            : primaryGlow
                                ? Color.EZNotesOrange
                                : Color.EZNotesBlue,
                        location: 0.4
                    ),
                    .init(
                        color: isError
                            ? Color.yellow
                            : Color.EZNotesBlue,
                        location: 0.5
                    ),
                    .init(
                        color: isError
                            ? Color.yellow
                            : Color.EZNotesBlue,
                        location: 0.7
                    ),
                    .init(
                        color: isError
                            ? Color.yellow
                            : primaryGlow
                                ? Color.EZNotesOrange
                                : Color.EZNotesBlue,
                        location: 0.9
                    ),
                    .init(
                        color: isError
                            ? Color.yellow
                            : primaryGlow
                                ? Color.EZNotesOrange
                                : Color.EZNotesBlue,
                        location: 1.0
                    ),
                  ],
                  center: .center,
                  startAngle: Angle(radians: .zero),
                  endAngle: Angle(radians: .pi * 2)
                ),
                lineWidth: backgroundColor != .clear
                    ? 5
                    : 2.5
              )
        )
    }
    
    var body: some View {
        ResponsiveView { prop in
            HStack(spacing: 0) {
                if !serverError {
                    if !prop.isLandscape || prop.isIpad {
                        /*if prop.isIpad && prop.size.width > prop.size.height {
                            Text(prop.isIpad ? "**Flip iPad To Use App**" : "**Flip iPhone To Use App**")
                                .font(
                                    .system(size: 30)
                                )
                                .foregroundStyle(Color.white)
                        } else {*/
                            switch(screen)
                            {
                            case "home": HomeScreen(
                                prop: prop,
                                screen: $screen,
                                startupScreen: StartupScreen(
                                    userHasSignedIn: $userHasSignedIn,
                                    goBackToLogin: $goBackToLogin,
                                    faceIDAuthenticated: $faceIDAuthenticated
                                )
                            );
                            case "login": LoginScreen(
                                prop: prop,
                                startupScreen: StartupScreen(
                                    userHasSignedIn: $userHasSignedIn,
                                    goBackToLogin: $goBackToLogin,
                                    faceIDAuthenticated: $faceIDAuthenticated
                                ),
                                screen: $screen,
                                userHasSignedIn: $userHasSignedIn
                            );
                            case "signup": SignUpScreen(
                                prop: prop,
                                startupScreen: StartupScreen(
                                    userHasSignedIn: $userHasSignedIn,
                                    goBackToLogin: $goBackToLogin,
                                    faceIDAuthenticated: $faceIDAuthenticated
                                ),
                                screen: $screen,
                                userHasSignedIn: $userHasSignedIn,
                                serverError: $serverError,
                                supportedStates: $supportedStates
                            );
                            default: HomeScreen(
                                prop: prop,
                                screen: $screen,
                                startupScreen: StartupScreen(
                                    userHasSignedIn: $userHasSignedIn,
                                    goBackToLogin: $goBackToLogin,
                                    faceIDAuthenticated: $faceIDAuthenticated
                                )
                            )
                            }
                        //}
                    } else {
                        Text(prop.isIpad ? "**Flip iPad To Use App**" : "**Flip iPhone To Use App**")
                            .font(
                                .system(size: 30)
                            )
                            .foregroundStyle(Color.white)
                    }
                } else {
                    VStack {
                        Spacer()
                        
                        Image("Logo")
                            .logoImageModifier(prop: prop)
                        
                        Text("Oh No!")
                            .font(
                                .system(size: 30, design: .rounded)
                            )
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.red)
                        
                        Text("Something went wrong!")
                            .frame(
                                maxWidth: prop.isIpad
                                    ? prop.size.width - 520
                                    : 320,
                                maxHeight: 45,
                                alignment: .top
                            )
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .font(
                                .system(
                                    size: 25, design: .rounded
                                )
                            )
                        
                        Text("This can be due to the server being down or a faulty Wi-Fi Connection.")
                            .frame(
                                maxWidth: prop.isIpad
                                    ? prop.size.width - 520
                                    : 320,
                                maxHeight: 110,
                                alignment: .top
                            )
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                            .font(
                                .system(
                                    size: 20
                                )
                            )
                            .multilineTextAlignment(.center)
                        
                        /*createButton(
                            prop: prop,
                            text: "Report",
                            primaryGlow: false,
                            isError: true,
                            action: { exit(0) }
                        )*/
                        Button(action: { exit(0) }) {
                            Text("Report")
                                .frame(maxWidth: prop.size.width - 200, maxHeight: 10)
                                .padding()
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.gray.opacity(0.6))
                                .stroke(.yellow, lineWidth: 2.5)
                        )
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding([.top], -200)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            /*Image(screen == "home" ? "Background2" : "Background5")
                .opacity(0.9)
                .blur(radius: 3.5)*/
            /*MeshGradient(width: 3, height: 3, points: [
                .init(0, 0.5), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                Color.EZNotesBlack, .purple, .indigo,
                .orange, .white, .blue,
                .yellow, .green, .mint
            ])*/
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.3, 0), .init(1, 0),
                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesOrange,
                Color.EZNotesOrange, Color.EZNotesLightBlack, Color.EZNotesBlue
                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
            ])
            .opacity(0.5)
        )
        .edgesIgnoringSafeArea([.top, .bottom])
        .onReceive(rotationChangePublisher) { _ in
            // This is called when there is a orientation change
            // You can set back the orientation to the one you like even
            // if the user has turned around their phone to use another
            // orientation.
            requestOrientations(.portrait)
        }
        .onAppear(
            perform: {
                /*if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                        // Handle denial of request.
                    }
                }*/
                RequestAction<ReqPlaceholder>(
                    parameters: ReqPlaceholder()
                )
                .perform(action: check_server_active_req)
                { r in
                    if r.Bad != nil {
                        self.serverError = true
                    } else {
                        RequestAction<ReqPlaceholder>(
                            parameters: ReqPlaceholder()
                        )
                        .perform(action: get_supported_states_req)
                        { r in
                            if r.Good != nil {
                                let message = r.Good?.Message.components(separatedBy: "\n");
                                
                                message!.forEach { m in
                                    self.supportedStates.append(m)
                                }
                            } else { self.serverError = true }
                        }
                    }
                }
            }
        )
    }
    
    private func requestOrientations(_ orientations: UIInterfaceOrientationMask) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations)) { error in
                // Handle denial of request.
            }
        }
    }
}

struct StartupScreen_Preview: PreviewProvider
{
    static var previews: some View {
        ContentView()
    }
}
