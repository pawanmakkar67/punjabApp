//
//  AddgenderView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct AddgenderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var genderChoice: [String] = ["Female","Male","Other"]
    @StateObject private var viewModel: RegistrationViewModel
    @State private var goToNext = false
    @State private var isNextDisabled = true
    @State private var isColorChange = true

    init(viewModel: RegistrationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading,spacing: 20) {
            
                Text("What's your gender?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top)
                Text("You can change who sees your gender on your profile later")
                                .font(.footnote)
                VStack(alignment: .leading,spacing: 24) {
                    ForEach(genderChoice,id: \.self) { choice in
                        Button {
                            viewModel.gender = choice
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(choice)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                    if choice == "Other" {
                                        Text("Select other option to choose another gender or if you'd rather not say.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color(.darkGray))
                                            .padding(.trailing)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                Spacer()
                                Circle()
                                    .stroke(viewModel.gender == choice ? .blue : .gray,lineWidth: 1)
                                    .frame(width: 25, height: 25)
                                    .overlay {
                                        Circle()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(viewModel.gender == choice ? .blue : .clear)
                                    }
                                
                            }
                        }
                       
                        
                    }
                }
                .padding(20)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                CustomButton(title: "Next", style: .custom,isDisabled : isNextDisabled, weight: .semibold, font: .latoSemiBold(.h12), borderRunningColors:[AppColors.themeColor,AppColors.themeColor,AppColors.themeColor,AppColors.themeColor], customBackground: isColorChange ? [Color.gray.opacity(0.3)] : [AppColors.themeColor]) {
                    goToNext = true
                }.frame(height: 50)
                
                NavigationLink("", destination: AddEmailView(viewModel: viewModel).navigationBarBackButtonHidden(), isActive: $goToNext)
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
        }.onChange(of: viewModel.gender) { _ in updateButtonState() }.onAppear {
            updateButtonState()
        }
    }
    // MARK: - Button Enable Logic
    private func updateButtonState() {
        isNextDisabled = (viewModel.gender == "")
        if (viewModel.gender == "") {
            isColorChange = (viewModel.gender == "")
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isColorChange = (viewModel.gender == "")
            }
        }
    }
}


#Preview {
    AddgenderView(viewModel: RegistrationViewModel())
}
