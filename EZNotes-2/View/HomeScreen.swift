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
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    public var prop: Properties
    
    @Binding public var screen: String
    @Binding public var userNotFound: Bool
    
    public var startupScreen: StartupScreen
    
    @available(iOS 17.0, *)
    var body: some View {
        VStack {
            if self.networkMonitor.needsNoWifiBanner {
                HStack {
                    ZStack { }.frame(maxWidth: 30, alignment: .leading)
                    
                    Text("No Wifi Connection")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, prop.size.height / 2.5 > 300 ? 45 : 10)
                        .foregroundStyle(.white)
                        .font(.system(size: prop.isLargerScreen ? 18 : 16))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.semibold)
                    
                    ZStack { }.frame(maxWidth: 30, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2.5 > 300 ? 80 : 60)
                .background(Color.EZNotesRed.opacity(0.85))
            } else {
                if self.userNotFound {
                    HStack {
                        ZStack { }.frame(maxWidth: 30, alignment: .leading)
                        
                        Text("Error: User Not Found.")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(.top, prop.size.height / 2.5 > 300 ? 45 : 10)
                            .foregroundStyle(.white)
                            .font(.system(size: prop.isLargerScreen ? 18 : 16))
                            .minimumScaleFactor(0.5)
                            .fontWeight(.semibold)
                        
                        ZStack { }.frame(maxWidth: 30, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: prop.size.height / 2.5 > 300 ? 80 : 60)
                    .background(Color.EZNotesRed.opacity(0.85))
                    .onAppear {
                        UserDefaults.standard.removeObject(forKey: "plan_selected")
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "email")
                        UserDefaults.standard.removeObject(forKey: "major_field")
                        UserDefaults.standard.removeObject(forKey: "major_name")
                        UserDefaults.standard.removeObject(forKey: "college_state")
                        UserDefaults.standard.removeObject(forKey: "college_name")
                    }
                }
            }
            
            /* "Header" */
            VStack {
                Image("Logo")
                    .logoImageModifier(prop: prop)
                
                Spacer()
                
                ZStack {
                    MeshGradient(width: 3, height: 3, points: [
                        .init(0, 0.5), .init(0.5, 0), .init(1, 0),
                        .init(0.0, 0.3), .init(0, 0.3), .init(1, 0.3),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ], colors: [
                        Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesBlue,
                        Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                        Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesRed
                        /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                         Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                         Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                    ])
                    .frame(
                        maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 20,
                        maxHeight: prop.isIpad ? 500 : 350,
                        alignment: .top
                    )
                    .mask(
                        VStack {
                            Text("No Pen, No Pencil")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contrast(10)
                                .shadow(color: .white, radius: 2.5)
                                .fontWeight(.heavy)
                                .font(Font.custom("Poppins-Regular", size: prop.isIpad
                                                  ? 65
                                                  : prop.size.height / 2.5 > 300
                                                  ? 40
                                                  : 30)
                                )
                                .multilineTextAlignment(.center)
                            
                            Text("Never miss a detail—your notes are taken, sorted, and ready automatically for you.")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contrast(10)
                                .shadow(color: .white, radius: 2.5)
                                .fontWeight(.heavy)
                                .font(Font.custom("Poppins-ExtraLight", size: prop.isIpad
                                                  ? 28
                                                  : prop.size.height / 2.5 > 300
                                                  ? 18
                                                  : 14)
                                )
                                .multilineTextAlignment(.center)
                        }
                    )
                }
                .frame(maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 60, maxHeight: 260, alignment: .center)//(maxWidth: prop.size.height / 2.5 > 300 ? prop.size.width - 40 : prop.size.width - 20, maxHeight: 320)
                .background(
                    Image("Test-Bg-3")
                        .resizable()
                        //.frame(maxWidth: prop.size.height / 2.5 > 300 ? .infinity : 100, maxHeight: prop.size.height / 2.5 > 300 ? .infinity : 100)
                        .aspectRatio(1, contentMode: .fill)
                        .overlay(Color.EZNotesBlack.opacity(0.6))
                        .blur(radius: 2.5)
                )
                .padding(.top, prop.size.height / 2.5 > 300 ? 0 : 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(
                .top,
                prop.isIpad ? -60 :
                    prop.isLargerScreen
                    ? self.userNotFound || self.networkMonitor.needsNoWifiBanner ? -25 : 50
                    : self.userNotFound || self.networkMonitor.needsNoWifiBanner ? -25 : -30
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
            .padding(
                .bottom,
                prop.size.height / 2.5 > 300
                    ? 40
                    : prop.size.height / 2.5 > 290 ? 30 : 10
            )

        }
        .background(
            Color.EZNotesBlack
        )
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct HomeScreen_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
