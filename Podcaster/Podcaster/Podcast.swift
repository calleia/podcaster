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
    var name: String
    var url: String
    var timestamp: Date
    var desc: String

    init(url: String,
         timestamp: Date = Date(),
         name: String = "",
         desc: String = "") {
        self.name = name
        self.url = url
        self.timestamp = timestamp
        self.desc = desc
    }
}
