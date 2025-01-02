//
//  UserDefaultsFunctions.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/12/24.
//
import SwiftUI

/* MARK: UD stands for UserDefault. */

/* MARK: Just make the entire operation shorter. `assignUDKey` - Assign UserDefault(UD) Key */
public func assignUDKey(key: String, value: Any) -> Void { UserDefaults.standard.set(value, forKey: key) }
public func removeUDKey(key: String) -> Void {
    if UserDefaults.standard.object(forKey: key) != nil { UserDefaults.standard.removeObject(forKey: key) }
}
public func getUDValue<T>(key: String) -> T {
    return UserDefaults.standard.value(forKey: key)! as! T
}
public func udKeyExists(key: String) -> Bool { return UserDefaults.standard.object(forKey: key) != nil }

public func removeAllSignUpTempKeys() -> Void {
    removeUDKey(key: "temp_college")
    removeUDKey(key: "temp_field")
    removeUDKey(key: "temp_major")
    removeUDKey(key: "temp_state")
    removeUDKey(key: "temp_username")
    removeUDKey(key: "temp_email")
    removeUDKey(key: "temp_password")
    removeUDKey(key: "temp_account_id")
    removeUDKey(key: "usecase")
}

public func udRemoveAllAccountInfoKeys() -> Void {
    removeUDKey(key: "username")
    removeUDKey(key: "email")
    removeUDKey(key: "password")
    removeUDKey(key: "account_id")
    removeUDKey(key: "college")
    removeUDKey(key: "major")
    removeUDKey(key: "major_field")
    removeUDKey(key: "state")
    removeUDKey(key: "usecase")
}
