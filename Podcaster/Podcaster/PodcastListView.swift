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

            loadRSSFeed(from: urlString) { result in
                switch result {
                case .success(let title):
                    Task { @MainActor in
                        newPodcast.name = title
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

extension PodcastListView {
    enum RSSError: Error { case invalidURL, badStatus, noData, parseFailed }

    func loadRSSFeed(from urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(.failure(RSSError.invalidURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/rss+xml", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(RSSError.badStatus))
            }
            guard let data = data else {
                return completion(.failure(RSSError.noData))
            }

            // Response XML string
            //print(String(data: data, encoding: .utf8))

            DispatchQueue.global(qos: .userInitiated).async {
                let parser = XMLParser(data: data)
                let rssParserDelegate = RSSParserDelegate()
                parser.delegate = rssParserDelegate

                if parser.parse() {
                    completion(.success(rssParserDelegate.channelTitle))
                } else {
                    completion(.failure(RSSError.parseFailed))
                }
            }
        }

        task.resume()
    }
}
