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
    @EnvironmentObject private var categoryData: CategoryData
    
    var prop: Properties
    
    /* MARK: States, and variables, for "action" buttons (excluding the "+" button). */
    var categoryBackground: Image
    @Binding public var categoryName: String
    @Binding public var categoryDescription: String?
    @Binding public var launchCategory: Bool
    
    @Binding public var categoryBackgroundColor: Color?
    @Binding public var categoryTitleColor: Color?
    
    @State private var categoryBeingEdited: String = ""
    @State private var newCategoryDescription: String = ""
    @State private var newCategoryDisplayColor: Color = Color.EZNotesLightBlack
    @State private var newCategoryTextColor: Color = .white
    @State private var editCategoryDetails: Bool = false
    
    @State private var categoryAlert: Bool = false
    @State private var categoryToDelete: String = ""
    @Binding public var alertType: AlertTypes
    
    @Binding public var showDescription: Bool
    
    private func resetAlert() {
        if self.alertType == .DeleteCategoryAlert {
            self.categoryToDelete.removeAll()
        }
        
        self.categoryAlert = false
        self.alertType = .None
    }
    
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
                /*HStack {
                    Button(action: {
                        self.categoryToDelete = self.categoryName
                        self.categoryAlert = true
                        self.alertType = .DeleteCategoryAlert
                    }) {
                        ZStack {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.red)
                        }
                        .frame(alignment: .leading)
                        .padding(.trailing, 10)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .alert("Are you sure?", isPresented: $categoryAlert) {
                        Button(action: {
                            self.launchCategory = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if self.categoryData.categoriesAndSets.count == 1 {
                                    self.categoryData.categoriesAndSets.removeAll()
                                    self.categoryData.setAndNotes.removeAll()
                                    self.categoryData.categoryCustomTextColors.removeAll()
                                    self.categoryData.categoryCustomColors.removeAll()
                                    self.categoryData.categoryDescriptions.removeAll()
                                } else {
                                    self.categoryData.categoriesAndSets.removeValue(forKey: self.categoryToDelete)
                                    self.categoryData.setAndNotes.removeValue(forKey: self.categoryToDelete)
                                    
                                    if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryToDelete) {
                                        self.categoryData.categoryCustomTextColors.removeValue(forKey: self.categoryToDelete)
                                    }
                                    
                                    if self.categoryData.categoryCustomColors.keys.contains(self.categoryToDelete) {
                                        self.categoryData.categoryCustomColors.removeValue(forKey: self.categoryToDelete)
                                    }
                                    
                                    if self.categoryData.categoryDescriptions.keys.contains(self.categoryToDelete) {
                                        self.categoryData.categoryDescriptions.removeValue(forKey: self.categoryToDelete)
                                    }
                                }
                                
                                /* MARK: Ensure the cache is up to date. */
                                writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                writeSetsAndNotes(setsAndNotes: self.categoryData.setAndNotes)
                                writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                
                                resetAlert()
                            }
                            
                            /* TODO: Add support for actually storing category information in the database. That will, thereby, prompt us to need to send a request to the server to delete the given category from the database. */
                        }) {
                            Text("Yes")
                        }
                        
                        Button(action: { resetAlert() }) { Text("No") }
                    } message: {
                        Text(self.alertType == .DeleteCategoryAlert
                             ? "Once deleted, the category **\"\(self.categoryToDelete)\"** will be removed from cloud or local storage and cannot be recovered."
                             : "") /* TODO: Finish this. There will presumably be more alert types. */
                    }
                    
                    Button(action: {
                        if self.categoryData.categoryDescriptions.keys.contains(self.categoryName) {
                            self.newCategoryDescription = self.categoryData.categoryDescriptions[self.categoryName]!
                        } else { self.newCategoryDescription = "" }
                        
                        if self.categoryData.categoryCustomColors.keys.contains(self.categoryName) {
                            self.newCategoryDisplayColor = self.categoryData.categoryCustomColors[self.categoryName]!
                        } else { self.newCategoryDisplayColor = Color.EZNotesOrange }
                        
                        if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryName) {
                            self.newCategoryTextColor = self.categoryData.categoryCustomTextColors[self.categoryName]!
                        } else { self.newCategoryTextColor = .white }
                        
                        self.categoryBeingEdited = self.categoryName
                        //self.categoryBeingEditedImage = self.categoryData.categoryImages[self.categoryName]!
                        self.editCategoryDetails = true
                    }) {
                        ZStack {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.EZNotesBlue)
                        }
                        .frame(alignment: .leading)
                        .padding(.trailing, 10)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    //.padding(.trailing, 6)
                    .popover(isPresented: $editCategoryDetails) {
                        EditCategory(
                            prop: self.prop,
                            categoryBeingEditedImage: self.categoryBackground,
                            categoryBeingEdited: $categoryBeingEdited,
                            categoryLaunched: $categoryName,
                            categoryData: self.categoryData,
                            newCategoryDisplayColor: $newCategoryDisplayColor,
                            newCategoryTextColor: $newCategoryTextColor
                        )
                        .onDisappear {
                            self.categoryBackgroundColor = self.categoryData.categoryCustomColors[self.categoryName]
                            self.categoryTitleColor = self.categoryData.categoryCustomTextColors[self.categoryName]
                        }
                    }
                    
                    ShareLink(
                        item: self.categoryBackground,
                        subject: Text(self.categoryName),
                        message: Text(
                            self.categoryDescription != nil
                                ? "\(self.categoryDescription!)\n\nCreated with the support of **EZNotes**"
                                : ""
                        ),
                        preview: SharePreview(self.categoryName, image: self.categoryBackground))
                    {//(item: URL(string: "https://apps.apple.com/us/app/light-speedometer/id6447198696")!) {
                        Label("", systemImage: "square.and.arrow.up")
                            .foregroundStyle(Color.EZNotesBlue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) /* MARK: `maxWidth` is in this as it's the last element in the HStack, thus pushing all the other content over. */
                    //.padding(.leading, 6)
                    
                    Button(action: { }) {
                        ZStack {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.EZNotesBlue)
                        }
                        .frame(alignment: .leading)
                        .padding(.trailing, 10)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    //.padding(.trailing, 6)
                    
                    Button(action: { self.showDescription = true }) {
                        ZStack {
                            Image(systemName: "info.square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.EZNotesBlue)
                        }
                        .frame(alignment: .leading)
                        .padding(.trailing, 10)
                    }
                    .buttonStyle(NoLongPressButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark))
                .cornerRadius(20)
                .padding(.horizontal)*/
                //.clipShape(RoundedRectangle(cornerRadius: 20))
                
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
            .padding(.bottom, prop.isLargerScreen ? 25 : 15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
