//
//  AccountPermissionView.swift
//  Cora
//
//  Created by Mohammed Alsayed on 16/04/2025.
//

import SwiftUI

struct AccountPermissionView: View {
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer(minLength: 40)
            
            Image("cora-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text("اربط حسابك")
                .customFont(size: 20, weight: "Rubik-Bold")
            
            Text("الخدمة التالية تتطلب مشاركة معلوماتك")
                .customFont(size: 16, weight: "Rubik-SemiBold")
            
            Text("شركة كورا لتقنية المعلومات تساعدك على تحليل صرفياتك والقيام بمدفوعاتك ومعرفة احتياجاتك المالية. لذا، نطلب الوصول الى هذه البيانات")
                .customFont(size: 14, weight: "Rubik-Regular")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                permissionRow("المعلومات الشخصية")
                permissionRow("بيانات حساباتك وبطاقاتك")
                permissionRow("تفاصيل وبيانات الحساب")
                permissionRow("تفاصيل عملياتك البنكية")
            }
            .padding(.top, 20)
            
            Spacer()
            
            Button(action: {
                onConfirm()
            }) {
                Text("تأكيد ومتابعة")
                    .customFont(size: 16, weight: "Rubik-Bold")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Bur"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            Text("سيتم جلب بياناتك من تاريخ 2023/4/17")
                .customFont(size: 10, weight: "Rubik-Regular")
                .multilineTextAlignment(.center)
            Spacer(minLength: 40)
        }
        .padding()
        .environment(\.layoutDirection, .leftToRight)
    }
    
    func permissionRow(_ title: String) -> some View {
        HStack {
            Image(systemName: "checkmark")
                .foregroundColor(Color("Bur"))
            Text(title)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .customFont(size: 16, weight: "Rubik-Regular")
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


#Preview {
    AccountPermissionView {
        print("تم التأكيد")
    }
}
