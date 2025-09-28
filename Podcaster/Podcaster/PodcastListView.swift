//
//  PodcastListView.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
//

import SwiftUI
import SwiftData

struct PodcastListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var podcasts: [Podcast]

    @State private var showingAddPodcast = false
    @State private var newPodcastURL = ""

    @StateObject private var viewModel: PodcastListViewModel

    init() {
        _viewModel = StateObject(wrappedValue: PodcastListViewModel())
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(podcasts) { podcast in
                    NavigationLink {
                        PodcastView(podcast: podcast)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(podcast.name)
                            if !podcast.url.isEmpty {
                                Text(podcast.url)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
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
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .submitLabel(.done)

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

            viewModel.loadPodcast(from: urlString) { result in
                switch result {
                case .success(let podcast):
                    Task { @MainActor in
                        newPodcast.name = podcast.name
                        try? modelContext.save()
                    }
                case .failure(let error):
                    print(error)
                }
            }
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
    PodcastListView()
        .modelContainer(for: Podcast.self, inMemory: true)
}
