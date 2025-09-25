//
//  Podcast.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
//

import Foundation
import SwiftData

@Model
final class Podcast {
    var url: String
    var timestamp: Date

    init(url: String, timestamp: Date) {
        self.url = url
        self.timestamp = timestamp
    }
}
