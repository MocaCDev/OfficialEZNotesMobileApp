//
//  JSONHandler.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/8/24.
//
import SwiftUI

public func attemptDeleteJSON(filename: String) {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        try FileManager.default.removeItem(at: fileURL)
    } catch {
        print("[attemptDeleteJSON] Error deleting file \(filename): \(error.localizedDescription)")
    }
}

/* MARK: Function used in functions writing JSON objects to cache. Exists to mitigate repetitive code (also to mitigate the length of the file).
 * */
private func writeJSON<T: Encodable>(data: T, filename: String) throws -> Bool {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(filename)
        
        try JSONEncoder()
            .encode(data)
            .write(to: fileURL)
        
        return true
    } catch let error {
        throw error
    }
}

/* MARK: Function used in functions obtaining JSON objects from cache. Exists to mitigate repetitive code (also to mitigate the length of the file).
 * */
private func obtainJSON<T: Decodable>(type: T.Type, filename: String) throws -> T? {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        if !FileManager.default.fileExists(atPath: fileURL.path()) { return nil }
        
        let fileData = try Data(contentsOf: fileURL)
        let data = try JSONDecoder().decode(T.self, from: fileData)
        
        return data
    } catch let error {
        print("ERROR: \(error)")
        throw error
    }
}

public func writeSettings(settings: [String: Bool]) -> Void {
    guard let _ = try? writeJSON(data: settings, filename: "settings.json") else {
        print("[writeSettings] -> Failed to write \(settings) to cache")
        return
    }
}

public func writeCategoryData(categoryData: [String: Array<String>]) -> Void {
    /* TODO: I don't think we need the below `if let`. Just during development it'll be nice. */
    guard let _ = try? writeJSON(data: categoryData, filename: "categories_data.json") else {
        print("[writeCategoryData] -> Failed to write \(categoryData) to cache")
        return
    }
}

public func writeCategoryCreationDates(categoryCreationDates: [String: Date]) -> Void {
    guard let _ = try? writeJSON(data: categoryCreationDates, filename: "category_creation_dates.json") else {
        print("[writeCategoryCreationDates] -> Failed to write \(categoryCreationDates) to cache")
        return
    }
}

public func writeCategoryImages(categoryImages: [String: UIImage]) -> Void {
    var imageData: [String: Data] = [:]
    
    for (_, value) in categoryImages.enumerated() {
        imageData[value.key] = value.value.jpegData(compressionQuality: 0.9)
    }
    
    guard let _ = try? writeJSON(data: imageData, filename: "categories_images.json") else {
        print("[writeCategoryImages] -> Failed to write \(categoryImages) to cache")
        return
    }
}

public func writeCategoryDescriptions(categoryDescriptions: [String: String]) -> Void {
    guard let _ = try? writeJSON(data: categoryDescriptions, filename: "category_descriptions.json") else {
        print("[writeCategoryDescriptions] -> Failed to write \(categoryDescriptions) to cache")
        return
    }
}

struct ColorData: Codable {
    var red: Double
    var green: Double
    var blue: Double
}

extension Color {
    func components() -> (red: Double, green: Double, blue: Double) {
        let color = UIColor(self) // Convert SwiftUI Color to UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        return (Double(red), Double(green), Double(blue))
    }
}


public func writeCategoryCustomColors(categoryCustomColors: [String: Color]) -> Void {
    var data: [String: [String: Double]] = [:]
    
    let colorDataArray = categoryCustomColors.map { (name, color) -> ColorData in
        let components = color.components()
        return ColorData(red: components.red, green: components.green, blue: components.blue)
    }
    
    for (index, value) in categoryCustomColors.enumerated() {
        data[value.key] = [
            "Red": colorDataArray[index].red,
            "Green": colorDataArray[index].green,
            "Blue": colorDataArray[index].blue
        ]
    }
    
    guard let _ = try? writeJSON(data: data, filename: "category_custom_colors.json") else {
        print("[writeCategoryCustomColors] -> Failed to write \(data) to cache")
        return
    }
}

public func writeCategoryTextColors(categoryTextColors: [String: Color]) -> Void {
    var data: [String: [String: Double]] = [:]
    
    let colorDataArray = categoryTextColors.map { (name, color) -> ColorData in
        let components = color.components()
        return ColorData(red: components.red, green: components.green, blue: components.blue)
    }
    
    for (index, value) in categoryTextColors.enumerated() {
        data[value.key] = [
            "Red": colorDataArray[index].red,
            "Green": colorDataArray[index].green,
            "Blue": colorDataArray[index].blue
        ]
    }
    
    guard let _ = try? writeJSON(data: data, filename: "category_custom_text_colors.json") else {
        print("[writeCategoryTextColors] -> Failed to write \(data) to cache")
        return
    }
}

func writeTemporaryChatHistory(chatHistory: [String: [UUID: Array<MessageDetails>]]) -> Void {
    guard let _ = try? writeJSON(data: chatHistory, filename: "temp_chat_history.json") else {
        print("[writeTemporaryChatHistory] -> Failed to write \(chatHistory) to cache")
        return
    }
}

func writeSetsAndNotes(setsAndNotes: [String: Array<[String: String]>]) -> Void {
    guard let _ = try? writeJSON(data: setsAndNotes, filename: "sets_and_notes.json") else {
        print("[writeSetsAndNotes] -> Failed to write \(setsAndNotes) to cache")
        return
    }
}

func writeFontConfiguration(fontConfiguration: [String: [String: String]]) -> Void {
    guard let _ = try? writeJSON(data: fontConfiguration, filename: "font_configuration.json") else {
        print("[writeSetsAndNotes] -> Failed to write \(fontConfiguration) to cache")
        return
    }
}

func writeUserCreatedCategoryNames(userCreatedCategoryNames: Array<String>) -> Void {
    guard let _ = try? writeJSON(data: userCreatedCategoryNames, filename: "user_created_categories.json") else {
        print("[writeUserCreatedCategoryNames] -> Failed to write \(userCreatedCategoryNames) to cache")
        return
    }
}

func writeUserCreatedSetNames(userCreatedSetNames: Array<String>) -> Void {
    guard let _ = try? writeJSON(data: userCreatedSetNames, filename: "user_created_sets.json") else {
        print("[writeUserCreatedSetNames] -> Failed to write \(userCreatedSetNames) to cache")
        return
    }
}

public func writeSetFlashcards(flashcards: [String: String]) -> Void {
    guard let _ = try? writeJSON(data: flashcards, filename: "set_flashcards.json") else {
        print("[writeSetFlashcards] -> Failed to write \(flashcards) to cache")
        return
    }
}

public func writeSetSlideshows(slideshows: [String: String]) -> Void {
    guard let _ = try? writeJSON(data: slideshows, filename: "set_slideshows.json") else {
        print("[writeSetSlideshows] -> Failed to write \(slideshows) to cache")
        return
    }
}


public func getSettings() -> [String: Bool] {
    if let result = try? obtainJSON(type: [String: Bool].self, filename: "settings.json") { return result }
    else {
        print("[getSettings] -> Failed to obtain category data from cache")
        
        return [:]
    }
}

public func getCategoryData() -> [String: Array<String>] {
    guard let result = try? obtainJSON(type: [String: Array<String>].self, filename: "categories_data.json") else  {
        print("[getCategoryData] -> Failed to obtain category data from cache")
        
        return [:]
    }
    
    return result
}

public func getCategoryCreationDates() -> [String: Date] {
    guard let result = try? obtainJSON(type: [String: Date].self, filename: "category_creation_dates.json") else {
        print("[getCategoryCreationDates] -> Failed to get category creation dates from cache")
        return [:]
    }
    
    return result
}

public func getCategoriesImageData() -> [String: UIImage] {
    guard let result = try? obtainJSON(type: [String: Data].self, filename: "categories_images.json") else {
        print("[getCategoriesImageData] -> Failed to obtain category images from cache")
        return [:]
    }
    
    var imagesData: [String: UIImage] = [:]
    
    for (_, value) in result.enumerated() {
        imagesData[value.key] = UIImage(data: value.value)
    }
    
    return imagesData
}

public func getCategoryDescriptions() -> [String: String] {
    guard let result = try? obtainJSON(type: [String: String].self, filename: "category_descriptions.json") else {
        print("[getCategoryDescriptions] -> Failed to get category descriptions from cache")
        return [:]
    }
    
    return result
}

public func getCategoryCustomColors() -> [String: Color] {
    guard let result = try? obtainJSON(type: [String: [String: Double]].self, filename: "category_custom_colors.json") else {
        print("[getCategoryDescriptions] -> Failed to get custon category display colors from cache")
        return [:]
    }
    
    var retData: [String: Color] = [:]
    
    for (_, value) in result.enumerated() {
        retData[value.key] = Color(red: value.value["Red"]!, green: value.value["Green"]!, blue: value.value["Blue"]!)
    }
    
    return retData
}

public func getCategoryCustomTextColors() -> [String: Color] {
    guard let result = try? obtainJSON(type: [String: [String: Double]].self, filename: "category_custom_text_colors.json") else {
        print("[getCategoryCustomTextColors] -> Failed to get custom category text colors from cache")
        return [:]
    }
    
    var retData: [String: Color] = [:]
    
    for (_, value) in result.enumerated() {
        retData[value.key] = Color(red: value.value["Red"]!, green: value.value["Green"]!, blue: value.value["Blue"]!)
    }
    
    return retData
}

func getTemporaryStoredChats() -> [String: [UUID: Array<MessageDetails>]] {
    guard let result = try? obtainJSON(type: [String: [UUID: Array<MessageDetails>]].self, filename: "temp_chat_history.json") else {
        print("[getTemporaryStoredChats] -> Failed to get temporary stores chats from cache")
        return [:]
    }
    
    return result
}

func getSetsAndNotes() -> [String: Array<[String: String]>] {
    guard let result = try? obtainJSON(type: [String: Array<[String: String]>].self, filename: "sets_and_notes.json") else {
        print("[getSetsAndNotes] -> Failed to get sets and notes from cache")
        return [:]
    }
    
    return result
}

func getFontConfiguration() -> [String: [String: String]]? {
    guard let result = try? obtainJSON(type: [String: [String: String]].self, filename: "font_configuration.json") else {
        print("[getFontConfiguration] -> Failed to get font configuration from cache")
        return nil
    }
    
    return result
}

func getUserCreatedCategoryNames() -> Array<String> {
    guard let result = try? obtainJSON(type: Array<String>.self, filename: "user_created_categories.json") else {
        print("[getUserCreatedCategoryNames] -> Failed to get user created categories from cache")
        return []
    }
    
    return result
}

func getUserCreatedSetNames() -> Array<String> {
    guard let result = try? obtainJSON(type: Array<String>.self, filename: "user_created_sets.json") else {
        print("[getUserCreatedSetNames] -> Failed to get user created categories from cache")
        return []
    }
    
    return result
}

func getSetFlashcards() -> [String: String] {//[String: [String: String]] {
    guard let result = try? obtainJSON(type: [String: String].self, filename: "set_flashcards.json") else {
        print("[getSetFlashcards] -> Failed to get flashcard data for sets from cache")
        return [:]
    }
    
    return result
}

func getSetSlideshows() -> [String: String] {//[String: [String: String]] {
    guard let result = try? obtainJSON(type: [String: String].self, filename: "set_slideshows.json") else {
        print("[getSetSlideshows] -> Failed to get slideshow data for sets from cache")
        return [:]
    }
    
    return result
}
