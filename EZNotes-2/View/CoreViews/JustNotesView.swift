//
//  JustNotesView.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/5/24.
//
import SwiftUI

struct JustNotes: View {
    var prop: Properties
    
    @StateObject private var fontConfiguration: FontConfiguration = FontConfiguration(defaultFont: "Poppins-Regular", defaultFontSize: 12)
    
    /* MARK: Key will be the notes name, value will be the actual notes. */
    @State private var allNotes: [String: String] = [
        /*"Test Note": "This is a test to see if shit works",
        "Test Note2": "This is a test to see if shit works2",
        "Test Note3": "This is a test to see if shit works3",
        "Test Note4": "This is a test to see if shit works",
        "Test Note5": "This is a test to see if shit works2",
        "Test Note6": "This is a test to see if shit works3"*/
        :
    ]
    
    var body: some View {
        VStack {
            if !self.allNotes.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Text("Notes(\(self.allNotes.count))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .padding([.leading], 15)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(Array(self.allNotes.keys), id: \.self) { noteTitle in
                                VStack {
                                    Button(action: { print(noteTitle) }) {
                                        VStack {
                                            Text(self.allNotes[noteTitle]!)
                                                .frame(width: 105, height: 105)
                                                .foregroundStyle(.white)
                                                .font(Font.custom(self.fontConfiguration.fontPicked, size: 8))
                                                .padding(8)
                                                .background(Color.EZNotesLightBlack.opacity(0.8))
                                                .cornerRadius(15)
                                            
                                            Text(noteTitle)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 18 : 16))
                                                .truncationMode(.tail)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                            }
                            
                            HStack {
                                Button(action: { print("Add Notes") }) {
                                    VStack {
                                        ZStack {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }
                                        .frame(width: 105, height: 105)
                                        .foregroundStyle(.white)
                                        .font(Font.custom(self.fontConfiguration.fontPicked, size: 10))
                                        .padding(8)
                                        .background(Color.EZNotesLightBlack.opacity(0.8))
                                        .cornerRadius(15)
                                        
                                        Text("Add")
                                            .frame(alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(Font.custom("Poppins-Regular", size: 20))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(alignment: .leading)
                                    .padding(.leading, 10)
                                }
                                .buttonStyle(NoLongPressButtonStyle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            } else {
                VStack {
                    Spacer()
                    
                    Text("JustNotes")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: prop.isLargerScreen ? 45 : 40, weight: .bold, design: .rounded))
                        .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ], colors: [
                            .indigo, .indigo, Color.EZNotesBlue,
                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                        ]))
                    
                    Text("Your notes, your way.\nOur tools, at your disposal.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: prop.isLargerScreen ? 16 : 13, weight: .medium))
                        /*.foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ], colors: [
                            .indigo, .indigo, .pink,
                            .pink, Color.EZNotesBlue, .purple,
                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                        ]))*/
                        .foregroundStyle(LinearGradient(colors: [.pink, Color.EZNotesBlue], startPoint: .leading, endPoint: .trailing))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 15)
                    
                    Button(action: { }) {
                        HStack {
                            Text("Create Note")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 8)
                                .foregroundStyle(.black)
                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: prop.isIpad
                               ? UIDevice.current.orientation.isLandscape
                                ? prop.size.width - 800
                                : prop.size.width - 450
                               : prop.size.width - 80)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                        )
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    
                    Text("(Coming Soon)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: prop.isLargerScreen ? 16 : 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.bottom, 30)
                    
                    Text("Beta Testers: To get back to the main app, click the gear icon at the top right of your screen and tap \"Turn Off JustNotes\", or tap on your profile picture, tap \"Settings\" and toggle \"JustNotes\" off.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}
