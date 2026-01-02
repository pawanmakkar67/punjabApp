//
//  AddAgeView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var goToNext = false
    @State private var isNextDisabled = true

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(alignment: .leading,spacing: 20) {
                    
                    Text("What's your birthdate?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    
                    VStack {
                        CustomTextField(placeholder: "Date Of birth", text: $viewModel.age)
                    }
                    
                    
                    CustomButton(title: "Next", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: [Color.gray.opacity(0.2)]) {
                        goToNext = true
                    }.frame(height: 50)

                    
                    NavigationLink("", destination: AddgenderView(viewModel: viewModel).navigationBarBackButtonHidden(), isActive: $goToNext)
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
        }.onChange(of: viewModel.age) { _ in updateButtonState() }

    }
    // MARK: - Button Enable Logic
    private func updateButtonState() {
        isNextDisabled = !viewModel.isAgeValid
    }
}

#Preview {
    DashboardView()
}



