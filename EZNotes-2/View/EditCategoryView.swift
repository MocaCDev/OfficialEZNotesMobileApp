//
//  EditCategoryView.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/24/24.
//
import SwiftUI

struct EditCategory: View {
    var prop: Properties
    var categoryBeingEditedImage: UIImage
    
    @Binding public var categoryBeingEdited: String
    @ObservedObject public var categoryData: CategoryData
    
    @State private var editSection: String = "edit"
    @State private var newCategoryName: String = ""
    @State private var newCategoryDescription: String = ""
    @State private var newCategoryDisplayColor: Color = Color.EZNotesOrange
    @State private var newCategoryTextColor: Color = Color.white
    @State private var showSaveAlert: Bool = false
    @FocusState private var newCategoryDescriptionFocus: Bool
    @State private var toggleCategoryBackgroundColorPicker: Bool = false
    @State private var toggleCategoryTextColorPicker: Bool = false
    
    private func textHeight(for text: String, width: CGFloat) -> CGFloat {
        /*let font = UIFont.systemFont(ofSize: 17)  // Customize this to match your font
         let constrainedSize = CGSize(width: width - 20, height: .infinity)  // Add padding to the width
         let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
         return boundingRect.height*/
        let textView = UITextView()
        textView.text = text + "\n\n\n"
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        
        let fixedWidth = width - 16 // Account for padding
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return max(size.height, 100) // Add a buffer and ensure a minimum height
    }
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Text("Editing Category")
                        .frame(maxWidth: prop.size.width - 20, alignment: .center)
                        .foregroundStyle(Color.secondary)
                        .font(.system(size: 25, design: .rounded))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    Text(self.categoryBeingEdited)
                        .frame(maxWidth: prop.size.width - 20, alignment: .center)
                        .foregroundStyle(.white)
                        //.shadow(color: .white, radius: 2)
                        .font(Font.custom("Poppins-SemiBold", size: prop.isLargerScreen ? 40 : 30))//.font(.system(size: prop.isLargerScreen ? 44 : 36, design: .rounded))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                    
                    HStack {
                        VStack {
                            Button(action: {
                                self.editSection = "edit"
                            }) {
                                Text("Edit")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(5)
                                    .foregroundStyle(self.editSection != "edit" ? Color.EZNotesBlack : Color.EZNotesOrange)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderless)
                            .animation(.easeIn(duration: 0.5), value: self.editSection == "edit")
                            .animation(.easeOut(duration: 0.5), value: self.editSection != "edit")
                        }
                        .frame(maxWidth: 150, maxHeight: .infinity)
                        .background(
                            self.editSection == "edit"
                                    ? AnyView(RoundedRectangle(cornerRadius: 15)
                                        .fill(.gray.opacity(0.70))
                                        .stroke(.white, lineWidth: 4))
                                    : AnyView(RoundedRectangle(cornerRadius: 15)
                                        .fill(.white.opacity(0.75)))
                        )
                        .cornerRadius(15)
                        
                        VStack {
                            Button(action: {
                                self.editSection = "preview"
                            }) {
                                Text("Preview")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding(5)
                                    .foregroundStyle(self.editSection != "preview" ? Color.EZNotesBlack : Color.EZNotesOrange)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            .padding([.leading, .trailing], 30)
                            .buttonStyle(.borderless)
                            .animation(.easeIn(duration: 0.5), value: self.editSection == "preview")
                            .animation(.easeOut(duration: 0.5), value: self.editSection != "preview")
                        }
                        .frame(maxWidth: 150, maxHeight: .infinity)
                        .background(self.editSection == "preview"
                                    ? AnyView(RoundedRectangle(cornerRadius: 15)
                                        .fill(.gray.opacity(0.70))
                                        .stroke(.white, lineWidth: 4))
                                    : AnyView(RoundedRectangle(cornerRadius: 15)
                                        .fill(.white.opacity(0.75)))
                        )
                        .cornerRadius(15)
                    }
                    .frame(maxWidth: prop.size.width - 50, maxHeight: 40, alignment: .bottom)
                    .cornerRadius(15)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(
                Image(uiImage: self.categoryBeingEditedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        Color.EZNotesLightBlack.opacity(0.45)
                    )
                    .blur(radius: 2.5)
            )
            
            VStack {
                /* MARK: "Padding". */
                VStack {
                    
                }.frame(maxWidth: .infinity, maxHeight: 15)
                
                if self.editSection == "edit" {
                    VStack {
                        Text("Edit Details")
                            .frame(maxWidth: .infinity, maxHeight: 25)
                            .padding([.top], 15)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        
                        Divider()
                            .frame(width: prop.size.width - 50)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                Text("Category Title: ")
                                    .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, design: .rounded))
                                    .fontWeight(.light)
                                
                                ZStack {
                                    TextField("New Title...", text: $newCategoryName)
                                        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .leading)
                                        .padding([.leading], 15)
                                        .padding(7)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(7.5)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 30)
                                
                            }
                            .frame(maxWidth: prop.size.width - 80, maxHeight: 80)
                            .padding([.top], 10)
                            
                            VStack {
                                HStack {
                                    Text("Category Description")
                                        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20, design: .rounded))
                                        .fontWeight(.light)
                                    
                                    Button(action: {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        self.newCategoryDescriptionFocus = false
                                    }) {
                                        Text("Done")
                                            .foregroundStyle(Color.EZNotesBlue)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: 25)
                                
                                TextField(
                                    self.categoryData.categoryDescriptions.keys.contains(self.categoryBeingEdited)
                                    ? self.categoryData.categoryDescriptions[self.categoryBeingEdited]!
                                    : "Description...",
                                    text: $newCategoryDescription,
                                    axis: .vertical
                                )
                                .frame(maxHeight: textHeight(for: newCategoryDescription, width: UIScreen.main.bounds.width), alignment: .leading)
                                .padding([.leading], 15)
                                .padding(7)
                                .background(Color(.systemGray6))
                                .cornerRadius(7.5)
                                .lineLimit(3...8)
                                .onChange(of: self.newCategoryDescription) {
                                    if self.newCategoryDescription.count > 150 {
                                        self.newCategoryDescription = String(self.newCategoryDescription.prefix(150))
                                    }
                                }
                                
                                Text("\(self.newCategoryDescription.count) out of 150 characters")
                                    .frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                                    .padding([.leading], 5)
                                    .foregroundStyle(
                                        self.newCategoryDescription.count < 150
                                        ? self.newCategoryDescription.count > 140 && self.newCategoryDescription.count < 150
                                        ? .yellow
                                        : Color.secondary
                                        : .red
                                    )
                                    .font(.system(size: 10, design: .rounded))
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: prop.size.width - 80)
                            .padding([.top, .bottom])
                            
                            VStack {
                                VStack {
                                    HStack {
                                        Text("Category Color")
                                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18, design: .rounded))
                                            .fontWeight(.light)
                                        
                                        //if self.toggleCategoryBackgroundColorPicker {
                                        ColorPicker("", selection: $newCategoryDisplayColor)
                                            .frame(width: 38, height: 40)
                                            .padding(3.5)
                                        //}
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                            ? self.newCategoryDisplayColor == self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                            ? self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                            : self.newCategoryDisplayColor
                                            : self.newCategoryDisplayColor
                                        )
                                        .frame(maxHeight: 100)
                                        .scaledToFit()
                                        .onTapGesture { self.toggleCategoryBackgroundColorPicker = true }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                VStack {
                                    HStack {
                                        Text("Text Color")
                                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 18, design: .rounded))
                                            .fontWeight(.light)
                                        
                                        //if self.toggleCategoryTextColorPicker {
                                        ColorPicker("", selection: $newCategoryTextColor)
                                            .frame(width: 30, height: 40)
                                        //}
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .padding(.trailing, 10)
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                            ? self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                            ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                            : self.newCategoryTextColor
                                            : self.newCategoryTextColor
                                        )
                                        .frame(maxHeight: 100)
                                        .scaledToFit()
                                        //.onTapGesture { self.toggleCategoryTextColorPicker = true }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(maxWidth: prop.size.width - 80)
                            .padding([.top], 5)
                            .padding([.bottom], 160)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, -150)
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                self.toggleCategoryTextColorPicker = false
                                self.toggleCategoryBackgroundColorPicker = false
                                
                                self.showSaveAlert = true
                            }) {
                                HStack {
                                    Text("Save Changes")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                .padding([.top, .bottom], 8)
                                .background(.white)
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .alert("Hang On", isPresented: $showSaveAlert) {
                                Button(action: {
                                    if self.newCategoryName.count > 0 && !(self.newCategoryName == self.categoryBeingEdited) {
                                        let categoryData = self.categoryData.categoriesAndSets[self.categoryBeingEdited]
                                        let categoryImageData = self.categoryData.categoryImages[self.categoryBeingEdited]
                                        let categoryCreationDate = self.categoryData.categoryCreationDates[self.categoryBeingEdited]
                                        
                                        self.categoryData.categoriesAndSets.removeValue(forKey: self.categoryBeingEdited)
                                        self.categoryData.categoryImages.removeValue(forKey: self.categoryBeingEdited)
                                        self.categoryData.categoryCreationDates.removeValue(forKey: self.categoryBeingEdited)
                                        
                                        self.categoryData.categoriesAndSets[self.newCategoryName] = categoryData
                                        writeCategoryData(categoryData: self.categoryData.categoriesAndSets)
                                        
                                        self.categoryData.categoryImages[self.newCategoryName] = categoryImageData
                                        writeCategoryImages(categoryImages: self.categoryData.categoryImages)
                                        
                                        self.categoryData.categoryCreationDates[self.newCategoryName] = categoryCreationDate
                                        writeCategoryCreationDates(categoryCreationDates: self.categoryData.categoryCreationDates)
                                        
                                        if self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited) {
                                            self.categoryData.categoryCustomColors.removeValue(forKey: self.categoryBeingEdited)
                                        }
                                        
                                        if self.categoryData.categoryDescriptions.keys.contains(self.categoryBeingEdited) {
                                            self.categoryData.categoryDescriptions.removeValue(forKey: self.categoryBeingEdited)
                                        }
                                        
                                        if self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) {
                                            self.categoryData.categoryCustomTextColors.removeValue(forKey: self.categoryBeingEdited)
                                        }
                                        
                                        self.categoryBeingEdited = self.newCategoryName
                                    }
                                    
                                    if self.newCategoryDisplayColor != Color.EZNotesOrange {
                                        self.categoryData.categoryCustomColors[self.categoryBeingEdited] = self.newCategoryDisplayColor
                                        writeCategoryCustomColors(categoryCustomColors: self.categoryData.categoryCustomColors)
                                        //self.newCategoryDisplayColor = Color.EZNotesOrange
                                    }
                                    
                                    if self.newCategoryTextColor != Color.white {
                                        self.categoryData.categoryCustomTextColors[self.categoryBeingEdited] = self.newCategoryTextColor
                                        writeCategoryTextColors(categoryTextColors: self.categoryData.categoryCustomTextColors)
                                        //self.newCategoryTextColor = Color.white
                                    }
                                    
                                    if self.newCategoryDescription.count > 0 {
                                        let str = self.newCategoryDescription.filter{!$0.isWhitespace || !$0.isNewline}
                                        
                                        if str == "" { return }
                                        
                                        self.categoryData.categoryDescriptions[self.categoryBeingEdited] = self.newCategoryDescription
                                        writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                        //self.newCategoryDescription.removeAll()
                                    } else {
                                        self.categoryData.categoryDescriptions.removeValue(forKey: self.categoryBeingEdited)
                                        writeCategoryDescriptions(categoryDescriptions: self.categoryData.categoryDescriptions)
                                    }
                                }) {
                                    Text("Okay")
                                }
                                Button("Cancel", role: .cancel) { }
                            } message: {
                                Text("Once you save, all changes are final.")
                            }
                            
                            Button(action: { print("Resetting") }) {
                                HStack {
                                    Text("Reset")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundStyle(.black)
                                        .setFontSizeAndWeight(weight: .bold, size: 18)
                                }
                                .frame(maxWidth: prop.size.width - 40, alignment: .center)
                                .padding([.top, .bottom], 8)
                                .background(Color.EZNotesLightBlack)
                                .cornerRadius(15)
                            }
                            .buttonStyle(NoLongPressButtonStyle())
                            .padding([.bottom], 35)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .background(
                            Rectangle()
                                .fill(Color.EZNotesBlack.opacity(0.7))
                                .blur(radius: 10)
                        )
                    }
                    .frame(maxWidth: prop.size.width, maxHeight: .infinity)
                    .cornerRadius(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                            .shadow(color: .black, radius: 6.5)
                    )
                    .edgesIgnoringSafeArea(.bottom)
                    .onTapGesture {
                        self.toggleCategoryTextColorPicker = false
                        self.toggleCategoryBackgroundColorPicker = false
                    }
                } else {
                    VStack {
                        Text("Preview Details")
                            .frame(maxWidth: .infinity, maxHeight: 25)
                            .padding([.top], 15)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        
                        Divider()
                            .frame(width: prop.size.width - 50)
                        
                        VStack {
                            HStack {
                                Image(uiImage: self.categoryBeingEditedImage)
                                    .resizable()
                                    .frame(width: 150.5, height: 190.5)
                                    .scaledToFit()
                                    .zIndex(1)
                                    .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                                
                                VStack {
                                    VStack {
                                        HStack {
                                            Text(self.newCategoryName.count > 0 ? self.newCategoryName : self.categoryBeingEdited)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .foregroundStyle(
                                                    self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                        ? self.newCategoryTextColor != .white
                                                            ? self.newCategoryTextColor
                                                            : self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                        : self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                            ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                            : self.newCategoryTextColor != .white
                                                                ? self.newCategoryTextColor
                                                                : .white
                                                )
                                                .font(.system(size: 18.5, design: .rounded))
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                            
                                            Divider()
                                                .frame(height: 35)
                                            
                                            Text("Sets: \(self.categoryData.categoriesAndSets[self.categoryBeingEdited]!.count)")
                                                .frame(maxWidth: 80, alignment: .trailing)
                                                .foregroundStyle(
                                                    self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                        ? self.newCategoryTextColor != .white
                                                            ? self.newCategoryTextColor
                                                            : self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                        : self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                            ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                            : self.newCategoryTextColor != .white
                                                                ? self.newCategoryTextColor
                                                                : .white
                                                )
                                                .font(.system(size: 18.5, design: .rounded))
                                                .fontWeight(.medium)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: (prop.size.width - 20) - 180, maxHeight: .infinity, alignment: .center)
                                        .border(width: 0.5, edges: [.bottom], color: .white)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .top)
                                    .background(
                                        self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryData.categoryCustomColors[self.categoryBeingEdited]!)
                                            ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                ? AnyView(self.newCategoryDisplayColor.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                : AnyView(self.categoryData.categoryCustomColors[self.categoryBeingEdited].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                            : self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                ? AnyView(self.categoryData.categoryCustomColors[self.categoryBeingEdited].background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                    ? AnyView(self.newCategoryDisplayColor.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                                    : AnyView(Color.EZNotesOrange.background(.ultraThinMaterial).environment(\.colorScheme, .light))
                                    )
                                    .cornerRadius(15, corners: [.topRight])
                                    .padding([.leading], -20)
                                    
                                    VStack {
                                        VStack {
                                            VStack {
                                                if self.newCategoryDescription != "" {
                                                    //ZStack {
                                                    Text(self.newCategoryDescription)
                                                        .foregroundStyle(
                                                            self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                ? self.newCategoryTextColor != .white
                                                                    ? self.newCategoryTextColor
                                                                    : self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                : self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                    ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                    : self.newCategoryTextColor != .white
                                                                        ? self.newCategoryTextColor
                                                                        : .white
                                                        )
                                                        .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 40, alignment: .leading)
                                                        .padding([.leading], 20)
                                                        .minimumScaleFactor(0.5)
                                                        .fontWeight(.light)
                                                        .multilineTextAlignment(.leading)
                                                } else {
                                                    Text("No Description")
                                                        .foregroundStyle(
                                                            self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                                ? self.newCategoryTextColor != .white
                                                                    ? self.newCategoryTextColor
                                                                    : self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                : self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                    ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                    : self.newCategoryTextColor != .white
                                                                        ? self.newCategoryTextColor
                                                                        : .white
                                                        )
                                                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                                                        .padding([.leading], 20)
                                                        .minimumScaleFactor(0.6)
                                                        .fontWeight(.medium)
                                                        .padding()
                                                        .multilineTextAlignment(.leading)
                                                }
                                                
                                                Text("Created \(self.categoryData.categoryCreationDates[self.categoryBeingEdited]!.formatted(date: .numeric, time: .omitted))")
                                                    .frame(maxWidth: (prop.size.width - 20) - 200, maxHeight: 20, alignment: .leading)
                                                    .padding([.bottom], 5)
                                                    .padding([.leading], 20)
                                                    .foregroundStyle(
                                                        self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryTextColor == self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!)
                                                            ? self.newCategoryTextColor != .white
                                                                ? self.newCategoryTextColor
                                                                : self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                            : self.categoryData.categoryCustomTextColors.keys.contains(self.categoryBeingEdited)
                                                                ? self.categoryData.categoryCustomTextColors[self.categoryBeingEdited]!
                                                                : self.newCategoryTextColor != .white
                                                                    ? self.newCategoryTextColor
                                                                    : .white
                                                    )
                                                    .fontWeight(.medium)
                                                    .font(.system(size: 10))
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                            .padding([.leading], 30)
                                            
                                            HStack {
                                                Button(action: {
                                                }) {
                                                    Image(systemName: "pencil")
                                                        .resizable()
                                                        .frame(width: 14.5, height: 14.5)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .padding([.trailing], 10)
                                                    
                                                    Text("Edit")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 14))
                                                        .fontWeight(.medium)
                                                        .padding([.leading], -10)
                                                }
                                                .padding([.leading], 10)
                                                .padding([.trailing], 5)
                                                
                                                Button(action: { print("Delete Category") }) {
                                                    Image(systemName: "trash")
                                                        .resizable()
                                                        .frame(width: 14.5, height: 14.5)
                                                        .foregroundStyle(.red)
                                                        .padding([.trailing, .top, .bottom], 10)
                                                    
                                                    Text("Delete")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 13))
                                                        .fontWeight(.medium)
                                                        .padding([.leading], -10)
                                                }
                                                .padding([.trailing], 5)
                                                
                                                Button(action: { print("Share") }) {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .resizable()
                                                        .frame(width: 14.5, height: 19.5)
                                                        .foregroundStyle(Color.EZNotesBlue)
                                                        .padding([.trailing, .bottom], 10)
                                                        .padding([.top], 5)
                                                    
                                                    Text("Share")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 13))
                                                        .fontWeight(.medium)
                                                        .padding([.leading], -10)
                                                }
                                                .padding([.trailing], 5)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .background(
                                                Color.clear.background(.ultraThinMaterial).environment(\.colorScheme, .dark).shadow(color: .black, radius: 2.5, x: 0, y: -1)
                                            )
                                            .padding([.leading], 20)
                                        }
                                        .padding([.leading], -20)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(
                                        self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryData.categoryCustomColors[self.categoryBeingEdited]!)
                                            ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                                ? self.newCategoryDisplayColor
                                                : self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                            : self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                                ? self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                                : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                    ? self.newCategoryDisplayColor
                                                    : Color.EZNotesOrange
                                    )
                                    .padding([.leading], -20)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryData.categoryCustomColors[self.categoryBeingEdited]!)
                                        ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                            ? self.newCategoryDisplayColor
                                            : self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                        : self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                            ? self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                            : self.newCategoryDisplayColor != Color.EZNotesOrange
                                                ? self.newCategoryDisplayColor
                                                : Color.EZNotesOrange
                                )
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: prop.size.width - 20, maxHeight: 190)
                        .background(
                            self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited) && !(self.newCategoryDisplayColor == self.categoryData.categoryCustomColors[self.categoryBeingEdited]!)
                                ? self.newCategoryDisplayColor != Color.EZNotesOrange
                                    ? self.newCategoryDisplayColor
                                    : self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                : self.categoryData.categoryCustomColors.keys.contains(self.categoryBeingEdited)
                                    ? self.categoryData.categoryCustomColors[self.categoryBeingEdited]!
                                    : self.newCategoryDisplayColor != Color.EZNotesOrange
                                        ? self.newCategoryDisplayColor
                                        : Color.EZNotesOrange
                        )
                        .cornerRadius(15)
                        .padding([.top, .bottom], 10)
                        
                        Spacer()
                    }
                    .frame(maxWidth: prop.size.width, maxHeight: .infinity)
                    .cornerRadius(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                            .shadow(color: .black, radius: 6.5)
                    )
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .animation(.default, value: self.editSection == "edit" || self.editSection == "preview")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            /*LinearGradient(
                gradient: Gradient(
                    colors: [
                        .black,
                        .black,
                        Color.EZNotesLightBlack
                    ]),
                startPoint: .top,
                endPoint: .bottom
            )*/
            .white
        )
    }
}
