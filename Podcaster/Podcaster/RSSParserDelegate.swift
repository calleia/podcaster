//
//  RSSParserDelegate.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 26/09/25.
//

import Foundation

final class RSSParserDelegate: NSObject, XMLParserDelegate {
    // Podcast information
    private(set) var channelTitle: String = ""
    private(set) var channelDescription: String = ""
    private(set) var channelImageURL: String = ""
    private(set) var channelAuthor: String = ""
    private(set) var channelCategories: [String] = []
    private(set) var channelEpisodes: [Episode] = []

    // Episode information
    private var episodeTitle: String = ""
    private var episodeDuration: String = ""
    private var episodeURL: String = ""
    private var episodeType: String = ""
    private var episodeLength: Int = 0

    private var isCapturingItem: Bool = false

    private var stack: [String] = []

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        stack.append(elementName)
        if elementName == "itunes:image" {
            channelImageURL = attributeDict["href"] ?? ""
        } else if elementName == "itunes:category" {
            // TODO: improve handling of subcategories
            if stack.count > 1, stack[stack.count - 2] == "itunes:category" {
                channelCategories.removeLast()
            }

            guard let category = attributeDict["text"] else { return }
            channelCategories.append(category)
        } else if elementName == "item" {
            isCapturingItem = true
            resetEpisode()
        } else if elementName == "enclosure" {
            guard isCapturingItem else { return }
            if let url = attributeDict["url"] {
                episodeURL = url
            }
            if let type = attributeDict["type"] {
                episodeType = type
            }
            if let lengthString = attributeDict["length"], let length = Int(lengthString) {
                episodeLength = length
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard stack.count > 1 else { return }
        if stack[stack.count - 2] == "channel" {
            switch stack.last! {
            case "title":
                channelTitle.append(string)
            case "description":
                channelDescription.append(string)
            case "itunes:image":
                channelImageURL.append(string)
            case "itunes:author":
                channelAuthor.append(string)
            default:
                break
            }
        } else if stack[stack.count - 2] == "item" {
            guard isCapturingItem else { return }
            switch stack.last! {
            case "title":
                episodeTitle.append(string)
            case "itunes:duration":
                episodeDuration.append(string)
            default:
                break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        stack.removeLast()
        if elementName == "item" {
            isCapturingItem = false
            addEpisode()
        }
    }
}

extension RSSParserDelegate {
    private func addEpisode() {
        guard let episodeDuration = Int(episodeDuration) else { return }
        let episode = Episode(
            title: episodeTitle,
            duration: episodeDuration,
            url: episodeURL,
            type: episodeType,
            length: episodeLength
        )
        channelEpisodes.append(episode)
    }

    private func resetEpisode() {
        episodeTitle = ""
        episodeDuration = ""
        episodeURL = ""
        episodeType = ""
        episodeLength = 0
    }
}
