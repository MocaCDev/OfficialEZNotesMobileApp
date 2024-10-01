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
    public var startupScreen: StartupScreen
    
    var body: some View {
        VStack {
            /* "Header" */
            VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
                
                VStack {
                    LinearGradient(
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
                    .mask(
                        Text("Hello, and Welcome")
                            .contrast(10)
                            .shadow(color: .white, radius: 8)
                            .padding(
                                [.top],
                                prop.isIpad
                                    ? 30
                                    : prop.size.height / 2.5 > 300
                                        ? 75
                                        : 20)
                            .padding([.bottom], -80)
                            .frame(alignment: .centerLastTextBaseline)
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
                    )
                    
                    Text("**To your New & Completely Automated Note Taking App**")
                        .opacity(0.9)
                        .padding([.top], prop.size.height / 2.5 > 300 ? -20 : -70)
                        .font(
                            .system(
                                size: prop.size.height / 2.5 > 300 ? 25 : 22
                            )
                        )
                        .multilineTextAlignment(.center)
                        .frame(
                            maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width  - 100 : prop.size.width - 60,
                            maxHeight: prop.size.height / 2, alignment: .top)
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
            }
            .padding(
                [.top],
                prop.size.height / 2.5 > 300
                    ? prop.isIpad
                            ? 60
                            : 0
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
            )
            
            //Spacer()
            Spacer()
            
            /* Buttons at bottom of screen. */
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
            .frame(maxWidth: .infinity, alignment: .bottom)
            .padding(
                [.bottom],
                prop.isIpad
                    ? prop.isLandscape ? 140 : 60
                    : prop.size.height / 2.5 > 300
                        ? 0
                        : 30)
        }
    }
}

struct HomeScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
