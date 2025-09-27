//
//  RSSParserDelegate.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 26/09/25.
//

import Foundation

final class RSSParserDelegate: NSObject, XMLParserDelegate {
    private(set) var channelTitle: String = ""
    private(set) var channelDescription: String = ""
    private(set) var channelImageURL: String = ""
    private(set) var channelAuthor: String = ""

    private var stack: [String] = []

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        stack.append(elementName)
        if elementName == "itunes:image" {
            channelImageURL = attributeDict["href"] ?? ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard stack.count > 1 else { return }
        guard stack[stack.count - 2] == "channel" else { return }
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
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        stack.removeLast()
    }
}
