//
//  SecuTrialError.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public enum SecuTrialError: ErrorType, CustomStringConvertible {
	case Unauthenticated
	case OperationNotConfigured
	case EnvelopeNotFound
	case ResponseBeanNotFound
	case InvalidDOM(String)
	case HTTPStatus(Int)
	case NoSessionReceived
	case Error(String)
	
	public var description: String {
		switch self {
		case .Unauthenticated:
			return "Not authenticated"
		case .OperationNotConfigured:
			return "The operation was not properly configured: expected-bean-type or -path is missing"
		case .EnvelopeNotFound:
			return "No \"Envelope\" node was found"
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