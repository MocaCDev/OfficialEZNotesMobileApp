//
//  PlusButtonView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/29/24.
//
import SwiftUI

struct PlusButton: View {
    var prop: Properties
    
    @Binding public var createNewCategory: Bool
    @Binding public var testPopup: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if self.testPopup {
                HStack {
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.clear)
                    
                    VStack {
                        Button(action: { print("Upload PDF") }) {
                            HStack {
                                ZStack {
                                    Image(systemName: "document")
                                        .resizable()
                                        .frame(width: 15, height: 20)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: 20, alignment: .leading)
                                .padding(.leading, 5)
                                
                                Text("Upload PDF")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Divider()
                            .background(.gray)
                        
                        Button(action: { self.createNewCategory = true }) {
                            HStack {
                                ZStack {
                                    Image(systemName: "folder.badge.plus")
                                        .resizable()
                                        .frame(width: 20, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: 20, alignment: .leading)
                                .padding(.leading, 5)
                                
                                Text("Create Category")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))
                            }
                            .frame(maxWidth: .infinity)
                            .padding([.top, .bottom], 5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesBlack)
                            .shadow(radius: 2.5)
                    )
                    .cornerRadius(15)
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            }
            
            HStack {
                Spacer()
                
                Button(action: { self.testPopup.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(Color.EZNotesBlue.opacity(0.8))
                            .scaledToFit()
                            .shadow(color: Color.black, radius: 4.5)
                            .overlay(
                                self.testPopup
                                    ? Circle().fill(Color.EZNotesLightBlack.opacity(0.6))
                                    : Circle().fill(.clear)
                            )
                        
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.EZNotesBlack)
                    }
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 25)
                }
                .buttonStyle(NoLongPressButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.bottom, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

struct CategoryInternalsPlusButton: View {
    var prop: Properties
    
    @Binding public var testPopup: Bool /* MARK: Rename this. This name is used in `HomeView.swift` as well. */
    @Binding public var createNewSet: Bool
    @Binding public var createNewSetByImage: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if self.testPopup {
                HStack {
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.clear)
                    
                    VStack {
                        Button(action: { self.createNewSet = true }) {
                            HStack {
                                ZStack {
                                    Image(systemName: "circle.grid.2x2")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: 20, alignment: .leading)
                                .padding(.leading, 5)
                                
                                Text("Create Set")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(NoLongPressButtonStyle())
                        
                        Divider()
                            .background(.gray)
                        
                        Button(action: { self.createNewSetByImage = true }) {
                            HStack {
                                ZStack {
                                    Image(systemName: "camera")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: 20, alignment: .leading)
                                .padding(.leading, 5)
                                
                                Text("Create Set by Image")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.white)
                                    .font(Font.custom("Poppins-Regular", size: prop.isLargerScreen ? 15 : 13))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.EZNotesLightBlack)
                            .shadow(radius: 2.5)
                    )
                    .cornerRadius(15)
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            }
            
            HStack {
                Spacer()
                
                Button(action: { self.testPopup.toggle() }) {
                    ZStack {
                        Circle()
                            .fill(Color.EZNotesBlue.opacity(0.8))
                            .scaledToFit()
                            .shadow(color: Color.black, radius: 4.5)
                            .overlay(
                                self.testPopup
                                    ? Circle().fill(Color.EZNotesLightBlack.opacity(0.6))
                                    : Circle().fill(.clear)
                            )
                        
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.EZNotesBlack)
                    }
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 25)
                }
                .buttonStyle(NoLongPressButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.bottom, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
