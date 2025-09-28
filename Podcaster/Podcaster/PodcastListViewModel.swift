//
//  PodcastListViewModel.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class PodcastListViewModel: ObservableObject {
    @Published var podcasts: [Podcast] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let context: ModelContext
    private let service: PodcastServiceProtocol

    init(context: ModelContext, service: PodcastServiceProtocol = PodcastService()) {
        self.context = context
        self.service = service
    }

    func refresh() {
        do {
            let descriptor = FetchDescriptor<Podcast>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            podcasts = try context.fetch(descriptor)
        } catch {
            self.error = error
        }
    }

    func addPodcast(urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard URL(string: trimmed) != nil else { return }

        withAnimation {
            let newPodcast = Podcast(url: trimmed, timestamp: Date())
            context.insert(newPodcast)
            do { try context.save() } catch { self.error = error }
            refresh()
        }

        loadPodcast(from: trimmed) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let details):
                if let idx = self.podcasts.firstIndex(where: { $0.url == trimmed }) {
                    let p = self.podcasts[idx]
                    p.name = details.name
                    do { try self.context.save() } catch { self.error = error }
                    self.refresh()
                }
            case .failure(let error):
                self.error = error
            }
        }
    }

    func deletePodcasts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(podcasts[index])
            }
            do { try context.save() } catch { self.error = error }
            refresh()
        }
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
