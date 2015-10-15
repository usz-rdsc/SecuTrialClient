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
	
	public func addInput(input opInput: SecuTrialOperationInput) {
		addChild(opInput)
	}
	
	public func request() -> SOAPRequest {
		let request = SOAPRequest()
		if let reqns = request.envelope.namespace {
			attributes = [SOAPNodeAttribute(name: "\(reqns.name):encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/")]
		}
		request.envelope.bodyContent = self
		return request
	}
	
	public func handleResponseData(data: NSData) throws -> SOAPResponse? {
		let parser = SOAPEnvelopeParser()
		if let envelope = try parser.parse(data) {
			return SOAPResponse(envelope: envelope)
		}
		return nil
	}
}


public class SecuTrialOperationInput: SOAPTextNode {
	public convenience init(name: String, type: String, textValue: String) {
		self.init(name: name, textValue: textValue)
		attributes.append(SOAPNodeAttribute(name: "xsi:type", value: type))
	}
}

