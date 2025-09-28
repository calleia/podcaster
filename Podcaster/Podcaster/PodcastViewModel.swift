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
    @Published var podcast: Podcast
    @Published var isLoading = false
    @Published var error: Error?

    private let service: PodcastServiceProtocol

    init(podcast: Podcast, service: PodcastServiceProtocol = PodcastService()) {
        self.podcast = podcast
        self.service = service
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        service.loadPodcastDetails(from: podcast.url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let podcast):
                self.podcast = podcast
            case .failure(let error):
                self.error = error
            }
            self.isLoading = false
        }
    }
}
