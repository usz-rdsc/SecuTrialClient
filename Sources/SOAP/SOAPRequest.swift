//
//  SOAPRequest.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

import Foundation


/**
This is an INCREDIBLY FAKE implementation of a real SOAP request.
*/
open class SOAPRequest {
	
	open lazy var envelope = SOAPEnvelope()
	
	public init() { }
	
	
	// MARK: - Performable Requests
	
	open func requestReadyForURL(_ url: URL) -> URLRequest {
		let req = NSMutableURLRequest(url: url)
		req.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
		req.setValue("application/xml", forHTTPHeaderField: "Accept")
		req.httpMethod = "POST"
		req.httpBody = asXMLData()
		return req as URLRequest
	}
	
	open func asXMLData() -> Data? {
		return asXMLString().data(using: String.Encoding.utf8)
	}
	
	open func asXMLString() -> String {
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\(envelope.asXMLString(0))"
	}
}

