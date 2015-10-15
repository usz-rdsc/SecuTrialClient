//
//  SOAPEnvelope.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 15/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/**
A class to handle SOAP Envelopes and provides some goodies.
*/
public class SOAPEnvelope: SOAPNode {
	
	public internal(set) var header: SOAPNode?
	
	public internal(set) var body: SOAPNode?
	
	public var bodyContent: SOAPNode? {
		didSet {
			if let body = body {
				removeChild(body)
			}
			if let bc = bodyContent {
				let newBody = SOAPNode(name: "Body")
				newBody.namespace = namespace
				newBody.addChild(bc)
				addChild(newBody)
			}
		}
	}
	
	public init() {
		super.init(name: "Envelope")
		namespace = SOAPNamespace(name: "soapenv", url: "http://schemas.xmlsoap.org/soap/envelope/")
		namespaces = [
			SOAPNamespace(name: "soapenc", url: "http://schemas.xmlsoap.org/soap/encoding/"),
			SOAPNamespace(name: "xsi", url: "http://www.w3.org/2001/XMLSchema-instance"),
			SOAPNamespace(name: "xsd", url: "http://www.w3.org/2001/XMLSchema"),
		]
		attributes = [
			SOAPNodeAttribute(name: "soapenv:encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/"),
		]
	}
	
	public required init(name: String) {
		super.init(name: name)
	}
	
	override func addChild(child: SOAPNode, atIndex: Int? = nil) {
		if "Header" == child.name {
			header = child
		}
		if "Body" == child.name {
			body = child
		}
		super.addChild(child, atIndex: atIndex)
	}
	
	override func removeChild(child: SOAPNode) -> Int? {
		if header === child {
			header = nil
		}
		if body === child {
			body = nil
		}
		return super.removeChild(child)
	}
}


/**
Simple XML parser designed to parse SOAP request and response bodies, which have an "Envelope" node at their root.
*/
public class SOAPEnvelopeParser: NSObject, NSXMLParserDelegate {
	var rootNode: SOAPNode?
	
	var parsingNode: SOAPNode?
	
	var parsingNamespaces = [SOAPNamespace]()
	
	/**
	Starts parsing given data, throwing an error if the data does not represent valid XML.
	
	- parameter data: The data, presumed to be UTF-8 encoded XML data, that should be parsed
	- returns: The SOAPEnvelope node found at the root level of the XML document, if any
	- throws: An error when parsing fails
	*/
	public func parse(data: NSData) throws -> SOAPEnvelope? {
		let parser = NSXMLParser(data: data)
		parser.shouldProcessNamespaces = true
		parser.shouldReportNamespacePrefixes = true
		parser.delegate = self
		parser.parse()
		if let error = parser.parserError {
			throw error
		}
		return rootNode?.childNodes.first as? SOAPEnvelope
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
		let node = "Envelope" == elementName ? SOAPEnvelope(name: "Envelope") : SOAPNode(name: elementName)
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
			let textNode = SOAPTextNode.replace(otherNode: parsingNode!)
			textNode.text = string
		}
	}
	
	public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		parsingNode = parsingNode?.parent
	}
	
	public func parserDidEndDocument(parser: NSXMLParser) {
		assert(rootNode === parsingNode)
	}
}

