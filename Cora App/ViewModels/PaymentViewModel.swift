//
//  PaymentRequest.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/05/2025.
//

import Foundation
import MoyasarSdk

class PaymentViewModel: ObservableObject {
    
    @Published var paymentRequest: PaymentRequest?
    
    private var transactionId: String
    private let apiKey = "pk_test_d4rEfyS8gi6Z5gcu3wPZr58aGpMkXKdY72xdpv7z"
    
    init(amount: Double, transactionId: String) {
        self.transactionId = transactionId
        print("🚀 Received amount: \(amount), transactionId: \(transactionId)")
        setupRequest(amount: amount)
    }

    
    private func setupRequest(amount: Double) {
        
        guard amount.isFinite, amount > 0 else {
              print("❌ المبلغ غير صالح: \(amount)")
              return
          }
        
        do {
            let request = try PaymentRequest(
                apiKey: apiKey,
                amount: Int(amount * 100),
                currency: "SAR",
                description: transactionId,
                metadata: [
                    "sdk": .stringValue("ios"),
                    "order_id": .stringValue(transactionId)
                ],
                manual: false,
                saveCard: false,
                allowedNetworks: [.mada],
                payButtonType: .pay
            )
            self.paymentRequest = request
            print("🧾 PaymentRequest metadata: \(request.metadata), description: \(request.description ?? "")")
        } catch {
            print("❌ فشل في إعداد الطلب:", error.localizedDescription)
        }
    }
    
    func handleResult(_ result: PaymentResult) {
        switch result {
        case .completed(let payment):
            if payment.status == .paid {
                print("✅ تم الدفع بنجاح: \(payment.id)")
                finalizeCharge(payTransactionId: payment.id)
            } else {
                print("⚠️ الدفع لم يكتمل. الحالة: \(payment.status.rawValue)")
            }
        case .failed(let error):
            print("❌ خطأ في الدفع:", error.localizedDescription)
        case .canceled:
            print("🚫 تم إلغاء العملية من المستخدم")
        default:
            print("❓ حالة غير معروفة")
        }
    }
    
    func finalizeCharge(payTransactionId: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-charge-resolver/finalize-wallet-charge") else {
            print("❌ رابط API غير صالح")
            return
        }
        
        let payload: [String: Any] = [
            "pay_transaction_external_key": payTransactionId,
            "cora_transaction_id": transactionId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ فشل تحويل البيانات:", error.localizedDescription)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ فشل الاتصال بالسيرفر:", error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ استجابة غير صالحة")
                    return
                }
                
                if let data = data,
                   let responseBody = String(data: data, encoding: .utf8) {
                    print("📩 استجابة السيرفر: \(responseBody)")
                }
                
                if httpResponse.statusCode == 200 {
                    print("✅ تمت معالجة الدفع بنجاح في API Cora")
                } else {
                    print("⚠️ API استجاب بحالة: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}
