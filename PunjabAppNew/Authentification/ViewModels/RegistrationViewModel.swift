//
//  RegistrationViewModel.swift
//  FacebookClone
//
//  Created by Omar Thamri on 8/1/2024.
//

import Foundation

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var cnfPassword: String = ""
    @Published var firstName: String = ""
    @Published var familyName: String = ""
    @Published var age: String = ""
    @Published var gender: String = ""
    @Published var mobileNo: String = ""
    @Published var otp: String = ""

    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var isOTPSent = false
    @Published var errorMessage: String?
    
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    @Published var moveToOTP = false

    // MARK: - Computed Validation
    var isFormNameValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 &&
        familyName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    var isEmailValid: Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic regex: valid 99% of normal emails
        let regex = #"^\S+@\S+\.\S+$"#

        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    var isMobileValid: Bool {
        mobileNo.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10    }
    
    var isAgeValid: Bool {
        !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isPasswordValid: Bool {
        (password.trimmingCharacters(in: .whitespacesAndNewlines) == cnfPassword.trimmingCharacters(in: .whitespacesAndNewlines)) && password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
    }
    
    // MARK: - Public Methods
    func validateAndSubmit() async {
        guard !firstName.isEmpty else { return showError("Please Enter First Name") }
        guard !familyName.isEmpty else { return showError("Please Enter Last Name") }
        guard !email.isEmpty else { return showError("Please Enter Email") }
        guard !password.isEmpty else { return showError("Please Enter Password") }
        guard password == cnfPassword else { return showError("Passwords do not match") }
        self.isOTPSent = false
        await registerUser { success, message in
             if success {
                 print("🎉 Registration Successful")
                 self.isOTPSent = true

                 self.alertTitle = "Success"
                 self.alertMessage = message ?? "Account Created"
                 self.showAlert = true
             } else {
                 print("❌ Registration Failed: \(message ?? "")")

                 self.alertTitle = "Error"
                 self.alertMessage = message ?? "Something went wrong"
                 self.showAlert = true
             }
         }
    }
    
    // MARK: - Public Methods
    func validateOTP(_ otpStr: String) async {
        self.otp = otpStr
        self.isLoggedIn = false
        await confirmOTP() { success, message in
             if success {
                 print("🎉 Registration Successful")
                 self.isLoggedIn = true

                 self.alertTitle = "Success"
                 self.alertMessage = message ?? "Account Created"
                 self.showAlert = true
             } else {
                 print("❌ Registration Failed: \(message ?? "")")

                 self.alertTitle = "Error"
                 self.alertMessage = message ?? "Something went wrong"
                 self.showAlert = true
             }
         }
    }
    
    // MARK: - API Call
    private func registerUser(completion: @escaping (Bool, String?) -> Void) async {
        isLoading = true
        defer { isLoading = false }

        let params = [
            "email": email,
            "password": password,
            "confirm_password": cnfPassword,
            "first_name": firstName,
            "last_name": familyName,
            "phone_num": mobileNo,
            "gender": gender,
            "birthday": age
        ]
        
        do {
                        
            let response: RegistrationResponseModel = try await APIManager.shared.requestWithoutHeader(
                url: APIList.register,
                parameters: params,
                model: RegistrationResponseModel.self
            )

            if response.apiStatus >= 200 && response.apiStatus <= 300 {
                if let abc = response.userId {
                    UserDefaults.setUserID(token: abc)
                    completion(true, response.message ?? "")
                }
            } else {
                completion(false, response.errors?.errorText ?? "Unknown error")
            }

        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    // MARK: - API Call
    private func confirmOTP(completion: @escaping (Bool, String?) -> Void) async {
        isLoading = true
        defer { isLoading = false }
        var userIDD = ""
        if let user1  = UserDefaults.getUserID() {
            userIDD = user1
        }
        do {
            let response: OtpVerifyModel = try await APIManager.shared.requestWithoutHeader(
                url: APIList.verifyOTP,
                parameters: ["type" : "verify","code":self.otp,"user_id" : userIDD],
                model: OtpVerifyModel.self
            )

            if (response.apiStatus >= 200) && (response.apiStatus <= 300) {
                UserDefaults.setUserToken(token: response.accessTokenn ?? "")
                completion(true, "")
            } else {
                completion(false, response.errors?.errorText ?? "Unknown error")
            }

        } catch {
            completion(false, error.localizedDescription)
        }
    }

    // MARK: - Error Handling
    private func showError(_ message: String) {
        errorMessage = message
        print("❌ Error:", message)
    }
    
    func showError(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

}
