//
//  EpisodeView.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import SwiftUI

struct EpisodeView: View {
    @StateObject private var viewModel: EpisodeViewModel

    init(episode: Episode) {
        _viewModel = StateObject(wrappedValue: EpisodeViewModel(episode: episode))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.episode.title)
                .font(.headline)

            Text("Duration: \(viewModel.episode.duration)")
            Text("Type: \(viewModel.episode.type)")
            Text("Length: \(viewModel.episode.length)")

            // Player
            if viewModel.canPlay {
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { viewModel.currentTime },
                            set: { viewModel.seek(to: $0) }
                        ),
                        in: 0...(viewModel.duration > 0 ? viewModel.duration : max(viewModel.currentTime, 1))
                    )

                    HStack {
                        Text(viewModel.formatted(viewModel.currentTime))
                        Spacer()
                        Text(viewModel.formatted(viewModel.duration))
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                    Button {
                        viewModel.togglePlayPause()
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
            } else {
                Text("Audio unavailable (invalid URL)")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    let episode = Episode(
        title: "Episode Title",
        duration: "42m42s",
        url: "Episode URL",
        type: "Episode Type",
        length: 42
    )
    EpisodeView(episode: episode)
}
