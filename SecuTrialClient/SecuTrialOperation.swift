//
//  SecuTrialOperation.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/// Aliasing "$" to `SecuTrialOperation`.
public typealias $ = SecuTrialOperation


/**
An operation to be performed against secuTrial's SOAP interface.
*/
public class SecuTrialOperation: SOAPNode {
	
	public required init(name: String) {
		super.init(name: name)
		namespace = SOAPNamespace(name: "ns0", url: "http://DefaultNamespace")
	}
	
	
	// MARK: - Operation Input
	
	public func addInput(input: SecuTrialOperationInput) {
		addChild(input)
	}
	
	public func hasInput(name: String) -> Bool {
		return (nil != childNamed(name))
	}
	
	
	// MARK: - Request
	
	public func request() -> SOAPRequest {
		let request = SOAPRequest()
		if let reqns = request.envelope.namespace {
			attributes = [SOAPNodeAttribute(name: "\(reqns.name):encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/")]
		}
		request.envelope.bodyContent = self
		return request
	}
	
	
	// MARK: - Response
	
	/// Optional block to execute that will return a desired response from the parsed response envelope.
	public var withResponseEnvelope: ((envelope: SOAPEnvelope) -> SecuTrialResponse)?
	
	/**
	Incoming XML data is passed to this method, whith attempts to parse the XML and instantiates a suitable response.
	
	This method will call `withResponseEnvelope` if it's defined, otherwise return a `SecuTrialResponse` instance with the parsed envelope.
	
	- parameter data: The data received from the server, expected to be UTF-8 encoded XML
	- returns: A SecuTrialResponse instance
	*/
	public func handleResponseData(data: NSData) -> SecuTrialResponse {
		secu_debug("handling response data of \(data.length) bytes")
		let parser = SOAPEnvelopeParser()
		do {
			if let envelope = try parser.parse(data) {
				if let handler = withResponseEnvelope {
					return handler(envelope: envelope)
				}
				return SecuTrialResponse(envelope: envelope)
			}
			return hadError(nil)
		}
		catch let err {
			return hadError(err as NSError)
		}
	}
	
	public func hadError(error: NSError?) -> SecuTrialResponse {
		if let error = error {
			return SecuTrialResponse(error: error)
		}
		return SecuTrialResponse(error: NSError(domain: "SecuTrialErrorDomain", code: 0, userInfo: nil))
	}
}


public class SecuTrialOperationInput: SOAPTextNode {
	public convenience init(name: String, type: String, textValue: String) {
		self.init(name: name, textValue: textValue)
		attributes.append(SOAPNodeAttribute(name: "xsi:type", value: type))
	}
}

