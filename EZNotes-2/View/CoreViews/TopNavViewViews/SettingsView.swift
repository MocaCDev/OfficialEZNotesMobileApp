//
//  SettingsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

struct Settings: View {
    var prop: Properties
    
    @State private var showShortAndLongSetNamesDifferently: Bool = false
    
    var body: some View {
        VStack {
            /* MARK: Ensure there is spacing between the header and the content of the view. */
            VStack { }.frame(maxWidth: .infinity).padding(.top, 15)
            
            ScrollView(.vertical, showsIndicators: false) {
                Toggle("Display short/long set names differently", isOn: $showShortAndLongSetNamesDifferently)
                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                
                if self.showShortAndLongSetNamesDifferently {
                    Text("All short/long set names will be shown in a separate view, rather than both being combined in one view.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("All short/long set names will be shown in one view, rather than being separated into two views.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
                
                Text("When selecting a category, you might notice there is a single view where longer set names span across the screen and shorter set names will have two sets in a single row. The longer set names appear at the top of the view, and the shorter set names will appear at the bottom. By enabling this setting, you will seggregate the longer set names into one view and the shorter set names into another view. This setting simply enables a more feasible way to view the sets.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 2)
                    .foregroundStyle(.gray)
                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
        .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
    }
}
