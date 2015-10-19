//
//  STPatientBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class STPatientBean: SecuTrialBean {
	
	let node: SOAPNode
	
	
	public required init(node: SOAPNode) throws {
		self.node = node
	}
}

