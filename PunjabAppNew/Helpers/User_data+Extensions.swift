//
//  User_data+Extensions.swift
//  PunjabAppNew
//
//  Created for user display name helper
//

import Foundation

extension User_data {
    /// Returns the display name: full name if available, otherwise username
    var displayName: String {
        let firstName = first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fullName.isEmpty {
            return username ?? "Unknown User"
        }
        return fullName
    }
}
extension User {
    /// Returns the display name: full name if available, otherwise username
    var displayName: String {
        let firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = familyName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fullName.isEmpty {
            return "Unknown User"
        }
        return fullName
    }
}


extension Publisher {
    /// Returns the display name: full name if available, otherwise username
    var displayName: String {
        let firstName = first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fullName.isEmpty {
            return username ?? "Unknown User"
        }
        return fullName
    }
}

extension Stories {
    /// Returns the display name: full name if available, otherwise username
    var displayName: String {
        let firstName = first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fullName.isEmpty {
            return username ?? "Unknown User"
        }
        return fullName
    }
}

//extension User_data {
//    /// Returns the display name: full name if available, otherwise username (for User model)
//    var displayName: String {
//        let firstName = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        let lastName = last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if fullName.isEmpty {
//            return username ?? "Unknown User"
//        }
//        return fullName
//    }
//}
