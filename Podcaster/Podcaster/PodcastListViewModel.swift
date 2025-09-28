//
//  PodcastListViewModel.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import SwiftUI
import Combine

@MainActor
final class PodcastListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?

    private let service: PodcastServiceProtocol

    init(service: PodcastServiceProtocol = PodcastService()) {
        self.service = service
    }

    func loadPodcast(from urlString: String, completion: @escaping (Result<Podcast, Error>) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        service.loadPodcastDetails(from: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let podcast):
                completion(.success(podcast))
            case .failure(let error):
                self.error = error
                completion(.failure(error))
            }
            self.isLoading = false
        }
    }
}
