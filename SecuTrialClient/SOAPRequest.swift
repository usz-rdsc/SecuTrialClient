//
//  SOAPRequest.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/**
This is an INCREDIBLY FAKE implementation of a real SOAP request.
*/
public class SOAPRequest
{
	public var namespaces: [String: String]?
	
	let envelope = SOAPEnvelope()
	
	var header: SOAPNode?
	
	var body: SOAPNode?
	
	public var bodyContent: SOAPNode? {
		didSet {
			if let bc = bodyContent {
				let nodeName = (nil != envelope.namespace) ? "\(envelope.namespace!.name):Body" : "Body"
				body = SOAPNode(name: nodeName)
				body?.childNodes = [bc]
			}
			else {
				body = nil
			}
		}
	}
	
	public init() {
	}
	
	public func asXMLString() -> String {
		envelope.namespaces = namespaces
		envelope.childNodes = [SOAPNode]()
		if let header = header {
			envelope.childNodes.append(header)
		}
		if let body = body {
			envelope.childNodes.append(body)
		}
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\(envelope.asXMLString(0))"
	}
}


class SOAPEnvelope: SOAPNode
{
	var namespaces: [String: String]?
	
	init() {
		super.init(name: "Envelope")
		namespace = SOAPNamespace(name: "soapenv", url: "http://schemas.xmlsoap.org/soap/envelope/")
		attributes = [
			SOAPNodeAttribute(name: "xmlns:soapenc", value: "http://schemas.xmlsoap.org/soap/encoding/"),
			SOAPNodeAttribute(name: "xmlns:xsi", value: "http://www.w3.org/2001/XMLSchema-instance"),
			SOAPNodeAttribute(name: "xmlns:xsd", value: "http://www.w3.org/2001/XMLSchema"),
			SOAPNodeAttribute(name: "soapenv:encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/"),
		]
	}
	
	override func asXMLString(indentLevel: Int = 0) -> String {
		if let namespaces = namespaces {
			for (key, val) in namespaces {
				var found = false
				for attr in attributes {
					if attr.name == key {
						found = true
						attr.value = val
					}
				}
				if !found {
					attributes.append(SOAPNodeAttribute(name: key, value: val))
				}
			}
		}
		return super.asXMLString(indentLevel)
	}
}

