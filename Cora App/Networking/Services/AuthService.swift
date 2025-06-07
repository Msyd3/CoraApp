import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func registerUser(user: User, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/resiger-end-user") else {
            print("❌ خطأ: رابط API غير صالح")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "رابط API غير صالح"])))
            return
        }
        
        let parameters: [String: Any] = [
            "full_name": user.name,
            "phone_number": user.phone,
            "otpCode": user.otpCode,
            "password": user.passkey,
            "is_on_waiting_list": true
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            request.timeoutInterval = 30
            
            print("📡 إرسال طلب تسجيل إلى: \(url)")
            print("📤 البيانات المرسلة (JSON): \(parameters)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ خطأ في الطلب: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ لم يتم استلام استجابة صحيحة من السيرفر.")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "استجابة غير صالحة من السيرفر."])))
                    return
                }
                
                print("📩 كود الاستجابة: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📩 استجابة السيرفر: \(responseString)")
                }
                
                if httpResponse.statusCode == 400 {
                    print("❌ OTP غير صحيح أو الرقم موجود مسبقًا")
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "OTP غير صحيح أو الرقم موجود مسبقًا"])))
                    return
                }
                
                if httpResponse.statusCode == 200, let data = data {
                    do {
                        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("✅ استجابة التسجيل: \(responseJSON)")
                            
                            DispatchQueue.main.async {
                                if let authToken = responseJSON["auth_token"] as? String {
                                    UserDefaults.standard.set(authToken, forKey: "auth_token")
                                }
                                if let accountOrder = responseJSON["account_order"] as? String {
                                    UserDefaults.standard.set(accountOrder, forKey: "account_order")
                                }
                                UserDefaults.standard.synchronize()
                                
                                completion(.success(true))
                            }
                        } else {
                            print("❌ تنسيق الاستجابة غير صحيح")
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "تنسيق الاستجابة غير صحيح"])))
                        }
                    } catch {
                        print("❌ خطأ في تحليل JSON: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else {
                    print("⚠️ السيرفر لم يُرجع استجابة صالحة أو كود غير متوقع!")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "خطأ غير متوقع من السيرفر"])))
                }
            }.resume()
        } catch {
            print("❌ خطأ في إنشاء JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func signInUser(phone: String, passkey: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/sign-in-end-user") else {
            print("❌ خطأ: رابط API غير صالح")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "رابط API غير صالح"])))
            return
        }
        
        let parameters: [String: Any] = [
            "phone_number": phone,
            "password": passkey
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            request.timeoutInterval = 30
            
            print("📡 إرسال طلب تسجيل دخول إلى: \(url)")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 البيانات المرسلة (JSON): \(jsonString)")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ خطأ في الطلب: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ لم يتم استلام استجابة صحيحة من السيرفر.")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "استجابة غير صالحة من السيرفر."])))
                        return
                    }
                    
                    print("📩 كود الاستجابة: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 404 {
                        print("❌ خطأ: المسار غير موجود، تحقق من الـ Endpoint في السيرفر")
                        completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "المسار غير موجود"])))
                        return
                    }
                    
                    guard let responseData = data, !responseData.isEmpty else {
                        print("⚠️ الاستجابة فارغة!")
                        completion(.failure(NSError(domain: "", code: 204, userInfo: [NSLocalizedDescriptionKey: "لا يوجد بيانات في الاستجابة"])))
                        return
                    }
                    
                    do {
                        if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                            print("✅ تسجيل الدخول ناجح: \(responseJSON)")
                            
                            
                            if let fullName = responseJSON["full_name"] as? String {
                                print("✅ الاسم:", fullName)
                                UserDefaults.standard.set(fullName, forKey: "full_name")
                            }
                            
                            if let authToken = responseJSON["auth_token"] as? String {
                                UserDefaults.standard.set(authToken, forKey: "auth_token")
                            } else {
                                print("❌ لم يتم العثور على auth_token في الاستجابة")
                                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "لم يتم العثور على `auth_token`"])))
                                return
                            }
                            
                            if let accountOrder = responseJSON["account_order"] as? Int,
                               let totalAccountCount = responseJSON["total_account_count"] as? Int {
                                UserDefaults.standard.set(accountOrder, forKey: "account_order")
                                UserDefaults.standard.set(totalAccountCount, forKey: "total_account_count")
                            }
                            print("✅ رقم الهاتف:", phone)
                            if let phoneValue = responseJSON["phone_number"] as? String {
                                UserDefaults.standard.set(phoneValue, forKey: "phone_number")
                            }
                            UserDefaults.standard.set(passkey, forKey: "passkey")
                            UserDefaults.standard.synchronize()
                            
                            completion(.success(true))
                        } else {
                            print("❌ البيانات المستلمة غير بتنسيق JSON صحيح.")
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "تنسيق البيانات غير صحيح"])))
                        }
                    } catch {
                        print("❌ خطأ في تحليل JSON: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }.resume()
        } catch {
            print("❌ خطأ في إنشاء JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    
    
    func sendOTP(phone: String, otpType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/send-otp") else {
            print("❌ رابط API غير صالح")
            return
        }
        
        let body: [String: Any] = [
            "phoneNumber": phone,
            "otpType": otpType,
            "amount": 0
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 البيانات المرسلة (JSON): \(jsonString)")
            }
            
        } catch {
            print("❌ فشل في تحويل البيانات:", error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ فشل الاتصال:", error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ استجابة غير صالحة")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("✅ OTP تم إرساله بنجاح!")
                    completion(.success(()))
                } else {
                    let message = String(data: data ?? Data(), encoding: .utf8) ?? "خطأ غير معروف"
                    print("⚠️ فشل إرسال OTP. الحالة: \(httpResponse.statusCode) - \(message)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            }
        }.resume()
    }
    
    
    func verifyPhoneNumber(phone: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/verify-phone-number-register") else {
            print("❌ خطأ: رابط API غير صالح")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "رابط API غير صالح"])))
            return
        }
        
        let parameters: [String: Any] = [
            "phoneNumber": phone
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 30
            
            print("📡 إرسال طلب التحقق من رقم الهاتف إلى: \(url)")
            print("📤 البيانات المرسلة (JSON): \(parameters)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ خطأ في الطلب: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("⚠️ لا يوجد استجابة من السيرفر!")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "استجابة غير صالحة من السيرفر"])))
                        return
                    }
                    
                    print("📩 كود الاستجابة: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        print("✅ رقم الهاتف متاح!")
                        completion(.success(true))
                    } else if httpResponse.statusCode == 400 {
                        print("❌ رقم الهاتف مسجل مسبقًا!")
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "رقم الهاتف مسجل مسبقًا!"])))
                    } else {
                        print("❌ خطأ غير متوقع: \(httpResponse.statusCode)")
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "خطأ غير متوقع"])))
                    }
                }
            }.resume()
        } catch {
            print("❌ خطأ في إنشاء JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    
    
    func verifyOTP(phone: String, otpCode: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/authentication/verify-phone-number-register") else {
            print("❌ خطأ: رابط API غير صالح")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "رابط API غير صالح"])))
            return
        }
        
        let parameters: [String: Any] = [
            "phoneNumber": phone,
            "otpCode": otpCode
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 30
            
            print("📡 إرسال طلب التحقق من OTP إلى: \(url)")
            print("📤 البيانات المرسلة (JSON): \(parameters)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ خطأ في الطلب: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("⚠️ لا يوجد استجابة من السيرفر!")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "استجابة غير صالحة من السيرفر"])))
                        return
                    }
                    
                    print("📩 كود الاستجابة: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        print("✅ OTP صحيح!")
                        completion(.success(true))
                    } else {
                        print("❌ OTP غير صحيح!")
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "OTP غير صحيح!"])))
                    }
                }
            }.resume()
        } catch {
            print("❌ خطأ في إنشاء JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
