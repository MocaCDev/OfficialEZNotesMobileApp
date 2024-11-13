//
//  ErrorMessageView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/12/24.
//
import SwiftUI

struct ErrorMessage: View {
    var prop: Properties
    var placement: Alignment
    var message: String
    var showReportProblemButton: Bool = false
    var bottomPadding: CGFloat = 0
    
    var body: some View {
        VStack {
            if (self.placement == .center || self.placement == .bottom) && self.placement != .top { Spacer() }
            
            Image(systemName: "exclamationmark.warninglight.fill")
                .resizable()
                .frame(width: 45, height: 40)
                .padding([.top, .bottom], 15)
                .foregroundStyle(Color.EZNotesRed)
            
            Text(self.message)
                .frame(maxWidth: prop.size.width - 60, alignment: .center)
                .foregroundColor(.white)
                .setFontSizeAndWeight(weight: .medium, size: 20)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
            
            if self.showReportProblemButton {
                Button(action: { print("Report Problem") }) {
                    HStack {
                        Text("Report a Problem")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding([.top, .bottom], 8)
                            .foregroundStyle(.black)
                            .setFontSizeAndWeight(weight: .bold, size: 18)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: prop.size.width - 80)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                    )
                    .cornerRadius(15)
                }
                .buttonStyle(NoLongPressButtonStyle())
                .padding(.top, 15)
            }
            
            if (self.placement == .center || self.placement == .top) && self.placement != .bottom { Spacer() }
            
            if self.placement == .bottom && self.bottomPadding != 0 {
                VStack { }.frame(maxWidth: .infinity, maxHeight: self.bottomPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
