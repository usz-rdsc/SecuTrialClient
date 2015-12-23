//
//  SecuTrialError.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public enum SecuTrialError: ErrorType, CustomStringConvertible {
	case NoAccount
	case Unauthenticated
	case OperationNotConfigured
	case ResponseBeanNotFound
	case InvalidDOM(String)
	case HTTPStatus(Int)
	case NoSessionReceived
	case Error(String)
	
	public var description: String {
		switch self {
		case .NoAccount:
			return "No account has been set up yet"
		case .Unauthenticated:
			return "Not authenticated"
		case .OperationNotConfigured:
			return "The operation was not properly configured: expected-bean-type or -path is missing"
		case .ResponseBeanNotFound:
			return "The response bean was not found"
		case .InvalidDOM(let message):
			return message
		case .HTTPStatus(let code):
			return "Status \(code)"
		case .NoSessionReceived:
			return "No session-id received"
		case .Error(let message):
			return message
		}
	}
}