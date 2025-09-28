//
//  EpisodeViewModel.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
final class EpisodeViewModel: ObservableObject {
    @Published var episode: Episode

    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    var canPlay: Bool { player != nil }

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: Any?

    init(episode: Episode) {
        self.episode = episode

        guard let url = URL(string: episode.url) else {
            return
        }

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player

        // Update time & (once known) duration
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self, let item = player.currentItem else { return }
            self.currentTime = time.seconds.isFinite ? time.seconds : 0
            let dur = item.duration.seconds
            if dur.isFinite { self.duration = dur }
        }

        // Reset at end
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isPlaying = false
            self.seek(to: 0)
        }
    }

    deinit {
        if let obs = timeObserver { player?.removeTimeObserver(obs) }
        if let endObs = endObserver { NotificationCenter.default.removeObserver(endObs) }
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func play() {
        guard let player else { return }
        isPlaying = true
        player.play()
    }

    func pause() {
        isPlaying = false
        player?.pause()
    }

    func seek(to seconds: Double) {
        guard let player else { return }
        let t = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: t, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func formatted(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "--:--" }
        let total = Int(seconds.rounded())
        let s = total % 60
        let m = (total / 60) % 60
        let h = total / 3600
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
}
