//
//  EZNotesExtensions.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/28/24.
//
import SwiftUI

public extension View {
    internal func topNavSettings(prop: Properties, backgroundColor: Color) -> some View {
        self
            .frame(
                maxWidth: .infinity,
                maxHeight: prop.size.height / 2.5 > 300 ? 50 : 50
            )
            .background(backgroundColor.opacity(0.1).blur(radius: 3.5))
            .edgesIgnoringSafeArea(.top)
    }
    
    func frameAndPadding(width: CGFloat, height: CGFloat, align: Alignment = .center, padEdges: Edge.Set, pad: CGFloat) -> some View {
        self
            .frame(width: width, height: height, alignment: align)
            .padding(padEdges, pad)
    }
    
    func frameAndPadding(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat? = .infinity, align: Alignment = .center, padEdges: Edge.Set, pad: CGFloat) -> some View {
        self
            .frame(width: maxWidth, height: maxHeight, alignment: align)
            .padding(padEdges, pad)
    }
    
    func setFontSizeAndWeight(weight: Font.Weight? = .regular, size: CGFloat? = 12, design: Font.Design? = .default) -> some View {
        self
            .fontWeight(weight)
            .font(.system(size: size!, design: design))
    }
}

public extension Image {
    func resizableImage(width: CGFloat, height: CGFloat, align: Alignment? = .center) -> some View {
        self
            .resizable()
            .frame(width: width, height: height, alignment: align!)
    }
    func resizableImageFill(width: CGFloat, height: CGFloat, align: Alignment? = .center) -> some View {
        self
            .resizableImage(width: width, height: height, align: align)
            .aspectRatio(contentMode: .fill)
    }
    func resizableImageScaleFactor(width: CGFloat, height: CGFloat, factor: CGFloat? = 1, align: Alignment? = .center) -> some View {
        self
            .resizableImage(width: width, height: height, align: align)
            .minimumScaleFactor(factor!)
    }
    
    func resizableImage(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat? = .infinity, align: Alignment? = .center) -> some View {
        self
            .resizable()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: align!)
    }
    func resizableImageFill(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat? = .infinity, align: Alignment? = .center) -> some View {
        self
            .resizableImage(maxWidth: maxWidth, maxHeight: maxHeight, align: align)
            .aspectRatio(contentMode: .fill)
    }
    func resizableImageScaleFactor(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat? = .infinity, factor: CGFloat? = 1, align: Alignment? = .center) -> some View {
        self
            .resizableImage(maxWidth: maxWidth, maxHeight: maxHeight, align: align)
            .minimumScaleFactor(factor!)
    }
}
