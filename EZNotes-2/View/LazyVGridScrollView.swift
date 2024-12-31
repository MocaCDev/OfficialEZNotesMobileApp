//
//  LazyVGridScrollView.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/30/24.
//
import SwiftUI

/* MARK: Scrollview for arrays. */
struct LazyVGridScrollViewForArray<T: Hashable>: View {
    var direction: Axis.Set = .vertical /* MARK: Default to vertical scrollview. */
    var showScrollbar: Bool = false
    var lazyVGridColumns: [GridItem] = [GridItem(.flexible())] /* MARK: Default is one "unit" per "row". */
    var lazyVGridSpacing: CGFloat = 0
    
    /* MARK: Data for `ForEach` that dwells inside the `LazyVGrid`. */
    var data: Array<T>
    
    var body: some View {
        VStack {
            ScrollView(self.direction, showsIndicators: self.showScrollbar) {
                LazyVGrid(columns: self.lazyVGridColumns, spacing: self.lazyVGridSpacing) {
                    ForEach(self.data, id: \.self) { value in
                        Text("\(value)") /* MARK: `T` can be anything, ensure it is displayed as a string. */
                    }
                }
            }
        }
        /* MARK: `.frame` will be applies to the view when used. */
    }
}
