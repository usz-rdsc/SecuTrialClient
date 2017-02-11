//
//  SOAPError.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 28/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


/**
SOAP Errors.
*/
public enum SOAPError: Error, CustomStringConvertible {
	case rootNotFound
	case invalidDOM(String)
	case envelopeNotFound
	case error(String)
	
	public var description: String {
		switch self {
		case .rootNotFound:
			return "The root node was not found"
		case .invalidDOM(let message):
			return message
		case .envelopeNotFound:
			return "No \"Envelope\" node was found"
		case .error(let message):
			return message
		}
	}
}

