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
    
    @State private var categoryDescription: String? = nil
    @State private var generatingDesc: Bool = false
    @State private var errorGenerating: Bool = false
    
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
    
    var body: some View {
        VStack {
            TopNavCategoryView(
                prop: prop,
                categoryName: categoryName,
                totalSets: self.categoriesAndSets[self.categoryName]!.count,
                launchCategory: $launchCategory,
                showTitle: $show_category_internal_title
            )
            
            HStack {
                VStack {
                    HStack {
                        ZStack {
                            Image(uiImage: self.categoryBackground)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: prop.size.height / 2.5 > 300 ? 60 : 50, height: prop.size.height / 2.5 > 300 ? 60 : 50, alignment: .center)
                                .minimumScaleFactor(0.3)
                                .foregroundStyle(.white)
                                .clipShape(.rect)
                                .cornerRadius(15)
                                .shadow(color: .black, radius: 2.5)
                        }
                        .frame(width: prop.size.height / 2.5 > 300 ? 60 : 50, height: prop.size.height / 2.5 > 300 ? 60 : 50, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : Color.EZNotesOrange, lineWidth: 1)
                        )
                        
                        Text(self.categoryName)
                            .frame(maxWidth: prop.size.width - 40, alignment: .leading)
                            .padding(.leading, 5)
                            .foregroundStyle(self.categoryTitleColor == nil ? Color.EZNotesOrange : self.categoryTitleColor!)
                            .setFontSizeAndWeight(weight: .semibold, size: prop.size.height / 2.5 > 300 ? 50 : 40)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("\(self.categoriesAndSets[self.categoryName]!.count) \(self.categoriesAndSets[self.categoryName]!.count > 1 ? "Sets" : "Set")")
                            .frame(alignment: .leading)
                            .setFontSizeAndWeight(weight: .thin, size: prop.size.height / 2.5 > 300 ? 12.5 : 10.5)
                            //.padding([.leading, .trailing], 8)
                            .padding([.top, .bottom], 2.5)
                        
                        Divider()
                            .background(.white)
                        
                        Text("Created \(self.creationDate)")
                            .frame(alignment: .trailing)
                            .setFontSizeAndWeight(weight: .thin, size: prop.size.height / 2.5 > 300 ? 12.5 : 10.5)
                            //.padding([.leading, .trailing], 8)
                            .padding([.top, .bottom], 2.5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                    .padding(.top, -20)
                    .padding(.bottom, 5)
                    
                    if self.categoryDescription != nil {
                        Text(self.categoryDescription!)
                            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)//(maxWidth: prop.size.width - 60, alignment: .leading)
                            .foregroundStyle(.white)
                            .setFontSizeAndWeight(weight: .medium, size: prop.size.height / 2.5 > 300 ? 18 : 13)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                            .truncationMode(.tail)
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
                                    .foregroundStyle(.blue)
                                /*.tint(
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
                                 )*/
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Button(action: { }) {
                        Text("Edit")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(2.5)
                            .background(Color.EZNotesBlue)
                            .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(NoLongPressButtonStyle())
                    
                    Button(action: { }) {
                        Text("Share")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(2.5)
                            .background(Color.EZNotesBlue)
                            .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(NoLongPressButtonStyle())
                    
                    Button(action: { }) {
                        Text("Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(2.5)
                            .background(Color.EZNotesRed)
                            .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(NoLongPressButtonStyle())
                }
                .frame(maxWidth: 120, alignment: .trailing)//.frame(maxWidth: prop.size.width - 40, maxHeight: 30)
                .padding(.trailing, 10)
            }
            .frame(maxWidth: prop.size.width - 40, alignment: .top)
            .frame(width: nil, height: 250, alignment: .top)
            .padding(.top, -15)
            /*.background(
                Image(uiImage: self.categoryBackground)
                    .resizableImageFill()
                    .overlay(Color.EZNotesBlack.opacity(0.8))
            )*/
            
            VStack {
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                Rectangle()
                    .fill(.black)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                    .shadow(color: self.categoryBackgroundColor != nil
                            ? self.categoryBackgroundColor != Color.black
                                ? self.categoryBackgroundColor!
                                : Color.EZNotesOrange
                            : Color.EZNotesOrange, radius: 10)
            )
            .padding(.top, -45)
            /*TopNavCategoryView(
                prop: prop,
                categoryName: categoryName,
                totalSets: self.categoriesAndSets[self.categoryName]!.count,
                launchCategory: $launchCategory,
                showTitle: $show_category_internal_title
            )
            
            VStack {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Image(uiImage: self.categoryBackground)
                                .resizableImageFill(width: 130, height: 130)
                                .clipShape(.rect)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .strokeBorder(.white, lineWidth: 1)
                                )
                            
                            HStack {
                                Text("\(self.categoriesAndSets[self.categoryName]!.count) Sets")
                                    .frame(alignment: .leading)
                                    .padding([.leading, .trailing], 8)
                                    .padding([.top, .bottom], 2.5)
                                
                                Divider()
                                    .background(.white)
                                
                                Text("Created \(self.creationDate)")
                                    .frame(alignment: .trailing)
                                    .padding([.leading, .trailing], 8)
                                    .padding([.top, .bottom], 2.5)
                            }
                            .frame(maxWidth: 200, alignment: .center)
                            .padding(.bottom, 5)
                            .padding(.top, 8)
                            
                            Text(self.categoryName)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(LinearGradient(gradient: Gradient(
                                    colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                ), startPoint: .leading, endPoint: .trailing))
                                .setFontSizeAndWeight(weight: .semibold, size: prop.size.height / 2.5 > 300 ? 60 : 50)
                                .multilineTextAlignment(.center)
                            
                            Text(self.categoryDescription == nil ? "No Description." : self.categoryDescription!)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .light, size: prop.size.height / 2.5 > 300 ? 20 : 15)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: prop.size.width - 40, alignment: .top)
                        .padding()
                        
                        /*VStack {
                            VStack {
                                Text(self.categoryName)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .foregroundStyle(LinearGradient(gradient: Gradient(
                                        colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                                    ), startPoint: .leading, endPoint: .trailing))
                                    .setFontSizeAndWeight(weight: .semibold, size: prop.size.height / 2.5 > 300 ? 30 : 25)
                                
                                Text(self.creationDate)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .thin, size: prop.size.height / 2.5 > 300 ? 25 : 20)
                            }
                            .frame(maxWidth: prop.size.width - 100, alignment: .top)
                            .padding(.top)
                            
                            VStack {
                                Text(self.categoryDescription == nil ? "No Description." : self.categoryDescription!)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 5)
                                    .foregroundStyle(.white)
                                    .setFontSizeAndWeight(weight: .thin, size: prop.size.height / 2.5 > 300 ? 15 : 10)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: prop.size.width - 40)
                            
                            Divider()
                                .background(.white)
                                .frame(width: prop.size.width - 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)*/
                        
                        VStack {
                            ForEach(Array(self.categoriesAndSets.keys), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .padding(.leading, 10)
                                }
                                .frame(maxWidth: prop.size.width - 40, maxHeight: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.black)
                                        .shadow(color: Color.EZNotesBlack, radius: 2.5)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        /*VStack {
                         HStack {
                         HStack {
                         VStack {
                         GeometryReader { innerGeometry in
                         Text(self.categoryName)
                             .frame(maxWidth: .infinity, alignment: .topLeading)
                             .foregroundStyle(LinearGradient(gradient: Gradient(
                             colors: [Color.EZNotesBlue, Color.EZNotesOrange, Color.EZNotesGreen]
                             ), startPoint: .leading, endPoint: .trailing))
                             .setFontSizeAndWeight(weight: .semibold, size: 110)
                             .minimumScaleFactor(0.5)
                         .onChange(of: innerGeometry.frame(in: .global)) {
                         checkIfOutOfFrame(innerGeometry: innerGeometry, outerGeometry: geometry)
                         }
                         }
                         
                         Text(self.creationDate)
                         .frame(maxWidth: .infinity, alignment: .topLeading)
                         .foregroundStyle(.white)
                         .setFontSizeAndWeight(weight: .thin, size: 25)
                         .minimumScaleFactor(0.5)
                         
                         Text("Description")
                         .frame(maxWidth: .infinity, alignment: .topLeading)
                         .padding(.top)
                         .foregroundStyle(.white)
                         .setFontSizeAndWeight(weight: .semibold, size: 20)
                         .minimumScaleFactor(0.5)
                         
                         Text(self.categoryDescription != nil ? self.categoryDescription! : "No description")
                         .frame(maxWidth: .infinity, alignment: .topLeading)
                         .padding(.leading)
                         .foregroundStyle(.white)
                         .setFontSizeAndWeight(weight: .light, size: 16)
                         .minimumScaleFactor(0.5)
                         }
                         }
                         .frame(maxWidth: prop.size.width - 80, maxHeight: .infinity)
                         
                         /*Divider()
                          .foregroundStyle(.white)
                          .frame(maxWidth: prop.size.width - 80)*/
                         }
                         .frame(maxWidth: .infinity, alignment: .top)
                         .background(Color.EZNotesLightBlack.opacity(0.65))
                         
                         
                         Spacer()
                         
                         VStack {
                         
                         }
                         .frame(maxWidth: .infinity, maxHeight: .infinity)
                         .background(
                         Rectangle()
                         .fill(.black)
                         .shadow(color: .black, radius: 2.5, y: -2.5)
                         )
                         }
                         .frame(maxWidth: .infinity, maxHeight: .infinity)*/
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, -10)
            
            /*TopNavCategoryView(
                prop: prop,
                categoryName: categoryName,
                totalSets: self.categoriesAndSets[self.categoryName]!.count,
                launchCategory: $launchCategory
            )
            
            VStack {
                HStack {
                    HStack {
                        VStack {
                            Text(self.categoryName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .semibold, size: 35)
                                .minimumScaleFactor(0.5)
                            
                            Text(self.creationDate)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .setFontSizeAndWeight(weight: .thin, size: 14)
                                .minimumScaleFactor(0.5)
                        }
                        
                        HStack {
                            Button(action: { }) {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 16.5, height: 16.5)
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding([.trailing], 10)
                                
                                Text("Edit")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            .padding([.leading], 10)
                            .padding([.trailing], 5)
                            
                            Button(action: { }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 16.5, height: 16.5)
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding([.trailing], 10)
                                
                                Text("Delete")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            .padding([.leading], 10)
                            .padding([.trailing], 5)
                            
                            Button(action: { }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .frame(width: 16.5, height: 16.5)
                                    .foregroundStyle(Color.EZNotesBlue)
                                    .padding([.trailing], 10)
                                
                                Text("Share")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            .padding([.leading], 10)
                            .padding([.trailing], 5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: prop.size.width - 100, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(
                    Image(uiImage: self.categoryBackground)
                        .resizableImageFill()
                        .overlay(Color.EZNotesBlack.opacity(0.35))
                )
                
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 115)*/*/
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea([.top, .bottom])
        .background(.black)//.background(self.categoryBackgroundColor != nil ? self.categoryBackgroundColor! : .black)//.background(.black)
        .onAppear {
            self.categoryDescription = self.categoryDescriptions[self.categoryName]
        }
    }
}
