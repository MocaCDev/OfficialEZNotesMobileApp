//
//  LoadingView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

struct LoadingView: View {
    var message: String
    
    var body: some View {
        Text(self.message)
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(.white)
            .setFontSizeAndWeight(weight: .medium, size: 14)
            .minimumScaleFactor(0.5)
        
        ProgressView()
            .tint(Color.EZNotesBlue)
    }
}
