//
//  NotificationView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 08/04/2025.
//

import SwiftUI

struct NotificationView: View {
    @ObservedObject var manager = NotificationManager.shared
    
    var body: some View {
        ScrollView {
            
            Text("الإشعارات")
                .customFont(size: 24, weight: "Rubik-Bold")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 40)

            if manager.notifications.isEmpty {
                Text("لا توجد إشعارات حالياً")
                    .customFont(size: 18, weight: "Rubik-Bold")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
            } else {
                VStack(spacing: 16) {
                    ForEach(manager.notifications) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.title)
                                .customFont(size: 18, weight: "Rubik-Bold")
                                .foregroundColor(Color("Bur"))
                            
                            Text(notification.message)
                                .customFont(size: 12, weight: "Rubik-Medium")
                                .foregroundColor(.gray)
                            
                            Text(notification.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        

        .navigationTitle("الإشعارات")
        .onAppear {
            if manager.notifications.isEmpty {
                manager.addNotification(title: "مرحباً بك 👋", message: "هذا مثال على إشعار داخل التطبيق.")
            }
        }
    }
}

#Preview {
    NotificationPreviewWrapper()
}

struct NotificationPreviewWrapper: View {
    @StateObject private var mockManager = NotificationManager.shared
    
    var body: some View {
        NotificationView()
            .onAppear {
                mockManager.notifications = [
                    CoraNotification(title: "مرحباً بك", message: "هذا إشعار تجريبي ١"),
                    CoraNotification(title: "طلب جديد", message: "تم إرسال طلبك بنجاح"),
                    CoraNotification(title: "تنبيه", message: "لا تنسَ تحديث بياناتك")
                ]
            }
    }
}
