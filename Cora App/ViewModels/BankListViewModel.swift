//
//  BankListViewModel.swift
//  Cora
//
//  Created by Mohammed Alsayed on 15/04/2025.
//

import Foundation

class BankListViewModel: ObservableObject {
    @Published var banks: [Bank] = [
        Bank(name: "بنك الراجحي", logo: "alRajhi", code: "RAJHI"),
        Bank(name: "مصرف الانماء", logo: "Alinma", code: "INMA"),
        Bank(name: "بنك البلاد", logo: "ALBILAD", code: "BILAD"),
        Bank(name: "بنك الاول", logo: "SABB", code: "SAB"),
        Bank(name: "البنك السعودي الفرنسي", logo: "BSF", code: "BSF"),
        Bank(name: "البنك العربي الوطني", logo: "anb", code: "ANB"),
        Bank(name: "البنك الأهلي السعودي", logo: "SNB", code: "NCB"),
        Bank(name: "البنك السعودي للاستثمار", logo: "SAIB", code: "SAIB"),
        Bank(name: "بنك الجزيرة", logo: "ALJAZIRA", code: "BJAZ")
    ]
}
