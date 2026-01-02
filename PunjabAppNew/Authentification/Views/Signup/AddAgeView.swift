//
//  AddAgeView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct AddAgeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegistrationViewModel()
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
                    
                    Text("What's your birthdate?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    
                    VStack {
                        CustomDatePicker(placeholder: "Date Of birth", selectedDateString: $viewModel.age)
                    }
                    
                    
                    CustomButton(title: "Next", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: isColorChange ? [Color.gray.opacity(0.3)] : [AppColors.themeColor]) {
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
        }.onChange(of: viewModel.age) { _ in updateButtonState() }.onAppear {
            updateButtonState()
        }

    }
    // MARK: - Button Enable Logic
    private func updateButtonState() {
        isNextDisabled = !viewModel.isAgeValid
        if viewModel.isAgeValid == false {
            isColorChange = !viewModel.isAgeValid
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isColorChange = !viewModel.isAgeValid
            }
        }
    }
}

#Preview {
    AddAgeView(viewModel: RegistrationViewModel())
}



#Preview {
    AddNameView()
}
