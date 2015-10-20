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
	
	public var account: SecuTrialAccount?
	
	var session: String?
	
	
	public init(url: NSURL, customer: String? = nil, username: String? = nil, password: String? = nil) {
		service = SecuTrialService(url: url)
		account = SecuTrialAccount(customer: customer, username: username, password: password)
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
				secu_debug("operation failed with error: \(error)")
			}
			
			if "authenticate" != operation.name && "terminate" != operation.name {
				print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\(operation.asXMLString(0))")
				self.terminate(response, callback: callback)
			}
			else {
				callback(response: response)
			}
		}
	}
	
	
	// MARK: - Authentication & Termination
	
	func authenticate(callback: ((response: SecuTrialResponse) -> Void)) {
		if let auth = account?.authOperation() {
			secu_debug("performing operation “\(auth.name)”")
			service.performOperation(auth) { response in
				if nil == response.error {
					if let bean = response.bean as? STWebServiceResult {
						if let sessionId = bean.message {
							self.session = sessionId
						}
						else {
							response.error = SecuTrialError.NoSessionReceived
						}
					}
					else {
						response.error = SecuTrialError.InvalidDOM("Authenticate operation did not receive a WebServiceResult Bean")
					}
				}
				callback(response: response)
			}
		}
		else {
			secu_debug("no `account`, cannot authenticate")
			callback(response: SecuTrialResponse(error: .NoAccount))
		}
	}
	
	func autoAuthenticateOperation(operation: SecuTrialOperation, callback: ((response: SecuTrialResponse) -> Void)) {
		guard "authenticate" != operation.name else {
			self.performOperation(operation, callback: callback)
			return
		}
		authenticate() { response in
			if nil == response.error {
				self.performOperation(operation, callback: callback)
			}
			else {
				callback(response: response)
			}
		}
	}
	
	func terminate(afterResponse: SecuTrialResponse, callback: ((response: SecuTrialResponse) -> Void)) {
		if let sessionId = session {
			let terminate = SecuTrialOperation(name: "terminate")
			terminate.addInput(SecuTrialOperationInput(name: "sessionId", type: "soapenc:string", textValue: sessionId))
			terminate.expectsResponseBeanAt = ["terminateResponse", "terminateReturn"]
			
			secu_debug("performing operation “\(terminate.name)”")
			service.performOperation(terminate) { response in
				if let error = response.error {
					secu_debug("error terminating: \(error)")
				}
				callback(response: afterResponse)
			}
		}
		else {
			secu_debug("No session id, no need to terminate")
			callback(response: afterResponse)
		}
	}
}


func secu_debug(@autoclosure message: () -> String, function: String = __FUNCTION__, file: NSString = __FILE__, line: Int = __LINE__) {
#if DEBUG
	print("# \(file.lastPathComponent):\(line), \(function)():  \(message())")
#endif
}

