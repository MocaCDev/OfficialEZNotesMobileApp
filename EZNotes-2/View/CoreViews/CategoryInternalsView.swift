//
//  CategoryInternalsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/9/24.
//
import SwiftUI

struct CategoryInternalsView: View {
    
    var prop: Properties
    var categoryName: String
    var creationDate: String
    var categoryTitleColor: Color?
    var categoryBackgroundColor: Color?
    var categoriesAndSets: [String: Array<String>]
    var categoryBackground: UIImage
    //var categoriesSetsAndNotes: Array<[String: String]>
    
    @State private var categoryDescription: String? = nil
    @State private var generatingDesc: Bool = false
    @State private var errorGenerating: Bool = false
    @State private var setsYOffset: CGFloat = 0
    @State private var internalInfoOpacity: CGFloat = 0
    
    @Binding public var setAndNotes: [String: Array<[String: String]>]
    @Binding public var launchCategory: Bool
    @Binding public var categoryDescriptions: [String: String]
    
    @State private var show_category_internal_title: Bool = false
    
    private func checkIfOutOfFrame(innerGeometry: GeometryProxy, outerGeometry: GeometryProxy) {
        let textFrame = innerGeometry.frame(in: .global)
        let scrollViewFrame = outerGeometry.frame(in: .global)
        
        // Check if the text frame is out of the bounds of the ScrollView
        if textFrame.maxY < scrollViewFrame.minY || textFrame.minY > scrollViewFrame.maxY {
            self.show_category_internal_title = true
        } else {
            self.show_category_internal_title = false
        }
    }
    
    @State private var launchedSet: Bool = false
    
    /* MARK: If a set has been clicked, store the set name as well as the content of the notes for the set. */
    @State private var setName: String = ""
    @State private var notesContent: String = ""
    @State private var originalContet: String = "" /* MARK: This variable stores the current value of the notes. It will not be edited rather it will be used to re-assign `notesContent` in `ShowNotesView.swift` if "Undo Changes" is pressed. */
    
    var body: some View {
        if !self.launchedSet {
            VStack {
                TopNavCategoryView(
                    prop: prop,
                    categoryName: categoryName,
                    totalSets: self.categoriesAndSets[self.categoryName]!.count,
                    launchCategory: $launchCategory,
                    showTitle: $show_category_internal_title
                )
                
                //ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack {
                        VStack {
                            HStack {
                                ZStack {
                                    Image(uiImage: self.categoryBackground)
                                        .resizable()
                                        .frame(width: 55, height: 85)//(width: prop.isLargerScreen ? 100.5 : 90.5, height: prop.isLargerScreen ? 140.5 : 130.5)
                                        .scaledToFit()
                                        .zIndex(1)
                                        .cornerRadius(5)
                                        .shadow(color: self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange, radius: 2.5)
                                    /*.resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(width: prop.isLargerScreen ? 180 : 140, height: prop.isLargerScreen ? 250 : 200, alignment: .center)
                                     .minimumScaleFactor(0.3)
                                     .foregroundStyle(.white)
                                     .clipShape(.rect)
                                     .cornerRadius(15)
                                     .shadow(color: .black, radius: 2.5)*/
                                }
                                .frame(width: 55, height: 85)
                                
                                Text(self.categoryName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 5)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 30 : 25))//.setFontSizeAndWeight(weight: .semibold, size: prop.isLargerScreen ? 35 : 30)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            /*VStack {
                             Text(self.categoryName)
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .foregroundStyle(self.categoryTitleColor == nil ? Color.EZNotesOrange : self.categoryTitleColor!)
                             .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 30 : 25))//.setFontSizeAndWeight(weight: .semibold, size: prop.isLargerScreen ? 35 : 30)
                             .minimumScaleFactor(0.5)
                             .multilineTextAlignment(.leading)
                             }
                             .frame(maxWidth: .infinity, alignment: .leading)*/
                            
                            HStack {
                                Text("\(self.categoriesAndSets[self.categoryName]!.count) \(self.categoriesAndSets[self.categoryName]!.count > 1 ? "Sets" : "Set")")
                                    .frame(alignment: .leading)
                                    .setFontSizeAndWeight(weight: .thin, size: prop.isLargerScreen ? 12.5 : 10.5)
                                //.padding([.leading, .trailing], 8)
                                //.padding([.top, .bottom], 2.5)
                                
                                Divider()
                                    .background(.white)
                                
                                Text("Created \(self.creationDate)")
                                    .frame(alignment: .trailing)
                                    .setFontSizeAndWeight(weight: .thin, size: prop.size.height / 2.5 > 300 ? 12.5 : 10.5)
                                //.padding([.leading, .trailing], 8)
                                //.padding([.top, .bottom], 2.5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                            .padding(.top, -10)
                            .padding(.bottom, 5)
                            
                            HStack {
                                HStack {
                                    Button(action: { }) {
                                        Text("Edit")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .padding(2.5)
                                            .background(Color.EZNotesBlue)
                                            .cornerRadius(15)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { }) {
                                        Text("Share")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .padding(2.5)
                                            .background(Color.EZNotesBlue)
                                            .cornerRadius(15)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .buttonStyle(NoLongPressButtonStyle())
                                    
                                    Button(action: { }) {
                                        Text("Delete")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(2.5)
                                            .background(Color.EZNotesRed)
                                            .cornerRadius(15)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .buttonStyle(NoLongPressButtonStyle())
                                }
                                .frame(maxWidth: prop.size.width - 100, alignment: .leading)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            
                            if self.categoryDescription != nil {
                                VStack {
                                    Text("Brief Description:")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 8)
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-SemiBold", size: 20))
                                        .minimumScaleFactor(0.5)
                                    
                                    Text(self.categoryDescription!)
                                        .frame(maxWidth: .infinity, alignment: .leading)//(maxWidth: prop.size.width - 60, alignment: .leading)
                                        .padding([.bottom, .leading], 8) /* MARK: Pad the bottom to ensure space between the text and the sets information. Pad to the lefthand side (`.leading`) to have a indentation. */
                                        .foregroundStyle(.white)
                                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))//.setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 15 : 13)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.leading)
                                        .truncationMode(.tail)
                                }
                                .padding([.top, .bottom], 5)
                            } else {
                                VStack {
                                    if !self.generatingDesc {
                                        Button(action: {
                                            self.generatingDesc = true
                                            
                                            RequestAction<GenerateDescRequestData>(
                                                parameters: GenerateDescRequestData(
                                                    Subject: self.categoryName
                                                )
                                            ).perform(action: generate_desc_req) { statusCode, resp in
                                                guard resp != nil && statusCode == 200 else {
                                                    self.generatingDesc = false
                                                    return
                                                }
                                                
                                                self.categoryDescriptions[self.categoryName] = resp!["Desc"] as? String
                                                self.categoryDescription = resp!["Desc"] as? String
                                                writeCategoryDescriptions(categoryDescriptions: self.categoryDescriptions)
                                            }
                                        }) {
                                            if #available(iOS 18.0, *) {
                                                Text("Generate Description")
                                                    .frame(maxWidth: 200, alignment: .center)
                                                    .padding([.top, .bottom], 5)
                                                    .foregroundStyle(
                                                        MeshGradient(width: 3, height: 3, points: [
                                                            .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                                                        ], colors: [
                                                            .indigo, .indigo, Color.EZNotesBlue,
                                                            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                                            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                                            /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                             Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                             Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                                        ])
                                                    )
                                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 16 : 13)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(.white)
                                                            .strokeBorder(.white, lineWidth: 1)
                                                    )
                                            } else {
                                                Text("Generate Description")
                                                    .frame(maxWidth: 200, alignment: .center)
                                                    .padding([.top, .bottom], 5)
                                                    .foregroundStyle(.black)
                                                    .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 16 : 13)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(.white)
                                                            .strokeBorder(.white, lineWidth: 1)
                                                    )
                                            }
                                        }
                                        .padding(.top, 15)
                                        
                                        if self.errorGenerating {
                                            Text("Error generating description.. try again")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .setFontSizeAndWeight(weight: .medium, size: 16)
                                                .minimumScaleFactor(0.5)
                                        }
                                    } else {
                                        Text("Generating Description...")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.top, 15)
                                            .setFontSizeAndWeight(weight: .medium, size: 12)
                                        
                                        ProgressView()
                                            .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                                            ], colors: [
                                                .indigo, .indigo, Color.EZNotesBlue,
                                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                                                /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                                                 Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                                                 Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                                            ]))//(.blue)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        
                        Divider()
                            .background(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : .white)
                    }
                    .frame(maxWidth: prop.size.width - 40, alignment: .top)
                    .padding(.top, -15)
                    
                    VStack {
                        VStack {
                            if self.setAndNotes[self.categoryName]!.count == 0 {
                                Text("No sets or notes in this category.")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(.top)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: 20))
                                    .minimumScaleFactor(0.5)
                            } else {
                                ScrollView(.vertical, showsIndicators: false) {
                                    ForEach(Array(self.setAndNotes[self.categoryName]!.enumerated()), id: \.offset) { index, val in
                                        if val != [:] {
                                            ForEach(Array(val.keys), id: \.self) { key in
                                                Button(action: {
                                                    self.setName = key
                                                    self.notesContent = val[key]!
                                                    self.originalContet = self.notesContent
                                                    self.launchedSet = true
                                                }) {
                                                    VStack {
                                                        HStack {
                                                            Text(key)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .foregroundStyle(self.categoryTitleColor != nil ? self.categoryTitleColor! : .white)
                                                                .padding(.leading, 15)
                                                                .font(Font.custom("Poppins-SemiBold", size: 18))
                                                                .minimumScaleFactor(0.5)
                                                                .multilineTextAlignment(.leading)
                                                            
                                                            ZStack {
                                                                Image(systemName: "chevron.forward")
                                                                    .resizable()
                                                                    .frame(width: 10, height: 15)
                                                                    .foregroundStyle(.gray)
                                                            }
                                                            .frame(maxWidth: 20, alignment: .trailing)
                                                            .padding(.trailing, 15)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: 190)
                                                        .padding(/*index == self.setAndNotes[self.categoryName]!.count - 1
                                                                 ? [.top, .bottom, .leading, .trailing]
                                                                 : [.top, .leading, .trailing],*/
                                                                 8
                                                        )
                                                    }
                                                    .frame(maxWidth: prop.size.width - 20)
                                                    .padding(8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .fill(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange)
                                                    )
                                                    .cornerRadius(15)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, -25)
                            }
                        }
                        .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                    }
                    .frame(maxWidth: prop.size.width - 30, maxHeight: .infinity)
                    .padding()
                    .padding(.top, 15)
                    .cornerRadius(15)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 115)
                //}
                .padding(.top, -100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.EZNotesBlack)
            .ignoresSafeArea(edges: [.top])
            .onAppear {
                self.categoryDescription = self.categoryDescriptions[self.categoryName]
                self.setsYOffset = prop.size.height - 100
                
                /* TODO: Is this needed? Keep for now just in case. */
                withAnimation(.easeIn(duration: 0.65)) {
                    self.setsYOffset = 0
                    self.internalInfoOpacity = 1
                }
            }
        } else {
            ShowNotes(
                prop: self.prop,
                categoryName: self.categoryName,
                setName: self.setName,
                categoryBackgroundColor: self.categoryBackgroundColor,
                categoryTitleColor: self.categoryTitleColor,
                originalContent: self.originalContet,
                notesContent: $notesContent,
                launchedSet: $launchedSet,
                setAndNotes: $setAndNotes
            )
        }
    }
}
