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
public class SOAPRequest {
	
	public lazy var envelope = SOAPEnvelope()
	
	public init() { }
	
	
	// MARK: - Performable Requests
	
	public func requestReadyForURL(url: NSURL) -> NSURLRequest {
		let req = NSMutableURLRequest(URL: url)
		req.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
		req.setValue("application/xml", forHTTPHeaderField: "Accept")
		req.HTTPMethod = "POST"
		req.HTTPBody = asXMLData()
		return req
	}
	
	public func asXMLData() -> NSData? {
		return asXMLString().dataUsingEncoding(NSUTF8StringEncoding)
	}
	
	public func asXMLString() -> String {
		return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\(envelope.asXMLString(0))"
	}
}

