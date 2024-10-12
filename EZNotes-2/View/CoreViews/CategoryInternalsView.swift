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
    var categoriesAndSets: [String: Array<String>]
    var categoryBackground: UIImage
    
    @Binding public var launchCategory: Bool
    
    var body: some View {
        VStack {
            ZStack {
                TopNavCategoryView(
                    prop: prop,
                    categoryName: categoryName,
                    totalSets: self.categoriesAndSets[self.categoryName]!.count,
                    launchCategory: $launchCategory
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(uiImage: categoryBackground)
                //.resizable()
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.scaledToFill()//.aspectRatio(contentMode: .fill)
                //.overlay(Color.EZNotesBlack.opacity(0.4))
                .blur(radius: 2.5)
        )
    }
}
