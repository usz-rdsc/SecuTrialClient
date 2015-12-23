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
	
	/// Response bean.
	public internal(set) var bean: SecuTrialBean?
	
	/// Response error, if any.
	public internal(set) var error: SecuTrialError?
	
	
	public init(envelope: SOAPEnvelope, path: [String], type: SecuTrialBean.Type) {
		super.init(envelope: envelope)
		do {
			try parseResponse(path, type: type)
		}
		catch let err as SecuTrialError {
			error = err
		}
		catch let err {
			error = SecuTrialError.Error("\(err)")
		}
	}
	
	public init(error: SecuTrialError) {
		super.init(envelope: SOAPEnvelope())
		self.error = error
	}
	
	func parseResponse(path: [String], type: SecuTrialBean.Type) throws {
		guard let node = findResponseNode(envelope, at: path) else {
			throw SecuTrialError.ResponseBeanNotFound
		}
		bean = try type.init(node: node)
	}
	
	func findResponseNode(envelope: SOAPEnvelope, at path: [String]) -> SOAPNode? {
		var node = envelope.body
		for part in path {
			node = node?.childNamed(part)
			if nil == node {
				let sep = "” > “"
				secu_debug("Desired response bean at “\(path.joinWithSeparator(sep))” not found in:\n\(envelope.asXMLString())\n----")
				break
			}
		}
		return node
	}
}

