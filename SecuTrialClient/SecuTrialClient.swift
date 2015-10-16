//
//  SecuTrialClient.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


public class SecuTrialClient {
	
	let service: SecuTrialService
	
	public var customer: String?
	
	public var username: String?
	
	public var password: String?
	
	public var session: String?
	
	
	public init(url: NSURL, customer: String? = nil, username: String? = nil, password: String? = nil) {
		service = SecuTrialService(url: url)
		self.customer = customer
		self.username = username
		self.password = password
		secu_debug("client initialized against \(service.serviceURL.host ?? service.serviceURL.description)")
	}
	
	
	// MARK: - Operations & Requests
	
	/**
	Performs the given operation against the receiver's service URL.
	
	- parameter operation: The operation to perform
	- parameter callback: Callback called when the operation finishes, either with a response or an error instance
	*/
	public func performOperation(operation: SecuTrialOperation, callback: ((response: SecuTrialResponse) -> Void)) {
		if !operation.hasInput("sessionId") {
			if let sessionId = session {
				operation.addInput(SecuTrialOperationInput(name: "sessionId", type: "soapenc:string", textValue: sessionId))
			}
			else {
				secu_debug("no session-id, authenticating")
				autoAuthenticateOperation(operation, callback: callback)
				return
			}
		}
		
		secu_debug("performing operation “\(operation.name)”")
		service.performOperation(operation) { response in
			if let error = response.error {
				switch error {
				case .Unauthenticated:
					secu_debug("unauthenticated, authenticating")
					operation.removeInput("sessionId")
					self.autoAuthenticateOperation(operation, callback: callback)
					return
				default:
					break
				}
			}
			if let error = response.error {
				secu_debug("operation failed with error: \(error)")
			}
			callback(response: response)
		}
	}
	
	func autoAuthenticateOperation(operation: SecuTrialOperation, callback: ((response: SecuTrialResponse) -> Void)) {
		authenticate() { response in
			if nil == response.error {
				self.performOperation(operation, callback: callback)
			}
			else {
				callback(response: response)
			}
		}
	}
	
	
	// MARK: - Authentication
	
	func authenticate(callback: ((response: SecuTrialResponse) -> Void)) {
		// TODO: create request object classes
		let auth = SecuTrialOperation(name: "authenticate")
		if let customer = customer {
			auth.addInput(SecuTrialOperationInput(name: "customerId", type: "soapenc:string", textValue: customer))
		}
		if let username = username {
			auth.addInput(SecuTrialOperationInput(name: "username", type: "soapenc:string", textValue: username))
		}
		if let password = password {
			auth.addInput(SecuTrialOperationInput(name: "password", type: "soapenc:string", textValue: password))
		}
		auth.expectedResponseBean = STWebServiceResult.self
		auth.expectsResponseBeanAt = ["authenticateResponse", "authenticateReturn"]
		
		secu_debug("performing operation “\(auth.name)”")
		service.performOperation(auth) { response in
			if nil == response.error {
				if let sessionId = response.bean?.message {
					self.session = sessionId
				}
				else {
					response.knownError = SecuTrialError.NoSessionReceived
				}
			}
			callback(response: response)
		}
	}
}


func secu_debug(@autoclosure message: () -> String, function: String = __FUNCTION__, file: NSString = __FILE__, line: Int = __LINE__) {
#if DEBUG
	print("# \(file.lastPathComponent):\(line), \(function)():  \(message())")
#endif
}

