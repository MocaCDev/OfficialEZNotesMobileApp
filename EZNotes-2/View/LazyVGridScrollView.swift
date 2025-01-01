//
//  LazyVGridScrollView.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/30/24.
//
import SwiftUI

/* MARK: Compresses code in this file a bit enabling us to simply use `LazyVGridScrollViewConfiguration` instead of re-defining each of the variables within the aforementioned structure. */
struct LazyVGridScrollViewConfiguration {
    var direction: Axis.Set = .vertical /* MARK: Default to vertical scrollview. */
    var showScrollbar: Bool = false
    var lazyVGridColumns: [GridItem] = [GridItem(.flexible())] /* MARK: Default is one "unit" per "row". */
    var lazyVGridSpacing: CGFloat = 0
}

struct LazyVGridScrollView<Content: View>: View {
    var config: LazyVGridScrollViewConfiguration
    var action: ()->Content
    
    var body: some View {
        VStack {
            ScrollView(self.config.direction, showsIndicators: self.config.showScrollbar) {
                LazyVGrid(columns: self.config.lazyVGridColumns, spacing: self.config.lazyVGridSpacing) {
                    action()
                }
            }
        }
    }
}

/* MARK: Scrollview for arrays. */
struct LazyVGridScrollViewForArray<T: Hashable, Content: View>: View {
    var config: LazyVGridScrollViewConfiguration = LazyVGridScrollViewConfiguration()
    
    /*var direction: Axis.Set = .vertical /* MARK: Default to vertical scrollview. */
    var showScrollbar: Bool = false
    var lazyVGridColumns: [GridItem] = [GridItem(.flexible())] /* MARK: Default is one "unit" per "row". */
    var lazyVGridSpacing: CGFloat = 0*/
    
    /* MARK: Data for `ForEach` that dwells inside the `LazyVGrid`. */
    var data: Array<T>
    var action: (T)->Content
    
    var body: some View {
        /*VStack {
            ScrollView(self.config.direction, showsIndicators: self.config.showScrollbar) {
                LazyVGrid(columns: self.config.lazyVGridColumns, spacing: self.config.lazyVGridSpacing) {
                    ForEach(self.data, id: \.self) { value in
                        Text("\(value)") /* MARK: `T` can be anything, ensure it is displayed as a string. */
                    }
                }
            }
        }*/
        LazyVGridScrollView(config: self.config) {
            ForEach(self.data, id: \.self) { value in
                action(value)
                //Text("\(value)") /* MARK: `T` can be anything, ensure it is displayed as a string. */
            }
        }
        /* MARK: `.frame` will be applies to the view when used. */
    }
}

/* MARK: `T1` will be the keys type, `T2` will be the values type. */
struct LazyVGridScrollViewForDictionary<T1: Hashable, T2: Hashable, Content: View>: View {
    var config: LazyVGridScrollViewConfiguration = LazyVGridScrollViewConfiguration()
    var data: Dictionary<T1, T2>
    var action: (Dictionary<T1, T2>, T1)->Content
    
    var body: some View {
        LazyVGridScrollView(config: self.config) {
            ForEach(Array(self.data.keys), id: \.self) { key in
                action(self.data, key)
                //Text("\(value)") /* MARK: `T` can be anything, ensure it is displayed as a string. */
            }
        }
    }
}
