//
//  AddAgeView.swift
//  FacebookClone
//
//  Created by omar thamri on 4/1/2024.
//

import SwiftUI

struct CreatePassword: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RegistrationViewModel
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
                    Text("Create a password whith at least 6 letters or numbers. It should be something that others can't guess.")
                                    .font(.footnote)
                    PasswordField(placeholder: "Password", text: $viewModel.password)
                    
                    PasswordField(placeholder: "Confirm Password", text: $viewModel.cnfPassword)
                    
                    NavigationLink {
                        AddAgeView(viewModel: viewModel)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Next")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: proxy.size.width - 30,height: 44)
                            .background(Color(.systemBlue))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .padding(.top)

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
        }
    }
}

#Preview {
    CreatePassword(viewModel: RegistrationViewModel())
}
