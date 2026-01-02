//
//  LaunchView.swift
//  PunjabAppNew
//
//  Created by pc on 13/11/25.
//


import SwiftUI

struct LaunchView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            RootView()
        } else {
            VStack {
                Image("loginImg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280 , height: 280)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.app)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { isActive = true }
                }
            }
        }
    }
}
