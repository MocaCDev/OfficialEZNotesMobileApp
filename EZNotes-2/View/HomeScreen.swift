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
    
    @available(iOS 18.0, *)
    var body: some View {
        VStack {
            if self.userNotFound {
                HStack {
                    ZStack { }.frame(maxWidth: 30, alignment: .leading)
                    
                    Text("Error: User Not Found.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, 45)
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.semibold)
                    
                    ZStack { }.frame(maxWidth: 30, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, maxHeight: 90)
                .background(Color.EZNotesRed.opacity(0.85))
            }
            
            /* "Header" */
            VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
                
                MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0.3), .init(0.3, 0), .init(1, 0),
                    .init(0.0, 0.3), .init(0, 0.5), .init(1, 0.3),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ], colors: [
                    Color.EZNotesGreen, Color.EZNotesOrange, Color.EZNotesBlue,
                    Color.EZNotesGreen, Color.EZNotesGreen, Color.EZNotesOrange,
                    Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesBlue
                    /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                    Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                    Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                ])
                .frame(maxWidth: prop.size.width - 40, maxHeight: 300, alignment: .top)
                .mask(
                    VStack {
                        Text("Hello, and Welcome")
                        //.frame(maxWidth: prop.size.width - 40, alignment: .top)
                            .contrast(10)
                            .shadow(color: .white, radius: 2.5)
                        //.frame(width: prop.isIpad ? 550 : 350, height: prop.isIpad ? 300 : 250)
                        //.padding([.bottom], -80)
                            .fontWeight(.heavy)
                        /*.font(
                         .system(
                         size: prop.isIpad
                         ? 105
                         : prop.size.height / 2.5 > 300
                         ? 65
                         : 55
                         )
                         )*/
                            .font(Font.custom("Poppins-ExtraLight", size: prop.isIpad
                                              ? 105
                                              : prop.size.height / 2.5 > 300
                                              ? 65
                                              : 55))
                            .multilineTextAlignment(.center)
                        
                        Text("To Your New Note-Taking Bestfriend")
                            .frame(maxWidth: prop.size.width - 80, alignment: .top)
                            .font(Font.custom("Poppins-ExtraLight", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            //.setFontSizeAndWeight(weight: .bold, size: 20)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(
                .top,
                prop.size.height / 2.5 > 300
                    ? self.userNotFound ? -15 : 50
                    : 0
            )
            
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
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .bottom)
            .padding(.bottom, prop.size.height / 2.5 > 300 ? 40 : 10)

        }
        .background(
            Color.EZNotesBlack
        )
        .edgesIgnoringSafeArea([.top, .bottom])
        .onAppear {
            print(UIDevice.current.localizedModel)
        }
    }
}

struct HomeScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
