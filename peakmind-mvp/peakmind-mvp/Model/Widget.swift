
//
//  Widget.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 4/24/24.
//

import Foundation

import SwiftUI


struct Widget: Identifiable, Codable{
    var id: UUID = .init()
    var name: String
    var title: String
}
