//
//  OTPScreen.swift
//  PunjabAppNew
//
//  Created by pc on 14/11/25.
//

import SwiftUI

struct OTPScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RegistrationViewModel
    @State private var goToNext = false
    @State private var isNextDisabled = true
    @State private var isColorChange = true
    @State private var otp: String = ""
    @FocusState private var isFocused: Bool
    @State private var changedOTP = ""

    init(viewModel: RegistrationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 20) {
                    Text("Enter Verification Code")
                        .font(.title2.bold())
                    
                    Text("We’ve sent a 5-digit code to your phone.")
                        .foregroundColor(.gray)
                  OTPView(length: 5,viewModel: viewModel) { otp in
                        print("Entered OTP:", otp)
                      if changedOTP != otp && otp.count == 5 {
                          changedOTP = otp
                          Task {
                              await viewModel.validateOTP(otp)
                          }
                      }
                  }
                    
                    Spacer()
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
            }.background(AppColors.background)
            NavigationLink("", destination: MainTabbarView().navigationBarBackButtonHidden(), isActive: $viewModel.isLoggedIn)

        }.onChange(of: viewModel.isLoggedIn) { loggedIn in
            if loggedIn {
                print("validated otp")
                goToNext = true
                // Move to next screen
            }
        }

    }
}



#Preview {
    OTPScreen(viewModel: RegistrationViewModel())
}



