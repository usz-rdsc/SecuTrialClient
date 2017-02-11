//
//  SOAPResponse.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 08/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//



open class SOAPResponse {
	
	open let envelope: SOAPEnvelope
	
	public init(envelope: SOAPEnvelope) {
		self.envelope = envelope
	}
}
