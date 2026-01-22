//
//  PublicProfileHeader.swift
//  PunjabAppNew
//
//  Created by pc on 22/01/2026.
//

import SwiftUI
import Kingfisher

struct PublicProfileHeader: View {
    let user: User_data
    
    var body: some View {
        VStack(spacing: 8) {
            KFImage(URL(string: user.avatar ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            Text(user.displayName ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            if let genderText = user.gender_text, !genderText.isEmpty {
                 Text(genderText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else if let gender = user.gender {
                Text(gender.capitalized)
                   .font(.subheadline)
                   .foregroundColor(.gray)
            }
            
            if let birthday = user.birthday, !birthday.isEmpty {
                Text(birthday)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if let relId = user.relationship_id, relId != "0" && !relId.isEmpty {
                Text("Relationship: \(getRelationshipStatus(id: relId))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 20)
    }
    
    // Helper to map relationship IDs
    func getRelationshipStatus(id: String) -> String {
        switch id {
        case "1": return "Single"
        case "2": return "In a relationship"
        case "3": return "Married"
        case "4": return "Engaged"
        default: return "Complex"
        }
    }
}
