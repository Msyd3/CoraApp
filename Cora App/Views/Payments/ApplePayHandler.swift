//
//  ApplePayHandler.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/05/2025.
//

import Foundation
import PassKit
import MoyasarSdk

class ApplePayHandler: NSObject, ObservableObject, PKPaymentAuthorizationControllerDelegate {
    
    var controller: PKPaymentAuthorizationController?
    var applePayService: ApplePayService?
    var paymentRequest: PaymentRequest!
    private var transactionId: String = ""
    
    func present(amount: Double, transactionId: String) {
        self.transactionId = transactionId
        
        let items = [
            PKPaymentSummaryItem(label: "Cora", amount: NSDecimalNumber(value: amount), type: .final)
        ]
        
        let request = PKPaymentRequest()
        request.paymentSummaryItems = items
        request.merchantIdentifier = "merchant.Cora"
        request.countryCode = "SA"
        request.currencyCode = "SAR"
        request.supportedNetworks = [.mada, .visa, .masterCard]
        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
        
        controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller?.delegate = self
        
        do {
            paymentRequest = try PaymentRequest(
                apiKey: "pk_test_d4rEfyS8gi6Z5gcu3wPZr58aGpMkXKdY72xdpv7z",
                amount: Int(amount * 100),
                currency: "SAR",
                description: transactionId,
                metadata: [
                    "sdk": MetadataValue.stringValue("ios"),
                    "order_id": MetadataValue.stringValue(transactionId)
                ],
                manual: false,
                saveCard: false
            )
            applePayService = try ApplePayService(apiKey: "pk_test_d4rEfyS8gi6Z5gcu3wPZr58aGpMkXKdY72xdpv7z")
        } catch {
            print("❌ خطأ في إعداد الطلب:", error.localizedDescription)
        }
        
        controller?.present(completion: { success in
            print("✅ Apple Pay Presented: \(success ? "Yes" : "No")")
        })
    }
    
    // MARK: - Delegate Methods
    
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
      
        print("🔐 Apple Pay Token Info:")
        print("🔹 Payment Method Type: \(payment.token.paymentMethod.type.rawValue)")
        print("🔹 Display Name: \(payment.token.paymentMethod.displayName ?? "N/A")")
        print("🔹 Network: \(payment.token.paymentMethod.network?.rawValue ?? "N/A")")
        
        if let tokenString = String(data: payment.token.paymentData, encoding: .utf8) {
            print("🔹 Payment Data (JSON): \(tokenString)")
        } else {
            print("⚠️ فشل تحويل paymentData إلى JSON قابل للقراءة.")
        }

    
        Task {
            do {
                guard let applePayService = applePayService else {
                    print("❌ applePayService is nil")
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [DemoError.paymentError("Apple Pay Service غير مهيأ")]))
                    return
                }
                let result = try await applePayService.authorizePayment(request: paymentRequest, token: payment.token)
                handleCompletedPaymentResult(result, handler: completion)
            } catch {
                print("❌ Apple Pay Error:", error.localizedDescription)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            }
        }
    }

    
    func handleCompletedPaymentResult(_ apiPaymentResult: ApiPayment?, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        guard let result = apiPaymentResult else {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [DemoError.paymentError("No result")]))
            return
        }
        
        print("📦 Payment status: \(result.status), ID: \(result.id)")
        
        switch result.status {
        case .paid:
            finalizeCharge(
                payTransactionId: result.id,
                coraTransactionId: transactionId
            )
            completion(PKPaymentAuthorizationResult(status: .success, errors: []))
            
        case .failed:
            let message: String = if case let .applePay(source) = result.source {
                source.message ?? "unspecified"
            } else {
                "Returned source is not Apple Pay"
            }
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [DemoError.paymentError(message)]))
        default:
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [DemoError.paymentError("Unexpected status")]))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            print("💨 Apple Pay dismissed.")
        }
    }
    
    func finalizeCharge(payTransactionId: String, coraTransactionId: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/endUser/wallet-charge-resolver/finalize-wallet-charge") else {
            print("❌ رابط API غير صالح")
            return
        }
        
        let payload: [String: Any] = [
            "pay_transaction_external_key": payTransactionId,
            "cora_transaction_id": coraTransactionId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ خطأ في تحويل JSON:", error.localizedDescription)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ فشل الاتصال بالسيرفر:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ استجابة غير صالحة")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("✅ تمت معالجة الدفع بنجاح في API Cora")
            } else {
                print("⚠️ API استجاب بحالة: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

enum DemoError: LocalizedError {
    case paymentError(String)
    
    var errorDescription: String? {
        switch self {
        case .paymentError(let message):
            return message
        }
    }
}

