//
//  SecuTrialBeanWebServiceResult.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


/**
Manually created "WebServiceResult" bean, would be cool if it was automated!
*/
open class SecuTrialBeanWebServiceResult: SecuTrialBean {
	
	let node: SOAPNode
	
	/// Response status code.
	open internal(set) var statusCode = 0
	
	/// Response message, if any.
	open internal(set) var message: String?
	
	
	public required init() {
		node = SOAPNode(name: "result")
	}
	
	public required init(node: SOAPNode) throws {
		self.node = node
		let messages = node.childrenNamed("message").filter() { $0 is SOAPTextNode && nil != ($0 as! SOAPTextNode).text }
		message = messages.map() { ($0 as! SOAPTextNode).text! }.joined(separator: "")
		if let status = (node.childNamed("statusCode") as? SOAPTextNode)?.text, let code = Int(status) {
			statusCode = code
		}
		else {
			throw SecuTrialError.invalidDOM("`statusCode` is missing:\n\(node.asXMLString())\n----")
		}
		if let err = (node.childNamed("errorCode") as? SOAPTextNode)?.text, let code = Int(err) {
			if 0 != code {
				if 1 == code {
					throw SecuTrialError.unauthenticated
				}
				if let message = message {
					throw SecuTrialError.error("\(message) [\(code)]")
				}
				throw SecuTrialError.error("Error code \(code)")
			}
		}
		else {
			throw SecuTrialError.invalidDOM("`errorCode` is missing:\n\(node.asXMLString())\n----")
		}
	}
	
	
	open func node(_ name: String) -> SOAPNode {
		return node
	}
}

