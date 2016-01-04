//
//  SecuTrialError.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


public enum SecuTrialError: ErrorType, CustomStringConvertible {
	case NoAccount
	case Unauthenticated
	case OperationNotConfigured
	case ResponseBeanNotFound
	case InvalidDOM(String)
	case HTTPStatus(Int)
	case NoSessionReceived
	
	case AlreadyPerformingSurvey
	case ImportFormatNotKnownToForm
	case ImportFormatWithoutIdentifier
	case SurveyFinishedWithError
	
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
		
		case .AlreadyPerformingSurvey:
			return "The survey is already ongoing"
		case .ImportFormatNotKnownToForm:
			return "The import format does not belong to the form"
		case .ImportFormatWithoutIdentifier:
			return "The import format does not have an identifier"
		case .SurveyFinishedWithError:
			return "Survey finished with an error"
		
		case .Error(let message):
			return message
		}
	}
}


func strk_warn(@autoclosure message: () -> String, function: String = __FUNCTION__, file: NSString = __FILE__, line: Int = __LINE__) {
	print("[\(file.lastPathComponent):\(line)] \(function)  WARNING: \(message())")
}

