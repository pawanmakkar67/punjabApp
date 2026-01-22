//
//  HeaderView.swift
//  FacebookClone
//
//  Created by omar thamri on 2/1/2024.
//

import SwiftUI
import Foundation

struct HeaderView: View {
    let facebookBlue = Color(red: 66/255, green: 103/255, blue: 178/255, opacity: 1)
    
    var onPlusTap: () -> Void = {}
    var onSeachTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 24) {
            
            Text("Punjab App")
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(AppColors.themeColor)
            
            Spacer()
            
            Button(action: {
                onPlusTap()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppColors.themeColor)
            }
            Button(action: {
                onSeachTap()
            }) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFill()
                    .font(.system(size: 18,weight: .bold))
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppColors.themeColor)
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    HeaderView()
}
