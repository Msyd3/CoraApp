//
//  CustomLinkViewModel.swift
//  Cora
//
//  Created by Mohammed Alsayed on 28/05/2025.
//

import SwiftUI

class CustomLinkViewModel: ObservableObject {
    @Published var buttonColor: Color = Color("Bur")
    @Published var buttonText: String = NSLocalizedString("Select", comment: "")
    @Published var userDomain: String = ""
    @Published var isLoading: Bool = false
    @Published var showBanner = false
    
    func fetchUserDomain(isLinkConfirmed: Binding<Bool>) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/payment-link-generator/get-account-domain") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                if let data = data, let domain = String(data: data, encoding: .utf8), !domain.isEmpty {
                    self.userDomain = domain
                    isLinkConfirmed.wrappedValue = true
                    UserDefaults.standard.set(domain, forKey: "user_domain")
                }
            }
        }.resume()
    }
    
    func checkAndReserveDomain(linkName: String, isLinkConfirmed: Binding<Bool>) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/payment-link-generator/reserve-domain") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters = ["domain": linkName.trimmingCharacters(in: .whitespaces)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.buttonColor = Color("Rede")
                    self.buttonText = "Taken"
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    self.userDomain = linkName
                    isLinkConfirmed.wrappedValue = true
                    self.buttonColor = Color("Greend")
                    self.buttonText = NSLocalizedString("Done", comment: "")
                    self.showBanner = true
                case 409:
                    self.buttonColor = Color("Rede")
                    self.buttonText = NSLocalizedString("Taken", comment: "")
                default:
                    self.buttonColor = Color("Rede")
                    self.buttonText = NSLocalizedString("Taken", comment: "")
                }
            }
        }.resume()
    }
}
