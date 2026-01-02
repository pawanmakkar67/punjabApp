//
//  OTPView.swift
//  PunjabAppNew
//
//  Created by pc on 14/11/25.
//


import SwiftUI

struct OTPView: View {
    let length: Int
    @StateObject var viewModel: RegistrationViewModel
    var onComplete: (String) -> Void

    @State private var otp: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                ForEach(0..<length, id: \.self) { i in
                    otpBox(i)
                }
            }
            .onTapGesture {
                isFocused = true     // focus hidden field
            }

            // Hidden input box
            TextField("", text: Binding(
                get: { otp },
                set: { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count <= length {
                        otp = filtered
                    }
                    if otp.count == length {
                        onComplete(otp)
                    }
                }
            ))
            .textContentType(.oneTimeCode)      // 🔥 REQUIRED FOR SMS AUTO-FILL
            .keyboardType(.numberPad)
            .focused($isFocused)
            .opacity(0)              // hidden input
            .frame(width: 0, height: 0)
        }
        .onAppear {
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }

    // Visible OTP boxes
    private func otpBox(_ index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .frame(width: 45, height: 55)

            Text(charAt(index))
                .font(.title2.bold())
        }
    }

    private func charAt(_ index: Int) -> String {
        if index < otp.count {
            let arr = Array(otp)
            return String(arr[index])
        }
        return ""
    }
}




