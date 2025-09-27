//
//  PodcastView.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 26/09/25.
//

import SwiftUI

struct PodcastView: View {
    @StateObject private var viewModel: PodcastViewModel

    init(podcast: Podcast) {
        _viewModel = StateObject(wrappedValue: PodcastViewModel(podcast: podcast))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(viewModel.podcast.name)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            .padding()
        }
        .task(id: viewModel.podcast.url) { viewModel.load() }
        .refreshable { viewModel.load() }
    }
}

#Preview {
    let podcast = Podcast(
        url: "https://podcast.domain/rss",
        timestamp: Date(),
        name: "Podcast Name"
    )
    PodcastView(podcast: podcast)
}
