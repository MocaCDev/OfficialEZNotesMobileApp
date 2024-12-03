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
    @Published public var displayUserCreatedSetsSeparately: Bool = false
    
    final public func saveSettings() {
        writeSettings(settings: [
            "seggregateShortAndLongNames": self.seggregateShortAndLongNames,
            "displayUserCreatedSetsSeparately": self.displayUserCreatedSetsSeparately
        ])
    }
    
    final public func loadSettings() {
        let settings = getSettings()
        
        guard
            settings.keys.contains("seggregateShortAndLongNames"),
            settings.keys.contains("displayUserCreatedSetsSeparately")
        else {
            print("Missing keys from settings recovered from cache.")
            return
        }
        
        self.seggregateShortAndLongNames = settings["seggregateShortAndLongNames"]!
        self.displayUserCreatedSetsSeparately = settings["displayUserCreatedSetsSeparately"]!
    }
    
    init() { }
    deinit { }
}
