//
//  Info.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 2/26/24.
//

import SwiftUI

// MARK: Quiz Info Codable Model
struct Info: Codable{
    var title: String
    var peopleAttended: Int
    var rules: [String]
    
    enum CodingKeys: CodingKey {
        case title
        case peopleAttended
        case rules
    }
}
