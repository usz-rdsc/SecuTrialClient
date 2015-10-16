//
//  SecuTrialBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public protocol SecuTrialBean {
	
	var error: SecuTrialError? { get }
	
	var message: String? { get }
	
	init(node: SOAPNode) throws
}


/**
Manually created "WebServiceResult" bean, would be cool if it was automated!
*/
public class STWebServiceResult: SecuTrialBean {
	
	let node: SOAPNode
	
	/// Response status code.
	public internal(set) var statusCode = 0
	
	/// Response error code.
	public internal(set) var errorCode = 0
	
	/// Response message, if any.
	public internal(set) var message: String?
	
	public var error: SecuTrialError? {
		if 0 != errorCode {
			if 1 == errorCode {
				return SecuTrialError.Unauthenticated
			}
			if let message = message {
				return SecuTrialError.Error("\(message) [\(errorCode)]")
			}
			return SecuTrialError.Error("Error code \(errorCode)")
		}
		return nil
	}
	
	
	public required init(node: SOAPNode) throws {
		self.node = node
		if let status = (node.childNamed("statusCode") as? SOAPTextNode)?.text, let code = Int(status) {
			statusCode = code
		}
		else {
			throw SecuTrialError.InvalidDOM("`statusCode` is missing:\n\(node.asXMLString())\n----")
		}
		if let err = (node.childNamed("errorCode") as? SOAPTextNode)?.text, let code = Int(err) {
			errorCode = code
		}
		else {
			throw SecuTrialError.InvalidDOM("`errorCode` is missing:\n\(node.asXMLString())\n----")
		}
		message = (node.childNamed("message") as? SOAPTextNode)?.text
	}
}

