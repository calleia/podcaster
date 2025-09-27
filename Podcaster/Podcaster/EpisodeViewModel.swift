//
//  EpisodeViewModel.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import SwiftUI
import Combine

@MainActor
final class EpisodeViewModel: ObservableObject {
    @Published var episode: Episode

    init(episode: Episode) {
        self.episode = episode
    }
}
