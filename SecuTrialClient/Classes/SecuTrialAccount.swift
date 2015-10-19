//
//  SecuTrialAccount.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialAccount {
	
	public var customer: String?
	
	public var username: String?
	
	public var password: String?
	
	public init(customer: String?, username: String?, password: String?) {
		self.customer = customer
		self.username = username
		self.password = password
	}
	
	
	// MARK: - Authentication
	
	public func authOperation() -> SecuTrialOperation {
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
		return auth
	}
}
