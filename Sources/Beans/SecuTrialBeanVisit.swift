//
//  SecuTrialBeanVisit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialBeanVisit: SecuTrialBean {
	
	public var label: String?
	
	public var nr: String?
	
	public var date: String?
	
	
	public required init() {
	}
	
	public required init(node: SOAPNode) throws {
	}
	
	public func node(name: String) -> SOAPNode {
		let node = SOAPNode(name: name)
		if let txt = label {
			node.addChild(SOAPTextNode(name: "label", textValue: txt))
		}
		if let txt = nr {
			node.addChild(SOAPTextNode(name: "nr", textValue: txt))
		}
		if let txt = date {
			node.addChild(SOAPTextNode(name: "date", textValue: txt))
		}
		return node
	}
}

