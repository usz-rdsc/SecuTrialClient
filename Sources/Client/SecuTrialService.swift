//
//  SecuTrialService.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation
#if !SKIP_INTERNAL_IMPORT
import SOAP
import Beans
#endif


public class SecuTrialService {
	let url: NSURL
	
	let serviceURL: NSURL
	
	public init(url: NSURL) {
		self.url = url
		let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!
		components.query = nil
		components.fragment = nil
		serviceURL = components.URL!
	}
	
	
	// MARK: - Definition
	
	func retrieveDefinition() {
		fatalError("Not implemented")
	}
	
	
	// MARK: - Operations & Requests
	
	/**
	Performs the given operation against the receiver's service URL.
	
	- parameter operation: The operation to perform
	- parameter callback: Callback called when the operation finishes, either with a response or an error instance
	*/
	public func performOperation(operation: SecuTrialOperation, callback: ((response: SecuTrialResponse) -> Void)) {
		performRequest(operation.request()) { data, error in
			if let data = data {
				callback(response: operation.handleResponseData(data))
			}
			else {
				callback(response: operation.hadError(error))
			}
		}
	}
	
	/**
	Performs the given request against the service URL.
	
	- parameter request: The SOAPRequest to perform
	- parameter callback: Callback that's called when the request finishes, either with a data or an error instance
	*/
	public func performRequest(request: SOAPRequest, callback: ((data: NSData?, error: SecuTrialError?) -> Void)) {
		let session = NSURLSession.sharedSession()
		let request = request.requestReadyForURL(serviceURL)
		let task = session.uploadTaskWithRequest(request, fromData: request.HTTPBody) { data, response, error in
			if let error = error {
				callback(data: nil, error: SecuTrialError.Error(error.localizedDescription))
			}
			else if let response = response as? NSHTTPURLResponse where response.statusCode >= 400 {
				callback(data: nil, error: SecuTrialError.HTTPStatus(response.statusCode))
			}
			else if let data = data {
				callback(data: data, error: nil)
			}
		}
		task.resume()
	}
}

