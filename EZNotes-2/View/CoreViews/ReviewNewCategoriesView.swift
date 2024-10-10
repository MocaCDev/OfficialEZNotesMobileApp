//
//  ReviewNewCategorisView.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/1/24.
//
import SwiftUI

struct ReviewNewCategories: View {
    
    @Binding public var section: String
    @Binding public var images_to_upload: Array<[String: UIImage]>
    
    @Binding var newCategoriesAndSets: [String: Array<String>]
    @Binding var categoriesAndSets: [String: Array<String>]
    @Binding var categoryImages: [String: UIImage]
    @Binding var categories: Array<String>
    @Binding var sets: Array<String>
    @Binding var briefDescriptions: Array<String>
    @Binding var photos: Array<String>
    
    @State public var indexOfSetsToRemove: Array<Int> = []
    @State public var indexOfCategoriesToRemove: Array<Int> = []
    @State public var valueOfCategoriesToRemove: Array<String> = []
    @State public var valueOfSetsToRemove: [String: Array<String>] = [:] /* The key will be the category where the sets are, the array will be the value of all the sets to remove. */

    var prop: Properties
    
    private func findImage(for key: String) -> UIImage? {
        for dictionary in self.images_to_upload {
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
                                    .padding([.top], 10)
                                
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
                                    .tint(Color.clear)//(Color.EZNotesOrange)
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
                                        .tint(Color.clear)//(Color.EZNotesOrange)
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
                        .padding([.bottom], 100)
                    }
                }
                .padding([.top], 30)
                
                Button(action: {
                    print("Before: \(self.newCategoriesAndSets)")
                    
                    if self.indexOfCategoriesToRemove.count > 0 {
                        for (_, value) in self.valueOfCategoriesToRemove.enumerated() {
                            for (_, value2) in self.newCategoriesAndSets.enumerated() {
                                if value2.key == value {
                                    self.newCategoriesAndSets.removeValue(forKey: value)
                                    break
                                }
                            }
                        }
                    }
                    
                    if self.indexOfSetsToRemove.count > 0 {
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
                    }
                    
                    print("After: \(self.newCategoriesAndSets)")
                    
                    for (_, value) in self.newCategoriesAndSets.enumerated() {
                        for (_, value2) in value.value.enumerated() {
                            if self.categoriesAndSets.keys.contains(value.key) {
                                self.categoriesAndSets[value.key]!.append(value2)
                            } else {
                                self.categoriesAndSets[value.key] = [value2]
                            }
                        }
                    }
                    
                    /* MARK: Save the categories to a JSON file. */
                    writeCategoryData(categoryData: self.categoriesAndSets)
                    writeCategoryImages(categoryImages: self.categoryImages)
                    
                    /* Remove all upload information. */
                    self.photos.removeAll()
                    self.sets.removeAll()
                    self.categories.removeAll()
                    self.briefDescriptions.removeAll()
                    self.images_to_upload.removeAll()
                    
                    self.valueOfSetsToRemove.removeAll()
                    self.indexOfSetsToRemove.removeAll()
                    self.indexOfCategoriesToRemove.removeAll()
                    self.valueOfCategoriesToRemove.removeAll()
                    self.newCategoriesAndSets.removeAll()
                    
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
                .tint(Color.EZNotesGreen)//(Color.EZNotesOrange)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                        .stroke(Color.EZNotesGreen, lineWidth: 1)
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
