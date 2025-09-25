//
//  ContentView.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var podcasts: [Podcast]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(podcasts) { podcast in
                    NavigationLink {
                        Text("Podcast at \(podcast.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(podcast.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deletePodcasts)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addPodcast) {
                        Label("Add Podcast", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a podcast")
        }
    }

    private func addPodcast() {
        withAnimation {
            // TODO: add Podcast's RSS feed URL string
            let newPodcast = Podcast(url: "", timestamp: Date())
            modelContext.insert(newPodcast)
        }
    }

    private func deletePodcasts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(podcasts[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Podcast.self, inMemory: true)
}
