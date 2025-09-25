//
//  Item.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
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
