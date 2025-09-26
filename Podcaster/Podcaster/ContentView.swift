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
        loadRSSFeed(from: urlString)
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

extension ContentView {
    func loadRSSFeed(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/rss+xml", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("CLIENT ERROR: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("SERVER ERROR: \(response.debugDescription)")
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }

            // Response XML string
            print(String(data: data, encoding: .utf8))

            // TODO: parse XML
        }

        task.resume()
    }
}
