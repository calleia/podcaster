//
//  RSSParserDelegate.swift
//  Podcaster
//
//  Created by Fellipe Calleia on 26/09/25.
//

import Foundation

final class RSSParserDelegate: NSObject, XMLParserDelegate {
    private(set) var title: String = ""

    private var stack: [String] = []

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        stack.append(elementName)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard stack.count > 1 else { return }
        guard stack[stack.count - 1] == "title" else { return }
        guard stack[stack.count - 2] == "channel" else { return }
        title.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        stack.removeLast()
    }
}
