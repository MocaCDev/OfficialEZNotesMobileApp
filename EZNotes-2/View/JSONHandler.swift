//
//  JSONHandler.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/8/24.
//
import SwiftUI

public func writeCategoryData(categoryData: [String: Array<String>]) -> Void {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("categories_data.json")
        
        try JSONEncoder()
            .encode(categoryData)
            .write(to: fileURL)
        
        //print("Finished writing \(categoryData) to \(fileURL)")
    } catch let error {
        print(error)
    }
}

public func writeCategoryImages(categoryImages: [String: UIImage]) -> Void {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("categoreis_images.json")
        
        var imageData: [String: Data] = [:]
        
        for (_, value) in categoryImages.enumerated() {
            imageData[value.key] = value.value.jpegData(compressionQuality: 0.9)
        }
        
        try JSONEncoder()
            .encode(imageData)
            .write(to: fileURL)
        
        //print("Finished Writing \(imageData) to \(fileURL)")
    } catch let error {
        print(error)
    }
}

public func getCategoryData() -> [String: Array<String>] {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("categories_data.json")
        
        if !FileManager.default.fileExists(atPath: fileURL.path()) {
            return [:]
        }
        
        let fileData = try Data(contentsOf: fileURL)
        let categoriesData = try JSONDecoder().decode([String: Array<String>].self, from: fileData)
        
        return categoriesData
    } catch {
        return [:]
    }
}

public func getCategoriesImageData() -> [String: UIImage] {
    do {
        let fileURL = try FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("categoreis_images.json")
        
        if !FileManager.default.fileExists(atPath: fileURL.path()) {
            return [:]
        }
        
        let fileData = try Data(contentsOf: fileURL)
        let categoriesImages = try JSONDecoder().decode([String: Data].self, from: fileData)
        
        var imagesData: [String: UIImage] = [:]
        
        for (_, value) in categoriesImages.enumerated() {
            imagesData[value.key] = UIImage(data: value.value)
        }
        
        return imagesData
    } catch {
        return [:]
    }
}
