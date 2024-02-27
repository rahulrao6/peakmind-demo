//
//  Question.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

struct Question: Identifiable, Codable{
    var id: UUID = .init()
    var question: String
    var selectedNumber: Int
}
