//
//  PodcastService.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 27/09/25.
//

import Foundation

protocol PodcastServiceProtocol {
    func loadPodcastDetails(from urlString: String, completion: @escaping (Result<Podcast, Error>) -> Void)
}

struct PodcastService: PodcastServiceProtocol {
    enum PodcastServiceError: Error { case invalidURL, badStatus, noData, parseFailed }

    func loadPodcastDetails(from urlString: String, completion: @escaping (Result<Podcast, any Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            return completion(.failure(PodcastServiceError.invalidURL))
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
                return completion(.failure(PodcastServiceError.badStatus))
            }
            guard let data = data else {
                return completion(.failure(PodcastServiceError.noData))
            }

            // Response XML string
            //print(String(data: data, encoding: .utf8))

            DispatchQueue.global(qos: .userInitiated).async {
                let parser = XMLParser(data: data)
                let rssParserDelegate = RSSParserDelegate()
                parser.delegate = rssParserDelegate

                if parser.parse() {
                    let podcast = Podcast(
                        url: urlString,
                        name: rssParserDelegate.channelTitle,
                        desc: rssParserDelegate.channelDescription,
                        imageURL: rssParserDelegate.channelImageURL,
                        author: rssParserDelegate.channelAuthor,
                        categories: rssParserDelegate.channelCategories
                    )
                    completion(.success(podcast))
                } else {
                    completion(.failure(PodcastServiceError.parseFailed))
                }
            }
        }

        task.resume()
    }
}
