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

    private var placeholder: some View {
        ZStack {
            Rectangle().fill(Color.secondary.opacity(0.1))
            Image(systemName: "mic.fill")
                .imageScale(.large)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
        }
        .scaledToFit()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Artwork
                Group {
                    if let url = URL(string: viewModel.podcast.imageURL) {
                        // iOS 15+
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                placeholder
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                    } else {
                        placeholder
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 0.5)
                )
                .accessibilityLabel(Text("\(viewModel.podcast.name) artwork"))

                // Title
                Text(viewModel.podcast.name)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                // Description
                if !viewModel.podcast.desc.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(viewModel.podcast.desc)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }

                // Authors
                Text(viewModel.podcast.author)
                    .font(.subheadline)

                // Genre
                Text(viewModel.podcast.categories.joined(separator: " | "))
                    .font(.subheadline)

                // Episodes
                Divider()

                Text("Episodes")
                    .font(.title)

                ForEach(viewModel.podcast.episodes) { episode in
                    NavigationLink {
                        Text(episode.title)
                    } label: {
                        HStack(alignment: .center, spacing: 4) {
                            Text(episode.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            if !episode.duration.isEmpty {
                                Spacer()
                                Text("\(episode.duration)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
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
