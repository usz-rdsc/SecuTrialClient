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


open class SecuTrialService {
	let url: URL
	
	let serviceURL: URL
	
	public init(url: URL) {
		self.url = url
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		components.query = nil
		components.fragment = nil
		serviceURL = components.url!
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
	open func performOperation(_ operation: SecuTrialOperation, callback: @escaping ((_ response: SecuTrialResponse) -> Void)) {
		performRequest(operation.request()) { data, error in
			if let data = data {
				callback(operation.handleResponseData(data))
			}
			else {
				callback(operation.hadError(error))
			}
		}
	}
	
	/**
	Performs the given request against the service URL.
	
	- parameter request: The SOAPRequest to perform
	- parameter callback: Callback that's called when the request finishes, either with a data or an error instance
	*/
	open func performRequest(_ request: SOAPRequest, callback: @escaping ((_ data: Data?, _ error: SecuTrialError?) -> Void)) {
		let session = URLSession.shared
		let request = request.requestReadyForURL(serviceURL)
		let task = session.uploadTask(with: request, from: request.httpBody, completionHandler: { data, response, error in
			if let error = error {
				callback(nil, SecuTrialError.error(error.localizedDescription))
			}
			else if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
				callback(nil, SecuTrialError.httpStatus(response.statusCode))
			}
			else if let data = data {
				callback(data, nil)
			}
		}) 
		task.resume()
	}
}

