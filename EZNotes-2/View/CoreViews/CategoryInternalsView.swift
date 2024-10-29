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
    var categoryDescription: String?
    var categoriesAndSets: [String: Array<String>]
    var categoryBackground: UIImage
    
    @Binding public var launchCategory: Bool
    
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
            .padding(.top, 115)*/
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.top)
        .background(.black)
    }
}
