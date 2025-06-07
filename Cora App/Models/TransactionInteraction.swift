//
//  TransactionInteraction.swift
//  Cora
//
//  Created by Mohammed Alsayed on 02/05/2025.
//

import SwiftUI

struct TransactionInteraction: Identifiable {
    var id = UUID()
    var log: ShareLog
    var likes: Int
    var comments: [String]
    var showComments = false
    var newComment = ""
}
