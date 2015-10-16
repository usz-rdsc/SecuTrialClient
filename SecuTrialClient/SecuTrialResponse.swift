//
//  SecuTrialResponse.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/**
Response to a `SecuTrialOperation`.
*/
public class SecuTrialResponse: SOAPResponse {
	public var isError: Bool {
		return (nil != errorCode && 0 != errorCode!) || nil != error
	}
	
	var bodyPath: [String]?
	
	/// Response status code.
	public internal(set) var statusCode: Int?
	
	/// Response error code.
	public internal(set) var errorCode: Int?
	
	/// Response error, if any.
	public internal(set) var error: NSError?
	
	/// Response message, if any.
	public internal(set) var message: String?
	
	
	public init(envelope: SOAPEnvelope, parsePath: [String]? = nil) {
		bodyPath = parsePath
		super.init(envelope: envelope)
		parseResponse()
	}
	
	public init(error: NSError) {
		super.init(envelope: SOAPEnvelope())
		self.error = error
	}
	
	func parseResponse() {
		if let node = findResponseNode(envelope) {
			parseResponseNode(node)
		}
	}
	
	func findResponseNode(envelope: SOAPEnvelope) -> SOAPNode? {
		var node = envelope.body
		if let path = bodyPath {
			for part in path {
				node = node?.childNamed(part)
				if nil == node {
					let sep = " > "
					secu_debug("Desired body node at \(path.joinWithSeparator(sep)) not found in:\n\(envelope.asXMLString())\n----")
					break
				}
			}
		}
		return node
	}
	
	func parseResponseNode(node: SOAPNode) {
		statusCode = nil
		if let status = (node.childNamed("statusCode") as? SOAPTextNode)?.text {
			statusCode = Int(status)
		}
		message = (node.childNamed("message") as? SOAPTextNode)?.text
		errorCode = nil
		if let err = (node.childNamed("errorCode") as? SOAPTextNode)?.text, let code = Int(err) {
			errorCode = code
			if let message = message where code != 0 && nil == error {
				error = NSError(domain: "SecuTrialErrorDomain", code: code, userInfo: [NSLocalizedDescriptionKey: message])
			}
		}
	}
}

