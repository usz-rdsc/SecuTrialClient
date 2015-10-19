//
//  STPatientBean.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//


public class STPatientBean: SecuTrialBean {
	
	public var psd: String?
	
	public var aid: String?
	
	public var labid: String?
	
	public var entrydate: String?
	
	
	public required init() {
	}
	
	public required init(node: SOAPNode) throws {
	}
	
	public func node(name: String) -> SOAPNode {
		let node = SOAPNode(name: name)
		if let txt = psd {
			node.addChild(SOAPTextNode(name: "psd", textValue: txt))
		}
		if let txt = aid {
			node.addChild(SOAPTextNode(name: "aid", textValue: txt))
		}
		if let txt = labid {
			node.addChild(SOAPTextNode(name: "labid", textValue: txt))
		}
		if let txt = entrydate {
			node.addChild(SOAPTextNode(name: "entrydate", textValue: txt))
		}
		return node
	}
}

