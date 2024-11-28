//
//  UploadReviewView.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/30/24.
//
import SwiftUI

/*class ReviewActions: ObservableObject {
    @Published public var longPressed: Bool = false
    @Published public var uploadsSelected: Array<String> = []
}*/

struct ReviewView: View {
    var prop: Properties
    
    @ObservedObject public var images_to_upload: ImagesUploads
    //@ObservedObject public var reviewActions: ReviewActions
    
    @Binding public var longPressed: Bool
    @Binding public var showLargerImage: Bool
    @Binding public var indexOfImageSelected: Int!
    @Binding public var uploadsSelected: Array<String>
    
    let cols4 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: /*self.images_to_upload.images_to_upload.count >= 8 ? cols4 : cols2*/cols4, spacing: 5) {
                ForEach(Array(self.images_to_upload.images_to_upload.enumerated()), id: \.offset) { index, value in
                    ForEach(Array(self.images_to_upload.images_to_upload[index].keys), id: \.self) { key in
                        /* MARK: Below if statement needed as the array `images_to_upload.images_to_upload` will be manipulated. The view updates accordingly, but `index` does not. So, we want to ensure we are only performing code within the bounds of the aforementioned array. */
                        if index < self.images_to_upload.images_to_upload.count {
                            Button(action: {
                                if self.longPressed {
                                    if self.uploadsSelected.contains(key) {
                                        for (index, value) in self.uploadsSelected.enumerated() {
                                            if value == key { self.uploadsSelected.remove(at: index); break }
                                        }
                                        
                                        if self.uploadsSelected.count == 0 { self.longPressed = false }
                                    } else {
                                        self.uploadsSelected.append(key)
                                    }
                                    
                                    return
                                }
                                self.showLargerImage = true
                                self.indexOfImageSelected = index//self.images_to_upload.images_to_upload[index][key]!
                            }) {
                                Image(uiImage: self.images_to_upload.images_to_upload[index][key]!)
                                    .resizable()
                                    .frame(width: 80, height: 130)
                                    .minimumScaleFactor(0.5)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.clear)
                                            .strokeBorder(.white, lineWidth: 1)
                                    )
                                    .onLongPressGesture {
                                        if !self.longPressed { self.longPressed = true }
                                        
                                        if self.uploadsSelected.contains(key) {
                                            for (index, value) in self.uploadsSelected.enumerated() {
                                                if value == key { self.uploadsSelected.remove(at: index); break }
                                            }
                                            
                                            if self.uploadsSelected.count == 0 { self.longPressed = false }
                                        } else {
                                            self.uploadsSelected.append(key)
                                        }
                                    }
                                
                                if self.longPressed {
                                    VStack {
                                        Circle()
                                            .fill(self.uploadsSelected.contains(key) ? Color.EZNotesBlue : Color.clear)
                                            .strokeBorder(Color.white, lineWidth: 1)
                                    }
                                    .frame(width: 20, height: 20)
                                    .padding([.top, .bottom], 6)
                                }
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                        }
                    }
                }
            }
            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity, alignment: .top)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UploadReview: View {
    @ObservedObject public var images_to_upload: ImagesUploads
    @ObservedObject public var categoryData: CategoryData
    @Binding public var topBanner: TopBanner
    //@StateObject public var reviewActions: ReviewActions = ReviewActions()
    
    @Binding public var localUpload: Bool
    @Binding public var createOneCategory: Bool
    @Binding public var section: String
    @Binding public var lastSection: String
    @Binding public var errorType: String
    
    /*@Binding public var newCategoriesAndSets: [String: Array<String>]
    @Binding public var newSetNotes: [String: Array<[String: String]>]
    @Binding public var categoryImages: [String: UIImage]
    @Binding public var categories: Array<String>
    @Binding public var sets: Array<String>
    @Binding public var photos: Array<String>
    @Binding public var briefDescriptions: Array<String>*/
    
    var prop: Properties
    
    @State private var uploadState: String = "review"
    @State private var indexOfImageSelected: Int! = nil
    @State private var showLargerImage: Bool = false
    
    let cols4 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let cols2 = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func findImage(for key: String) -> UIImage? {
        for dictionary in self.images_to_upload.images_to_upload {
            if let image = dictionary[key] {
                return image
            }
        }
        return nil
    }
    
    @State private var longPressed: Bool = false
    @State private var uploadsSelected: Array<String> = []
    @State private var longPressTopMenuVisible: Bool = false
    @State private var reviewSection: String = "review"
    
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
                            if self.showLargerImage {
                                self.showLargerImage = false
                                self.indexOfImageSelected = nil
                                return
                            }
                            
                            self.section = self.lastSection
                            self.lastSection = self.section
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .padding([.leading], 20)
                                    .foregroundStyle(.white)
                                //.padding([.top], prop.size.height / 2.5 > 300 ? 20 : -5)
                            }
                        }
                    }
                    .frame(maxWidth: 70, alignment: .leading)
                    
                    VStack {
                        Text("Review Uploads")
                            .foregroundStyle(.white)
                            .font(.system(size: 25, design: .rounded))
                            .fontWeight(.semibold)
                            //.padding([.top], prop.isLargerScreen ? 10 : -10)
                        //.padding([.leading], -30)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    /* MARK: The below `ZStack` forces the above `VStack` to be in the middle. */
                    ZStack { }.frame(maxWidth: 70, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
                
                if self.showLargerImage {
                    VStack {
                        Image(uiImage: self.images_to_upload.images_to_upload[self.indexOfImageSelected].first!.value)
                            .resizable()
                            .frame(width: prop.size.width - 100, height: 550)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.clear)
                            )
                            .shadow(color: Color.EZNotesLightBlack, radius: 3.5)
                        
                        HStack {
                            Button(action: {
                                self.showLargerImage = false
                                self.images_to_upload.images_to_upload.remove(at: self.indexOfImageSelected)
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.red)
                                
                                Text("Delete")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding([.top], 10)
                        .padding([.bottom], 30)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding([.bottom], 25)
                } else {
                    if self.longPressed {
                        HStack {
                            if self.uploadsSelected.count == 1 {
                                VStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .frame(width: 20, height: 25)
                                        .foregroundStyle(.white)
                                    
                                    Text("Share")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 12, weight: .light))
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                                
                                VStack {
                                    Image(systemName: "square.and.arrow.down")
                                        .resizable()
                                        .frame(width: 20, height: 25)
                                        .foregroundStyle(.white)
                                    
                                    Text("Save")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 12, weight: .light))
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                                Button(action: {
                                    /* MARK: Since there is only one selection, get the first value from the array. */
                                    let toDelete = self.uploadsSelected.first!
                                    self.reviewSection = "deleting_selecte"
                                    
                                    for (index, value) in self.images_to_upload.images_to_upload.enumerated() {
                                        for key in value.keys {
                                            if key == toDelete {
                                                self.images_to_upload.images_to_upload.remove(at: index)
                                                
                                                self.uploadsSelected.removeAll()
                                                self.longPressed = false
                                                
                                                self.reviewSection = "review"
                                                
                                                if self.images_to_upload.images_to_upload.count == 0 {
                                                    self.section = "upload"
                                                }
                                                
                                                return
                                            }
                                        }
                                    }
                                }) {
                                    VStack {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(Color.EZNotesRed)
                                        
                                        Text("Delete")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 12, weight: .light))
                                            .minimumScaleFactor(0.5)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 10)
                                }
                            } else {
                                HStack {
                                    Button(action: {
                                        let newImagesToUploads: ImagesUploads = ImagesUploads()
                                        
                                        /* MARK: Filter out all of the selected images from the array and only append the images not selected to `newImagesToUploads`. */
                                        for (index, value) in self.images_to_upload.images_to_upload.enumerated() {
                                            for key in value.keys {
                                                if !self.uploadsSelected.contains(key) {
                                                    newImagesToUploads.images_to_upload.append(self.images_to_upload.images_to_upload[index])
                                                }
                                            }
                                        }
                                        
                                        /* MARK: Reassign the array with the new images. */
                                        self.images_to_upload.images_to_upload = newImagesToUploads.images_to_upload
                                        
                                        self.uploadsSelected.removeAll()
                                        self.longPressed = false
                                        
                                        self.reviewSection = "review"
                                        
                                        if self.images_to_upload.images_to_upload.count == 0 {
                                            self.section = "upload"
                                        }
                                    }) {
                                        HStack {
                                            Text("Remove All")
                                                .frame(alignment: .center)
                                                .padding(8)
                                                .foregroundStyle(.black)
                                                .setFontSizeAndWeight(weight: .medium, size: 18)
                                                .minimumScaleFactor(0.5)
                                            
                                            Image(systemName: "trash")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding([.top, .bottom], 5)
                                .background(Color.EZNotesRed.opacity(0.8))
                                .cornerRadius(20)
                            }
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        .padding([.top, .bottom], 10)
                        .background(self.uploadsSelected.count == 1
                                    ? AnyView(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                                    : AnyView(Color.clear)
                        )
                        .cornerRadius(15)
                        .scaleEffect(x: 1.0, y: self.longPressTopMenuVisible ? 1.0 : 0.0, anchor: .leading) // Animate width from left to right
                        .animation(.easeOut(duration: 0.5), value: self.longPressTopMenuVisible)
                        .onAppear {
                            self.longPressTopMenuVisible = true
                        }
                        .onDisappear {
                            self.longPressTopMenuVisible = false
                        }
                    } else {
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: { self.reviewSection = "review" }) {
                                        HStack {
                                            Text("Review")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.reviewSection == "review" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.reviewSection == "review" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Button(action: { self.reviewSection = "configuration" }) {
                                        HStack {
                                            Text("Configuration")
                                                .frame(alignment: .center)
                                                .padding([.top, .bottom], 4)
                                                .padding([.leading, .trailing], 8.5)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(self.reviewSection == "configuration" ? Color.EZNotesBlue : .clear)
                                                )
                                                .foregroundStyle(self.reviewSection == "configuration" ? .black : .secondary)
                                                .font(Font.custom("Poppins-SemiBold", size: 12))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 15)
                        .padding(.top, 5)
                        
                        VStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(.secondary)
                    }
                    
                    switch(self.reviewSection) {
                    case "review":
                        ReviewView(
                            prop: self.prop,
                            images_to_upload: self.images_to_upload,
                            longPressed: $longPressed,
                            showLargerImage: $showLargerImage,
                            indexOfImageSelected: $indexOfImageSelected,
                            uploadsSelected: $uploadsSelected
                        )
                    case "configuration":
                        VStack {
                            VStack {
                                Toggle("Save upload to device", isOn: $localUpload)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .font(.system(size: 18))
                                    .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 12)
                            .background(Color.EZNotesLightBlack.opacity(0.8))
                            .cornerRadius(15)
                            .padding(.top)
                            
                            if self.localUpload == false {
                                Text("All categories will be created and stored in the cloud.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("All categories will be created and stored on your device.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            VStack {
                                Toggle("Create One Category", isOn: $createOneCategory)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .font(.system(size: 18))
                                    .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 12)
                            .background(Color.EZNotesLightBlack.opacity(0.8))
                            .cornerRadius(15)
                            .padding(.top)
                            
                            if self.createOneCategory {
                                Text("The first image received by the server will be used to determine the category name. Any sets/set of notes belonging to the given set will then be stored in the category. This is best if all of your uploads are directly adjacent to a specific topic. If they are not, it is recommended to disable this.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                /*.frame(maxWidth: prop.size.width - 100)
                                 .foregroundStyle(Color.EZNotesLightBlack)
                                 .font(.system(size: 14))
                                 .italic()
                                 .fontWeight(.bold)
                                 .multilineTextAlignment(.center)*/
                            } else {
                                Text("Each image will generate a different category, each with sets and each with notes belonging to the set.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.leading, .trailing], 10)
                                    .padding(.bottom, 2)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                                    .minimumScaleFactor(0.5)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    /*.frame(maxWidth: prop.size.width - 100)
                                    .foregroundStyle(Color.EZNotesLightBlack)
                                    .font(.system(size: 14))
                                    .italic()
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)*/
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
                    default:
                        ReviewView(
                            prop: self.prop,
                            images_to_upload: self.images_to_upload,
                            longPressed: $longPressed,
                            showLargerImage: $showLargerImage,
                            indexOfImageSelected: $indexOfImageSelected,
                            uploadsSelected: $uploadsSelected
                        )
                    }
                }
                
                if !self.showLargerImage {
                    Button(action: {
                        //self.uploadState = "uploading" /* MARK: Show the loading screen. */
                        self.topBanner = .LoadingUploads
                        self.section = "upload"
                        
                        var errors: Int = 0
                        
                        if self.images_to_upload.images_to_upload.count < 10 {
                            UploadImages(imageUpload: self.images_to_upload.images_to_upload)
                                .requestNativeImageUpload() { resp in
                                    self.topBanner = .None
                                    
                                    if resp.Bad != nil {
                                        print(resp.Bad!)
                                        
                                        /* MARK: If `errors` accumulates to the # of values in the array `images_to_upload`, that means none of the images uploaded had anything valuable in them. Prompt an error.
                                         * */
                                        if errors == self.images_to_upload.images_to_upload.count - 1 {
                                            self.topBanner = .ErrorUploading
                                            self.images_to_upload.images_to_upload.removeAll()
                                            
                                            self.lastSection = self.section
                                            //self.section = "upload_error"
                                            //self.errorText = resp.Bad!.Message
                                            //self.errorType = resp.Bad!.Message
                                        }
                                        
                                        errors += 1
                                        
                                        return
                                    } else {
                                        //self.uploadState = "review" /* MARK: Reset the `uploadState` for another round of uploading. */
                                        
                                        for r in resp.Good!.Data {
                                            self.categoryData.categories.append(r.category)
                                            self.categoryData.sets.append(r.set_name)
                                            self.categoryData.briefDescriptions.append(r.brief_description)
                                            self.categoryData.photos.append(r.image_name)
                                            
                                            if !self.categoryData.categoryImages.keys.contains(r.category) {
                                                self.categoryData.categoryImages[r.category] = findImage(for: r.image_name)!
                                            }
                                            
                                            /* Append the category/set_name to the `categoriesAndSets` variable
                                             * so the `Home` view gets updated.
                                             * */
                                            if self.categoryData.newCategoriesAndSets.keys.contains(r.category) {
                                                //if !self.newCategoriesAndSets[r.category]!.contains(r.set_name) {
                                                var set_name: String = ""//self.categoryData.configureSetName(categoryName: r.category, currentSetName: r.set_name)
                                                var number: Int = 0
                                                
                                                for i in self.categoryData.newCategoriesAndSets[r.category]! {
                                                    if i.contains(r.set_name) {
                                                        number += 1
                                                    }
                                                }
                                                
                                                if number > 0 { set_name = "\(r.set_name) \(number)" }
                                                
                                                self.categoryData.newCategoriesAndSets[r.category]!.append(set_name)
                                                self.categoryData.newSetNotes[r.category]!.append([set_name: r.notes])
                                                
                                                //}
                                            } else {
                                                let set_name: String = self.categoryData.configureSetName(categoryName: r.category, currentSetName: r.set_name)
                                                
                                                self.categoryData.newCategoriesAndSets[r.category] = [set_name]
                                                self.categoryData.newSetNotes[r.category] = [[set_name: r.notes]]
                                            }
                                        }
                                        
                                        self.topBanner = .UploadsReadyToReview
                                        
                                        self.lastSection = self.section
                                        self.section = "upload"
                                        
                                        //self.lastSection = self.section
                                        //self.section = "review_new_categories"
                                        return
                                    }
                                }
                        } else {
                            var uploads: Array<[String: UIImage]> = []
                            let requestsBeingSent: Float = Float(self.images_to_upload.images_to_upload.count) / 5
                            let totalResponsesExpected = Int(requestsBeingSent.rounded(.up))
                            var totalResponses = 0
                            var i: Int = 0
                            var errors: Int = 0
                            
                            for (index, value) in self.images_to_upload.images_to_upload.enumerated() {
                                uploads.append(value)
                                i += 1
                                
                                if i == 5  || index == self.images_to_upload.images_to_upload.count - 1 {
                                    UploadImages(imageUpload: uploads)
                                        .requestNativeImageUpload() { resp in
                                            if index == self.images_to_upload.images_to_upload.count - 1 {
                                                self.topBanner = .None
                                            }
                                            
                                            if resp.Bad != nil || (resp.Bad == nil && resp.Good!.Status != "200") {
                                                //self.topBanner = .ErrorUploading
                                                print(resp.Bad!)
                                                
                                                if errors == self.images_to_upload.images_to_upload.count - 1 {
                                                    self.topBanner = .ErrorUploading
                                                    self.images_to_upload.images_to_upload.removeAll()
                                                    
                                                    self.lastSection = self.section
                                                    //self.section = "upload_error"
                                                    //self.errorType = resp.Bad!.Message
                                                }
                                                
                                                errors += 1
                                                
                                                return
                                            } else {
                                                totalResponses += 1
                                                //print(totalResponses, totalResponsesExpected)
                                                //self.uploadState = "review" /* MARK: Reset the `uploadState` for another round of uploading. */
                                                
                                                for r in resp.Good!.Data {
                                                    self.categoryData.categories.append(r.category)
                                                    self.categoryData.sets.append(r.set_name)
                                                    self.categoryData.briefDescriptions.append(r.brief_description)
                                                    self.categoryData.photos.append(r.image_name)
                                                    
                                                    if !self.categoryData.categoryImages.keys.contains(r.category) {
                                                        self.categoryData.categoryImages[r.category] = findImage(for: r.image_name)!
                                                    }
                                                    
                                                    /* Append the category/set_name to the `categoriesAndSets` variable
                                                     * so the `Home` view gets updated.
                                                     * */
                                                    if self.categoryData.newCategoriesAndSets.keys.contains(r.category) {
                                                        var set_name: String = self.categoryData.configureSetName(categoryName: r.category, currentSetName: r.set_name)
                                                        var number: Int = 0
                                                        
                                                        for i in self.categoryData.newCategoriesAndSets[r.category]! {
                                                            if i.contains(r.set_name) {
                                                                number += 1
                                                            }
                                                        }
                                                        
                                                        /* MARK: `number+1` due to the fact that if number is > 0, that means there is already a set name that exists.. therefore the next one will be number + 1. */
                                                        if number > 0 { set_name = "\(r.set_name) \(number+1)" }
                                                        
                                                        self.categoryData.newCategoriesAndSets[r.category]!.append(set_name)
                                                        self.categoryData.newSetNotes[r.category]!.append([set_name: r.notes])
                                                        
                                                        //if !self.newCategoriesAndSets[r.category]!.contains(r.set_name) {
                                                        //self.categoryData.newCategoriesAndSets[r.category]!.append(r.set_name)
                                                        //self.categoryData.newSetNotes[r.category]!.append([r.set_name: r.notes])
                                                        //}
                                                    } else {
                                                        let set_name: String = self.categoryData.configureSetName(categoryName: r.category, currentSetName: r.set_name)
                                                        
                                                        self.categoryData.newCategoriesAndSets[r.category] = [set_name]
                                                        self.categoryData.newSetNotes[r.category] = [[set_name: r.notes]]
                                                        //self.categoryData.newCategoriesAndSets[r.category] = [r.set_name]
                                                        //self.categoryData.newSetNotes[r.category] = [[r.set_name: r.notes]]
                                                    }
                                                }
                                                
                                                if totalResponses == totalResponsesExpected {
                                                    self.uploadState = "review"
                                                    self.topBanner = .UploadsReadyToReview
                                                    
                                                    self.lastSection = self.section
                                                    self.section = "upload"
                                                    
                                                    //self.lastSection = self.section
                                                    //self.section = "review_new_categories"
                                                }
                                            }
                                        }
                                    
                                    i = 0
                                    uploads.removeAll()
                                }
                                /*if i >= 5 || index == self.images_to_upload.images_to_upload.count - 1 {
                                 print("OKAY")
                                 
                                 UploadImages(imageUpload: uploads)
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
                                 totalResponses += 1
                                 print(totalResponses, totalResponsesExpected)
                                 //self.uploadState = "review" /* MARK: Reset the `uploadState` for another round of uploading. */
                                 
                                 if totalResponses == totalResponsesExpected {
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
                                 
                                 if totalResponses == totalResponsesExpected {
                                 self.uploadState = "review"
                                 self.lastSection = self.section
                                 self.section = "review_new_categories"
                                 }
                                 }
                                 }
                                 }
                                 
                                 uploads.removeAll()
                                 i = 0
                                 }
                                 
                                 uploads.append(value)
                                 i += 1*/
                            }
                            
                            /*UploadImages(imageUpload: self.images_to_upload.images_to_upload)
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
                             
                             for (index, _) in resp.enumerated() {
                             print(resp[index].Good!.Data.count)
                             }
                             
                             print(resp[resp.count - 1].Good!.Data.count)
                             
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
                             }*/
                        }
                    }) {
                        HStack {
                            Text("Upload")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.black)
                                .setFontSizeAndWeight(weight: .bold, size: 18)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        .padding(8)
                        .background(.white)
                        .cornerRadius(15)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                }
                
                if !prop.isLargerScreen {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        .black,
                        .black,
                        .black,
                        Color.EZNotesLightBlack
                        /*Color.EZNotesBlack,
                        Color.EZNotesBlack,
                        Color.EZNotesBlack,
                        Color.EZNotesLightBlack*/
                    ]),
                startPoint: .top,
                endPoint: .bottom
            )
            /*Image("Background8")
                .overlay(
                    Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .light)
            )*///.blur(radius: 3.5)
        )
    }
}
