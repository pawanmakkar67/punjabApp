//
//  CommonAlertModifier.swift
//  PunjabAppNew
//
//  Created by pc on 03/11/25.
//


import SwiftUI

struct CommonAlertModifier: ViewModifier {
    @Binding var showAlert: Bool
    var title: String
    var message: String
    var onDismiss: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $showAlert, actions: {
                Button("OK") {
                    showAlert = false
                    onDismiss?()
                }
            }, message: {
                Text(message)
            })
    }
}

extension View {
    func commonAlert(showAlert: Binding<Bool>, title: String, message: String, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(CommonAlertModifier(showAlert: showAlert, title: title, message: message, onDismiss: onDismiss))
    }
}
