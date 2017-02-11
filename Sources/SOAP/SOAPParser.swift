//
//  SOAPParser.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/**
Simple XML parser.
*/
open class SOAPParser: NSObject, XMLParserDelegate {
	
	var rootNode: SOAPNode?
	
	var parsingNode: SOAPNode?
	
	var parsingNamespaces = [SOAPNamespace]()
	
	var customError: Error?
	
	/// Optional block to call when an element finishes parsing; receives the node that has just finished, if returning a different node
	/// will insert the returned node in place of the original node.
	open var onEndElement: ((_ element: SOAPNode) throws -> SOAPNode?)?
	
	/**
	Starts parsing given data, throwing an error if the data does not represent valid XML.
	
	- parameter data: The data, presumed to be UTF-8 encoded XML data, that should be parsed
	- returns: The SOAPEnvelope node found at the root level of the XML document, if any
	- throws: A SOAPError when parsing fails
	*/
	open func parse(_ data: Data) throws -> SOAPNode {
		let parser = XMLParser(data: data)
		parser.shouldProcessNamespaces = true
		parser.shouldReportNamespacePrefixes = true
		parser.delegate = self
		parser.parse()
		if let error = parser.parserError {
			if let raw = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
				if XMLParser.errorDomain == error._domain && 111 == error._code {		// CharacterRefInPrologError
					throw SOAPError.error(raw as String)
				}
			}
			if let custom = customError {
				throw custom
			}
			throw SOAPError.error(error.localizedDescription)
		}
		if let root = rootNode?.childNodes.first {
			return root
		}
		throw SOAPError.rootNotFound
	}
	
	
	// MARK: - NSXMLParser Delegate Methods
	
	open func parserDidStartDocument(_ parser: XMLParser) {
		rootNode = SOAPNode(name: "root")
		parsingNamespaces.removeAll()
		parsingNode = rootNode
	}
	
	open func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
		let ns = SOAPNamespace(name: prefix, url: namespaceURI)
		parsingNamespaces.append(ns)
	}
	
	open func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		let node = SOAPNode(name: elementName)
		parsingNode?.addChild(node)
		parsingNode = node
		
		if !parsingNamespaces.isEmpty {
			node.namespaces = parsingNamespaces
			parsingNamespaces.removeAll()
		}
		if let nsURI = namespaceURI {
			node.namespace = node.namespaceWithURI(nsURI)
		}
		for (key, val) in attributeDict {
			let attr = SOAPNodeAttribute(name: key, value: val)
			node.attributes.append(attr)
		}
	}
	
	open func parser(_ parser: XMLParser, foundCharacters string: String) {
		let stripped = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		if !stripped.isEmpty {
			if let textNode = parsingNode as? SOAPTextNode, let existing = textNode.text {		// we only create text nodes when we have a non-empty string, so there should always be text in a text node
				textNode.text = existing + string
			}
			else {
				let textNode = SOAPTextNode.replace(with: parsingNode!)
				textNode.text = string
				parsingNode = textNode
			}
		}
	}
	
	open func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if let onEndElement = onEndElement, let parsing = parsingNode {
			do {
				if let ret = try onEndElement(parsing) {
					ret.replace(with: parsing)
					parsingNode = ret
				}
			}
			catch let error {
				customError = error
				parser.abortParsing()
			}
		}
		parsingNode = parsingNode?.parent
	}
	
	open func parserDidEndDocument(_ parser: XMLParser) {
		assert(rootNode === parsingNode)
	}
}

