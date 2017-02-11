//
//  SecuTrialOperation.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation
#if !SKIP_INTERNAL_IMPORT
import SOAP
import Beans
#endif


/// Aliasing "$" to `SecuTrialOperation`.
public typealias $ = SecuTrialOperation


/**
An operation to be performed against secuTrial's SOAP interface.
*/
open class SecuTrialOperation: SOAPNode {
	
	var inputs = [SecuTrialOperationInput]()
	
	open var expectedResponseBean: SecuTrialBean.Type = SecuTrialBeanWebServiceResult.self
	
	open var expectsResponseBeanAt: [String]?
	
	
	public required init(name: String) {
		super.init(name: name)
		namespace = SOAPNamespace(name: "ns0", url: "http://DefaultNamespace")
	}
	
	
	// MARK: - Operation Input
	
	open func addInput(_ input: SecuTrialOperationInput) {
		inputs.append(input)
	}
	
	open func hasInput(_ name: String) -> Bool {
		return !inputs.filter() { $0.node.name == name }.isEmpty
	}
	
	open func removeInput(_ name: String) {
		inputs = inputs.filter() { $0.node.name != name }
	}
	
	open override func childNodesForXMLString() -> [SOAPNode] {
		return inputs.map() { $0.node }
	}
	
	
	// MARK: - Request
	
	open func request() -> SOAPRequest {
		let request = SOAPRequest()
		if let reqns = request.envelope.namespace {
			attributes = [SOAPNodeAttribute(name: "\(reqns.name):encodingStyle", value: "http://schemas.xmlsoap.org/soap/encoding/")]
		}
		request.envelope.bodyContent = self
		return request
	}
	
	
	// MARK: - Response
	
	/**
	Incoming XML data is passed to this method, whith attempts to parse the XML and instantiates a suitable response.
	
	- parameter data: The data received from the server, expected to be UTF-8 encoded XML
	- returns: A SecuTrialResponse instance
	*/
	open func handleResponseData(_ data: Data) -> SecuTrialResponse {
		secu_debug("handling response data of \(data.count) bytes")
		let parser = SOAPEnvelopeParser()
		do {
			let envelope = try parser.parse(data)
			if let beanPath = expectsResponseBeanAt {
				return SecuTrialResponse(envelope: envelope, path: beanPath, type: expectedResponseBean)
			}
			throw SecuTrialError.operationNotConfigured
		}
		catch let err as SecuTrialError {
			return hadError(err)
		}
		catch {
			return hadError(SecuTrialError.error("unknown"))
		}
	}
	
	open func hadError(_ error: SecuTrialError?) -> SecuTrialResponse {
		if let error = error {
			return SecuTrialResponse(error: error)
		}
		return SecuTrialResponse(error: SecuTrialError.error("unknown"))
	}
}


open class SecuTrialOperationInput {
	
	let name: String
	
	var type: String?
	
	var textValue: String?
	
	var bean: SecuTrialBean?
	
	open var node: SOAPNode {
		if let bean = bean {
			return bean.node(name)
		}
		let node = SOAPTextNode(name: name, textValue: textValue ?? "")
		if let type = type {
			node.attr("xsi:type", value: type)
		}
		return node
	}
	
	public init(name: String, type: String, textValue: String) {
		self.name = name
		self.type = type
		self.textValue = textValue
	}
	
	public init(name: String, bean: SecuTrialBean) {
		self.name = name
		self.bean = bean
	}
}

