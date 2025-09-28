//
//  PodcastListView.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 25/09/25.
//

import SwiftUI
import SwiftData

struct PodcastListView: View {
    @State private var showingAddPodcast = false
    @State private var newPodcastURL = ""

    @StateObject private var viewModel: PodcastListViewModel

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: PodcastListViewModel(context: context))
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.podcasts) { podcast in
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
                .onDelete(perform: viewModel.deletePodcasts)
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
                    viewModel.addPodcast(urlString: newPodcastURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    newPodcastURL = ""
                }
            } message: {
                Text("Enter the URL of an RSS feed.")
            }
        } detail: {
            Text("Select a podcast")
        }
        .onAppear() { viewModel.refresh() }
    }
}

#Preview {
//    PodcastListView(context: modelContext)
//        .modelContainer(for: Podcast.self, inMemory: true)
}
