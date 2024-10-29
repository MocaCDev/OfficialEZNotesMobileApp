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
    var categoriesAndSets: [String: Array<String>]
    var categoryBackground: UIImage
    
    @Binding public var launchCategory: Bool
    
    var body: some View {
        VStack {
            TopNavCategoryView(
                prop: prop,
                categoryName: categoryName,
                totalSets: self.categoriesAndSets[self.categoryName]!.count,
                launchCategory: $launchCategory
            )
            
            VStack {
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
                }
                .frame(maxWidth: prop.size.width - 40, alignment: .topLeading)
                
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.top)
        .background(.black)
    }
}
