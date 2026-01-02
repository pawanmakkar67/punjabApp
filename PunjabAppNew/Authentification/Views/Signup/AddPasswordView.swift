//
//  AddPasswordView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct AddPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RegistrationViewModel
    @State private var goToNext = false
    @State private var isNextDisabled = true
    @State private var isColorChange = true

    init(viewModel: RegistrationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(alignment: .leading,spacing: 20) {
                    
                    Text("Create a password")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top)
                    Text("Create a password whith at least 8 letters or numbers. It should be something that others can't guess.")
                                    .font(.footnote)
                    PasswordField(placeholder: "Password", text: $viewModel.password)
                    
                    PasswordField(placeholder: "Confirm Password", text: $viewModel.cnfPassword)
                    
                    CustomButton(title: "Next", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: isColorChange ? [Color.gray.opacity(0.3)] : [AppColors.themeColor], customTextColor: Color.white) {
                        if (viewModel.isPasswordValid) {
                            goToNext = true
                        }
                        else {
                            viewModel.showError("Alert", "Password is not same or valid;")
                        }
                    }.frame(height: 50)
                    
                    
                    NavigationLink("", destination: AgreementView(viewModel: viewModel).navigationBarBackButtonHidden(), isActive: $goToNext)
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
            }.commonAlert(
                showAlert: $viewModel.showAlert,
                title: viewModel.alertTitle,
                message: viewModel.alertMessage
            )
        }.onChange(of: [viewModel.password,viewModel.cnfPassword]) { _ in updateButtonState() }.onAppear {
            updateButtonState()
        }
    }
    // MARK: - Button Enable Logic
    private func updateButtonState() {
        isNextDisabled = !(viewModel.isPasswordValid)
        if (!viewModel.isPasswordValid) {
            isColorChange = !(viewModel.isPasswordValid)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isColorChange = !(viewModel.isPasswordValid)
            }
        }
    }
}

#Preview {
    AddPasswordView(viewModel: RegistrationViewModel())
}
