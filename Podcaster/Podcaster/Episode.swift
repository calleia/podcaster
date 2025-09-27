//
//  Episode.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import Foundation
import SwiftData

@Model
final class Episode {
    var title: String
    var duration: String

    // Enclosure tag attributes
    var url: String
    var type: String
    var length: Int

    init(title: String,
         duration: String,
         url: String,
         type: String,
         length: Int) {
        self.title = title
        self.duration = duration
        self.url = url
        self.type = type
        self.length = length
    }
}
