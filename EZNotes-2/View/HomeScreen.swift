//
//  HomeScreen.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/21/24.
//
import SwiftUI

extension View where Self: Shape {
  func glow(
    fill: some ShapeStyle,
    lineWidth: Double,
    blurRadius: Double = 8.0,
    lineCap: CGLineCap = .round
  ) -> some View {
    self
      .stroke(style: StrokeStyle(lineWidth: 3, lineCap: lineCap))
      .fill(fill)
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius)
      }
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius / 2)
      }
  }
}

let strokeTextAttributes = [
  NSAttributedString.Key.strokeColor : UIColor.red,
  NSAttributedString.Key.foregroundColor : UIColor.white,
  NSAttributedString.Key.strokeWidth : -4.0,
  NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)]
  as [NSAttributedString.Key : Any]

struct SUILabel: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> UILabel
    {
        let myLabel: UILabel = UILabel()
        
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.white,
          NSAttributedString.Key.foregroundColor : UIColor.clear,
          NSAttributedString.Key.strokeWidth : -2.0,
          NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 60)]
          as [NSAttributedString.Key : Any]

        myLabel.attributedText = NSMutableAttributedString(string: text, attributes: strokeTextAttributes)
        return myLabel
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<SUILabel>) { }
}

struct HomeScreen: View {
    public var prop: Properties
    
    @Binding public var screen: String
    @Binding public var userNotFound: Bool
    
    public var startupScreen: StartupScreen
    
    var body: some View {
        VStack {
            if self.userNotFound {
                HStack {
                    ZStack { }.frame(maxWidth: 30, alignment: .leading)
                    
                    Text("Error: User Not Found.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, 25)
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.semibold)
                    
                    ZStack { }.frame(maxWidth: 30, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .background(Color.EZNotesRed.opacity(0.85))
            }
            
            /* "Header" */
            VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, prop.size.height / 2.5 > 300 ? 50 : 0)
            
            /*VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
                
                VStack {
                    /*LinearGradient(
                        gradient: Gradient(
                            colors: [
                                /*Color.EZNotesBlue,
                                Color.EZNotesBlue,
                                Color.EZNotesOrange,
                                Color.EZNotesOrange*/
                                Color.white
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                    )
                    .frame(width: prop.isIpad ? 550 : 350, height: prop.isIpad ? 300 : 250)
                    .mask(*/
                        Text("Hello, and Welcome")
                            .contrast(10)
                            .shadow(color: .white, radius: 8)
                            //.frame(width: prop.isIpad ? 550 : 350, height: prop.isIpad ? 300 : 250)
                            .padding(
                                [.top],
                                prop.isIpad
                                    ? 30
                                    : prop.size.height / 2.5 > 300
                                        ? 0
                                        : 20)
                            .padding([.bottom], -80)
                            .fontWeight(.medium)
                            .font(
                                .system(
                                    size: prop.isIpad
                                            ? 105
                                            : prop.size.height / 2.5 > 300
                                                ? 65
                                                : 55,
                                    design: .rounded
                                )
                            )
                            .multilineTextAlignment(.center)
                    //)
                    
                    /*Text("**To your New & Completely Automated Note Taking App**")
                        .frame(
                            maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width  - 100 : prop.size.width - 60,
                            maxHeight: prop.size.height / 2, alignment: .top)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 0 : -70)
                        .font(
                            .system(
                                size: prop.size.height / 2.5 > 300 ? 20 : 17,
                                design: .monospaced
                            )
                        )
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)*/
                }
                
                //Spacer()
            }
            .padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                        ? 60
                        : 110
                    : -50
            )
            .frame(
                width: prop.isIpad
                        ? 400
                        : nil,
                height: prop.isIpad
                        ? 850
                        : prop.size.height / 2.5 > 300
                            ? 550
                            : (prop.size.height / 2.5) + 300
            )*/
            
            Spacer()
            
            /* Buttons at bottom of screen. */
            ZStack {
                VStack {
                    startupScreen.createButton(
                        prop: prop,
                        text: "Log In",
                        action: { self.screen = "login" }
                    )
                    
                    startupScreen.createButton(
                        prop: prop,
                        text: "Sign Up",
                        action: { self.screen = "signup" }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2.5 > 300 ? 200 : 150, alignment: .bottom)
            /*.background(.blue.opacity(0.2))//Color.EZNotesLightBlack.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
            .cornerRadius(15, corners: [.topLeft, .topRight])
            .shadow(color: .black, radius: 2.5, x: 0, y: -2)*/
            //.edgesIgnoringSafeArea(.bottom)
            /*.padding(
                [.bottom],
                prop.isIpad
                    ? prop.isLandscape ? 140 : 60
                    : prop.size.height / 2.5 > 300
                        ? 40
                        : 30)*/
        }
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
            .opacity(0.5)
        )
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct HomeScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
