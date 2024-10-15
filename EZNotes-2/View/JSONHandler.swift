//
//  JSONHandler.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/8/24.
//
import SwiftUI

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
private func obtainJSON<T: Decodable>(type: T.Type, filename: String) throws -> T {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        if !FileManager.default.fileExists(atPath: fileURL.path()) {
            return [:] as! T
        }
        
        let fileData = try Data(contentsOf: fileURL)
        let data = try JSONDecoder().decode(T.self, from: fileData)
        
        return data
    } catch let error {
        print(error)
        throw error
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

public func getCategoryData() -> [String: Array<String>] {
    if let result = try? obtainJSON(type: [String: Array<String>].self, filename: "categories_data.json") { return result }
    else {
        print("[getCategoryData] -> Failed to obtain category data from cache")
        
        return [:]
    }
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
