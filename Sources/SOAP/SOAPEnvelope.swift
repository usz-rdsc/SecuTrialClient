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
open class SOAPEnvelope: SOAPNode {
	
	open internal(set) var header: SOAPNode?
	
	open internal(set) var body: SOAPNode?
	
	open var bodyContent: SOAPNode? {
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
	
	open override func addChild(_ child: SOAPNode, atIndex: Int? = nil) {
		if "Header" == child.name {
			header = child
		}
		if "Body" == child.name {
			body = child
		}
		super.addChild(child, atIndex: atIndex)
	}
	
	@discardableResult
	open override func removeChild(_ child: SOAPNode) -> Int? {
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
open class SOAPEnvelopeParser: SOAPParser {
	
	/**
	Starts parsing given data, throwing an error if the data is not valid XML and the root node is not an "Envelope".
	
	- parameter data: The data, presumed to be UTF-8 encoded XML data, that should be parsed
	- returns: The SOAPEnvelope node found at the root level of the XML document, if any
	- throws: SOAPError when parsing fails
	*/
	open override func parse(_ data: Data) throws -> SOAPEnvelope {
		let root = try super.parse(data)
		if "Envelope" == root.name {
			return SOAPEnvelope.replace(with: root)
		}
		throw SOAPError.envelopeNotFound
	}
}

