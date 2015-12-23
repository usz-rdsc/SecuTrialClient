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
public class SecuTrialBeanWebServiceResult: SecuTrialBean {
	
	let node: SOAPNode
	
	/// Response status code.
	public internal(set) var statusCode = 0
	
	/// Response message, if any.
	public internal(set) var message: String?
	
	
	public required init() {
		node = SOAPNode(name: "result")
	}
	
	public required init(node: SOAPNode) throws {
		self.node = node
		let messages = node.childrenNamed("message").filter() { $0 is SOAPTextNode && nil != ($0 as! SOAPTextNode).text }
		message = messages.map() { ($0 as! SOAPTextNode).text! }.joinWithSeparator("")
		if let status = (node.childNamed("statusCode") as? SOAPTextNode)?.text, let code = Int(status) {
			statusCode = code
		}
		else {
			throw SecuTrialError.InvalidDOM("`statusCode` is missing:\n\(node.asXMLString())\n----")
		}
		if let err = (node.childNamed("errorCode") as? SOAPTextNode)?.text, let code = Int(err) {
			if 0 != code {
				if 1 == code {
					throw SecuTrialError.Unauthenticated
				}
				if let message = message {
					throw SecuTrialError.Error("\(message) [\(code)]")
				}
				throw SecuTrialError.Error("Error code \(code)")
			}
		}
		else {
			throw SecuTrialError.InvalidDOM("`errorCode` is missing:\n\(node.asXMLString())\n----")
		}
	}
	
	
	public func node(name: String) -> SOAPNode {
		return node
	}
}

