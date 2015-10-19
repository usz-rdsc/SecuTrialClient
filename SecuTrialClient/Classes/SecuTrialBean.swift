//
//  SecuTrialBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 16/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public protocol SecuTrialBean {
	
	init()
	
	init(node: SOAPNode) throws
	
	func node(name: String) -> SOAPNode
}

