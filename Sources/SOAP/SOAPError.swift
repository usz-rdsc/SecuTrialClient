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
public enum SOAPError: ErrorType, CustomStringConvertible {
	case RootNotFound
	case InvalidDOM(String)
	case EnvelopeNotFound
	case Error(String)
	
	public var description: String {
		switch self {
		case .RootNotFound:
			return "The root node was not found"
		case .InvalidDOM(let message):
			return message
		case .EnvelopeNotFound:
			return "No \"Envelope\" node was found"
		case .Error(let message):
			return message
		}
	}
}

