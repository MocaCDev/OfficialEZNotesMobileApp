//
//  SettingsView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/13/24.
//
import SwiftUI

/* MARK: Types of info popups that will be shown when the user clicks on the question mark. */
enum InfoType {
    case None
    case displayShortLongSetNamesSeparatelyInfo
    case trackUserCreatedSetsInfo
    case displayUserCreatedSetsSeparatelyInfo
}

struct Settings: View {
    @EnvironmentObject private var settings: SettingsConfigManager
    var prop: Properties
    
    @State private var showInfoPopup: Bool = false
    @State private var infoType: InfoType = .None
    
    var body: some View {
        ZStack {
            if self.showInfoPopup {
                switch(self.infoType) {
                case .displayShortLongSetNamesSeparatelyInfo:
                    VStack {
                        Spacer()
                        
                        VStack {
                            Text(self.settings.seggregateShortAndLongNames
                                 ? "All short/long set names will be shown in a separate view, rather than both being combined in one view."
                                 : "All short/long set names will be shown in one view, rather than being separated into two views.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing], 10)
                            .padding(.bottom, 2)
                            .foregroundStyle(.gray)
                            .font(.system(size: prop.isLargerScreen ? 13 : 11))
                            .minimumScaleFactor(0.5)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: prop.size.width - 40)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.EZNotesBlack)
                                .shadow(color: Color.white, radius: 8)
                        )
                        .cornerRadius(15)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.EZNotesBlack.opacity(0.5))
                    .onTapGesture {
                        self.showInfoPopup = false
                        self.infoType = .None
                    }
                    .zIndex(1)
                case .trackUserCreatedSetsInfo:
                    VStack {
                        
                    }
                    .zIndex(1)
                case .displayUserCreatedSetsSeparatelyInfo:
                    VStack {
                        
                    }
                    .zIndex(1)
                default: VStack { }.onAppear { self.infoType = .None; self.showInfoPopup = false }
                }
            }
            VStack {
                /* MARK: Ensure there is spacing between the header and the content of the view. */
                VStack { }.frame(maxWidth: .infinity).padding(.top, 15)
                
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        Text("App")
                            .textCase(.uppercase)
                            .frame(alignment: .leading)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))//.setFontSizeAndWeight(weight: .bold, size: 18)
                            .minimumScaleFactor(0.5)
                        //.padding(.bottom, 1)
                        //.border(width: 1, edges: [.bottom], color: .secondary)
                            .padding(.bottom, 5)
                        
                        VStack {
                            Divider().background(MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ])).frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack {
                        Text("These settings impact the way the app works. The below settings enable you to tailor the app to your specific wants and/or needs. Changing the below settings will change your experience on the app.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.bottom, 10)
                            .foregroundStyle(.gray)
                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//(.system(size: prop.isLargerScreen ? 13 : 11))
                            .fontWeight(.medium)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                        
                        ZStack {
                            Toggle("JustNotes", isOn: $settings.justNotes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.justNotes
                            ? "The app will be used as a classic note taking app, with the subtraction of:\n\n\t1. Categories\n\t2. Sets\n\t3. Ability to take, and upload, pictures\n\nAll other features, such as EZNotes Chatbot, re-writing notes using EZNotes AI, and more will still be accessible. Upon disabling this setting, any notes you have written will be saved but will not be accessible unless you re-enable this feature."
                             : "The app will be used normally, with all features enabled.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom)
                            .foregroundStyle(.gray)
                            .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//(.system(size: prop.isLargerScreen ? 13 : 11))
                            .fontWeight(.medium)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                    }
                    .padding([.leading, .trailing])
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                            .shadow(color: Color.EZNotesLightBlack, radius: 2.5)
                    )
                    .padding([.leading, .trailing], 2.5)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Text("Sets")
                            .textCase(.uppercase)
                            .frame(alignment: .leading)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))//.setFontSizeAndWeight(weight: .bold, size: 18)
                            .minimumScaleFactor(0.5)
                        //.padding(.bottom, 1)
                        //.border(width: 1, edges: [.bottom], color: .secondary)
                            .padding(.bottom, 5)
                        
                        VStack {
                            Divider().background(MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ])).frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack {
                        ZStack {
                            Toggle("Display short/long set names separately", isOn: $settings.seggregateShortAndLongNames)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.top)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.seggregateShortAndLongNames
                             ? "All short/long set names will be shown in a separate view, rather than both being combined in one view."
                             : "All short/long set names will be shown in one view, rather than being separated into two views.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        
                        //Divider().background(.gray)
                        
                        ZStack {
                            Toggle("Track user created sets", isOn: $settings.trackUserCreatedSets)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.trackUserCreatedSets
                             ? "The app will keep track of all the sets you create."
                             : "The app will not keep track of all the sets you create. Since this setting is disabled, the below setting \"Display user created sets separately\" will not be affective.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//.font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        
                        //Divider().background(.gray)
                        
                        ZStack {
                            Toggle("Display user created sets separately", isOn: $settings.displayUserCreatedSetsSeparately)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.displayUserCreatedSetsSeparately
                             ? "All sets that are created by the user will be shown in a separate view. This view will not be affected by the setting \"Display short/long set names differently\"; however, the view will show all longer set names at the top and all shorter set names at the bottom of the view."
                             : "All sets created by the user will be merged with the sets generated by the app. The user created sets will be compliant with the setting \"Display short/long set names differently\".")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//.font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                    }
                    .padding([.leading, .trailing])
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                            .shadow(color: Color.EZNotesLightBlack, radius: 2.5)
                    )
                    .padding([.leading, .trailing], 2.5)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Text("Categories")
                            .textCase(.uppercase)
                            .frame(alignment: .leading)
                            .foregroundStyle(.white)
                            .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 18 : 16))//.setFontSizeAndWeight(weight: .bold, size: 18)
                            .minimumScaleFactor(0.5)
                        //.padding(.bottom, 1)
                        //.border(width: 1, edges: [.bottom], color: .secondary)
                            .padding(.bottom, 5)
                        
                        VStack {
                            Divider().background(MeshGradient(width: 3, height: 3, points: [
                                .init(0, 0), .init(0.3, 0), .init(1, 0),
                                .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                                .init(0, 1), .init(0.5, 1), .init(1, 1)
                            ], colors: [
                                .indigo, .indigo, Color.EZNotesBlue,
                                Color.EZNotesBlue, Color.EZNotesBlue, .purple,
                                .indigo, Color.EZNotesGreen, Color.EZNotesBlue
                            ])).frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack {
                        ZStack {
                            Toggle("Track user created categories", isOn: $settings.trackUserCreatedCategories)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.trackUserCreatedCategories
                             ? "All categories created by the user will be tracked."
                             : "New categories created by the user will not be tracked. All previously tracked/documented user created categories will still be displayed accordingly.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 12)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//.font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        
                        ZStack {
                            Toggle("Display user created categories separately", isOn: $settings.displayUserCreatedCategoriesSeparatly)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16, weight: .medium))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 4)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        
                        Text(self.settings.displayUserCreatedCategoriesSeparatly
                             ? "All categories created by the user will be shown in a separate view."
                             : "All catgories created by the user will be merged with the categories generated by the app.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 12)
                        .foregroundStyle(.gray)
                        .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 13 : 11))//.font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                    }
                    .padding([.leading, .trailing])
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                            .shadow(color: Color.EZNotesLightBlack, radius: 2.5)
                    )
                    .padding([.leading, .trailing], 2.5)
                    .padding(.bottom, 10)
                    
                    /*HStack {
                        ZStack {
                            Toggle("Display short/long set names separately", isOn: $settings.seggregateShortAndLongNames)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.system(size: prop.isLargerScreen ? 18 : 16))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 12)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        
                        Button(action: {
                            self.infoType = .displayShortLongSetNamesSeparatelyInfo
                            self.showInfoPopup = true
                        }) {
                            ZStack {
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .frame(width: 12, height: 18)
                                    .foregroundStyle(Color.EZNotesBlue)
                            }
                            .frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 10)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    
                    Text(self.settings.seggregateShortAndLongNames
                         ? "All short/long set names will be shown in a separate view, rather than both being combined in one view."
                         : "All short/long set names will be shown in one view, rather than being separated into two views.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 2)
                    .foregroundStyle(.gray)
                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    
                    Text("After selecting a category, you might notice there is a single view where longer set names span across the screen and shorter set names will have two sets in a single row. The longer set names appear at the top of the view, and the shorter set names will appear at the bottom. By enabling this setting, you will seggregate the longer set names into one view and the shorter set names into another view. This setting simply enables a more feasible way to view the sets.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 2)
                        .foregroundStyle(.gray)
                        .font(.system(size: prop.isLargerScreen ? 13 : 11))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        ZStack {
                            Toggle("Track user created sets", isOn: $settings.trackUserCreatedSets)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 12)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        
                        Button(action: {
                            self.infoType = .trackUserCreatedSetsInfo
                            self.showInfoPopup = true
                        }) {
                            ZStack {
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .frame(width: 12, height: 18)
                                    .foregroundStyle(Color.EZNotesBlue)
                            }
                            .frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 10)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .padding(.top)
                    
                    Text(self.settings.trackUserCreatedSets
                         ? "The app will keep track of all the sets you create."
                         : "The app will not keep track of all the sets you create. Since this setting is disabled, the below setting \"Display user created sets separately\" will not be affective.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 2)
                    .foregroundStyle(.gray)
                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    
                    HStack {
                        ZStack {
                            Toggle("Display user created sets separately", isOn: $settings.displayUserCreatedSetsSeparately)
                                .frame(maxWidth: prop.size.width - 50, alignment: .leading)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .font(.system(size: 18))
                                .toggleStyle(SwitchToggleStyle(tint: Color.EZNotesBlue))
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 12)
                        .background(Color.EZNotesLightBlack.opacity(0.8))
                        .cornerRadius(15)
                        
                        Button(action: {
                            self.infoType = .displayUserCreatedSetsSeparatelyInfo
                            self.showInfoPopup = true
                        }) {
                            ZStack {
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .frame(width: 12, height: 18)
                                    .foregroundStyle(Color.EZNotesBlue)
                            }
                            .frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 10)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                    }
                    .padding(.top)
                    
                    Text(self.settings.displayUserCreatedSetsSeparately
                         ? "All sets that are created by the user will be shown in a separate view. This view will not be affected by the setting \"Display short/long set names differently\"; however, the view will show all longer set names at the top and all shorter set names at the bottom of the view."
                         : "All sets created by the user will be merged with the rest of the sets. The user created sets will be compliant with the setting \"Display short/long set names differently\".")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 2)
                    .foregroundStyle(.gray)
                    .font(.system(size: prop.isLargerScreen ? 13 : 11))
                    .minimumScaleFactor(0.5)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)*/
                    
                    /* MARK: Ensure there is padding at the end of the ScrollView. */
                    VStack { }.frame(maxWidth: .infinity, maxHeight: 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            self.settings.saveSettings()
        }
    }
}
