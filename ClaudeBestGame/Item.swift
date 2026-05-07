//
//  Item.swift
//  ClaudeBestGame
//
//  Created by chang chiawei on 2026/05/07.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
