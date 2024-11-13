//
//  SettingsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

struct Settings: View {
    var prop: Properties
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Coming Soon")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .font(Font.custom("Poppins-Regular", size: 16))
                .minimumScaleFactor(0.5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
