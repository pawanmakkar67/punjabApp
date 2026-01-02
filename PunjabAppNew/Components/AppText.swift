//
//  AppText.swift
//  PunjabAppNew
//
//  Created by pc on 29/10/25.
//


import SwiftUI

struct AppText: View {
    var text: String
    var font: Font = .body
    var color: Color = .primary
    var weight: Font.Weight = .regular
    var alignment: TextAlignment = .leading
    var lineLimit: Int? = nil

    var body: some View {
        Text(text)
            .font(font.weight(weight))
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
    }
}
