//
//  KeyboardResponder.swift
//  PunjabAppNew
//
//  Created for SwiftUI keyboard management
//

import SwiftUI
import Combine

/// Observable object that tracks keyboard visibility and height
class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    @Published var isVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { $0.height }
            .sink { [weak self] height in
                self?.currentHeight = height
                self?.isVisible = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.currentHeight = 0
                self?.isVisible = false
            }
            .store(in: &cancellables)
    }
}

// MARK: - View Extensions

extension View {
    /// Dismisses the keyboard when tapping outside of text fields
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    /// Adds padding to avoid keyboard overlap
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
    
    /// Adds a toolbar above the keyboard with a Done button
    func keyboardToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}

// MARK: - Keyboard Aware Modifier

struct KeyboardAwareModifier: ViewModifier {
    @StateObject private var keyboard = KeyboardResponder()
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.currentHeight)
            .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
    }
}

// MARK: - Adaptive Keyboard Padding

struct AdaptiveKeyboardPadding: ViewModifier {
    @StateObject private var keyboard = KeyboardResponder()
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(height: geometry.size.height - keyboard.currentHeight)
                .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
        }
    }
}

extension View {
    /// Adjusts view height to account for keyboard
    func adaptiveKeyboardPadding() -> some View {
        self.modifier(AdaptiveKeyboardPadding())
    }
}
