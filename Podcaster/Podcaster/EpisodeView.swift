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
