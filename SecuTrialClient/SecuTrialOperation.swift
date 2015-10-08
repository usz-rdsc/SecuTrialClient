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
public class SecuTrialOperation: SOAPNode
{
	public func addInput(input opInput: SecuTrialOperationInput) {
		childNodes.append(opInput)
	}
	
	public func request() -> SOAPRequest {
		let request = SOAPRequest()
		if let reqns = request.envelope.namespace {
			attributes = [SOAPNodeAttribute(name: "\(reqns.name):encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/")]
		}
		request.bodyContent = self
		return request
	}
}


public class SecuTrialOperationInput: SOAPTextNode
{
	public convenience init(name: String, type: String, textValue: String) {
		self.init(name: name, textValue: textValue)
		attributes.append(SOAPNodeAttribute(name: "xsi:type", value: type))
	}
}

