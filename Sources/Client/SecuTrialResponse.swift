//
//  SecuTrialResponse.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation
#if !SKIP_INTERNAL_IMPORT
import SOAP
import Beans
#endif


/**
Response to a `SecuTrialOperation`.
*/
open class SecuTrialResponse: SOAPResponse {
	
	/// Response bean.
	public internal(set) var bean: SecuTrialBean?
	
	/// Response error, if any.
	public internal(set) var error: SecuTrialError?
	
	
	public init(envelope: SOAPEnvelope, path: [String], type: SecuTrialBean.Type) {
		super.init(envelope: envelope)
		do {
			try parseResponse(path: path, type: type)
		}
		catch let err as SecuTrialError {
			error = err
		}
		catch let err {
			error = SecuTrialError.error("\(err)")
		}
	}
	
	public init(error: SecuTrialError) {
		super.init(envelope: SOAPEnvelope())
		self.error = error
	}
	
	public func parseResponse(path: [String], type: SecuTrialBean.Type) throws {
		guard let node = findResponseNode(envelope: envelope, at: path) else {
			throw SecuTrialError.responseBeanNotFound
		}
		bean = try type.init(node: node)
	}
	
	public func findResponseNode(envelope: SOAPEnvelope, at path: [String]) -> SOAPNode? {
		var node = envelope.body
		for part in path {
			node = node?.childNamed(part)
			if nil == node {
				let sep = "” > “"
				secu_debug("Desired response bean at “\(path.joined(separator: sep))” not found in:\n\(envelope.asXMLString())\n----")
				break
			}
		}
		return node
	}
}

