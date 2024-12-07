//
//  SwitchStateView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/10/24.
//
import SwiftUI

struct SwitchState: View {
    var prop: Properties
    
    @ObservedObject public var accountInfo: AccountDetails
    @Binding public var accountPopupSection: String
    @Binding public var loadingChangeSchoolsSection: Bool
    @Binding public var errorLoadingChangeSchoolsSection: Bool
    @Binding public var colleges: Array<String>
    
    @State private var errorUpdatingStateName: Bool = false
    @State private var updateStateAlert: Bool = false
    @State private var temporaryStateValue: String = ""
    //@State private var colleges: Array<String> = []
    
    /* TODO: The exact same variable is in `SignUpScreen.swift`. We need to create a class that will hold these variables to be used anywhere. */
    let states = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
        "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
        "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia",
        "Wisconsin", "Wyoming"
    ]
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                }
                .frame(maxWidth: .infinity, maxHeight: prop.isLargerScreen ? 80 : 60)
                .background(
                    Image("DefaultThemeBg3")
                        .resizable()
                        .scaledToFill()
                )
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)
            
            VStack {
                HStack {
                    Button(action: { self.accountPopupSection = "main" }) {
                        ZStack {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: 20, alignment: .leading)
                        .padding(.top, 15)
                        .padding(.leading, 25)
                    }
                    
                    Text("Switch State")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding([.top], 15)
                        .setFontSizeAndWeight(weight: .bold, size: prop.isLargerScreen ? 26 : 22)
                        
                    /* MARK: "spacing" to ensure above Text stays in the middle. */
                    ZStack { }.frame(maxWidth: 20, alignment: .trailing).padding(.trailing, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(.top, prop.isLargerScreen ? 45 : 0)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                if self.errorUpdatingStateName {
                    Image(systemName: "exclamationmark.warninglight.fill")
                        .resizable()
                        .frame(width: 45, height: 40)
                        .padding([.top, .bottom], 15)
                        .foregroundStyle(Color.EZNotesRed)
                    
                    Text("Error updating state")
                        .frame(maxWidth: prop.size.width - 60, alignment: .center)
                        .foregroundColor(.white)
                        .setFontSizeAndWeight(weight: .medium, size: 20)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
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
                    
                    Spacer()
                } else {
                    HStack {
                        ZStack { }.frame(maxWidth: 10, alignment: .leading)
                        
                        ZStack {
                            Text("Select the state where you currently reside, or where your college is located.")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(.white)
                                .font(.system(size: prop.isLargerScreen ? 16 : 12, weight: .light))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        ZStack { }.frame(maxWidth: 10, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                ForEach(self.states, id: \.self) { state in
                                    Button(action: {
                                        self.temporaryStateValue = state
                                        self.updateStateAlert = true
                                    }) {
                                        HStack {
                                            Text(state)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .padding([.leading, .top, .bottom], 5)
                                                .foregroundStyle(.white)
                                                .font(Font.custom("Poppins-SemiBold", size: 18))//.setFontSizeAndWeight(weight: .semibold, size: 20)
                                                .fontWeight(.bold)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.EZNotesLightBlack.opacity(0.65))
                                                .shadow(color: Color.black, radius: 1.5)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding([.top, .bottom], -15)
                }
            }
            .frame(maxWidth: prop.size.width - 40, maxHeight: .infinity)
            .padding(.top, prop.isLargerScreen ? 80 : 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Did you switch colleges?", isPresented: $updateStateAlert) {
            Button(action: {
                RequestAction<UpdateStateData>(parameters: UpdateStateData(
                    NewState: self.temporaryStateValue,
                    AccountID: self.accountInfo.accountID
                ))
                .perform(action: update_state_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        /* TODO: Add error checking. */
                        self.errorUpdatingStateName = true
                        return
                    }
                    
                    self.errorUpdatingStateName = false
                    
                    self.accountInfo.setCollegeState(collegeState: self.temporaryStateValue)
                    UserDefaults.standard.set(self.temporaryStateValue, forKey: "college_state")
                    self.temporaryStateValue.removeAll()
                    
                    self.accountPopupSection = "switch_college"
                    self.loadingChangeSchoolsSection = true
                    
                    /* MARK: Get all the colleges for the state. */
                    RequestAction<GetCollegesRequestData>(parameters: GetCollegesRequestData(State: self.accountInfo.state))
                        .perform(action: get_colleges) { statusCode, resp in
                            self.loadingChangeSchoolsSection = false
                            /* TODO: Add loading screen while college names load. */
                            guard
                                resp != nil,
                                resp!.keys.contains("Colleges"),
                                statusCode == 200
                            else {
                                /* TODO: Add some sort of error checking. We can use the banner-thing that is used to signify a success or failure when updating PFP/PFP BG image. */
                                /* TODO: As has been aforementioned - lets go ahead and ensure the banner message can be used across the board, not just with update success/failures of PFP/PFP BG image. */
                                //self.serverError = true
                                if let resp = resp { print(resp) }
                                self.errorLoadingChangeSchoolsSection = true
                                return
                            }
                            
                            self.errorLoadingChangeSchoolsSection = false
                            
                            let respColleges = resp!["Colleges"] as! [String]
                            
                            /* MARK: Ensure the `colleges` array is empty. */
                            self.colleges.removeAll()
                            
                            for c in respColleges {
                                if !self.colleges.contains(c) { self.colleges.append(c) }
                            }
                            
                            self.colleges.append("Other")
                            //self.college = self.colleges[0]
                        }
                }
            }) { Text("Yes") }
            
            Button(action: {
                RequestAction<UpdateStateData>(parameters: UpdateStateData(
                    NewState: self.temporaryStateValue,
                    AccountID: self.accountInfo.accountID
                ))
                .perform(action: update_state_req) { statusCode, resp in
                    guard resp != nil && statusCode == 200 else {
                        self.temporaryStateValue.removeAll()
                        
                        /* TODO: Error handling. For now this is okay. */
                        self.accountPopupSection = "main"
                        return
                    }
                    
                    self.accountInfo.setCollegeState(collegeState: self.temporaryStateValue)
                    UserDefaults.standard.set(self.temporaryStateValue, forKey: "college_state")
                    self.temporaryStateValue.removeAll()
                    
                    /* MARK: Since "no" is tapped, redirect back to the main section. */
                    self.accountPopupSection = "main"
                }
            }) { Text("No") }
        } message: {
            Text("If you switched colleges it would be of your best interest to update that information to ensure EZNotes AI can assist you accordingly.")
        }
    }
}
