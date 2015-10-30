//
//  SecuTrialBeanFormDataItem.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class SecuTrialBeanFormDataItem: SecuTrialBean {
	
	public var key: String?
	
	public var value: String?
	
	public var repindex = 0
	
	public required init() {
	}
	
	public convenience init(key: String, value: String) {
		self.init()
		self.key = key
		self.value = value
	}
	
	public required init(node: SOAPNode) throws {
	}
	
	public func node(name: String) -> SOAPNode {
		let node = SOAPNode(name: name)
		if let txt = key {
			node.addChild(SOAPTextNode(name: "key", textValue: txt))
		}
		if let txt = value {
			node.addChild(SOAPTextNode(name: "value", textValue: txt))
		}
		node.addChild(SOAPTextNode(name: "repindex", textValue: "\(repindex)"))
		return node
	}
}

