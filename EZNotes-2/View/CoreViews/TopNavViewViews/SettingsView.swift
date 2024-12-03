//
//  SettingsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

struct Settings: View {
    @EnvironmentObject private var settings: SettingsConfigManager
    var prop: Properties
    
    var body: some View {
        VStack {
            /* MARK: Ensure there is spacing between the header and the content of the view. */
            VStack { }.frame(maxWidth: .infinity).padding(.top, 15)
            
            ScrollView(.vertical, showsIndicators: false) {
                Text("Sets")
                    .textCase(.uppercase)
                    .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                    .foregroundStyle(.white)
                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 26 : 22))//.setFontSizeAndWeight(weight: .bold, size: 18)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 1)
                    .border(width: 1, edges: [.bottom], color: .secondary)
                    .padding(.bottom, 5)
                
                ZStack {
                    Toggle("Display short/long set names separately", isOn: $settings.seggregateShortAndLongNames)
                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 12)
                .background(Color.EZNotesLightBlack.opacity(0.8))
                .cornerRadius(15)
                
                if self.settings.seggregateShortAndLongNames {
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
                
                Text("After selecting a category, you might notice there is a single view where longer set names span across the screen and shorter set names will have two sets in a single row. The longer set names appear at the top of the view, and the shorter set names will appear at the bottom. By enabling this setting, you will seggregate the longer set names into one view and the shorter set names into another view. This setting simply enables a more feasible way to view the sets.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 2)
                    .foregroundStyle(.gray)
                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                ZStack {
                    Toggle("Track user created sets", isOn: $settings.trackUserCreatedSets)
                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 12)
                .background(Color.EZNotesLightBlack.opacity(0.8))
                .cornerRadius(15)
                .padding(.top)
                
                if self.settings.trackUserCreatedSets {
                    Text("The app will keep track of all the sets you create.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("The app will not keep track of all the sets you create. Since this setting is disabled, the below setting \"Display user created sets separately\" will not be affective.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
                
                ZStack {
                    Toggle("Display user created sets separately", isOn: $settings.displayUserCreatedSetsSeparately)
                        .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 10)
                .padding([.top, .bottom], 12)
                .background(Color.EZNotesLightBlack.opacity(0.8))
                .cornerRadius(15)
                .padding(.top)
                
                if self.settings.displayUserCreatedSetsSeparately {
                    Text("All sets that are created by the user will be shown in a separate view. This view will not be affected by the setting \"Display short/long set names differently\"; however, the view will show all longer set names at the top and all shorter set names at the bottom of the view.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("All sets created by the user will be merged with the rest of the sets. The user created sets will be compliant with the setting \"Display short/long set names differently\".")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
        .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
    }
}
