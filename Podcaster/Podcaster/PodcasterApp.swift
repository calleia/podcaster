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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Podcast.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
