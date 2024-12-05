//
//  SettingsConfigManager.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/3/24.
//
import SwiftUI

class SettingsConfigManager: ObservableObject {
    @Published public var seggregateShortAndLongNames: Bool = false
    @Published public var trackUserCreatedSets: Bool = false
    @Published public var trackUserCreatedCategories: Bool = false
    @Published public var displayUserCreatedSetsSeparately: Bool = false
    @Published public var displayUserCreatedCategoriesSeparatly: Bool = false
    @Published public var justNotes: Bool = false
    
    private let requiredKeys: Array<String> = [
        "seggregateShortAndLongNames",
        "displayUserCreatedSetsSeparately",
        "trackUserCreatedSets",
        "displayUserCreatedCategoriesSeparatly",
        "justNotes",
        "trackUserCreatedCategories"
    ]
    
    final public func saveSettings() {
        writeSettings(settings: [
            "seggregateShortAndLongNames": self.seggregateShortAndLongNames,
            "displayUserCreatedSetsSeparately": self.displayUserCreatedSetsSeparately,
            "trackUserCreatedSets": self.trackUserCreatedSets,
            "displayUserCreatedCategoriesSeparatly": self.displayUserCreatedCategoriesSeparatly,
            "justNotes": self.justNotes,
            "trackUserCreatedCategories": self.trackUserCreatedCategories
        ])
    }
    
    final public func loadSettings() {
        let settings = getSettings()
        
        /* MARK: Ensure all required keys are found from cache. */
        for requiredKey in self.requiredKeys {
            guard settings.keys.contains(requiredKey) else {
                print("Missing keys from settings recovered from cache.")
                return
            }
        }
        
        self.seggregateShortAndLongNames = settings["seggregateShortAndLongNames"]!
        self.displayUserCreatedSetsSeparately = settings["displayUserCreatedSetsSeparately"]!
        self.displayUserCreatedCategoriesSeparatly = settings["displayUserCreatedCategoriesSeparatly"]!
        self.trackUserCreatedSets = settings["trackUserCreatedSets"]!
        self.justNotes = settings["justNotes"]!
        self.trackUserCreatedCategories = settings["trackUserCreatedCategories"]!
    }
    
    init() { }
    deinit { }
}
