//
//  SecuTrialAccount.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


open class SecuTrialAccount {
	
	open var customer: String?
	
	open var username: String?
	
	open var password: String?
	
	public init(customer: String?, username: String?, password: String?) {
		self.customer = customer
		self.username = username
		self.password = password
	}
	
	
	// MARK: - Authentication
	
	open func authOperation() -> SecuTrialOperation {
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
		auth.expectsResponseBeanAt = ["authenticateResponse", "authenticateReturn"]
		return auth
	}
}

