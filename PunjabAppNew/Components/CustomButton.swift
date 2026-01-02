import SwiftUI

enum AppButtonStyleType {
    case primary, secondary, destructive, custom
}

struct CustomButton: View {
    var title: String
    var icon: String? = nil
    var style: AppButtonStyleType = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var weight: Font.Weight = .regular
    var font: Font = .system(size: 17, weight: .semibold)
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 52
    var borderRunningColors: [Color]? = nil
    var borderWidth: CGFloat = 3
    var customBackground: [Color] = [Color(hex: "#571E40"), Color(hex: "#8C2F66")]
    var customTextColor: Color = .white
    var action: () -> Void

    @State private var borderOffset: CGFloat = -1.0
    @State private var repeatCount = 0
    @State private var hasAnimated = false

    // MARK: - Background Gradient
    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .secondary:
            return LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .destructive:
            return LinearGradient(colors: [Color.red, Color.red.opacity(0.8)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case .custom:
            return LinearGradient(colors: customBackground,
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return .black
        case .custom: return customTextColor
        }
    }

    var body: some View {
        Button(action: {
            guard !isLoading, !isDisabled else { return }
            action()
        }) {
            ZStack {
                // ✅ Background separated from animation
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundGradient)
                    .opacity(isDisabled ? 0.4 : 1.0)
                    .drawingGroup() // Prevent re-render flicker

                // ✅ Independent animated border
                if let borderColors = borderRunningColors, !borderColors.isEmpty {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: borderColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: borderWidth
                        )
                        .mask(
                            GeometryReader { geo in
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white, .clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: geo.size.width)
                                .offset(x: borderOffset * geo.size.width)
                            }
                        )
                }

                // MARK: - Button Content
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                            .scaleEffect(1.1)
                    } else {
                        if let icon = icon {
                            Image(systemName: icon)
                                .foregroundColor(textColor)
                        }
                        Text(title)
                            .font(font.weight(weight))
                            .foregroundColor(textColor.opacity(isDisabled ? 0.6 : 1.0))
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .contentShape(Rectangle())
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PressableButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .onChange(of: isDisabled) { newValue in
            if !newValue, !hasAnimated {
                hasAnimated = true
                animateBorder()
            }
        }
        .onAppear {
            if !isDisabled {
                animateBorder()
            }
        }
    }

    // MARK: - Animate Border (once)
    private func animateBorder() {
        repeatCount = 0
        borderOffset = -1.0

        func runAnimation() {
            guard repeatCount < 1 else { return }
            repeatCount += 1

            withAnimation(.linear(duration: 1.5)) {
                borderOffset = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                borderOffset = -1.0
            }
        }

        runAnimation()
    }
}

// MARK: - Press Animation
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
