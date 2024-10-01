//
//  ReviewNewCategorisView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/1/24.
//
import SwiftUI

struct ReviewNewCategories: View {
    
    @Binding public var section: String
    @ObservedObject public var images_to_upload: ImagesUploads
    var categories: Array<String>
    var sets: Array<String>
    var prop: Properties
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(Array(self.images_to_upload.images_to_upload.enumerated()), id: \.offset) { index, value in
                        VStack {
                            Image(uiImage: value)
                                .resizable()
                                .frame(width: prop.size.width - 50, height: 600)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.clear))
                                //         /*.stroke(Color.EZNotesBlue, lineWidth: 1)*/)
                                //.shadow(color: Color.white, radius: 6)
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Category: ")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding([.leading], 20)
                                    
                                    Spacer()
                                    
                                    Text(self.categories[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding([.trailing], 20)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: prop.size.width - 150, maxHeight: 150)
                                .padding([.top], 10)
                                
                                HStack {
                                    Text("Set: ")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding([.leading], 20)
                                    
                                    Spacer()
                                    
                                    Text(self.sets[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding([.trailing], 20)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: prop.size.width - 150, maxHeight: 150)
                                .padding([.top], 10)
                                Spacer()
                            }
                            .frame(maxWidth: prop.size.width - 150, maxHeight: 300)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.EZNotesBlack)
                                    .padding([.top], 10)
                                    .shadow(color: .white, radius: 3)
                            )
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 650)
                        .padding([.bottom], 150)
                    }
                    
                    Button(action: {
                        self.images_to_upload.images_to_upload.removeAll()
                        
                        self.section = "upload"
                    }) {
                        Text("Upload")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 25))
                            .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                            .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.EZNotesOrange)//(Color.EZNotesOrange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.clear)
                            .stroke(Color.EZNotesOrange, lineWidth: 1)
                            .shadow(color: Color.EZNotesBlack, radius: 12)
                    )
                }
                .padding([.top], 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top], 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
    }
}
