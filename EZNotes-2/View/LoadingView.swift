//
//  LoadingView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

struct LoadingView: View {
    var message: String = ""
    var tint: Color = Color.EZNotesBlue
    
    var body: some View {
        if !self.message.isEmpty {
            Text(self.message)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .setFontSizeAndWeight(weight: .medium, size: 14)
                .minimumScaleFactor(0.5)
        }
        
        ProgressView()
            .tint(self.tint)
    }
}
