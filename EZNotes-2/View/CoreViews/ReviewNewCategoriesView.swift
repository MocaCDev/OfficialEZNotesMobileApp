//
//  ReviewNewCategorisView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/1/24.
//
import SwiftUI

struct ReviewNewCategories: View {
    @EnvironmentObject private var categoryData: CategoryData
    
    @Binding public var section: String
    @ObservedObject public var images_to_upload: ImagesUploads
    
    @State public var indexOfSetsToRemove: Array<Int> = []
    @State public var indexOfCategoriesToRemove: Array<Int> = []
    @State public var valueOfCategoriesToRemove: Array<String> = []
    @State public var valueOfSetsToRemove: [String: Array<String>] = [:] /* The key will be the category where the sets are, the array will be the value of all the sets to remove. */
    @State private var possibleSameCategories: String = ""

    var prop: Properties
    
    private func findImage(for key: String) -> UIImage? {
        for dictionary in self.images_to_upload.images_to_upload {
            if let image = dictionary[key] {
                return image
            }
        }
        return nil
    }
    
    @State private var categoryDescHeight: CGFloat = 0
    @State private var categorySimilarities: [String: Array<String>] = [:]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(Array(self.categoryData.photos.enumerated()), id: \.offset) { index, value in
                        VStack {
                            HStack {
                                if let image = findImage(for: value) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 120, height: 170)
                                        .minimumScaleFactor(0.5)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.clear)
                                                .strokeBorder(.white, lineWidth: 1)
                                        )
                                }
                                
                                VStack {
                                    if !self.indexOfCategoriesToRemove.contains(index) {
                                        Text(self.categoryData.categories[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 26, design: .monospaced))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.bold)
                                    } else {
                                        Text(self.categoryData.categories[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 26, design: .monospaced))
                                            .minimumScaleFactor(0.5)
                                            .fontWeight(.bold)
                                            .strikethrough()
                                    }
                                    
                                    if !self.indexOfCategoriesToRemove.contains(index) {
                                        Text(self.categoryData.sets[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16, design: .serif))
                                            .minimumScaleFactor(0.3)
                                            .fontWeight(.medium)
                                    } else {
                                        Text(self.categoryData.sets[index])
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16, design: .serif))
                                            .minimumScaleFactor(0.3)
                                            .fontWeight(.medium)
                                            .strikethrough()
                                    }
                                    
                                    ZStack {
                                        Button(action: {
                                            if !self.indexOfCategoriesToRemove.contains(index) {
                                                self.indexOfCategoriesToRemove.append(index)
                                                self.valueOfCategoriesToRemove.append(self.categoryData.categories[index])
                                            }
                                            else {
                                                self.indexOfCategoriesToRemove = self.indexOfCategoriesToRemove.filter { $0 != index }
                                                self.valueOfCategoriesToRemove = self.valueOfCategoriesToRemove.filter { $0 != self.categoryData.categories[index] }
                                            }
                                        }) {
                                            ZStack {
                                                HStack {
                                                    Text(!self.indexOfCategoriesToRemove.contains(index) ? "Delete" : "Undo Removal")
                                                        .frame(alignment: .center)
                                                        .foregroundStyle(.white)
                                                        .setFontSizeAndWeight(weight: .medium, size: 16)
                                                        .minimumScaleFactor(0.5)
                                                    
                                                    if !self.indexOfCategoriesToRemove.contains(index) {
                                                        Image(systemName: "trash")
                                                            .resizable()
                                                            .frame(width: 15, height: 15)
                                                            .foregroundStyle(.gray)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding([.top, .bottom], 5)
                                            .background(!self.indexOfCategoriesToRemove.contains(index)
                                                        ? Color.EZNotesRed.opacity(0.8)
                                                        : Color.EZNotesGreen.opacity(0.8)
                                            )
                                            .cornerRadius(20)
                                        }
                                        .buttonStyle(NoLongPressButtonStyle())
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        self.categoryDescHeight = geometry.size.height
                                    }
                                    .onChange(of: geometry.size.height) {
                                        self.categoryDescHeight = geometry.size.height
                                    }
                                })
                                .padding([.leading, .trailing], 5.5)
                            }
                            .frame(maxWidth: prop.size.width - 20)
                            .padding([.top, .bottom])
                            
                            HStack {
                                Image("AI-Chat")
                                    .resizableImage(width: 20, height: 20)
                                
                                Text(self.categoryData.briefDescriptions[index])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.top, .bottom], 10)
                                    .padding([.leading, .trailing], 15)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 14, design: .rounded))
                                    .fontWeight(.light)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white.opacity(0.85))
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 5)
                            
                            if self.categoryData.categoriesAndSets.keys.contains(self.categoryData.categories[index]) {
                                Text("Category already exists.")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 8)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 12, weight: .medium))
                            } else {
                                if self.categorySimilarities != [:] {
                                    if self.categorySimilarities.keys.contains(self.categoryData.categories[index]) {
                                        HStack {
                                            Text("Similar Categories:")
                                                .frame(alignment: .leading)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 12, weight: .medium))
                                                .minimumScaleFactor(0.5)
                                            
                                            ScrollView(.horizontal, showsIndicators: true) {
                                                HStack {
                                                    ForEach(self.categorySimilarities[self.categoryData.categories[index]]!, id: \.self) { similarity in
                                                        Text(similarity)
                                                            .frame(maxWidth: .infinity, alignment: .center)
                                                            .padding(8)
                                                            .background(Color.EZNotesLightBlack.opacity(0.8))
                                                            .cornerRadius(20)
                                                            .foregroundStyle(.white)
                                                            .font(.system(size: 10, weight: .medium))
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                }
                                                .padding([.top, .bottom], 10)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .frame(maxWidth: prop.size.width - 40)
                                        //Text("\(self.categorySimilarities[self.categories[index]]!)")
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: prop.size.width - 20)
                        
                        VStack {
                            
                        }
                        .frame(maxWidth: prop.size.width - 20, maxHeight: 0.5).background(.secondary)
                        /*VStack {
                            if let image = findImage(for: value) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: prop.size.width - 50, height: 600)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.clear)
                                        .shadow(color: .black, radius: 2.5)
                                    )
                            }
                            
                            VStack {
                                if !self.indexOfCategoriesToRemove.contains(index) {
                                    Text(self.categories[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 28, design: .monospaced))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(self.categories[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 28, design: .monospaced))
                                        .fontWeight(.bold)
                                        .strikethrough()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                if !self.indexOfCategoriesToRemove.contains(index) {
                                    Text(self.sets[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20, design: .serif))
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(self.sets[index])
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20, design: .serif))
                                        .fontWeight(.medium)
                                        .strikethrough()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Text(self.briefDescriptions[index])
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14, design: .rounded))
                                    .fontWeight(.light)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.top, .bottom], 10)
                                
                                VStack {
                                    Button(action: {
                                        if !self.indexOfCategoriesToRemove.contains(index) {
                                            self.indexOfCategoriesToRemove.append(index)
                                            self.valueOfCategoriesToRemove.append(self.categories[index])
                                        }
                                        else {
                                            self.indexOfCategoriesToRemove = self.indexOfCategoriesToRemove.filter { $0 != index }
                                            self.valueOfCategoriesToRemove = self.valueOfCategoriesToRemove.filter { $0 != self.categories[index] }
                                        }
                                    }) {
                                        Text(!self.indexOfCategoriesToRemove.contains(index) ? "Delete" : "Undo Removal")
                                            .foregroundStyle(Color.white)
                                            .font(.system(size: 18))
                                            .fontWeight(.light)
                                            .frame(maxWidth: prop.size.width - 220, maxHeight: 15)
                                            .padding(5)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.clear)
                                            .stroke(!self.indexOfCategoriesToRemove.contains(index) ? Color.red : Color.green, lineWidth: 1)
                                    )
                                    
                                    if !self.indexOfCategoriesToRemove.contains(index) && self.categoriesAndSets.keys.contains(self.categories[index]) {
                                        Button(action: {
                                            if !self.indexOfSetsToRemove.contains(index) {
                                                self.indexOfSetsToRemove.append(index)
                                                
                                                if self.valueOfSetsToRemove.keys.contains(self.categories[index]) {
                                                    self.valueOfSetsToRemove[self.categories[index]]!.append(self.sets[index])
                                                } else {
                                                    self.valueOfSetsToRemove[self.categories[index]] = [self.sets[index]]
                                                }
                                            }
                                            else {
                                                self.indexOfSetsToRemove = self.indexOfSetsToRemove.filter { $0 != index }
                                                
                                                self.valueOfSetsToRemove[self.categories[index]] = self.valueOfSetsToRemove[self.categories[index]]?.filter { $0 != self.sets[index] }
                                            }
                                        }) {
                                            Text(!self.indexOfSetsToRemove.contains(index) ? "Delete Set" : "Undo Removal")
                                                .foregroundStyle(Color.white)
                                                .font(.system(size: 18))
                                                .fontWeight(.light)
                                                .frame(maxWidth: prop.size.width - 220, maxHeight: 15)
                                                .padding(5)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.clear)
                                                .stroke(!self.indexOfSetsToRemove.contains(index) ? Color.red : Color.green, lineWidth: 1)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                .padding([.top], 10)
                            }
                            .frame(maxWidth: prop.size.width - 50, maxHeight: 200)
                            .padding([.top], 15)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding([.bottom], 100)*/
                    }
                }
                .padding([.top], 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.top], 30)
            
            Button(action: {
                //print("Before: \(self.newCategoriesAndSets)")
                
                if self.indexOfCategoriesToRemove.count > 0 {
                    for (_, value) in self.valueOfCategoriesToRemove.enumerated() {
                        for (_, value2) in self.categoryData.newCategoriesAndSets.enumerated() {
                            if value2.key == value {
                                self.categoryData.newCategoriesAndSets.removeValue(forKey: value)
                                self.categoryData.newSetNotes.removeValue(forKey: value)
                                break
                            }
                        }
                    }
                }
                
                /*if self.indexOfSetsToRemove.count > 0 {
                    for (_, value) in self.valueOfSetsToRemove.enumerated() {
                        for (index, value2) in self.newCategoriesAndSets[value.key]!.enumerated() {
                            if value.value.contains(value2) {
                                self.newCategoriesAndSets[value.key]!.remove(at: index)
                                
                                if self.newCategoriesAndSets[value.key]!.count == 0 {
                                    self.newCategoriesAndSets.removeValue(forKey: value.key)
                                }
                            }
                        }
                    }
                }*/
                
                //print("After: \(self.newCategoriesAndSets)")
                
                self.categoryData.saveNewCategories()
    
                self.images_to_upload.images_to_upload.removeAll()
                
                self.valueOfSetsToRemove.removeAll()
                self.indexOfSetsToRemove.removeAll()
                self.indexOfCategoriesToRemove.removeAll()
                self.valueOfCategoriesToRemove.removeAll()
                
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
            .tint(Color.EZNotesGreen)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear)
                    .stroke(Color.EZNotesGreen, lineWidth: 1)
                    .shadow(color: Color.EZNotesBlack, radius: 12)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.EZNotesBlack)
        .onAppear {
            /* MARK: Don't do anything if categories don't exist yet. */
            if self.categoryData.categoriesAndSets.count == 0 { return }
            
            var existingCategories: Array<String> = []
            
            for key in self.categoryData.categoriesAndSets.keys {
                existingCategories.append(key)
            }
            
            RequestAction<DetectPossibleSimilarCategories>(parameters: DetectPossibleSimilarCategories(
                NewCategories: self.categoryData.categories, ExistingCategories: existingCategories
            ))
            .perform(action: detect_possible_similar_categories_req) { statusCode, resp in
                guard resp != nil && statusCode == 200 else {
                    /* TODO: Deal with error. */
                    if let resp = resp { print(resp) }
                    return
                }
                
                if let resp = resp {
                    /* MARK: If `NoData` is in the response, that means there were no similarities found. */
                    if !resp.keys.contains("NoData") {
                        self.categorySimilarities = resp as! [String: Array<String>]
                    }
                }
            }
        }
    }
}
