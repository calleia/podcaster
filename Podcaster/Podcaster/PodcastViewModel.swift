//
//  PodcastViewModel.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 26/09/25.
//

import SwiftUI
import Combine

@MainActor
final class PodcastViewModel: ObservableObject {
    let podcast: Podcast

    init(podcast: Podcast) {
        self.podcast = podcast
    }
}
