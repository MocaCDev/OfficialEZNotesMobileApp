//
//  CategoryDataManager.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/28/24.
//
import SwiftUI

@MainActor class CategoryData: ObservableObject {
    /* MARK: Data when uploading. */
    @Published public var newCategoriesAndSets: [String: Array<String>] = [:]
    @Published public var newSetNotes: [String: Array<[String: String]>] = [:]
    
    /* MARK: Data over existing categories. */
    @Published public var categoriesAndSets: [String: Array<String>] = [:]//getCategoryData()
    @Published public var setAndNotes: [String: Array<[String: String]>] = [:]//getSetsAndNotes()
    @Published public var categoryCreationDates: [String: Date] = [:]//getCategoryCreationDates()
    @Published public var categoryImages: [String: UIImage] = [:]//getCategoriesImageData()
    @Published public var categoryDescriptions: [String: String] = [:]//getCategoryDescriptions()
    @Published public var categoryCustomColors: [String: Color] = [:]//getCategoryCustomColors()
    @Published public var categoryCustomTextColors: [String: Color] = [:]//getCategoryCustomTextColors()
    @Published public var categories: Array<String> = []
    @Published public var sets: Array<String> = []
    @Published public var briefDescriptions: Array<String> = []
    @Published public var photos: Array<String> = []
    
    public final func getData() {
        self.categoriesAndSets = getCategoryData()
        self.setAndNotes = getSetsAndNotes()
        self.categoryCreationDates = getCategoryCreationDates()
        self.categoryImages = getCategoriesImageData()
        self.categoryDescriptions = getCategoryDescriptions()
        self.categoryCustomColors = getCategoryCustomColors()
        self.categoryCustomTextColors = getCategoryCustomTextColors()
        
    }
    
    /* MARK: Method used to figure out whether or not a number needs to be appended to the end of a set name. */
    public final func configureSetName(categoryName: String, currentSetName: String) -> String {
        /* MARK: If there is no data in `categoriesAndSets` dictionary, just return the set name. */
        if self.categoriesAndSets.count == 0 { return currentSetName; }
        
        var set_name: String = currentSetName
        var number: Int = 0
        
        if self.categoriesAndSets.keys.contains(categoryName) {
            for i in self.categoriesAndSets[categoryName]! {
                if i.contains(currentSetName) {
                    number += 1
                }
            }
            
            /* MARK: `number+1` due to the fact that if number is > 0, that means there is already a set name that exists.. therefore the next one will be number + 1. */
            if number > 0 { set_name = "\(currentSetName) \(number+1)" }
        }
        
        return set_name
    }
    
    public final func saveNewCategories() {
        for (_, value) in self.newCategoriesAndSets.enumerated() {
            for (_, value2) in value.value.enumerated() {
                if self.categoriesAndSets.keys.contains(value.key) {
                    /*var number: Int = 0
                    
                    for set in self.categoriesAndSets[value.key]! {
                        if set == value2 { number += 1 }
                    }
                    
                    if number > 0 { self.categoriesAndSets[value.key]!.append("\(value2) \(number)") }
                    else { self.categoriesAndSets[value.key]!.append(value2) }*/
                    self.categoriesAndSets[value.key]!.append(value2)
                } else {
                    self.categoryCreationDates[value.key] = Date.now
                    self.categoriesAndSets[value.key] = [value2]
                }
            }
        }
        self.newCategoriesAndSets.removeAll()
        
        for (_, value) in self.newSetNotes.enumerated() {
            for (_, value2) in value.value.enumerated() {
                if self.setAndNotes.keys.contains(value.key) {
                    self.setAndNotes[value.key]!.append(value2)
                } else {
                    self.setAndNotes[value.key] = [value2]
                }
            }
        }
        self.newSetNotes.removeAll()
        
        //print(self.setAndNotes)
        
        //print(self.categoryCreationDates)
        
        /* MARK: Save the categories to a JSON file. */
        writeCategoryData(categoryData: self.categoriesAndSets)
        writeCategoryImages(categoryImages: self.categoryImages)
        writeCategoryCreationDates(categoryCreationDates: self.categoryCreationDates)
        writeSetsAndNotes(setsAndNotes: self.setAndNotes)
        
        /* Remove all upload information. */
        self.photos.removeAll()
        self.sets.removeAll()
        self.categories.removeAll()
        self.briefDescriptions.removeAll()
    }
}
