//
//  AddNameView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct AddNameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var goToNext = false
    @State private var isNextDisabled = true
    @State private var isColorChange = true

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(alignment: .leading,spacing: 20) {
                    
                    Text("What's your name?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("Enter the name you use in real life")
                        .font(.footnote)
                    
                    
                    VStack {
                        CustomTextField(placeholder: "First Name", text: $viewModel.firstName, keyboardType: .alphabet)
                        
                        CustomTextField(placeholder: "Last name", text: $viewModel.familyName, keyboardType: .alphabet)
                    }
                    
                    
                    CustomButton(title: "Next", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: isColorChange ? [Color.gray.opacity(0.3)] : [AppColors.themeColor], customTextColor: Color.white) {
                        goToNext = true
                    }.frame(height: 50)
                    
                    NavigationLink("", destination: AddAgeView(viewModel: viewModel).navigationBarBackButtonHidden(), isActive: $goToNext)
                        .hidden()
                    
                    
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    })
                    
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "arrow.backward")
                            .imageScale(.large)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                }
                .background(AppColors.background)
            }
        }
        .onChange(of: viewModel.firstName) { _ in updateButtonState() }
                .onChange(of: viewModel.familyName) { _ in updateButtonState() }
    }
       
       // MARK: - Button Enable Logic
       private func updateButtonState() {
           isNextDisabled = !viewModel.isFormNameValid
           if viewModel.isFormNameValid == false {
               isColorChange = !viewModel.isFormNameValid
           }
           else {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                   isColorChange = !viewModel.isFormNameValid
               }
           }
       }
}

#Preview {
    AddNameView()
}
