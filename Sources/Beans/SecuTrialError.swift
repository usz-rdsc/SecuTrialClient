//
//  SecuTrialError.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


public enum SecuTrialError: Error, CustomStringConvertible {
	case noAccount
	case unauthenticated
	case operationNotConfigured
	case responseBeanNotFound
	case invalidDOM(String)
	case httpStatus(Int)
	case noSessionReceived
	
	case alreadyPerformingSurvey
	case importFormatNotKnownToForm
	case importFormatWithoutIdentifier
	case surveyFinishedWithError
	
	case error(String)
	
	public var description: String {
		switch self {
		case .noAccount:
			return "No account has been set up yet"
		case .unauthenticated:
			return "Not authenticated"
		case .operationNotConfigured:
			return "The operation was not properly configured: expected-bean-type or -path is missing"
		case .responseBeanNotFound:
			return "The response bean was not found"
		case .invalidDOM(let message):
			return message
		case .httpStatus(let code):
			return "Status \(code)"
		case .noSessionReceived:
			return "No session-id received"
		
		case .alreadyPerformingSurvey:
			return "The survey is already ongoing"
		case .importFormatNotKnownToForm:
			return "The import format does not belong to the form"
		case .importFormatWithoutIdentifier:
			return "The import format does not have an identifier"
		case .surveyFinishedWithError:
			return "Survey finished with an error"
		
		case .error(let message):
			return message
		}
	}
}


func strk_warn(_ message: @autoclosure () -> String, function: String = #function, file: NSString = #file, line: Int = #line) {
	print("[\(file.lastPathComponent):\(line)] \(function)  WARNING: \(message())")
}

