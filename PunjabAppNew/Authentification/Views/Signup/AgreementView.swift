import SwiftUI

struct AgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RegistrationViewModel
    @State private var goToNext = false
    @State private var isNextDisabled = false

    init(viewModel: RegistrationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title
                    Text("Agree to Facebook's terms and policies")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // MARK: - Paragraph 1
                    VStack(alignment: .leading, spacing: 4) {
                        Text("People who use our service may have uploaded your contact information to Facebook.")
                            .font(.footnote)
                        Text("Learn more")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    // MARK: - Paragraph 2
                    VStack(alignment: .leading, spacing: 4) {
                        Text("By tapping")
                            .font(.footnote)
                        +
                        Text(" I agree")
                            .font(.footnote)
                            .fontWeight(.bold)
                        +
                        Text(", you agree to create an account and to Facebook's ")
                            .font(.footnote)
                        +
                        Text("Terms, Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.blue)
                        +
                        Text(" and ")
                            .font(.footnote)
                        +
                        Text("Cookies Policy")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    // MARK: - Paragraph 3
                    VStack(alignment: .leading, spacing: 4) {
                        Text("The ")
                            .font(.footnote)
                        +
                        Text("Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.blue)
                        +
                        Text(" describes the way we can use the information we collect when you create an account. For example, we use this information to provide, personalise and improve our products, including ads.")
                            .font(.footnote)
                    }
                    
                    Spacer()
                    
                    
                    CustomButton(title: "I Agree", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: [AppColors.themeColor], customTextColor: Color.white) {
                        Task { try await viewModel.validateAndSubmit() }
                    }.frame(height: 50)
                    
                    
                    
                    // MARK: - Already have an account
                    Button(action: {
                        // Go to login screen
                    }) {
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "arrow.backward")
                            .imageScale(.large)
                            .onTapGesture { dismiss() }
                    }
                }
                .background(AppColors.background)
                NavigationLink("", destination: OTPScreen(viewModel: viewModel).navigationBarBackButtonHidden(), isActive: $goToNext)
                    .hidden()
            }.onChange(of: viewModel.isOTPSent) { loggedIn in
                if loggedIn {
                    goToNext = true
                    print("🎉 Navigate to Home Screen")
                    // Your navigation code here
                }
           
        }
        }
    }
}

#Preview {
    AgreementView(viewModel: RegistrationViewModel())
}
