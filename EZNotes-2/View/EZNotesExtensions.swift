//
//  EZNotesExtensions.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/28/24.
//
import SwiftUI

extension UIImage {
    // Function to resize the UIImage to a specific size
    func resize(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /* MARK: `borderBottomWLColor` - Border Bottom With LinearGradient Color. */
    func borderBottomWLColor(isError: Bool) -> some View {
        self
            .border(
                width: 1,
                edges: [.bottom],
                lcolor: !isError ? LinearGradient(
                    gradient: Gradient(
                        colors: [Color.EZNotesBlue, Color.EZNotesOrange]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                ) : LinearGradient(
                    gradient: Gradient(
                        colors: [Color.EZNotesRed, Color.EZNotesRed]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
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
