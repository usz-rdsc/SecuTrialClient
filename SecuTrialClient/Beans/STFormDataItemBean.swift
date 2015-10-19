//
//  STFormDataItemBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class STFormDataItemBean: SecuTrialBean {
	
	
	public required init(node: SOAPNode) throws {
	}
	
	public func node(name: String) -> SOAPNode {
		let node = SOAPNode(name: name)
		return node
	}
}

