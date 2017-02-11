//
//  SecuTrialBeanPatient.swift
//  SecuTrialClient
//
//  Created by Pascal Pfiffner on 19/10/15.
//  Copyright © 2015 USZ. All rights reserved.
//

#if !SKIP_INTERNAL_IMPORT
import SOAP
#endif


open class SecuTrialBeanPatient: SecuTrialBean {
	
	open var psd: String?
	
	open var aid: String?
	
	open var labid: String?
	
	open var entrydate: String?
	
	
	public required init() {  }
	
	public required init(node: SOAPNode) throws {  }
	
	open func node(_ name: String) -> SOAPNode {
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

