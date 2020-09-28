//
//  APIService.swift
//  Smartlink Cameras
//
//  Created by SecureNet Mobile Team on 1/10/20.
//  Copyright © 2020 SecureNet Technologies, LLC. All rights reserved.
//

import Foundation

protocol APIServiceProtocol {
    // Just an example
    //    func request() -> Decodable
    func request(username: String) throws -> URLRequest
}

final class APIService: APIServiceProtocol {
    
    enum ApiError: Error {
        case badFormattedURL, badFormattedBody
    }
    
    init() {
        
    }
    
    deinit {
        
    }
    
    func request(username: String) throws -> URLRequest {
        guard let url = URL(string: "http://registration.securenettech.com/registration.php") else { throw ApiError.badFormattedURL }
        
        var request = URLRequest(url: url)
        
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "getPartnerEnvironment"),
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "environment", value: "PRODUCTION")
        ]
        
        let httpBody = [
            "method": "getPartnerEnvironment",
            "username": username,
            "environment": "PRODUCTION"
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted) else { throw ApiError.badFormattedBody }
        request.httpBody = jsonData
        
        request.url = urlComponents.url!
        request.httpMethod = "POST"
        
        return request
    }
    
}
