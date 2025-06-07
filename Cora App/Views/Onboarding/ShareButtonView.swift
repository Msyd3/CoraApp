//
//  ShareButtonView.swift
//  Cora App
//
//  Created by Mohammed Alsayed on 04/03/2025.
//
//
//  ShareButtonView.swift
//  Cora App
//


import SwiftUI
import Foundation

struct ShareButtonView: View {
    @ObservedObject var logManager = ShareLogManager()
    
    var body: some View {
        Button(action: {
            let log = AppShareLog(message: "تم مشاركة التطبيق", date: Date())
            AppShareLogManager.shared.add(log: log)
            shareApp()
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("share_app".localized)
                    .customFont(size: 18, weight: "Rubik-Bold")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("LightBur"))
            .foregroundColor(Color("Bur"))
            .cornerRadius(12)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 20)
        }
    }
    
    func shareApp() {
        let phone = UserDefaults.standard.string(forKey: "phone_number") ?? "unknown"
        
        let urlString = "https://script.google.com/macros/s/AKfycbxJjpxmsOosRcsUaoA-Y6eyTFdbCx9knYeXAXToc5t-7Sq1Nu93nH02I03G0R2e1nkZOA/exec?phone=\(phone)&action=share"
        
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Logged to Google Sheet")
                }
            }.resume()
        }
        
        guard let appURL = URL(string: "https://apps.apple.com/app/id6741744029") else { return }
        let activityVC = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                            y: rootViewController.view.bounds.midY,
                                            width: 0,
                                            height: 0)
                popover.permittedArrowDirections = []
            }
            rootViewController.present(activityVC, animated: true)
        }
    }
}


#Preview {
    ShareButtonView(logManager: ShareLogManager())
}
