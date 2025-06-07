//
//  APIConfig.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 11/03/2025.
//

struct APIConfig {
    static let isProduction = true
    
    static let devBaseURL = "http://localhost:5207"
    static let prodBaseURL = "https://rest.dashboard.cora.sa"
    
    static let baseURL: String = isProduction ? prodBaseURL : devBaseURL
}


