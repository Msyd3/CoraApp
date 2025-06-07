//
//  ContactListViewModel.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/06/2025.
//

import Foundation

class ContactListViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    
    func loadContacts(pageIndex: Int = 0, pageSize: Int = 10) {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return }
        
        var components = URLComponents(string: "\(APIConfig.baseURL)/api/endUser/beneficiaries/list-my-beneficiaries")!
        components.queryItems = [
            URLQueryItem(name: "page_index", value: "\(pageIndex)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error loading contacts:", error)
                return
            }
            
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(BeneficiaryListResponse.self, from: data)
                DispatchQueue.main.async {
                    self.contacts = decoded.my_beneficiaries
                }
            } catch {
                print("❌ Decode error:", error)
                print(String(data: data, encoding: .utf8) ?? "No response string")
            }
        }.resume()
    }
}

struct BeneficiaryListResponse: Codable {
    let beneficiaries_count: Int
    let my_beneficiaries: [Contact]
}
