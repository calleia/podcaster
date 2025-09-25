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

    @State private var showingAddPodcast = false
    @State private var newPodcastURL = ""

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(podcasts) { podcast in
                    NavigationLink {
                        Text("Podcast at \(podcast.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(podcast.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            Text(podcast.url)
                        }
                    }
                }
                .onDelete(perform: deletePodcasts)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingAddPodcast = true
                    } label: {
                        Label("Add Podcast", systemImage: "plus")
                    }
                }
            }
            .alert("Add Podcast", isPresented: $showingAddPodcast) {
                TextField("", text: $newPodcastURL)

                Button("Cancel", role: .cancel) {
                    newPodcastURL = ""
                }

                Button("Add") {
                    addPodcast(urlString: newPodcastURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    newPodcastURL = ""
                }
            } message: {
                Text("Enter the URL of an RSS feed.")
            }
        } detail: {
            Text("Select a podcast")
        }
    }

    private func addPodcast(urlString: String) {
        withAnimation {
            // TODO: make sure the string is a valid URL
            let newPodcast = Podcast(url: urlString, timestamp: Date())
            modelContext.insert(newPodcast)
            // TODO: load RSS feed from the received URL
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
