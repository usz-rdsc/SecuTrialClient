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
public class SOAPParser: NSObject, NSXMLParserDelegate {
	var rootNode: SOAPNode?
	
	var parsingNode: SOAPNode?
	
	var parsingNamespaces = [SOAPNamespace]()
	
	var customError: ErrorType?
	
	/// Optional block to call when an element finishes parsing; receives the node that has just finished, if returning a different node
	/// will insert the returned node in place of the original node.
	public var onEndElement: ((element: SOAPNode) throws -> SOAPNode?)?
	
	/**
	Starts parsing given data, throwing an error if the data does not represent valid XML.
	
	- parameter data: The data, presumed to be UTF-8 encoded XML data, that should be parsed
	- returns: The SOAPEnvelope node found at the root level of the XML document, if any
	- throws: A SOAPError when parsing fails
	*/
	public func parse(data: NSData) throws -> SOAPNode {
		let parser = NSXMLParser(data: data)
		parser.shouldProcessNamespaces = true
		parser.shouldReportNamespacePrefixes = true
		parser.delegate = self
		parser.parse()
		if let error = parser.parserError {
			if let raw = NSString(data: data, encoding: NSUTF8StringEncoding) {
				if NSXMLParserErrorDomain == error.domain && 111 == error.code {		// CharacterRefInPrologError
					throw SOAPError.Error(raw as String)
				}
			}
			if let custom = customError {
				throw custom
			}
			throw SOAPError.Error(error.localizedDescription)
		}
		if let root = rootNode?.childNodes.first {
			return root
		}
		throw SOAPError.RootNotFound
	}
	
	
	// MARK: - NSXMLParser Delegate Methods
	
	public func parserDidStartDocument(parser: NSXMLParser) {
		rootNode = SOAPNode(name: "root")
		parsingNamespaces.removeAll()
		parsingNode = rootNode
	}
	
	public func parser(parser: NSXMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
		let ns = SOAPNamespace(name: prefix, url: namespaceURI)
		parsingNamespaces.append(ns)
	}
	
	public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
	
	public func parser(parser: NSXMLParser, foundCharacters string: String) {
		let stripped = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		if !stripped.isEmpty {
			if let textNode = parsingNode as? SOAPTextNode, let existing = textNode.text {		// we only create text nodes when we have a non-empty string, so there should always be text in a text node
				textNode.text = existing + string
			}
			else {
				let textNode = SOAPTextNode.replace(parsingNode!)
				textNode.text = string
				parsingNode = textNode
			}
		}
	}
	
	public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if let onEndElement = onEndElement, let parsing = parsingNode {
			do {
				if let ret = try onEndElement(element: parsing) {
					ret.replace(parsing)
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
	
	public func parserDidEndDocument(parser: NSXMLParser) {
		assert(rootNode === parsingNode)
	}
}
