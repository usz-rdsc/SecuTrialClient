//
//  SecuTrialBeanVisit.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


open class SecuTrialBeanVisit: SecuTrialBean {
	
	open var label: String?
	
	open var nr: String?
	
	open var date: String?
	
	
	public required init() {  }
	
	public required init(node: SOAPNode) throws {  }
	
	open func node(_ name: String) -> SOAPNode {
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

