//
//  LoginViewModel.swift
//  FacebookClone
//
//  Created by omar thamri on 8/1/2024.
//

import Foundation

import SwiftUI
import Combine
import ObjectMapper
import Alamofire

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var loginModel: LoginModel?
    @Published var errorMessage = ""

    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn: Bool = false

    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    
    func login() async {
        let params  = ["username":email, "password" : password, "device_type" : "ios"]

        do {
            let res: LoginModel = try await APIManager.shared.requestWithoutHeader(
                url: APIList.login,
                parameters: params,
                model: LoginModel.self
            )

            DispatchQueue.main.async {
                self.loginModel = res
                if res.apiStatus == 200 {
                    self.isLoggedIn = true
                    UserDefaults.setDeviceToken(token: res.accessToken ?? "")
                    UserDefaults.setUserID(token: res.userId ?? "")
                } else {
                    self.alertTitle = "Login Failed"
                    self.alertMessage = res.message ?? "Please try again"
                    self.showAlert = true
                }
            }

        } catch {
            DispatchQueue.main.async {
                self.alertTitle = "Network Error"
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }

    
    
    
    func loginUser() async throws -> LoginModel {
        let params  = ["username":email, "password" : password, "device_type" : "ios"]

        let url = APIList.login // Your login endpoint
        
        let response: LoginModel = try await APIManager.shared.requestWithoutHeader(
            url: url,
            method: .post,
            parameters: params,
            model: LoginModel.self
        )
        
        return response
    }

    
    
    func showError(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

}


