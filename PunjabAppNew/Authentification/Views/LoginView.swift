//
//  LoginView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var goToNext = false

    @available(iOS 16.0, *)
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 10) {
                    Spacer()
                    Image("App_ic")
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width/1.5, height: proxy.size.width/3)
                    VStack(spacing: 24) {
                        CustomTextField(placeholder: "Mobile Number/ Email/ Username", text: $viewModel.email, keyboardType: .emailAddress)
                        PasswordField(placeholder: "Password", text: $viewModel.password, keyboardType: .emailAddress)

                        CustomButton(title: "Log In", style: .custom, weight: .semibold, font: .latoSemiBold(.h12), customBackground: [AppColors.themeColor]) {
                            Task {
                                try await viewModel.login()
                            }
                        }.frame(height: 45)
                        AppText(text: "Forgot Password?", font: .latoSemiBold(.h9), weight: .semibold)
                    }.padding()
                    
                    HStack { Spacer()}
                    Spacer()
                    
                    CustomButton(title: "Create an Account", style: .secondary, weight: .semibold, font: .latoSemiBold(.h12)) {
                        goToNext = true
                    }.frame(height: 45) // 👈 Add this
                        .padding(.horizontal)
                    NavigationLink("", destination: AddNameView().navigationBarBackButtonHidden(), isActive: $goToNext)
                        .hidden()
                    NavigationLink("", destination: MainTabbarView().navigationBarBackButtonHidden(), isActive: $viewModel.isLoggedIn)
                        .hidden()

                }
                .background(AppColors.background)
            }.disabled(viewModel.isLoading)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }.commonAlert(
                    showAlert: $viewModel.showAlert,
                    title: viewModel.alertTitle,
                    message: viewModel.alertMessage
                )
        }
    }
}

#Preview {
    LoginView()
}
