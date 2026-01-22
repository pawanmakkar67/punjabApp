//
//  CreatePageView.swift
//  PunjabAppNew
//
//  Created by pc on 22/01/2026.
//

import SwiftUI

struct CreatePageView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var pageTitle: String = ""
    @State private var pageURL: String = ""
    @State private var selectedCategory: String = ""
    @State private var aboutText: String = ""
    
    let categories = ["Science and Technology", "Comedy", "Cars and Vehicles", "Music", "Education"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Page Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Page Title")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#58102C"))
                    
                    TextField("Name Your Page", text: $pageTitle)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Page URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Page URL")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#58102C"))
                    
                    HStack(spacing: 8) {
                        Text("Https://PunjabApp.com/")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        TextField("Page URL", text: $pageURL)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#58102C"))
                    
                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button(category) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                
                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#58102C"))
                    
                    TextEditor(text: $aboutText)
                        .frame(height: 120)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Spacer().frame(height: 20)
                
                // Create Button
                Button(action: {
                    // Action to create page
                }) {
                    Text("Create Page")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#58102C"))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("Create Page")
    }
}

#Preview {
    CreatePageView()
}
