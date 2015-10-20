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
	
	var inputs = [SecuTrialOperationInput]()
	
	public var expectedResponseBean: SecuTrialBean.Type = STWebServiceResult.self
	
	public var expectsResponseBeanAt: [String]?
	
	
	public required init(name: String) {
		super.init(name: name)
		namespace = SOAPNamespace(name: "ns0", url: "http://DefaultNamespace")
	}
	
	
	// MARK: - Operation Input
	
	public func addInput(input: SecuTrialOperationInput) {
		inputs.append(input)
	}
	
	public func hasInput(name: String) -> Bool {
		return !inputs.filter() { $0.node.name == name }.isEmpty
	}
	
	public func removeInput(name: String) {
		inputs = inputs.filter() { $0.node.name != name }
	}
	
	override func childNodesForXMLString() -> [SOAPNode] {
		return inputs.map() { $0.node }
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
	
	/**
	Incoming XML data is passed to this method, whith attempts to parse the XML and instantiates a suitable response.
	
	- parameter data: The data received from the server, expected to be UTF-8 encoded XML
	- returns: A SecuTrialResponse instance
	*/
	public func handleResponseData(data: NSData) -> SecuTrialResponse {
		secu_debug("handling response data of \(data.length) bytes")
		let parser = SOAPEnvelopeParser()
		do {
			let envelope = try parser.parse(data)
			if let beanPath = expectsResponseBeanAt {
				return SecuTrialResponse(envelope: envelope, path: beanPath, type: expectedResponseBean)
			}
			throw SecuTrialError.OperationNotConfigured
		}
		catch let err as SecuTrialError {
			return hadError(err)
		}
		catch {
			return hadError(SecuTrialError.Error("unknown"))
		}
	}
	
	public func hadError(error: SecuTrialError?) -> SecuTrialResponse {
		if let error = error {
			return SecuTrialResponse(error: error)
		}
		return SecuTrialResponse(error: SecuTrialError.Error("unknown"))
	}
}


public class SecuTrialOperationInput {
	
	let name: String
	
	var type: String?
	
	var textValue: String?
	
	var bean: SecuTrialBean?
	
	public var node: SOAPNode {
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

