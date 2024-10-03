//
//  HomeView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/2/24.
//
import SwiftUI

struct HomeView: View {
    @Binding public var section: String
    @ObservedObject public var images_to_upload: ImagesUploads
    var categoriesAndSets: [String: Array<String>]
    var categoryImages: [String: UIImage]
    
    @State private var home_section: String = "main"
    
    var prop: Properties
    
    var body: some View {
        VStack {
            TopNavHome(prop: prop, backgroundColor: Color.EZNotesLightBlack)
            
            /*HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(maxWidth: 30, maxHeight: 30)
                    .padding([.leading], 20)
                    .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                
                Spacer()
                
                Button(action: { print("POPUP!") }) {
                    Image("AI-Chat-Icon")
                        .resizable()
                        .frame(
                            width: prop.size.height / 2.5 > 300 ? 50 : 45,
                            height: prop.size.height / 2.5 > 300 ? 50 : 45
                        )
                        .padding([.trailing], -22)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                    
                    Text("Chat")
                        .foregroundStyle(Color.EZNotesBlue)
                        .font(.system(size: 15, design: .monospaced))
                        .fontWeight(.medium)
                        .padding([.trailing], 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? 30 : 5)
                }
                .buttonStyle(.borderless)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: prop.size.height / 2.5 > 300 ? 100 : 50
            )
            .background(Color.EZNotesLightBlack.opacity(0.4).blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)*/
            
            VStack {
                VStack {
                    Text("Categories:")
                        .foregroundStyle(.white)
                        .font(.system(size: 25, design: .rounded))
                        .fontWeight(.bold)
                        .padding([.leading], 20)
                        .padding([.top], prop.size.height / 2.5 > 300 ? -40 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                            VStack {
                                Image(uiImage: self.categoryImages[key]!)
                                    .resizable()
                                    .frame(width: prop.size.width - 50, height: 500)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.clear))
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text(key)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 20, design: .monospaced))
                                                .fontWeight(.heavy)
                                                .padding([.leading], 15)
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            
                                            Text("Created 69/69/69")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 14, design: .serif))
                                                .fontWeight(.heavy)
                                                .padding([.top], -5)
                                                //.padding([.leading], 15)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        }
                                        .frame(maxWidth: prop.size.width - 100, alignment: .leading)
                                        .padding()
                                        
                                        Spacer()
                                        
                                        VStack {
                                            Text("\(self.categoriesAndSets[key]!.count) Sets")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 18, design: .rounded))
                                                .fontWeight(.heavy)
                                                .frame(maxHeight: .infinity, alignment: .center)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    //.background(Color.EZNotesBlue.opacity(0.4).clipShape(RoundedRectangle(cornerRadius:10)))
                                    
                                    VStack {
                                        Button(action: { print("Launch Category") }) {
                                            Text("Launch")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 25, design: .rounded))
                                                .fontWeight(.bold)
                                                .frame(maxWidth: prop.size.width - 120, maxHeight: 50)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(Color.gray.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding([.bottom], 15)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                /*VStack {
                                    Text(key)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, design: .monospaced))
                                        .fontWeight(.heavy)
                                        .padding([.top], 10)
                                        .padding([.leading], 15)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    
                                    Text("Created 69/69/69")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 10, design: .serif))
                                        .fontWeight(.heavy)
                                        .padding([.top], -5)
                                        .padding([.leading], 15)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                                .frame(maxWidth: 130, maxHeight: .infinity, alignment: .leading)
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(self.categoriesAndSets[key]!.count) Sets")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 15, design: .rounded))
                                        .fontWeight(.heavy)
                                    //.padding([.leading], 15)
                                        .frame(maxHeight: .infinity, alignment: .center)
                                }.frame(maxWidth: .infinity, alignment: .center)
                                
                                Spacer()
                                
                                VStack {
                                    Button(action: { print("Open Category") }) {
                                        Image(systemName: "arrow.right")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .padding([.trailing], 30)
                                            .tint(.white)
                                    }
                                }.frame(maxWidth: .infinity, alignment: .trailing)*/
                            }
                            .frame(width: prop.size.width - 50, height: 650)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding([.top], 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    self.section = "upload"
                }
            })
        )
    }
}

struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
