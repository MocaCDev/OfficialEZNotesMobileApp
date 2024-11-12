//
//  UserDefaultsFunctions.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/12/24.
//
import SwiftUI

/* MARK: Just make the entire operation shorter. `assignUDKey` - Assign UserDefault(UD) Key */
public func assignUDKey(key: String, value: Any) -> Void { UserDefaults.standard.set(value, forKey: key) }
public func removeUDKey(key: String) -> Void {
    if UserDefaults.standard.object(forKey: key) != nil { UserDefaults.standard.removeObject(forKey: key) }
}

public func removeAllSignUpTempKeys() -> Void {
    removeUDKey(key: "temp_college")
    removeUDKey(key: "temp_field")
    removeUDKey(key: "temp_major")
    removeUDKey(key: "temp_state")
    removeUDKey(key: "temp_username")
    removeUDKey(key: "temp_email")
    removeUDKey(key: "temp_password")
    removeUDKey(key: "temp_account_id")
}
