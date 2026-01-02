//
//  APIManager.swift
//  PunjabAppNew
//
//  Created by pc on 03/11/25.
//

import Foundation
import Alamofire
import ObjectMapper

@MainActor
final class APIManager {
    static let shared = APIManager()
    private init() {}

    // MARK: - Request with Header
    func request<T: Mappable>(
        url: String,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        model: T.Type
    ) async throws -> T {

        var params = parameters ?? [:]
        params["server_key"] = APIConfig.serverKey

        var headerData = headers ?? [:]
        var finalURL = url
    
        if let token = UserDefaults.getDeviceToken(), !token.isEmpty {
            print("access_token ::",token)
            finalURL = url + "?access_token=\(token)"
        }

        let responseData = try await performRequest(
            url: finalURL,
            method: method,
            parameters: params,
            headers: headerData
        )

        guard let modelObj = Mapper<T>().map(JSONObject: responseData) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to map model"])
        }

        return modelObj
    }

    // MARK: - Request Without Header
    func requestWithoutHeader<T: Mappable>(
        url: String,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        model: T.Type
    ) async throws -> T {

        var params = parameters ?? [:]
        params["server_key"] = APIConfig.serverKey

        let responseData = try await performRequest(
            url: url,
            method: method,
            parameters: params,
            headers: []
        )

        guard let modelObj = Mapper<T>().map(JSONObject: responseData) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mapping error"])
        }

        return modelObj
    }

    // MARK: - Upload Request (Multipart)
    func uploadRequest<T: Mappable>(
        url: String,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        data: Data,
        name: String,
        fileName: String,
        mimeType: String,
        model: T.Type
    ) async throws -> T {
        
        var params = parameters ?? [:]
        params["server_key"] = APIConfig.serverKey
        
        var headerData = headers ?? [:]
        var finalURL = url
        
        if let token = UserDefaults.getDeviceToken(), !token.isEmpty {
             finalURL = url + "?access_token=\(token)"
        }

        let responseData = try await performUpload(
            url: finalURL,
            method: method,
            parameters: params,
            headers: headerData,
            data: data,
            name: name,
            fileName: fileName,
            mimeType: mimeType
        )

        guard let modelObj = Mapper<T>().map(JSONObject: responseData) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to map model"])
        }

        return modelObj
    }

    // MARK: - Core Request Logic
    private func performRequest(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders
    ) async throws -> Any {

        let dataTask = AF.request(
            url,
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        ).serializingData()

        let response = await dataTask.response

        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }

        let data = response.data ?? Data()

        // ❌ Non-success returned by server
        guard (200...299).contains(statusCode) else {
            let message = parseErrorMessage(data)
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        // Convert JSON → Dictionary
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }

        return jsonObject
    }

    // MARK: - Core Upload Logic
    private func performUpload(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders,
        data: Data,
        name: String,
        fileName: String,
        mimeType: String
    ) async throws -> Any {

        // Use Alamofire's upload method
        let uploadRequest = AF.upload(
            multipartFormData: { multipartFormData in
                // Append image/video data
                multipartFormData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
                
                // Append other parameters
                if let parameters = parameters {
                   for (key, value) in parameters {
                       if let stringValue = value as? String {
                           if let data = stringValue.data(using: .utf8) {
                               multipartFormData.append(data, withName: key)
                           }
                       } else if let intValue = value as? Int {
                           if let data = "\(intValue)".data(using: .utf8) {
                               multipartFormData.append(data, withName: key)
                           }
                       }
                   }
                }
            },
            to: url,
            method: method,
            headers: headers
        )
            .serializingData()

        let response = await uploadRequest.response
        
        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let responseData = response.data ?? Data()
        
        guard (200...299).contains(statusCode) else {
            let message = parseErrorMessage(responseData)
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData) else {
             throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        
        return jsonObject
    }

    // MARK: - Error Message Parser
    private func parseErrorMessage(_ data: Data?) -> String {
        guard let data = data else { return "Something went wrong." }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String {
                return message
            }
            if let errors = json["errors"] as? [String: Any],
               let errorText = errors["error_text"] as? String {
                return errorText
            }
            if let errorMsg = json["error"] as? String {
                return errorMsg
            }
            if let errorMsg = json["error_message"] as? String {
                return errorMsg
            }
        }
        return "Server error."
    }
}
