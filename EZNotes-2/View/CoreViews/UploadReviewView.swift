//
//  UploadReviewView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/30/24.
//
import SwiftUI

struct UploadReview: View {
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @Binding public var localUpload: Bool
    @Binding public var section: String
    @Binding public var lastSection: String
    
    @Binding public var newCategoriesAndSets: [String: Array<String>]
    @Binding public var categoryImages: [String: UIImage]
    @Binding public var categories: Array<String>
    @Binding public var sets: Array<String>
    @Binding public var photos: Array<String>
    @Binding public var briefDescriptions: Array<String>
    
    var prop: Properties
    
    @State private var uploadState: String = "review"
    
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
            if self.uploadState == "uploading" {
                VStack {
                    Text("Uploading \(self.images_to_upload.images_to_upload.count) images...")
                        .foregroundStyle(.white)
                        .font(.system(size: 25))
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.EZNotesBlack.opacity(0.7))
            } else {
                HStack(spacing: 0) {
                    VStack {
                        Button(action: {
                            self.section = self.lastSection
                            self.lastSection = self.section
                        }) {
                            HStack {
                                Image("Back")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding([.leading], 20)
                                    .padding([.top], prop.size.height / 2.5 > 300 ? 20 : -5)
                            }
                        }
                    }
                    .frame(maxWidth: 50, alignment: .leading)
                    
                    Spacer()
                    
                    VStack {
                        Text("Review Uploads")
                            .foregroundStyle(Color.EZNotesBlack)
                            .font(.system(size: 30))
                            .padding([.top], prop.size.height / 2.5 > 300 ? 10 : -10)
                            .padding([.leading], -30)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                if self.images_to_upload.images_to_upload.count == 1 {
                    VStack {
                        Image(uiImage: self.images_to_upload.images_to_upload[0].first!.value)
                            .resizable()
                            .frame(width: prop.size.width - 100, height: 550)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.clear)
                            )
                            .shadow(color: Color.EZNotesBlack, radius: 6)
                        
                        HStack {
                            Button(action: {
                                self.section = self.lastSection
                                self.lastSection = ""
                                
                                self.images_to_upload.images_to_upload.remove(at: 0)
                            }) {
                                Image("Delete")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                                Text("Delete")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding([.top], 10)
                        .padding([.bottom], 30)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerLastTextBaseline)
                    .padding([.bottom], 25)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(self.images_to_upload.images_to_upload.enumerated()), id: \.offset) { index, value in
                                ForEach(Array(value.enumerated()), id: \.offset) { index2, photo in
                                    VStack {
                                        Image(uiImage: photo.value)
                                            .resizable()
                                            .frame(width: prop.size.width - 100, height: 550)
                                            .clipShape(.rect(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.clear)
                                            )
                                            .shadow(color: Color.EZNotesBlack, radius: 6)
                                        
                                        HStack {
                                            Button(action: {
                                                self.images_to_upload.images_to_upload.remove(at: index)
                                                
                                                if self.images_to_upload.images_to_upload.count == 0 {
                                                    self.section = self.lastSection
                                                    self.lastSection = ""
                                                }
                                            }) {
                                                Image("Delete")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                
                                                Text("Delete")
                                                    .foregroundStyle(.red)
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .padding([.top], 10)
                                        .padding([.bottom], 30)
                                    }
                                    .padding([.trailing], 15)
                                    .padding([.leading], index == 0 ? 15 : 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .centerFirstTextBaseline)
                        .padding([.bottom], 25)
                    }
                }
                
                VStack {
                    Toggle("Save upload to device", isOn: $localUpload)
                        .frame(maxWidth: prop.size.width - 150)
                        .foregroundStyle(Color.EZNotesBlack)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                    
                    if self.localUpload == false {
                        Text("All categories will be created and stored in the cloud.")
                            .frame(maxWidth: prop.size.width - 100)
                            .foregroundStyle(Color.EZNotesLightBlack)
                            .font(.system(size: 14))
                            .italic()
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("All categories will be created and stored on your device.")
                            .frame(maxWidth: prop.size.width - 100)
                            .foregroundStyle(Color.EZNotesLightBlack)
                            .font(.system(size: 14))
                            .italic()
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.bottom], 15)
                
                Button(action: {
                    self.uploadState = "uploading" /* MARK: Show the loading screen. */
                    if self.images_to_upload.images_to_upload.count < 10 {
                        UploadImages(imageUpload: self.images_to_upload.images_to_upload)
                            .requestNativeImageUpload() { resp in
                                if resp.Bad != nil {
                                    print(resp.Bad!)
                                    
                                    if resp.Bad?.ErrorCode == 0x422 {
                                        self.images_to_upload.images_to_upload.removeAll()
                                        self.lastSection = self.section
                                        self.section = "confidential_upload_error"
                                        return
                                    }
                                    
                                    self.lastSection = self.section
                                    self.section = "upload_error"
                                    return
                                } else {
                                    self.uploadState = "review" /* MARK: Reset the `uploadState` for another round of uploading. */
                                    
                                    for r in resp.Good!.Data {
                                        self.categories.append(r.category)
                                        self.sets.append(r.set_name)
                                        self.briefDescriptions.append(r.brief_description)
                                        self.photos.append(r.image_name)
                                        
                                        if !self.categoryImages.keys.contains(r.category) {
                                            self.categoryImages[r.category] = findImage(for: r.image_name)!
                                        }
                                        
                                        /* Append the category/set_name to the `categoriesAndSets` variable
                                         * so the `Home` view gets updated.
                                         * */
                                        if self.newCategoriesAndSets.keys.contains(r.category) {
                                            if !self.newCategoriesAndSets[r.category]!.contains(r.set_name) {
                                                self.newCategoriesAndSets[r.category]!.append(r.set_name)
                                            }
                                        } else {
                                            self.newCategoriesAndSets[r.category] = [r.set_name]
                                        }
                                    }
                                    
                                    self.lastSection = self.section
                                    self.section = "review_new_categories"
                                }
                            }
                    } else {
                        UploadImages(imageUpload: self.images_to_upload.images_to_upload)
                            .multiImageUpload() { resp in
                                self.uploadState = "review"
                                
                                /* MARK: Make sure none of the responses were bad*/
                                for r in resp {
                                    if r.Bad != nil {
                                        if r.Bad!.ErrorCode == 0x422 {
                                            self.images_to_upload.images_to_upload.removeAll()
                                            self.lastSection = self.section
                                            self.section = "confidential_upload_error"
                                            return
                                        }
                                        
                                        self.lastSection = self.section
                                        self.section = "upload_error"
                                        return
                                    }
                                }
                                
                                for d in resp[resp.count - 1].Good!.Data {
                                    self.categories.append(d.category)
                                    self.sets.append(d.set_name)
                                    self.briefDescriptions.append(d.brief_description)
                                    self.photos.append(d.image_name)
                                    
                                    if !self.categoryImages.keys.contains(d.category) {
                                        self.categoryImages[d.category] = findImage(for: d.image_name)!
                                    }
                                    
                                    /* Append the category/set_name to the `categoriesAndSets` variable
                                     * so the `Home` view gets updated.
                                     * */
                                    if self.newCategoriesAndSets.keys.contains(d.category) {
                                        /* TODO: Should there be a if statement here that makes sure there aren't more than one of the same set names in the array belonging to the category?
                                         * */
                                        self.newCategoriesAndSets[d.category]!.append(d.set_name)
                                    } else {
                                        self.newCategoriesAndSets[d.category] = [d.set_name]
                                    }
                                }
                                
                                /* TODO: Iterate through all of the responses and curate data accordingly */
                                
                                self.lastSection = self.section
                                self.section = "review_new_categories"
                            }
                    }
                }) {
                    Text("Upload")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: prop.size.width - 120, maxHeight: 25)
                        .padding(5)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.EZNotesOrange)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                        .stroke(Color.EZNotesOrange, lineWidth: 1)
                        .shadow(color: Color.EZNotesBlack, radius: 12)
                )
                
                if prop.size.height / 2.5 < 300 {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("Background8")
                .blur(radius: 3.5)
        )
    }
}
