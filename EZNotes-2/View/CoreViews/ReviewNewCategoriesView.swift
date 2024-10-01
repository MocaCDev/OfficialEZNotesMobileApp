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
    
    @Binding var categories: Array<String>
    @Binding var sets: Array<String>
    @Binding var briefDescriptions: Array<String>
    @Binding var photos: Array<String>
    
    var prop: Properties
    
    private func findImage(for key: String) -> UIImage? {
        for dictionary in self.images_to_upload.images_to_upload {
            if let image = dictionary[key] {
                return image
            }
        }
        return nil
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(Array(self.photos.enumerated()), id: \.offset) { index, value in
                        VStack {
                            if let image = findImage(for: value) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: prop.size.width - 50, height: 600)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.clear))
                            }
                                //         /*.stroke(Color.EZNotesBlue, lineWidth: 1)*/)
                                //.shadow(color: Color.white, radius: 6)
                            
                            VStack {
                                Text(self.categories[index])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 28, design: .monospaced))
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(self.sets[index])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, design: .serif))
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(self.briefDescriptions[index])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14, design: .rounded))
                                    .fontWeight(.light)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.top], 10)
                            }
                            .frame(maxWidth: prop.size.width - 50, maxHeight: 200)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding([.bottom], 100)
                    }
                }
                .padding([.top], 30)
                
                Button(action: {
                    /* Remove all upload information. */
                    self.photos.removeAll()
                    self.sets.removeAll()
                    self.categories.removeAll()
                    self.briefDescriptions.removeAll()
                    self.images_to_upload.images_to_upload.removeAll()
                    
                    /* Go back to the "upload" screen. */
                    self.section = "upload"
                }) {
                    Text("Looks Good")
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top], 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
    }
}
