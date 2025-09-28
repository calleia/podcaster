//
//  PodcasterApp.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
//

import SwiftUI
import SwiftData

@main
struct PodcasterApp: App {
    let modelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            PodcastListView(context: modelContainer.mainContext)
        }
    }

    init() {
        do {
            modelContainer = try ModelContainer(for: Podcast.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
